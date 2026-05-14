SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;
BEGIN TRY

PRINT N'============================================================';
PRINT N'  Service Catalogue Standalone Hotfix';
PRINT N'============================================================';
PRINT N'';

DECLARE @entryUser NVARCHAR(20) = N'HOTFIX';
DECLARE @entryHost NVARCHAR(200) = HOST_NAME();
DECLARE @programID INT = 20;
DECLARE @adminRoleID BIGINT;
DECLARE @ticketAdminMenuID BIGINT;
DECLARE @ticketAdminDistributorID BIGINT;
DECLARE @serviceMenuID BIGINT;
DECLARE @serviceDistributorID BIGINT;
DECLARE @serviceMenuSerial INT = 4;
DECLARE @serviceMenuNameA NVARCHAR(200) =
    NCHAR(1583) + NCHAR(1604) + NCHAR(1610) + NCHAR(1604) + NCHAR(32) + NCHAR(1575) +
    NCHAR(1604) + NCHAR(1582) + NCHAR(1583) + NCHAR(1605) + NCHAR(1575) + NCHAR(1578);
DECLARE @serviceDistributorNameA NVARCHAR(200) =
    NCHAR(1589) + NCHAR(1604) + NCHAR(1575) + NCHAR(1581) + NCHAR(1610) + NCHAR(1577) +
    NCHAR(32) + NCHAR(45) + NCHAR(32) + NCHAR(1583) + NCHAR(1604) + NCHAR(1610) +
    NCHAR(1604) + NCHAR(32) + NCHAR(1575) + NCHAR(1604) + NCHAR(1582) + NCHAR(1583) +
    NCHAR(1605) + NCHAR(1575) + NCHAR(1578);
DECLARE @accessPermissionNameA NVARCHAR(200) =
    NCHAR(1575) + NCHAR(1604) + NCHAR(1608) + NCHAR(1589) + NCHAR(1608) + NCHAR(1604);
DECLARE @insertServicePermissionNameA NVARCHAR(200) =
    NCHAR(1573) + NCHAR(1590) + NCHAR(1575) + NCHAR(1601) + NCHAR(1577) + NCHAR(32) +
    NCHAR(1582) + NCHAR(1583) + NCHAR(1605) + NCHAR(1577);
DECLARE @updateServicePermissionNameA NVARCHAR(200) =
    NCHAR(1578) + NCHAR(1593) + NCHAR(1583) + NCHAR(1610) + NCHAR(1604) + NCHAR(32) +
    NCHAR(1582) + NCHAR(1583) + NCHAR(1605) + NCHAR(1577);
DECLARE @deleteServicePermissionNameA NVARCHAR(200) =
    NCHAR(1581) + NCHAR(1584) + NCHAR(1601) + NCHAR(32) + NCHAR(1582) + NCHAR(1583) +
    NCHAR(1605) + NCHAR(1577);
DECLARE @manageRoutingRulesPermissionNameA NVARCHAR(200) =
    NCHAR(1573) + NCHAR(1583) + NCHAR(1575) + NCHAR(1585) + NCHAR(1577) + NCHAR(32) +
    NCHAR(1602) + NCHAR(1608) + NCHAR(1575) + NCHAR(1593) + NCHAR(1583) + NCHAR(32) +
    NCHAR(1575) + NCHAR(1604) + NCHAR(1578) + NCHAR(1608) + NCHAR(1580) + NCHAR(1610) +
    NCHAR(1607);
DECLARE @manageSlaPoliciesPermissionNameA NVARCHAR(200) =
    NCHAR(1573) + NCHAR(1583) + NCHAR(1575) + NCHAR(1585) + NCHAR(1577) + NCHAR(32) +
    NCHAR(1587) + NCHAR(1610) + NCHAR(1575) + NCHAR(1587) + NCHAR(1575) + NCHAR(1578) +
    NCHAR(32) + N'SLA';
DECLARE @approveServiceSuggestionPermissionNameA NVARCHAR(200) =
    NCHAR(1575) + NCHAR(1604) + NCHAR(1605) + NCHAR(1608) + NCHAR(1575) + NCHAR(1601) +
    NCHAR(1602) + NCHAR(1577) + NCHAR(32) + NCHAR(1593) + NCHAR(1604) + NCHAR(1609) +
    NCHAR(32) + NCHAR(1575) + NCHAR(1602) + NCHAR(1578) + NCHAR(1585) + NCHAR(1575) +
    NCHAR(1581) + NCHAR(1575) + NCHAR(1578) + NCHAR(32) + NCHAR(1575) + NCHAR(1604) +
    NCHAR(1582) + NCHAR(1583) + NCHAR(1605) + NCHAR(1575) + NCHAR(1578);

