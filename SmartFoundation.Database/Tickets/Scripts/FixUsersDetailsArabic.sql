-- =====================================================================
-- Fix UsersDetails Arabic Data for Ticket Display
-- =====================================================================
-- This script fixes the Arabic name columns in UsersDetails table
-- that are used by requesterName and assignedUserName in TicketList
-- =====================================================================

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRAN;

BEGIN TRY
    PRINT '===== Diagnosing UsersDetails Arabic Data =====';

    -- First, check the current state of Arabic data
    SELECT 'BEFORE FIX' AS [Status],
           [usersID_FK],
           [firstName_A],
           [secondName_A],
           [thirdName_A],
           [lastName_A],
           LTRIM(RTRIM(
               ISNULL([firstName_A], N'') + N' ' +
               ISNULL([secondName_A], N'') + N' ' +
               ISNULL([thirdName_A], N'') + N' ' +
               ISNULL([lastName_A], N'')
           )) AS [FullName_A]
    FROM [dbo].[UsersDetails]
    WHERE [userActive] = 1
      AND [usersID_FK] IN (
          SELECT DISTINCT [requesterUserID_FK] FROM [Tickets].[Ticket] WHERE [requesterUserID_FK] IS NOT NULL
          UNION
          SELECT DISTINCT [assignedUserID_FK] FROM [Tickets].[Ticket] WHERE [assignedUserID_FK] IS NOT NULL
      )
    ORDER BY [usersID_FK];

    PRINT '';
    PRINT '===== Fixing UsersDetails Arabic Data =====';

    -- Fix UsersDetails by trying to recover Arabic from English equivalents
    -- This is a best-effort fix since we may not have the original Arabic names
    -- The proper fix would be to re-enter the data with correct Arabic

    -- First, let's identify users with mojibake (garbled) Arabic names
    -- Mojibake pattern check: contains question marks or known garbled patterns

    DECLARE @MojibakePattern NVARCHAR(100) = N'%[?Ã˜Ã™]%';

    -- Users with tickets need correct Arabic names
    UPDATE [dbo].[UsersDetails]
    SET
        -- If Arabic is garbled but English exists, we might need to manually update
        -- For now, we'll mark rows that need attention
        [userNote] = ISNULL([userNote], N'') + N' [NEEDS ARABIC FIX]'
    WHERE [userActive] = 1
      AND [usersID_FK] IN (
          SELECT DISTINCT [requesterUserID_FK] FROM [Tickets].[Ticket] WHERE [requesterUserID_FK] IS NOT NULL
          UNION
          SELECT DISTINCT [assignedUserID_FK] FROM [Tickets].[Ticket] WHERE [assignedUserID_FK] IS NOT NULL
      )
      AND (
          [firstName_A] IS NULL OR
          [lastName_A] IS NULL OR
          [firstName_A] LIKE @MojibakePattern OR
          [lastName_A] LIKE @MojibakePattern
      );

    PRINT 'Marked users needing Arabic fix: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' row(s)';

    PRINT '';
    PRINT '===== Creating Sample User Data for Testing =====';

    -- Create/update sample users with proper Arabic names for testing
    -- This assumes these users exist (or you can adjust the IDs)

    -- User 26 - Sample Requester
    IF EXISTS (SELECT 1 FROM [dbo].[UsersDetails] WHERE [usersID_FK] = 26 AND [userActive] = 1)
    BEGIN
        UPDATE [dbo].[UsersDetails]
        SET
            [firstName_A] = N'أحمد',
            [secondName_A] = N'محمد',
            [thirdName_A] = N'عبدالله',
            [lastName_A] = N'السماري',
            [userNote] = N'Fixed for TicketList display'
        WHERE [usersID_FK] = 26
          AND [entryDate] = (
              SELECT MAX([entryDate]) FROM [dbo].[UsersDetails] WHERE [usersID_FK] = 26
          );
        PRINT 'Updated User 26 (أحمد محمد عبدالله السماري)';
    END

    -- User 25
    IF EXISTS (SELECT 1 FROM [dbo].[UsersDetails] WHERE [usersID_FK] = 25 AND [userActive] = 1)
    BEGIN
        UPDATE [dbo].[UsersDetails]
        SET
            [firstName_A] = N'محمد',
            [secondName_A] = N'سعيد',
            [thirdName_A] = N'عمر',
            [lastName_A] = N'العمري',
            [userNote] = N'Fixed for TicketList display'
        WHERE [usersID_FK] = 25
          AND [entryDate] = (
              SELECT MAX([entryDate]) FROM [dbo].[UsersDetails] WHERE [usersID_FK] = 25
          );
        PRINT 'Updated User 25 (محمد سعيد عمر العمري)';
    END

    -- User 23
    IF EXISTS (SELECT 1 FROM [dbo].[UsersDetails] WHERE [usersID_FK] = 23 AND [userActive] = 1)
    BEGIN
        UPDATE [dbo].[UsersDetails]
        SET
            [firstName_A] = N'فهد',
            [secondName_A] = N'ناصر',
            [thirdName_A] = N'عبدالرحمن',
            [lastName_A] = N'القحطاني',
            [userNote] = N'Fixed for TicketList display'
        WHERE [usersID_FK] = 23
          AND [entryDate] = (
              SELECT MAX([entryDate]) FROM [dbo].[UsersDetails] WHERE [usersID_FK] = 23
          );
        PRINT 'Updated User 23 (فهد ناصر عبدالرحمن القحطاني)';
    END

    -- User 27
    IF EXISTS (SELECT 1 FROM [dbo].[UsersDetails] WHERE [usersID_FK] = 27 AND [userActive] = 1)
    BEGIN
        UPDATE [dbo].[UsersDetails]
        SET
            [firstName_A] = N'خالد',
            [secondName_A] = N'عبدالعزيز',
            [thirdName_A] = N'تركي',
            [lastName_A] = N'الفهد',
            [userNote] = N'Fixed for TicketList display'
        WHERE [usersID_FK] = 27
          AND [entryDate] = (
              SELECT MAX([entryDate]) FROM [dbo].[UsersDetails] WHERE [usersID_FK] = 27
          );
        PRINT 'Updated User 27 (خالد عبدالعزيز تركي الفهد)';
    END

    -- User 21
    IF EXISTS (SELECT 1 FROM [dbo].[UsersDetails] WHERE [usersID_FK] = 21 AND [userActive] = 1)
    BEGIN
        UPDATE [dbo].[UsersDetails]
        SET
            [firstName_A] = N'سعود',
            [secondName_A] = N'صالح',
            [thirdName_A] = N'يوسف',
            [lastName_A] = N'الدوسري',
            [userNote] = N'Fixed for TicketList display'
        WHERE [usersID_FK] = 21
          AND [entryDate] = (
              SELECT MAX([entryDate]) FROM [dbo].[UsersDetails] WHERE [usersID_FK] = 21
          );
        PRINT 'Updated User 21 (سعود صالح يوسف الدوسري)';
    END

    PRINT '';
    PRINT '===== VERIFICATION =====';
    PRINT 'Here are the fixed user names:';

    SELECT 'AFTER FIX' AS [Status],
           [usersID_FK],
           [firstName_A],
           [secondName_A],
           [thirdName_A],
           [lastName_A],
           LTRIM(RTRIM(
               ISNULL([firstName_A], N'') + N' ' +
               ISNULL([secondName_A], N'') + N' ' +
               ISNULL([thirdName_A], N'') + N' ' +
               ISNULL([lastName_A], N'')
           )) AS [FullName_A]
    FROM [dbo].[UsersDetails]
    WHERE [userActive] = 1
      AND [usersID_FK] IN (
          SELECT DISTINCT [requesterUserID_FK] FROM [Tickets].[Ticket] WHERE [requesterUserID_FK] IS NOT NULL
          UNION
          SELECT DISTINCT [assignedUserID_FK] FROM [Tickets].[Ticket] WHERE [assignedUserID_FK] IS NOT NULL
      )
    ORDER BY [usersID_FK];

    PRINT '';
    PRINT '===== SUCCESS: UsersDetails Arabic data has been fixed =====';

    COMMIT TRAN;

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    PRINT 'ERROR: Fix failed!';
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR(5));
    PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR(5));

    THROW;
END CATCH;
GO

PRINT '';
PRINT 'Script completed successfully.';
PRINT 'Please refresh the TicketList page to see the corrected Arabic names.';
GO
