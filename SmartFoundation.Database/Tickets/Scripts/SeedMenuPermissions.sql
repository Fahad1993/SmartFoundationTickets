SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;
BEGIN TRY

PRINT N'============================================================';
PRINT N'  Tickets Module — Menu & Permission Migration';
PRINT N'  Consolidates 11 sub-items to 3 functional pages';
PRINT N'============================================================';
PRINT N'';

DECLARE @entryUser  NVARCHAR(20)  = N'MIGRATION';
DECLARE @entryHost  NVARCHAR(200) = HOST_NAME();
DECLARE @programID  INT = 20;

----------------------------------------------------------------
-- STEP 0: Check existing state
----------------------------------------------------------------
PRINT N'--- Step 0: Current state ---';

DECLARE @existingCount INT;
SELECT @existingCount = COUNT(*) FROM dbo.Menu WHERE programID_FK = @programID AND menuActive = 1;
PRINT N'  Active menu items under Tickets: ' + CAST(@existingCount AS NVARCHAR);
PRINT N'';

----------------------------------------------------------------
-- STEP 1: Update Program icon/serial
----------------------------------------------------------------
PRINT N'--- Step 1: Update Tickets Program ---';

UPDATE dbo.Program
SET programName_A = N'نظام التذاكر',
    programIcon = N'fa-solid fa-ticket',
    programSerial = 18
WHERE programID = @programID;

PRINT N'  Updated Program icon and serial.';
PRINT N'';

----------------------------------------------------------------
-- STEP 2: Deactivate 8 old menu items (keep 3 + CRUD)
----------------------------------------------------------------
PRINT N'--- Step 2: Deactivating 8 old menu items ---';

UPDATE dbo.Menu
SET menuActive = 0
WHERE menuID IN (316, 317, 318, 319, 320, 321, 322);

PRINT N'  Deactivated ' + CAST(@@ROWCOUNT AS NVARCHAR) + N' old DDL menu items (IDs 316-322).';
PRINT N'';

----------------------------------------------------------------
-- STEP 3: Update remaining 3 visible menu items
----------------------------------------------------------------
PRINT N'--- Step 3: Updating 3 visible menu items ---';

UPDATE dbo.Menu
SET menuName_A = N'قائمة التذاكر',
    menuSerial = 1,
    menuActive = 1
WHERE menuID = 314;
PRINT N'  [1] قائمة التذاكر (TicketList) ID=314 serial=1';

UPDATE dbo.Menu
SET menuName_A = N'تفاصيل التذكرة',
    menuSerial = 2,
    menuActive = 1
WHERE menuID = 315;
PRINT N'  [2] تفاصيل التذكرة (TicketDetails) ID=315 serial=2';

UPDATE dbo.Menu
SET menuName_A = N'إدارة نظام التذاكر',
    menuName_E = N'TicketAdmin',
    menuLink = N'TicketAdmin',
    menuDescription = N'إدارة الخدمات والفئات والأولويات والحالات والأسباب',
    menuSerial = 3,
    menuActive = 1
WHERE menuID = 313;
PRINT N'  [3] إدارة نظام التذاكر (TicketAdmin) ID=313 serial=3';

-- Update the hidden CRUD entry
UPDATE dbo.Menu
SET menuName_A = N'عمليات التذاكر',
    menuName_E = N'Tickets',
    menuLink = N'#',
    menuSerial = 99,
    menuActive = 1
WHERE menuID = 324;
PRINT N'  [CRUD] عمليات التذاكر (Tickets) ID=324 serial=99 (hidden)';

PRINT N'';

DECLARE @menuID_TicketList BIGINT = 314;
DECLARE @menuID_TicketDetails BIGINT = 315;
DECLARE @menuID_TicketAdmin BIGINT = 313;
DECLARE @menuID_TicketsCRUD BIGINT = 324;

----------------------------------------------------------------
-- STEP 4: Ensure Distributors exist for each menu
----------------------------------------------------------------
PRINT N'--- Step 4: Ensure Distributors ---';

DECLARE @adminRoleID BIGINT;
SELECT TOP 1 @adminRoleID = roleID FROM dbo.[Role] WHERE roleName_E = N'Admin' OR roleName_A LIKE N'%مدير%' ORDER BY roleID;
IF @adminRoleID IS NULL SELECT TOP 1 @adminRoleID = roleID FROM dbo.[Role] ORDER BY roleID;
PRINT N'  Admin RoleID: ' + ISNULL(CAST(@adminRoleID AS NVARCHAR), 'NULL');