SELECT TOP 1
    @ticketAdminMenuID = m.menuID,
    @ticketAdminDistributorID = md.distributorID_FK,
    @adminRoleID = COALESCE(md.roleID_FK, d.roleID_FK)
FROM dbo.Menu m
INNER JOIN dbo.MenuDistributor md
    ON md.menuID_FK = m.menuID
   AND md.menuDistributorActive = 1
INNER JOIN dbo.Distributor d
    ON d.distributorID = md.distributorID_FK
   AND d.distributorActive = 1
WHERE m.programID_FK = @programID
  AND m.menuActive = 1
  AND m.menuName_E = N'TicketAdmin'
ORDER BY md.menuDistributorID DESC;

IF @adminRoleID IS NULL
BEGIN
    SELECT TOP 1 @adminRoleID = roleID
    FROM dbo.[Role]
    WHERE roleName_E = N'Admin' OR roleName_A LIKE N'%مدير%'
    ORDER BY roleID;
END

IF @ticketAdminDistributorID IS NULL
BEGIN
    RAISERROR(N'TicketAdmin baseline distributor was not found.', 16, 1);
END

IF @adminRoleID IS NULL
BEGIN
    RAISERROR(N'Admin role could not be resolved for the ServiceCatalogueList hotfix.', 16, 1);
END

SELECT TOP 1 @serviceMenuID = m.menuID
FROM dbo.Menu m
WHERE m.programID_FK = @programID
  AND (m.menuName_E = N'ServiceCatalogueList' OR m.menuLink = N'ServiceCatalogueList')
ORDER BY m.menuID DESC;

IF @serviceMenuID IS NULL
BEGIN
    INSERT INTO dbo.Menu
        (menuName_A, menuName_E, menuDescription, parentMenuID_FK, menuLink, programID_FK, menuSerial, menuActive, isDashboard, PageLvl)
    VALUES
        (@serviceMenuNameA, N'ServiceCatalogueList', N'Service Catalogue', NULL, N'ServiceCatalogueList', @programID, @serviceMenuSerial, 1, 0, 0);

    SET @serviceMenuID = SCOPE_IDENTITY();
END
ELSE
BEGIN
    UPDATE dbo.Menu
    SET menuName_A = @serviceMenuNameA,
        menuName_E = N'ServiceCatalogueList',
        menuDescription = N'Service Catalogue',
        parentMenuID_FK = NULL,
        menuLink = N'ServiceCatalogueList',
        programID_FK = @programID,
        menuSerial = @serviceMenuSerial,
        menuActive = 1,
        isDashboard = 0,
        PageLvl = 0
    WHERE menuID = @serviceMenuID;
END

SELECT TOP 1 @serviceDistributorID = md.distributorID_FK
FROM dbo.MenuDistributor md
INNER JOIN dbo.Distributor d
    ON d.distributorID = md.distributorID_FK
   AND d.distributorActive = 1
WHERE md.menuID_FK = @serviceMenuID
ORDER BY md.menuDistributorID DESC;

IF @serviceDistributorID IS NULL
BEGIN
    INSERT INTO dbo.Distributor
        (distributorName_A, distributorName_E, distributorDescription, distributorCode, distributorActive, distributorType_FK, roleID_FK, entryDate, entryData, hostName)
    VALUES
        (@serviceDistributorNameA, N'Perm - Service Catalogue', N'Service Catalogue', N'TKT-SCAT', 1, 4, @adminRoleID, GETDATE(), @entryUser, @entryHost);

    SET @serviceDistributorID = SCOPE_IDENTITY();
END
ELSE
BEGIN
    UPDATE dbo.Distributor
    SET distributorName_A = @serviceDistributorNameA,
        distributorName_E = N'Perm - Service Catalogue',
        distributorDescription = N'Service Catalogue',
        distributorActive = 1,
        distributorType_FK = 4,
        roleID_FK = COALESCE(roleID_FK, @adminRoleID)
    WHERE distributorID = @serviceDistributorID;
END

UPDATE dbo.MenuDistributor
SET menuDistributorActive = 1,
    roleID_FK = COALESCE(roleID_FK, @adminRoleID)
