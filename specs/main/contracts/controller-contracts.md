# Controller Contracts: Tickets Module

## TicketController Actions

### GET /Tickets/ServiceCatalogueList
- Calls `MastersServies.GetDataLoadDataSetAsync("ServiceCatalogueList", idaraID, usersId, hostName, filterServiceID, filterTicketClassID)`
- SplitDataSet → permissionTable + dt1 (services list)
- Permission flags: INSERTSERVICE, UPDATESERVICE, DELETESERVICE
- DDL lookups: TicketClassDDL, PriorityDDL (via CrudController.GetDDLValues)
- Builds SmartPageViewModel with TableDS (services grid)
- Toolbar: Add service, Edit service, Delete service
- Returns View("Tickets/ServiceCatalogueList", page)

### GET /Tickets/TicketList
- Calls `MastersServies.GetDataLoadDataSetAsync("TicketList", idaraID, usersId, hostName, filterStatusID, filterServiceID, filterDSDID)`
- SplitDataSet → permissionTable + dt1 (tickets list)
- DDL lookups: StatusDDL, ServiceDDL
- Builds SmartPageViewModel with Form (filters) + TableDS (tickets grid)
- Returns View("Tickets/TicketList", page)

### GET /Tickets/TicketDetails?id={ticketID}
- Calls `MastersServies.GetDataLoadDataSetAsync("TicketDetails", idaraID, usersId, hostName, ticketID)`
- Calls `MastersServies.GetDataLoadDataSetAsync("TicketHistory", idaraID, usersId, hostName, ticketID)` (second call for history)
- SplitDataSet → permissionTable + dt1 (ticket details) + dt2 (history)
- Returns View("Tickets/TicketDetails", page)

## CRUD Posts (handled by CrudController)
All go to `/crud/insert` or `/crud/update` or `/crud/delete` with:
- Hidden: pageName_ = 'Tickets', ActionType = e.g. 'INSERT_TICKET'
- Hidden: idaraID, entrydata, hostname
- Hidden: redirectAction = 'ServiceCatalogueList', redirectController = 'Tickets'
- Visible: p01..pNN mapped to parameter_01..parameter_NN

## DI Registration
```csharp
// In Program.cs
builder.Services.AddScoped<TicketController>();
```
TicketController depends on MastersServies and CrudController (both already registered).
