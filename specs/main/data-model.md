# Data Model: Tickets Module

## Entity Relationships

```
TicketStatus ──┐
TicketClass ───┤
Priority ──────┤
RequesterType ─┤
Service ───────┤──→ Ticket ←── TicketHistory
   │           │      │
   ├── ServiceRoutingRule   ├── TicketSLA ←── TicketSLAHistory
   ├── ServiceSLAPolicy     ├── TicketPauseSession ←── PauseReason
   └── ServiceCatalogSuggestion ├── ArbitrationCase ←── ArbitrationReason
                                ├── ClarificationRequest ←── ClarificationReason
                                └── QualityReview ←── QualityReviewResult
```

## Core Entities (already deployed)

### TicketStatus (lookup, 11 rows)
| Column | Type | Notes |
|--------|------|-------|
| ticketStatusID | INT PK | |
| ticketStatusCode | NVARCHAR(50) | Unique: NEW, ROUTED, ASSIGNED, IN_PROGRESS, etc. |
| ticketStatusName_A | NVARCHAR(200) | Arabic name |
| ticketStatusName_E | NVARCHAR(200) | English name |
| ticketStatusActive | BIT | Soft delete |
| entryData, hostName | Audit | |

### TicketClass (lookup, 5 rows)
| Column | Type | Notes |
|--------|------|-------|
| ticketClassID | INT PK | |
| ticketClassCode | NVARCHAR(50) | MAINTENANCE, SERVICE_REQUEST, etc. |
| ticketClassName_A/E | NVARCHAR(200) | |
| ticketClassActive | BIT | |

### Priority (lookup, 5 rows)
| Column | Type | Notes |
|--------|------|-------|
| priorityID | INT PK | |
| priorityCode | NVARCHAR(50) | CRITICAL, HIGH, MEDIUM, LOW, MINIMAL |
| priorityLevel | INT | Unique numeric ranking |
| priorityName_A/E | NVARCHAR(200) | |
| priorityActive | BIT | |

### RequesterType (lookup, 5 rows)
| Column | Type | Notes |
|--------|------|-------|
| requesterTypeID | INT PK | |
| requesterTypeCode | NVARCHAR(50) | RESIDENT, INTERNAL, SUPERVISOR, MANAGER, OTHER |
| requesterTypeName_A/E | NVARCHAR(200) | |
| requesterTypeActive | BIT | |

### Service (master, 5 rows)
| Column | Type | Notes |
|--------|------|-------|
| serviceID | BIGINT PK IDENTITY | |
| serviceCode | NVARCHAR(100) | Unique per idaraID |
| serviceName_A/E | NVARCHAR(300) | |
| serviceDesc | NVARCHAR(1000) | |
| idaraID_FK | INT | Tenant scope |
| ticketClassID_FK | INT → TicketClass | |
| defaultPriorityID_FK | INT → Priority | |
| requiresLocation | BIT | |
| allowsChildTickets | BIT | |
| requiresQualityReview | BIT | |
| serviceActive | BIT | Soft delete |

### ServiceRoutingRule (master)
| Column | Type | Notes |
|--------|------|-------|
| serviceRoutingRuleID | BIGINT PK IDENTITY | |
| serviceID_FK | BIGINT → Service | |
| idaraID_FK | INT | |
| targetDSDID_FK | INT | Target department |
| queueDistributorID_FK | INT | |
| effectiveFrom | DATETIME | |
| effectiveTo | DATETIME | NULL = currently active |
| changeReason | NVARCHAR(500) | |
| approvedByUserID | INT | |
| serviceRoutingRuleActive | BIT | |

### ServiceSLAPolicy (master)
| Column | Type | Notes |
|--------|------|-------|
| serviceSLAPolicyID | BIGINT PK IDENTITY | |
| serviceID_FK | BIGINT → Service | |
| idaraID_FK | INT | |
| priorityID_FK | INT → Priority | One policy per service+priority |
| firstResponseTargetMinutes | INT | |
| assignmentTargetMinutes | INT | |
| operationalCompletionTargetMinutes | INT | |
| finalClosureTargetMinutes | INT | |
| slaPolicyActive | BIT | |

