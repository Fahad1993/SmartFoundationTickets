# Gateway SP Contracts: Tickets Module

## Masters_DataLoad — Read Path

### Shared Parameters (all pages)
| Position | Param | Type | Notes |
|----------|-------|------|-------|
| 0 | pageName_ | NVARCHAR(400) | Route key |
| 1 | idaraID | INT | Tenant |
| 2 | entrydata | INT | UserID for permissions |
| 3 | hostname | NVARCHAR(400) | |
| 4+ | parameter_01..NN | NVARCHAR(4000) | Page-specific filters |

### Table 0: Permissions (all pages)
Always returns: `SELECT permissionTypeName_E FROM dbo.ft_UserPagePermissions(@entrydata, @pageName_)`

### ServiceCatalogueList
| Param | Maps To | Notes |
|-------|---------|-------|
| pageName_ | 'ServiceCatalogueList' | |
| parameter_01 | filterServiceID | Optional filter |
| parameter_02 | filterTicketClassID | Optional filter |

Returns: Table1 = Services with joined routing/SLA data (via V_ServiceFullDefinition columns)

### ServiceDDL
Returns: Table1 = serviceID, serviceName_A, serviceName_E WHERE serviceActive=1

### TicketList
| Param | Maps To | Notes |
|-------|---------|-------|
| parameter_01 | filterStatusID | Optional |
| parameter_02 | filterServiceID | Optional |
| parameter_03 | filterDSDID | Optional |

Returns: Table1 = ticketID, ticketNo, title, serviceName_A/E, priorityName_A, ticketStatusName_A/E, currentDSDID_FK, assignedUserID_FK, entryDate

### TicketDetails
| Param | Maps To | Notes |
|-------|---------|-------|
| parameter_01 | filterTicketID | Required |

Returns: Table1 = Full ticket with all joined lookup names

### TicketHistory
| Param | Maps To | Notes |
|-------|---------|-------|
| parameter_01 | filterTicketID | Required |

Returns: Table1 = ticketHistoryID, ticketID_FK, actionTypeCode, old/new status names, performerUserID, notes, actionDate

### StatusDDL
Returns: Table1 = ticketStatusID, ticketStatusCode, ticketStatusName_A/E WHERE ticketStatusActive=1

---

## Masters_CRUD — Write Path

### Shared Parameters
| Position | Param | Type | Notes |
|----------|-------|------|-------|
| 0 | pageName_ | NVARCHAR(400) | Route key |
| 1 | ActionType | NVARCHAR(100) | Operation |
| 2 | idaraID | INT | |
| 3 | entrydata | INT | UserID |
| 4 | hostname | NVARCHAR(4000) | |
| 5+ | parameter_01..50 | NVARCHAR(4000) | Mapped to typed SP params |

### Permission Check (all actions)
```sql
IF (SELECT COUNT(*) FROM dbo.V_GetListUserPermission v
    WHERE v.userID = @entrydata AND v.menuName_E = @pageName_
    AND v.permissionTypeName_E = @ActionType) <= 0
BEGIN GOTO Finish; END
```

### pageName_ = 'Tickets'

#### ActionType = INSERT_TICKET
| parameter | Maps to TicketSP | Type |
|-----------|-----------------|------|
| parameter_01 | ticketClassID_FK | INT |
| parameter_02 | requesterTypeID_FK | INT |
| parameter_03 | requesterUserID_FK | INT |
| parameter_04 | requesterResidentID_FK | BIGINT |
| parameter_05 | serviceID_FK | BIGINT |
| parameter_06 | title | NVARCHAR(500) |
| parameter_07 | description_ | NVARCHAR(4000) |
| parameter_08 | suggestedPriorityID_FK | INT |
| parameter_09 | currentDSDID_FK | INT |
| parameter_10 | currentQueueDistributorID_FK | INT |
| parameter_11 | assignedUserID_FK | INT |
| parameter_12 | locationBuildingNo | NVARCHAR(100) |
| parameter_13 | locationUnitNo | NVARCHAR(50) |
| parameter_14 | locationArea | NVARCHAR(200) |
| parameter_15 | requiresQualityReview | BIT |
| parameter_16 | isOtherService | BIT |

#### ActionType = INSERT_SERVICE
| parameter | Maps to ServiceSP | Type |
|-----------|------------------|------|
| parameter_01 | serviceCode | NVARCHAR(100) |
| parameter_02 | serviceName_A | NVARCHAR(300) |
| parameter_03 | serviceName_E | NVARCHAR(300) |
| parameter_04 | serviceDesc | NVARCHAR(1000) |
| parameter_05 | ticketClassID_FK | INT |
| parameter_06 | defaultPriorityID_FK | INT |
| parameter_07 | requiresLocation | BIT |
| parameter_08 | allowsChildTickets | BIT |
| parameter_09 | requiresQualityReview | BIT |

#### ActionType = UPDATE_SERVICE
| parameter | Maps to ServiceSP | Type |
|-----------|------------------|------|
| parameter_01 | serviceID (required) | BIGINT |
| parameter_02..09 | Same as INSERT | |

#### ActionType = DELETE_SERVICE
| parameter | Maps to ServiceSP | Type |
|-----------|------------------|------|
| parameter_01 | serviceID (required) | BIGINT |

#### ActionType = INSERT_ROUTING_RULE
| parameter | Maps to ServiceSP | Type |
|-----------|------------------|------|
| parameter_01 | serviceID | BIGINT |
| parameter_02 | targetDSDID_FK | INT |
| parameter_03 | changeReason | NVARCHAR(500) |
| parameter_04 | approvedByUserID | INT |

#### ActionType = CLOSE_ROUTING_RULE
| parameter | Maps to ServiceSP | Type |
|-----------|------------------|------|
| parameter_01 | serviceRoutingRuleID | BIGINT |

#### ActionType = UPSERT_SLA_POLICY
| parameter | Maps to ServiceSP | Type |
|-----------|------------------|------|
| parameter_01 | serviceID | BIGINT |
| parameter_02 | priorityID_FK | INT |
| parameter_03 | firstResponseTargetMinutes | INT |
| parameter_04 | assignmentTargetMinutes | INT |
| parameter_05 | operationalCompletionTargetMinutes | INT |
| parameter_06 | finalClosureTargetMinutes | INT |

### Result Format
All write operations return: `SELECT IsSuccessful INT, Message_ NVARCHAR(4000)`
