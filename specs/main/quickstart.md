# Quickstart: Tickets Module

## Prerequisites

1. Database layer deployed (21 tables, 4 SPs, 3 views in `[Tickets]` schema)
2. Seed data executed (`SeedLookups.sql`)
3. Solution builds: `dotnet build SmartFoundation.Mvc/SmartFoundation.Mvc.csproj`

## Implementation Order

### Step 1: Gateway SP Routing
Add `ELSE IF @pageName_` branches to both gateway procedures:

**Masters_DataLoad.sql** (insert before "PAGE NOT FOUND" block at ~line 2123):
```sql
ELSE IF @pageName_ IN ('ServiceCatalogueList', 'ServiceDDL', 'ServiceCatalogueSuggestions')
BEGIN
    EXEC [Tickets].[ServiceDL]
          @pageName_   = @pageName_
        , @idaraID     = @idaraID
        , @entryData   = @entrydata
        , @hostName    = @hostname
        , @filterServiceID    = @parameter_01
        , @filterTicketClassID = @parameter_02;
END
ELSE IF @pageName_ IN ('TicketList', 'TicketDetails', 'TicketHistory', 'StatusDDL')
BEGIN
    EXEC [Tickets].[TicketDL]
          @pageName_   = @pageName_
        , @idaraID     = @idaraID
        , @entryData   = @entrydata
        , @hostName    = @hostname
        , @filterTicketID     = @parameter_01
        , @filterTicketNo     = @parameter_02
        , @filterStatusID     = @parameter_03
        , @filterServiceID    = @parameter_04
        , @filterAssignedUserID = @parameter_05
        , @filterDSDID        = @parameter_06;
END
```

**Masters_CRUD.sql** (insert before "DO NOT TOUCH" block at ~line 5157):
```sql
ELSE IF @pageName_ = 'Tickets'
BEGIN
    -- Permission check
    IF (SELECT COUNT(*) FROM dbo.V_GetListUserPermission v
        WHERE v.userID = @entrydata AND v.menuName_E = @pageName_
        AND v.permissionTypeName_E = @ActionType) <= 0
    BEGIN SET @ok = 0; SET @msg = N'عفوا لاتملك صلاحية لهذه العملية'; GOTO Finish; END

    DELETE FROM @Result;

    IF @ActionType IN ('INSERT_TICKET')
    BEGIN
        INSERT INTO @Result(IsSuccessful, Message_)
        EXEC [Tickets].[TicketSP]
              @Action                    = @ActionType
            , @ticketClassID_FK         = @parameter_01
            , @requesterTypeID_FK       = @parameter_02
            , @requesterUserID_FK       = @parameter_03
            , @requesterResidentID_FK   = @parameter_04
            , @serviceID_FK             = @parameter_05
            , @title                    = @parameter_06
            , @description_             = @parameter_07
            , @suggestedPriorityID_FK   = @parameter_08
            , @currentDSDID_FK          = @parameter_09
            , @currentQueueDistributorID_FK = @parameter_10
            , @assignedUserID_FK        = @parameter_11
            , @locationBuildingNo       = @parameter_12
            , @locationUnitNo           = @parameter_13
            , @locationArea             = @parameter_14
            , @requiresQualityReview    = @parameter_15
            , @isOtherService           = @parameter_16
            , @idaraID_FK               = @idaraID
            , @entryData                = @entrydata
            , @hostName                 = @hostName;
    END
    ELSE IF @ActionType IN ('INSERT_SERVICE', 'UPDATE_SERVICE', 'DELETE_SERVICE',
                            'INSERT_ROUTING_RULE', 'CLOSE_ROUTING_RULE', 'UPSERT_SLA_POLICY')
    BEGIN
        INSERT INTO @Result(IsSuccessful, Message_)
        EXEC [Tickets].[ServiceSP]
              @Action     = @ActionType
            , @serviceID  = @parameter_01
            /* ... map remaining parameters per ActionType ... */
            , @idaraID_FK = @idaraID
            , @entryData  = @entrydata
            , @hostName   = @hostName
            /* + parameter_02..NN as needed */;
    END

    SELECT TOP 1 @ok = IsSuccessful, @msg = Message_ FROM @Result;
    GOTO Finish;
END
```

### Step 2: TicketController.Base.cs
Create `SmartFoundation.Mvc/Controllers/Tickets/TicketController.Base.cs`:
- Mirror `HousingController.Base.cs` exactly
- Same session fields, `InitPageContext`, `SplitDataSet`
- Inject `MastersServies` + `CrudController`

### Step 3: TicketController.Pages.cs
Create one partial file per page action:
- `TicketController.ServiceCatalog.cs` — ServiceCatalogueList action
- `TicketController.TicketList.cs` — TicketList action
- `TicketController.TicketDetails.cs` — TicketDetails action

### Step 4: Views
Create thin Razor views in `SmartFoundation.Mvc/Views/Tickets/`:
- `ServiceCatalogueList.cshtml`
- `TicketList.cshtml`
- `TicketDetails.cshtml`

Each view: `@await Component.InvokeAsync("SmartRenderer", new { model = Model })`

### Step 5: DI
In `Program.cs`: `builder.Services.AddScoped<TicketController>();`

### Step 6: Menu Entry
Add Tickets pages to the menu system via the admin UI.

## Build Verification
```powershell
dotnet build SmartFoundation.Mvc/SmartFoundation.Mvc.csproj
dotnet test SmartFoundation.Application.Tests/SmartFoundation.Application.Tests.csproj
```