DECLARE @roleDistType INT = 4;

DECLARE @distID_TicketList BIGINT;
DECLARE @distID_TicketDetails BIGINT;
DECLARE @distID_TicketAdmin BIGINT;
DECLARE @distID_TicketsCRUD BIGINT;

-- Check existing distributors for these menus
SELECT @distID_TicketList = d.distributorID
FROM dbo.Distributor d
INNER JOIN dbo.MenuDistributor md ON md.distributorID_FK = d.distributorID AND md.menuDistributorActive = 1
WHERE md.menuID_FK = @menuID_TicketList AND d.distributorActive = 1;

SELECT @distID_TicketDetails = d.distributorID
FROM dbo.Distributor d
INNER JOIN dbo.MenuDistributor md ON md.distributorID_FK = d.distributorID AND md.menuDistributorActive = 1
WHERE md.menuID_FK = @menuID_TicketDetails AND d.distributorActive = 1;

SELECT @distID_TicketAdmin = d.distributorID
FROM dbo.Distributor d
INNER JOIN dbo.MenuDistributor md ON md.distributorID_FK = d.distributorID AND md.menuDistributorActive = 1
WHERE md.menuID_FK = @menuID_TicketAdmin AND d.distributorActive = 1;

SELECT @distID_TicketsCRUD = d.distributorID
FROM dbo.Distributor d
INNER JOIN dbo.MenuDistributor md ON md.distributorID_FK = d.distributorID AND md.menuDistributorActive = 1
WHERE md.menuID_FK = @menuID_TicketsCRUD AND d.distributorActive = 1;

-- Create missing distributors
IF @distID_TicketList IS NULL
BEGIN
    INSERT INTO dbo.Distributor (distributorName_A, distributorName_E, distributorDescription, distributorCode, distributorActive, distributorType_FK, roleID_FK, entryDate, entryData, hostName)
    VALUES (N'صلاحية - قائمة التذاكر', N'Perm - Ticket List', N'Ticket List', N'TKT-TLIST', 1, @roleDistType, @adminRoleID, GETDATE(), @entryUser, @entryHost);
    SET @distID_TicketList = SCOPE_IDENTITY();
    INSERT INTO dbo.MenuDistributor (menuID_FK, distributorID_FK, roleID_FK, menuDistributorActive) VALUES (@menuID_TicketList, @distID_TicketList, @adminRoleID, 1);
    PRINT N'  Created Distributor for TicketList ID=' + CAST(@distID_TicketList AS NVARCHAR);
END
ELSE
    PRINT N'  Exists Distributor for TicketList ID=' + CAST(@distID_TicketList AS NVARCHAR);

IF @distID_TicketDetails IS NULL
BEGIN
    INSERT INTO dbo.Distributor (distributorName_A, distributorName_E, distributorDescription, distributorCode, distributorActive, distributorType_FK, roleID_FK, entryDate, entryData, hostName)
    VALUES (N'صلاحية - تفاصيل التذكرة', N'Perm - Ticket Details', N'Ticket Details', N'TKT-TDET', 1, @roleDistType, @adminRoleID, GETDATE(), @entryUser, @entryHost);
    SET @distID_TicketDetails = SCOPE_IDENTITY();
    INSERT INTO dbo.MenuDistributor (menuID_FK, distributorID_FK, roleID_FK, menuDistributorActive) VALUES (@menuID_TicketDetails, @distID_TicketDetails, @adminRoleID, 1);
    PRINT N'  Created Distributor for TicketDetails ID=' + CAST(@distID_TicketDetails AS NVARCHAR);
END
ELSE
    PRINT N'  Exists Distributor for TicketDetails ID=' + CAST(@distID_TicketDetails AS NVARCHAR);

IF @distID_TicketAdmin IS NULL
BEGIN
    INSERT INTO dbo.Distributor (distributorName_A, distributorName_E, distributorDescription, distributorCode, distributorActive, distributorType_FK, roleID_FK, entryDate, entryData, hostName)
    VALUES (N'صلاحية - إدارة التذاكر', N'Perm - Ticket Admin', N'Ticket Admin', N'TKT-TADM', 1, @roleDistType, @adminRoleID, GETDATE(), @entryUser, @entryHost);
    SET @distID_TicketAdmin = SCOPE_IDENTITY();
    INSERT INTO dbo.MenuDistributor (menuID_FK, distributorID_FK, roleID_FK, menuDistributorActive) VALUES (@menuID_TicketAdmin, @distID_TicketAdmin, @adminRoleID, 1);
    PRINT N'  Created Distributor for TicketAdmin ID=' + CAST(@distID_TicketAdmin AS NVARCHAR);