WHERE menuID_FK = @serviceMenuID
  AND distributorID_FK = @serviceDistributorID;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.MenuDistributor
    WHERE menuID_FK = @serviceMenuID
      AND distributorID_FK = @serviceDistributorID
      AND roleID_FK = @adminRoleID
      AND menuDistributorActive = 1
)
BEGIN
    INSERT INTO dbo.MenuDistributor (menuID_FK, distributorID_FK, roleID_FK, menuDistributorActive)
    VALUES (@serviceMenuID, @serviceDistributorID, @adminRoleID, 1);
END

DECLARE @RequiredPermissionTypes TABLE
(
    permissionTypeName_A NVARCHAR(200) NOT NULL,
    permissionTypeName_E NVARCHAR(200) NOT NULL PRIMARY KEY
);

INSERT INTO @RequiredPermissionTypes (permissionTypeName_A, permissionTypeName_E)
VALUES
    (@accessPermissionNameA, N'ACCESS'),
    (@insertServicePermissionNameA, N'INSERTSERVICE'),
    (@updateServicePermissionNameA, N'UPDATESERVICE'),
    (@deleteServicePermissionNameA, N'DELETESERVICE'),
    (@manageRoutingRulesPermissionNameA, N'MANAGEROUTINGRULES'),
    (@manageSlaPoliciesPermissionNameA, N'MANAGESLAPOLICIES'),
    (@approveServiceSuggestionPermissionNameA, N'APPROVESERVICESUGGESTION');

INSERT INTO dbo.PermissionType (permissionTypeName_A, permissionTypeName_E, permissionTypeActive, RoleID_FK)
SELECT rpt.permissionTypeName_A, rpt.permissionTypeName_E, 1, @adminRoleID
FROM @RequiredPermissionTypes rpt
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.PermissionType pt
    WHERE pt.permissionTypeName_E = rpt.permissionTypeName_E
      AND pt.permissionTypeActive = 1
);

DECLARE @ServicePermissionTypes TABLE
(
    permissionTypeID INT NOT NULL PRIMARY KEY,
    permissionTypeName_E NVARCHAR(200) NOT NULL
);

;WITH RankedPermissionTypes AS
(
    SELECT
        pt.permissionTypeID,
        pt.permissionTypeName_E,
        ROW_NUMBER() OVER (PARTITION BY pt.permissionTypeName_E ORDER BY pt.permissionTypeID DESC) AS rn
    FROM dbo.PermissionType pt
    INNER JOIN @RequiredPermissionTypes rpt
        ON rpt.permissionTypeName_E = pt.permissionTypeName_E
    WHERE pt.permissionTypeActive = 1
)
INSERT INTO @ServicePermissionTypes (permissionTypeID, permissionTypeName_E)
SELECT permissionTypeID, permissionTypeName_E
FROM RankedPermissionTypes
WHERE rn = 1;

UPDATE dpt
SET distributorPermissionTypeActive = 1,
    distributorPermissionTypeEndDate = NULL,
    permissionAuthLvl = COALESCE(permissionAuthLvl, 3)
FROM dbo.DistributorPermissionType dpt
INNER JOIN @ServicePermissionTypes spt
    ON spt.permissionTypeID = dpt.permissionTypeID_FK
WHERE dpt.distributorID_FK = @serviceDistributorID;

INSERT INTO dbo.DistributorPermissionType
    (permissionTypeID_FK, DistributorID_FK, distributorPermissionTypeStartDate, distributorPermissionTypeEndDate, distributorPermissionTypeActive, permissionAuthLvl, entryDate, entryData, hostName)
SELECT
    spt.permissionTypeID,
    @serviceDistributorID,
    GETDATE(),
    NULL,
    1,
    3,
    GETDATE(),
    @entryUser,
    @entryHost
FROM @ServicePermissionTypes spt
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.DistributorPermissionType dpt
    WHERE dpt.DistributorID_FK = @serviceDistributorID
      AND dpt.permissionTypeID_FK = spt.permissionTypeID
      AND dpt.distributorPermissionTypeActive = 1
);

DECLARE @TargetUsers TABLE
(
    UsersID BIGINT NOT NULL PRIMARY KEY,
    InIdaraID BIGINT NULL
);

INSERT INTO @TargetUsers (UsersID, InIdaraID)
SELECT
    p.UsersID_FK,
    MAX(p.InIdaraID)
FROM dbo.Permission p
INNER JOIN dbo.DistributorPermissionType dpt
    ON dpt.distributorPermissionTypeID = p.DistributorPermissionTypeID_FK
WHERE dpt.distributorID_FK = @ticketAdminDistributorID
  AND p.permissionActive = 1
  AND p.UsersID_FK IS NOT NULL
GROUP BY p.UsersID_FK;

