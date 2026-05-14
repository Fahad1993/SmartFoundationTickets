-- Patch: Update ResidentDDL to show only residents with active housing
-- This script updates the ResidentDDL section in Tickets.TicketDL

-- First, check if the ResidentDDL section exists and update it
DECLARE @sql NVARCHAR(MAX) = OBJECT_DEFINITION(OBJECT_ID('[Tickets].[TicketDL]'));

-- Find and replace the old ResidentDDL with the new one
SET @sql = REPLACE(@sql,
N'    IF @pageName_ = N''ResidentDDL''
    BEGIN
        SELECT
            [residentInfoID] AS [residentInfoID],
            [NationalID] AS [NationalID],
            [generalNo_FK] AS [generalNo_FK],
            [FullName_A] AS [FullName_A],
            [FullName_E] AS [FullName_E],
            [rankNameA] AS [rankNameA],
            [militaryUnitName_A] AS [militaryUnitName_A]
        FROM [Housing].[V_GetFullResidentDetails]
        WHERE [IdaraID] = @idaraID
          AND [residentInfoActive] = 1
        ORDER BY [FullName_A] ASC;

        RETURN;
    END',
N'    IF @pageName_ = N''ResidentDDL''
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
          AND r.[residentInfoActive] = 1
          AND bas.[Active] = 1
        ORDER BY r.[FullName_A] ASC;

        RETURN;
    END');

-- Execute the altered procedure
EXEC sp_executesql @sql;

PRINT 'ResidentDDL updated successfully!';