END
ELSE
    PRINT N'  Exists Distributor for TicketAdmin ID=' + CAST(@distID_TicketAdmin AS NVARCHAR);

IF @distID_TicketsCRUD IS NULL
BEGIN
    INSERT INTO dbo.Distributor (distributorName_A, distributorName_E, distributorDescription, distributorCode, distributorActive, distributorType_FK, roleID_FK, entryDate, entryData, hostName)
    VALUES (N'صلاحية - عمليات التذاكر', N'Perm - Tickets CRUD', N'Tickets CRUD', N'TKT-CRUD', 1, @roleDistType, @adminRoleID, GETDATE(), @entryUser, @entryHost);
    SET @distID_TicketsCRUD = SCOPE_IDENTITY();
    INSERT INTO dbo.MenuDistributor (menuID_FK, distributorID_FK, roleID_FK, menuDistributorActive) VALUES (@menuID_TicketsCRUD, @distID_TicketsCRUD, @adminRoleID, 1);
    PRINT N'  Created Distributor for Tickets CRUD ID=' + CAST(@distID_TicketsCRUD AS NVARCHAR);
END
ELSE
    PRINT N'  Exists Distributor for Tickets CRUD ID=' + CAST(@distID_TicketsCRUD AS NVARCHAR);

PRINT N'';

----------------------------------------------------------------
-- STEP 5: Create PermissionTypes
----------------------------------------------------------------
PRINT N'--- Step 5: Creating PermissionTypes ---';

DECLARE @ptCount INT = 0;

-- Using a temp table approach instead of cursor for cleaner code
-- Insert each permission type only if it does not exist

-- Page view permission
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'VIEW' AND permissionTypeActive = 1)
BEGIN
    INSERT INTO dbo.PermissionType (permissionTypeName_A, permissionTypeName_E, permissionTypeActive, RoleID_FK)
    VALUES (N'عرض', N'VIEW', 1, @adminRoleID); SET @ptCount += 1;
END

-- Ticket workflow
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'INSERT_TICKET' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'إنشاء تذكرة', N'INSERT_TICKET', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'ROUTE_TICKET' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'توجيه تذكرة', N'ROUTE_TICKET', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'ASSIGN_TICKET' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'تعيين تذكرة', N'ASSIGN_TICKET', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'REASSIGN_TICKET' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'إعادة تعيين', N'REASSIGN_TICKET', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'REQUEST_CLARIFICATION' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'طلب توضيح', N'REQUEST_CLARIFICATION', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'RESPOND_CLARIFICATION' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'الرد على التوضيح', N'RESPOND_CLARIFICATION', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'START_WORK' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'بدء العمل', N'START_WORK', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'RESOLVE_TICKET' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'حل تذكرة', N'RESOLVE_TICKET', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'CLOSE_TICKET' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'إغلاق تذكرة', N'CLOSE_TICKET', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'REJECT_TICKET' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'رفض تذكرة', N'REJECT_TICKET', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'REOPEN_TICKET' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'إعادة فتح', N'REOPEN_TICKET', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'PAUSE_TICKET' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'إيقاف مؤقت', N'PAUSE_TICKET', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'RESUME_TICKET' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'استئناف', N'RESUME_TICKET', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'CREATE_CHILD_TICKET' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'تذكرة فرعية', N'CREATE_CHILD_TICKET', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'SUBMIT_QUALITY_REVIEW' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'مراجعة جودة', N'SUBMIT_QUALITY_REVIEW', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'FINALIZE_QUALITY_REVIEW' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'إنهاء مراجعة', N'FINALIZE_QUALITY_REVIEW', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'RAISE_ARBITRATION' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'رفع تحكيم', N'RAISE_ARBITRATION', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'DECIDE_ARBITRATION' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'قرار تحكيم', N'DECIDE_ARBITRATION', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'CANCEL_ARBITRATION' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'إلغاء تحكيم', N'CANCEL_ARBITRATION', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'UPLOAD_ATTACHMENT' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'رفع مرفق', N'UPLOAD_ATTACHMENT', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'DELETE_ATTACHMENT' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'حذف مرفق', N'DELETE_ATTACHMENT', 1, @adminRoleID); SET @ptCount += 1; END

