-- Fix: Add/Update only ResidentDDL section in TicketDL
-- Execute this in SSMS

USE [DATACORETi]
GO

-- Get the current definition of TicketDL
DECLARE @procedureDefinition NVARCHAR(MAX);
DECLARE @residentDDL NVARCHAR(MAX) = N'

    IF @pageName_ = N''ResidentDDL''
    BEGIN
        SELECT DISTINCT
            r.[residentInfoID] AS [residentInfoID],
            r.[NationalID] AS [NationalID],
            r.[generalNo_FK] AS [generalNo_FK],
            r.[FullName_A] AS [FullName_A],
            r.[FullName_E] AS [FullName_E],
            r.[rankNameA] AS [rankNameA],
            r.[militaryUnitName_A] AS [militaryUnitName_A],
            ba.[BuildingNo] AS [BuildingNo]
        FROM [Housing].[V_GetFullResidentDetails] r
        INNER JOIN [DATACORE].[Housing].[BuildingAssign] ba
            ON r.[generalNo_FK] = ba.[GeneralNo]
        INNER JOIN [DATACORE].[Housing].[BuildingAssignStatus] bas
            ON ba.[BuildingAssignStatusID_FK] = bas.[BuildingAssignStatusID]
        WHERE r.[IdaraID] = @idaraID
          AND bas.[Active] = 1
        ORDER BY r.[FullName_A] ASC;

        RETURN;
    END
';

-- Check if ResidentDDL already exists
SELECT @procedureDefinition = OBJECT_DEFINITION(OBJECT_ID('[Tickets].[TicketDL]'));

IF @procedureDefinition LIKE '%IF @pageName_ = N''ResidentDDL''%'
BEGIN
    -- Remove existing ResidentDDL section
    DECLARE @startPos INT, @endPos INT;
    SET @startPos = CHARINDEX('IF @pageName_ = N''ResidentDDL''', @procedureDefinition);
    SET @endPos = CHARINDEX('IF @pageName_ = N''BuildingDDL''', @procedureDefinition, @startPos);

    IF @startPos > 0 AND @endPos > 0
    BEGIN
        SET @procedureDefinition = STUFF(@procedureDefinition, @startPos, @endPos - @startPos, '');
    END

    -- Drop and recreate the procedure
    DECLARE @sql NVARCHAR(MAX) = N'DROP PROCEDURE [Tickets].[TicketDL]';
    EXEC sp_executesql @sql;

    EXEC sp_executesql @procedureDefinition;
    PRINT 'Existing ResidentDDL removed and procedure recreated.';
END
ELSE
BEGIN
    -- Just add the new ResidentDDL before the final END
    SET @procedureDefinition = REPLACE(@procedureDefinition,
        'END' + CHAR(13) + CHAR(10) + 'END',
        @residentDDL + CHAR(13) + CHAR(10) + 'END' + CHAR(13) + CHAR(10) + 'END');

    DECLARE @sql NVARCHAR(MAX) = N'DROP PROCEDURE [Tickets].[TicketDL]';
    EXEC sp_executesql @sql;

    EXEC sp_executesql @procedureDefinition;
    PRINT 'New ResidentDDL added to procedure.';
END

GO

PRINT 'TicketDL updated successfully!';