### Ticket (transaction)
| Column | Type | Notes |
|--------|------|-------|
| ticketID | BIGINT PK IDENTITY | |
| ticketNo | NVARCHAR(50) | TKT-YYYY-NNNNN format |
| idaraID_FK | INT | Required |
| parentTicketID_FK | BIGINT → Ticket | NULL for top-level |
| rootTicketID_FK | BIGINT → Ticket | Set to self for top-level |
| serviceID_FK | BIGINT → Service | NULL for isOtherService |
| ticketClassID_FK | INT → TicketClass | Required |
| requesterTypeID_FK | INT → RequesterType | Required |
| requesterUserID_FK | INT | For INTERNAL types |
| requesterResidentID_FK | BIGINT | For RESIDENT type |
| title | NVARCHAR(500) | Required |
| description_ | NVARCHAR(4000) | |
| suggestedPriorityID_FK | INT → Priority | |
| effectivePriorityID_FK | INT → Priority | Resolved at creation |
| ticketStatusID_FK | INT → TicketStatus | Starts as NEW |
| currentDSDID_FK | INT | Current department |
| assignedUserID_FK | INT | |
| locationBuildingNo, locationUnitNo, locationArea | NVARCHAR | |
| requiresQualityReview | BIT | |
| isOtherService | BIT | |
| isParentBlocked | BIT | |
| ticketActive | BIT | Soft delete |

### TicketHistory (transaction)
| Column | Type | Notes |
|--------|------|-------|
| ticketHistoryID | BIGINT PK IDENTITY | |
| ticketID_FK | BIGINT → Ticket | |
| idaraID_FK | INT | |
| actionTypeCode | NVARCHAR(50) | CREATED, ASSIGNED, etc. |
| oldStatusID_FK | INT → TicketStatus | NULL for creation |
| newStatusID_FK | INT → TicketStatus | Required |
| performerUserID | INT | Who performed the action |
| notes | NVARCHAR(2000) | |
| actionDate | DATETIME | |

## State Transitions

```
NEW → ROUTED → ASSIGNED → IN_PROGRESS → RESOLVED → CLOSED
                                 ↓
                            CLARIFICATION
                            ARBITRATION
                            PAUSED
                                 ↓
                            RESOLVED → CLOSED
```

Additional transitions:
- Any active status → REJECTED
- CLOSED → REOPENED
- CLARIFICATION → ASSIGNED (back)
- ARBITRATION → ASSIGNED (back)
- PAUSED → previous status (resume)

## Validation Rules (enforced in SPs)

### INSERT_TICKET
- `title` is required
- `idaraID_FK` is required
- `ticketClassID_FK` is required
- `requesterTypeID_FK` is required
- RESIDENT type: must have `requesterResidentID_FK`, no `requesterUserID_FK`
- INTERNAL/SUPERVISOR/MANAGER: must have `requesterUserID_FK`, no `requesterResidentID_FK`
- Non-Other tickets (`isOtherService = 0`): must have `serviceID_FK`
- Auto-generates `ticketNo` as TKT-YYYY-NNNNN (sequential per year)
- Sets `rootTicketID_FK = SCOPE_IDENTITY()` for top-level
- Creates TicketHistory with actionTypeCode = 'CREATED'
- Creates AuditLog entry

### Service CRUD
- INSERT_SERVICE: `serviceName_A` required, unique per idaraID
- UPDATE_SERVICE: must exist and be active
- DELETE_SERVICE: soft delete (serviceActive = 0), must be currently active
- All actions create AuditLog entries

### Routing Rules
- INSERT_ROUTING_RULE: `serviceID` and `targetDSDID_FK` required
- CLOSE_ROUTING_RULE: must be currently active
- Creates CatalogRoutingChangeLog and AuditLog entries

### SLA Policies
- UPSERT_SLA_POLICY: `serviceID`, `priorityID_FK` required
- Upsert logic: if active policy exists for same service+priority+idara, update it; else insert