-- Service CRUD
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'INSERT_SERVICE' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'إضافة خدمة', N'INSERT_SERVICE', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'UPDATE_SERVICE' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'تعديل خدمة', N'UPDATE_SERVICE', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'DELETE_SERVICE' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'حذف خدمة', N'DELETE_SERVICE', 1, @adminRoleID); SET @ptCount += 1; END

-- Lookup CRUD
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'INSERT_TICKETCLASS' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'إضافة فئة تذكرة', N'INSERT_TICKETCLASS', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'UPDATE_TICKETCLASS' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'تعديل فئة تذكرة', N'UPDATE_TICKETCLASS', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'DELETE_TICKETCLASS' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'حذف فئة تذكرة', N'DELETE_TICKETCLASS', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'INSERT_PRIORITY' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'إضافة أولوية', N'INSERT_PRIORITY', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'UPDATE_PRIORITY' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'تعديل أولوية', N'UPDATE_PRIORITY', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'DELETE_PRIORITY' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'حذف أولوية', N'DELETE_PRIORITY', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'INSERT_TICKETSTATUS' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'إضافة حالة تذكرة', N'INSERT_TICKETSTATUS', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'UPDATE_TICKETSTATUS' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'تعديل حالة تذكرة', N'UPDATE_TICKETSTATUS', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'DELETE_TICKETSTATUS' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'حذف حالة تذكرة', N'DELETE_TICKETSTATUS', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'INSERT_PAUSEREASON' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'إضافة سبب إيقاف', N'INSERT_PAUSEREASON', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'UPDATE_PAUSEREASON' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'تعديل سبب إيقاف', N'UPDATE_PAUSEREASON', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'DELETE_PAUSEREASON' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'حذف سبب إيقاف', N'DELETE_PAUSEREASON', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'INSERT_ARBITRATIONREASON' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'إضافة سبب تحكيم', N'INSERT_ARBITRATIONREASON', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'UPDATE_ARBITRATIONREASON' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'تعديل سبب تحكيم', N'UPDATE_ARBITRATIONREASON', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'DELETE_ARBITRATIONREASON' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'حذف سبب تحكيم', N'DELETE_ARBITRATIONREASON', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'INSERT_QUALITYREVIEWRESULT' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'إضافة نتيجة مراجعة', N'INSERT_QUALITYREVIEWRESULT', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'UPDATE_QUALITYREVIEWRESULT' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'تعديل نتيجة مراجعة', N'UPDATE_QUALITYREVIEWRESULT', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'DELETE_QUALITYREVIEWRESULT' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'حذف نتيجة مراجعة', N'DELETE_QUALITYREVIEWRESULT', 1, @adminRoleID); SET @ptCount += 1; END

-- Page-level permission names (no underscore, used by TicketAdmin controller)
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'INSERTSERVICE' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'إضافة خدمة', N'INSERTSERVICE', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'UPDATESERVICE' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'تعديل خدمة', N'UPDATESERVICE', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'DELETESERVICE' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'حذف خدمة', N'DELETESERVICE', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'INSERTTICKETCLASS' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'إضافة فئة', N'INSERTTICKETCLASS', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'UPDATETICKETCLASS' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'تعديل فئة', N'UPDATETICKETCLASS', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'DELETETICKETCLASS' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'حذف فئة', N'DELETETICKETCLASS', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'INSERTPRIORITY' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'إضافة أولوية', N'INSERTPRIORITY', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'UPDATEPRIORITY' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'تعديل أولوية', N'UPDATEPRIORITY', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'DELETEPRIORITY' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'حذف أولوية', N'DELETEPRIORITY', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'INSERTTICKETSTATUS' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'إضافة حالة', N'INSERTTICKETSTATUS', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'UPDATETICKETSTATUS' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'تعديل حالة', N'UPDATETICKETSTATUS', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'DELETETICKETSTATUS' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'حذف حالة', N'DELETETICKETSTATUS', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'INSERTPAUSEREASON' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'إضافة سبب إيقاف', N'INSERTPAUSEREASON', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'UPDATEPAUSEREASON' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'تعديل سبب إيقاف', N'UPDATEPAUSEREASON', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'DELETEPAUSEREASON' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'حذف سبب إيقاف', N'DELETEPAUSEREASON', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'INSERTARBITRATIONREASON' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'إضافة سبب تحكيم', N'INSERTARBITRATIONREASON', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'UPDATEARBITRATIONREASON' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'تعديل سبب تحكيم', N'UPDATEARBITRATIONREASON', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'DELETEARBITRATIONREASON' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'حذف سبب تحكيم', N'DELETEARBITRATIONREASON', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'INSERTQUALITYREVIEWRESULT' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'إضافة نتيجة مراجعة', N'INSERTQUALITYREVIEWRESULT', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'UPDATEQUALITYREVIEWRESULT' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'تعديل نتيجة مراجعة', N'UPDATEQUALITYREVIEWRESULT', 1, @adminRoleID); SET @ptCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'DELETEQUALITYREVIEWRESULT' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'حذف نتيجة مراجعة', N'DELETEQUALITYREVIEWRESULT', 1, @adminRoleID); SET @ptCount += 1; END