IF NOT EXISTS (SELECT 1 FROM @TargetUsers)
BEGIN
    INSERT INTO @TargetUsers (UsersID, InIdaraID)
    SELECT TOP 1 p.UsersID_FK, p.InIdaraID
    FROM dbo.Permission p
    WHERE p.permissionActive = 1
      AND p.UsersID_FK IS NOT NULL
    ORDER BY p.UsersID_FK;
END

IF NOT EXISTS (SELECT 1 FROM @TargetUsers)
BEGIN
    RAISERROR(N'No active users were found to receive ServiceCatalogueList permissions.', 16, 1);
END

UPDATE p
SET permissionActive = 1,
    permissionEndDate = NULL,
    permissionNote = COALESCE(p.permissionNote, N'ServiceCatalogueList standalone hotfix'),
    InIdaraID = COALESCE(p.InIdaraID, tu.InIdaraID)
FROM dbo.Permission p
INNER JOIN dbo.DistributorPermissionType dpt
    ON dpt.distributorPermissionTypeID = p.DistributorPermissionTypeID_FK
INNER JOIN @TargetUsers tu
    ON tu.UsersID = p.UsersID_FK
WHERE dpt.distributorID_FK = @serviceDistributorID
  AND p.permissionActive = 0;

INSERT INTO dbo.Permission
    (DistributorPermissionTypeID_FK, UsersID_FK, RoleID_FK, distributorID_FK, IdaraID_FK, DSDID_FK, permissionStartDate, permissionEndDate, permissionActive, permissionNote, InIdaraID, entryDate, entryData, hostName)
SELECT
    dpt.distributorPermissionTypeID,
    tu.UsersID,
    NULL,
    NULL,
    NULL,
    NULL,
    GETDATE(),
    NULL,
    1,
    N'ServiceCatalogueList standalone hotfix',
    tu.InIdaraID,
    GETDATE(),
    @entryUser,
    @entryHost
FROM dbo.DistributorPermissionType dpt
CROSS JOIN @TargetUsers tu
WHERE dpt.distributorID_FK = @serviceDistributorID
  AND dpt.distributorPermissionTypeActive = 1
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.Permission p
      WHERE p.DistributorPermissionTypeID_FK = dpt.distributorPermissionTypeID
        AND p.UsersID_FK = tu.UsersID
        AND p.permissionActive = 1
  );

PRINT N'  TicketAdmin menu ID: ' + CAST(@ticketAdminMenuID AS NVARCHAR(20));
PRINT N'  ServiceCatalogueList menu ID: ' + CAST(@serviceMenuID AS NVARCHAR(20));
PRINT N'  ServiceCatalogueList distributor ID: ' + CAST(@serviceDistributorID AS NVARCHAR(20));
PRINT N'';

SELECT menuID, menuName_A, menuName_E, menuLink, menuSerial, menuActive
FROM dbo.Menu
WHERE menuID = @serviceMenuID;

SELECT distributorID, distributorName_A, distributorName_E, distributorCode, distributorActive, roleID_FK
FROM dbo.Distributor
WHERE distributorID = @serviceDistributorID;

SELECT pt.permissionTypeName_E
FROM dbo.DistributorPermissionType dpt
INNER JOIN dbo.PermissionType pt
    ON pt.permissionTypeID = dpt.permissionTypeID_FK
WHERE dpt.distributorID_FK = @serviceDistributorID
  AND dpt.distributorPermissionTypeActive = 1
ORDER BY pt.permissionTypeName_E;

SELECT p.UsersID_FK, pt.permissionTypeName_E
FROM dbo.Permission p
INNER JOIN dbo.DistributorPermissionType dpt
    ON dpt.distributorPermissionTypeID = p.DistributorPermissionTypeID_FK
INNER JOIN dbo.PermissionType pt
    ON pt.permissionTypeID = dpt.permissionTypeID_FK
WHERE dpt.distributorID_FK = @serviceDistributorID
  AND p.permissionActive = 1
ORDER BY p.UsersID_FK, pt.permissionTypeName_E;

COMMIT TRANSACTION;
PRINT N'';
PRINT N'TRANSACTION COMMITTED.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT N'';
    PRINT N'Hotfix failed and was rolled back.';
    PRINT N'Error: ' + CAST(ERROR_NUMBER() AS NVARCHAR(20)) + N' - ' + ERROR_MESSAGE();
    PRINT N'Line:  ' + CAST(ERROR_LINE() AS NVARCHAR(20));

    DECLARE @catchErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(@catchErrorMessage, 16, 1);
END CATCH