PRINT N'  Created ' + CAST(@ptCount AS NVARCHAR) + N' new PermissionTypes';
PRINT N'';

----------------------------------------------------------------
-- STEP 6: Link DistributorPermissionType + Permission
--
-- IMPORTANT: GetUserMenuTree SP requires p.UsersID_FK IS NOT NULL.
-- Permission rows with NULL UsersID_FK are invisible to the menu SP.
-- We assign permissions to a specific admin user (matching Housing pattern).
----------------------------------------------------------------
PRINT N'--- Step 6: Linking DistributorPermissionType + Permission ---';

-- Find the admin user who already has Housing permissions (consistent access)
DECLARE @ticketAdminUserID BIGINT;
SELECT TOP 1 @ticketAdminUserID = p.UsersID_FK
FROM dbo.Permission p
INNER JOIN dbo.DistributorPermissionType dpt ON dpt.distributorPermissionTypeID = p.DistributorPermissionTypeID_FK
INNER JOIN dbo.MenuDistributor md ON md.distributorID_FK = dpt.distributorID_FK AND md.menuDistributorActive = 1
INNER JOIN dbo.Menu m ON m.menuID = md.menuID_FK
WHERE m.programID_FK = 7 -- Housing
  AND p.permissionActive = 1
  AND p.UsersID_FK IS NOT NULL
ORDER BY p.UsersID_FK;

-- Fallback: pick any active user
IF @ticketAdminUserID IS NULL
    SELECT TOP 1 @ticketAdminUserID = usersID FROM dbo.Users WHERE usersActive = 1 ORDER BY usersID;

PRINT N'  Target admin user ID: ' + ISNULL(CAST(@ticketAdminUserID AS NVARCHAR), 'NULL');

DECLARE @dptCount INT = 0;
DECLARE @permCount INT = 0;
DECLARE @curDistID BIGINT;
DECLARE @curPTID INT;
DECLARE @newDPTID BIGINT;

DECLARE dist_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT distID FROM (
    SELECT @distID_TicketList AS distID WHERE @distID_TicketList IS NOT NULL
    UNION ALL SELECT @distID_TicketDetails WHERE @distID_TicketDetails IS NOT NULL
    UNION ALL SELECT @distID_TicketAdmin WHERE @distID_TicketAdmin IS NOT NULL
    UNION ALL SELECT @distID_TicketsCRUD WHERE @distID_TicketsCRUD IS NOT NULL
) d;

OPEN dist_cursor;
FETCH NEXT FROM dist_cursor INTO @curDistID;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE pt_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT pt.permissionTypeID
    FROM dbo.PermissionType pt
    WHERE pt.permissionTypeActive = 1
    AND NOT EXISTS (
        SELECT 1 FROM dbo.DistributorPermissionType dpt
        WHERE dpt.distributorID_FK = @curDistID
          AND dpt.permissionTypeID_FK = pt.permissionTypeID
          AND dpt.distributorPermissionTypeActive = 1
    );

    OPEN pt_cursor;
    FETCH NEXT FROM pt_cursor INTO @curPTID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO dbo.DistributorPermissionType
            (permissionTypeID_FK, DistributorID_FK, distributorPermissionTypeStartDate, distributorPermissionTypeEndDate, distributorPermissionTypeActive, permissionAuthLvl, entryDate, entryData, hostName)
        VALUES
            (@curPTID, @curDistID, GETDATE(), NULL, 1, 3, GETDATE(), @entryUser, @entryHost);

        SET @newDPTID = SCOPE_IDENTITY();
        SET @dptCount += 1;

        -- NOTE: UsersID_FK MUST be NOT NULL for GetUserMenuTree SP to see this permission.
        -- NULL UsersID_FK makes the permission invisible to the menu tree.
        INSERT INTO dbo.Permission
            (DistributorPermissionTypeID_FK, UsersID_FK, RoleID_FK, distributorID_FK, IdaraID_FK, DSDID_FK, permissionStartDate, permissionEndDate, permissionActive, permissionNote, InIdaraID, entryDate, entryData, hostName)
        VALUES
            (@newDPTID, @ticketAdminUserID, NULL, NULL, NULL, NULL, GETDATE(), NULL, 1, N'Auto: Tickets migration', NULL, GETDATE(), @entryUser, @entryHost);

        SET @permCount += 1;

        FETCH NEXT FROM pt_cursor INTO @curPTID;
    END

    CLOSE pt_cursor;
    DEALLOCATE pt_cursor;

    FETCH NEXT FROM dist_cursor INTO @curDistID;
END

CLOSE dist_cursor;
DEALLOCATE dist_cursor;

PRINT N'  Created ' + CAST(@dptCount AS NVARCHAR) + N' DistributorPermissionType rows';
PRINT N'  Created ' + CAST(@permCount AS NVARCHAR) + N' Permission rows (assigned to user ' + ISNULL(CAST(@ticketAdminUserID AS NVARCHAR), 'NULL') + N')';
PRINT N'';

----------------------------------------------------------------
-- STEP 7: Verify final state
----------------------------------------------------------------
PRINT N'--- Step 7: Final verification ---';

DECLARE @finalCount INT;
SELECT @finalCount = COUNT(*) FROM dbo.Menu WHERE programID_FK = @programID AND menuActive = 1;
PRINT N'  Active menu items: ' + CAST(@finalCount AS NVARCHAR) + N' (expected 4: 3 visible + 1 CRUD hidden)';

DECLARE @ptTotal INT;
SELECT @ptTotal = COUNT(*) FROM dbo.PermissionType WHERE permissionTypeActive = 1;
PRINT N'  Total active PermissionTypes: ' + CAST(@ptTotal AS NVARCHAR);
PRINT N'';

PRINT N'============================================================';
PRINT N'  MIGRATION COMPLETE';
PRINT N'============================================================';
PRINT N'';

-- STEP 8: Preserve ServiceCatalogueList menu
----------------------------------------------------------------
PRINT N'--- Step 8: Preserving ServiceCatalogueList menu ---';
PRINT N'  Standalone ServiceCatalogueList remains active.';
PRINT N'  Use ServiceCatalogueListStandaloneHotfix.sql to align live menu and permission data.';
PRINT N'';

----------------------------------------------------------------
-- STEP 9: Add new admin permission types
----------------------------------------------------------------
PRINT N'--- Step 9: Adding admin permission types ---';

DECLARE @adminPtCount INT = 0;

IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'MANAGEROUTINGRULES' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'إدارة قواعد التوجيه', N'MANAGEROUTINGRULES', 1, @adminRoleID); SET @adminPtCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'MANAGESLAPOLICIES' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'إدارة سياسات SLA', N'MANAGESLAPOLICIES', 1, @adminRoleID); SET @adminPtCount += 1; END
IF NOT EXISTS (SELECT 1 FROM dbo.PermissionType WHERE permissionTypeName_E = N'APPROVESERVICESUGGESTION' AND permissionTypeActive = 1)
BEGIN INSERT INTO dbo.PermissionType VALUES (N'الموافقة على اقتراحات الخدمات', N'APPROVESERVICESUGGESTION', 1, @adminRoleID); SET @adminPtCount += 1; END

PRINT N'  Created ' + CAST(@adminPtCount AS NVARCHAR) + N' new admin PermissionTypes';
PRINT N'';

PRINT N'  Program: نظام التذاكر (Tickets) — ID=' + CAST(@programID AS NVARCHAR);
PRINT N'  Menu 1:  قائمة التذاكر (TicketList) — ID=314';
PRINT N'  Menu 2:  تفاصيل التذكرة (TicketDetails) — ID=315';
PRINT N'  Menu 3:  إدارة نظام التذاكر (TicketAdmin) — ID=313';
PRINT N'  CRUD:    عمليات التذاكر (Tickets) — ID=324';
PRINT N'';
PRINT N'  Sidebar now shows exactly 3 items.';
PRINT N'';

COMMIT TRANSACTION;
PRINT N'TRANSACTION COMMITTED.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT N'';
    PRINT N'!!! MIGRATION FAILED - ROLLED BACK !!!';
    PRINT N'Error: ' + CAST(ERROR_NUMBER() AS NVARCHAR) + N' — ' + ERROR_MESSAGE();
    PRINT N'Line:  ' + CAST(ERROR_LINE() AS NVARCHAR);
END CATCH
