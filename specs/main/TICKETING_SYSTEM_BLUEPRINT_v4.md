# Multi-Department Ticketing System — Complete UI Blueprint

> **Purpose**: This document describes every page, component, layout, CSS class, color, data model, and interaction of the Multi-Department Ticketing System prototype. It is written with enough detail so that another AI agent (or developer) can rebuild the **exact same UI** using **C# ASP.NET MVC with MSSQL** (or any other stack).

---

## Table of Contents

1. [Technology Stack (Original)](#1-technology-stack-original)
2. [Global Design System](#2-global-design-system)
3. [Data Models (Database Tables)](#3-data-models-database-tables)
4. [Helper Functions & Formatters](#4-helper-functions--formatters)
5. [Application Layout (AppLayout)](#5-application-layout-applayout)
6. [Page 1: Dashboard (/)](#6-page-1-dashboard-)
7. [Page 2: Ticket Queue (/tickets)](#7-page-2-ticket-queue-tickets)
8. [Page 3: Ticket Detail (/tickets/:id)](#8-page-3-ticket-detail-ticketsid)
9. [Page 4: Create Ticket (/tickets/create)](#9-page-4-create-ticket-ticketscreate)
10. [Page 5: Service Catalogue (/services)](#10-page-5-service-catalogue-services)
11. [Page 6: Reports & Analytics (/reports)](#11-page-6-reports--analytics-reports)
12. [Reusable UI Components](#12-reusable-ui-components)
13. [Routing Map](#13-routing-map)
14. [Mock Data (Seed Data)](#14-mock-data-seed-data)
15. [Recommendations for C# MVC Rebuild](#15-recommendations-for-c-mvc-rebuild)

---

## 1. Technology Stack (Original)

| Layer | Technology |
|-------|-----------|
| Framework | React 18 + TypeScript |
| Routing | React Router v6 |
| Styling | Tailwind CSS v3 + tailwindcss-animate + @tailwindcss/aspect-ratio + @tailwindcss/typography |
| UI Components | Shadcn/ui (Radix UI primitives) |
| Icons | Lucide React |
| State | React useState/useMemo (local state only) |
| Data Fetching | @tanstack/react-query (configured but mock data used) |
| Build Tool | Vite |

### For C# MVC Rebuild
- Use **Bootstrap 5** or **Tailwind CSS CDN** to replicate the utility classes
- Use **Razor Views** (.cshtml) for each page
- Use **Entity Framework Core** with **MSSQL** for data access
- Use **ASP.NET Core MVC** controllers
- Icons: Use **Lucide** (available as SVG/web font) or **Bootstrap Icons**

---

## 2. Global Design System

### 2.1 Color Palette (CSS Custom Properties)

```css
:root {
  --background: 0 0% 100%;          /* white */
  --foreground: 222.2 84% 4.9%;     /* near-black */
  --card: 0 0% 100%;                /* white */
  --card-foreground: 222.2 84% 4.9%;
  --popover: 0 0% 100%;
  --popover-foreground: 222.2 84% 4.9%;
  --primary: 222.2 47.4% 11.2%;     /* dark navy */
  --primary-foreground: 210 40% 98%; /* near-white */
  --secondary: 210 40% 96.1%;       /* light gray-blue */
  --secondary-foreground: 222.2 47.4% 11.2%;
  --muted: 210 40% 96.1%;
  --muted-foreground: 215.4 16.3% 46.9%; /* medium gray */
  --accent: 210 40% 96.1%;
  --accent-foreground: 222.2 47.4% 11.2%;
  --destructive: 0 84.2% 60.2%;     /* red */
  --destructive-foreground: 210 40% 98%;
  --border: 214.3 31.8% 91.4%;      /* light border */
  --input: 214.3 31.8% 91.4%;
  --ring: 222.2 84% 4.9%;
  --radius: 0.5rem;                  /* 8px border radius */
}
```

### 2.2 Status Colors (Badge Background + Text)

| Status | CSS Classes | Visual |
|--------|------------|--------|
| Open | `bg-blue-100 text-blue-800` | Light blue bg, dark blue text |
| Assigned | `bg-indigo-100 text-indigo-800` | Light indigo bg, dark indigo text |
| InProgress | `bg-yellow-100 text-yellow-800` | Light yellow bg, dark yellow text |
| Paused | `bg-gray-200 text-gray-700` | Light gray bg, dark gray text |
| Resolved | `bg-green-100 text-green-800` | Light green bg, dark green text |
| Closed | `bg-slate-200 text-slate-600` | Light slate bg, medium slate text |
| PendingArbitration | `bg-orange-100 text-orange-800` | Light orange bg, dark orange text |
| PendingClarification | `bg-purple-100 text-purple-800` | Light purple bg, dark purple text |

### 2.3 Status Display Labels

| Status Key | Display Label |
|-----------|---------------|
| Open | "Open" |
| Assigned | "Assigned" |
| InProgress | "In Progress" |
| Paused | "Paused" |
| Resolved | "Resolved" |
| Closed | "Closed" |
| PendingArbitration | "Pending Arbitration" |
| PendingClarification | "Pending Clarification" |

### 2.4 Priority Colors (Badge Background + Text + Border)

| Priority | CSS Classes | Visual |
|----------|------------|--------|
| Critical | `bg-red-100 text-red-800 border-red-300` | Red tones |
| High | `bg-orange-100 text-orange-800 border-orange-300` | Orange tones |
| Medium | `bg-yellow-100 text-yellow-800 border-yellow-300` | Yellow tones |
| Low | `bg-green-100 text-green-800 border-green-300` | Green tones |

### 2.5 Status Bar Chart Colors (Reports page)

| Status | Bar Color Class |
|--------|----------------|
| Open | `bg-blue-500` |
| Assigned | `bg-indigo-500` |
| InProgress | `bg-yellow-500` |
| Paused | `bg-gray-400` |
| Resolved | `bg-green-500` |
| Closed | `bg-slate-400` |
| PendingArbitration | `bg-orange-500` |
| PendingClarification | `bg-purple-500` |

### 2.6 Typography

- **Page titles**: `text-2xl font-bold text-slate-900` (24px, bold, near-black)
- **Page subtitles**: `text-sm text-slate-500 mt-1` (14px, gray, 4px top margin)
- **Card titles**: `text-sm font-semibold` (14px, semi-bold)
- **Table text**: `text-sm` (14px)
- **Small labels**: `text-xs` (12px) or `text-[10px]` (10px)
- **Mono text** (ticket numbers, codes): `font-mono text-xs`

### 2.7 Badge Component (Global)

All badges use this base style:
```
inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold
```
- `rounded-full` = fully rounded pill shape
- `px-2.5 py-0.5` = 10px horizontal, 2px vertical padding
- `text-xs` = 12px font size
- `font-semibold` = 600 font weight
- Status/priority badges use `text-[10px]` (10px) override

### 2.8 Card Component

```
rounded-lg border bg-card text-card-foreground shadow-sm
```
- `rounded-lg` = 8px border radius (var(--radius))
- `border` = 1px solid border color
- `bg-card` = white background
- `shadow-sm` = subtle box shadow

### 2.9 Button Variants

| Variant | Style |
|---------|-------|
| default | Dark navy bg, white text |
| ghost | Transparent bg, hover: light gray bg |
| outline | White bg, border, dark text |
| Action buttons (custom) | Colored bg per action (see Section 8) |

---

## 3. Data Models (Database Tables)

### 3.1 Service (Service Catalogue)

```sql
CREATE TABLE Services (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Code NVARCHAR(20) NOT NULL,           -- e.g. "SVC-001"
    NameEn NVARCHAR(200) NOT NULL,        -- English name
    Department NVARCHAR(100) NOT NULL,
    Division NVARCHAR(100) NOT NULL,
    Section NVARCHAR(100) NOT NULL,
    DefaultPriority NVARCHAR(20) NOT NULL, -- "Critical"|"High"|"Medium"|"Low"
    IsActive BIT NOT NULL DEFAULT 1,
    SlaResponseMin INT NOT NULL,           -- minutes
    SlaAssignMin INT NOT NULL,             -- minutes
    SlaCompletionMin INT NOT NULL,         -- minutes
    SlaClosureMin INT NOT NULL             -- minutes
);
```

### 3.2 Ticket

```sql
CREATE TABLE Tickets (
    Id INT PRIMARY KEY IDENTITY(1,1),
    TicketNo NVARCHAR(30) NOT NULL,        -- e.g. "TKT-2026-0001"
    Title NVARCHAR(300) NOT NULL,
    Description NVARCHAR(MAX) NOT NULL,
    Status NVARCHAR(30) NOT NULL,          -- see TicketStatus enum
    Priority NVARCHAR(20) NOT NULL,        -- "Critical"|"High"|"Medium"|"Low"
    RequesterType NVARCHAR(20) NOT NULL,   -- "Resident"|"Internal"
    RequesterName NVARCHAR(200) NOT NULL,
    ServiceId INT NULL REFERENCES Services(Id),
    ServiceName NVARCHAR(200) NOT NULL,
    IsOtherService BIT NOT NULL DEFAULT 0,
    Department NVARCHAR(100) NOT NULL,
    Division NVARCHAR(100) NOT NULL,
    Section NVARCHAR(100) NOT NULL,
    CurrentQueue NVARCHAR(200) NOT NULL,
    AssignedUser NVARCHAR(200) NULL,
    ParentTicketId INT NULL REFERENCES Tickets(Id),
    IsParentBlocked BIT NOT NULL DEFAULT 0,
    RequiresQualityReview BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ResolvedAt DATETIME2 NULL,
    ClosedAt DATETIME2 NULL,
    SlaBreached BIT NOT NULL DEFAULT 0,
    SlaResponseRemainMin INT NOT NULL DEFAULT 0,
    SlaCompletionRemainMin INT NOT NULL DEFAULT 0,
    Location NVARCHAR(300) NOT NULL
);
-- Note: ChildTicketIds is derived via query: SELECT Id FROM Tickets WHERE ParentTicketId = @parentId
```

### 3.3 TicketHistory (Audit Trail)

```sql
CREATE TABLE TicketHistories (
    Id INT PRIMARY KEY IDENTITY(1,1),
    TicketId INT NOT NULL REFERENCES Tickets(Id),
    Action NVARCHAR(200) NOT NULL,         -- e.g. "Ticket Created", "Assigned", "Work Started"
    OldStatus NVARCHAR(30) NULL,
    NewStatus NVARCHAR(30) NULL,
    Performer NVARCHAR(200) NOT NULL,      -- who performed the action
    Notes NVARCHAR(MAX) NOT NULL,
    Date DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);
```

### 3.4 ArbitrationCase

```sql
CREATE TABLE ArbitrationCases (
    Id INT PRIMARY KEY IDENTITY(1,1),
    TicketId INT NOT NULL REFERENCES Tickets(Id),
    RaisedBy NVARCHAR(200) NOT NULL,
    FromDSD NVARCHAR(200) NOT NULL,        -- originating dept/section/division
    Reason NVARCHAR(MAX) NOT NULL,
    Status NVARCHAR(30) NOT NULL,          -- "Open"|"Redirected"|"Overruled"|"Cancelled"
    Arbitrator NVARCHAR(200) NOT NULL,
    Decision NVARCHAR(200) NULL,           -- e.g. "Redirect"
    DecisionTarget NVARCHAR(200) NULL,     -- target dept/division
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ResolvedAt DATETIME2 NULL
);
```

### 3.5 ClarificationRequest

```sql
CREATE TABLE ClarificationRequests (
    Id INT PRIMARY KEY IDENTITY(1,1),
    TicketId INT NOT NULL REFERENCES Tickets(Id),
    RequestedBy NVARCHAR(200) NOT NULL,
    TargetUser NVARCHAR(200) NOT NULL,
    Reason NVARCHAR(200) NOT NULL,
    Status NVARCHAR(30) NOT NULL,          -- "Open"|"Responded"|"Closed"
    RequestNotes NVARCHAR(MAX) NOT NULL,
    ResponseNotes NVARCHAR(MAX) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    RespondedAt DATETIME2 NULL
);
```

### 3.6 QualityReview

```sql
CREATE TABLE QualityReviews (
    Id INT PRIMARY KEY IDENTITY(1,1),
    TicketId INT NOT NULL REFERENCES Tickets(Id),
    Reviewer NVARCHAR(200) NOT NULL,
    Result NVARCHAR(30) NULL,              -- "Approved"|"ReturnedForCorrection"|"Rejected" or NULL=Pending
    Notes NVARCHAR(MAX) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ReviewedAt DATETIME2 NULL
);
```

### 3.7 PauseSession

```sql
CREATE TABLE PauseSessions (
    Id INT PRIMARY KEY IDENTITY(1,1),
    TicketId INT NOT NULL REFERENCES Tickets(Id),
    Reason NVARCHAR(50) NOT NULL,          -- "ChildDependency"|"Arbitration"|"Clarification"|"WarehouseDelay"|"ApprovalDelay"|"ExternalDependency"
    RelatedChildTicketId INT NULL,
    RelatedArbitrationId INT NULL,
    RelatedClarificationId INT NULL,
    StartedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    EndedAt DATETIME2 NULL,
    Notes NVARCHAR(MAX) NOT NULL
);
```

### 3.8 Enums Summary

```
TicketStatus: "Open" | "Assigned" | "InProgress" | "Paused" | "Resolved" | "Closed" | "PendingArbitration" | "PendingClarification"
Priority: "Critical" | "High" | "Medium" | "Low"
RequesterType: "Resident" | "Internal"
PauseReason: "ChildDependency" | "Arbitration" | "Clarification" | "WarehouseDelay" | "ApprovalDelay" | "ExternalDependency"
ArbitrationStatus: "Open" | "Redirected" | "Overruled" | "Cancelled"
ClarificationStatus: "Open" | "Responded" | "Closed"
QualityResult: "Approved" | "ReturnedForCorrection" | "Rejected"
SLAType: "FirstResponse" | "Assignment" | "OperationalCompletion" | "FinalClosure"
```

---

## 4. Helper Functions & Formatters

### 4.1 formatDate(isoString)
```
Input: ISO date string
Output: "Apr 10, 2026" format
Logic: month: "short", day: "numeric", year: "numeric"
```

### 4.2 formatDateTime(isoString)
```
Input: ISO date string
Output: "Apr 10, 08:30 AM" format
Logic: month: "short", day: "numeric", hour: "2-digit", minute: "2-digit"
```

### 4.3 formatMinutes(min)
```
Input: integer minutes
Output:
  - If min <= 0: "Overdue"
  - If min < 60: "{min}m"
  - If min < 1440: "{hours}h {remainingMin}m"
  - Else: "{days}d {hours}h"
```

### 4.4 getStatusCounts()
```
Returns: Dictionary<TicketStatus, int> — count of tickets per status
```

### 4.5 getDepartmentCounts()
```
Returns: Dictionary<string, int> — count of tickets per department
```

### 4.6 getServiceFrequency()
```
Returns: List of (serviceName, count) sorted descending by count
```

---

## 5. Application Layout (AppLayout)

Every page is wrapped in `AppLayout`. This is a **sidebar + top bar + content area** layout.

### 5.1 Overall Structure

```
┌──────────────────────────────────────────────────────┐
│ ┌──────────┐ ┌──────────────────────────────────────┐│
│ │          │ │ TOP BAR (h-14, white, border-bottom) ││
│ │          │ ├──────────────────────────────────────┤│
│ │ SIDEBAR  │ │                                      ││
│ │ (w-64)   │ │         MAIN CONTENT AREA            ││
│ │ bg-slate │ │         (p-4 md:p-6)                 ││
│ │ -900     │ │         overflow-y-auto               ││
│ │          │ │                                      ││
│ │          │ │                                      ││
│ └──────────┘ └──────────────────────────────────────┘│
└──────────────────────────────────────────────────────┘
```

### 5.2 Root Container
- `flex h-screen bg-slate-50` — full viewport height, light gray background

### 5.3 Sidebar (Left Panel)

**Container**: `fixed lg:static inset-y-0 left-0 z-50 w-64 bg-slate-900 text-white flex flex-col`
- Width: 256px (w-64)
- Background: `bg-slate-900` (very dark blue-gray, ~#0f172a)
- Text: white
- On mobile: slides in/out with `-translate-x-full lg:translate-x-0` transition
- Transition: `transition-transform duration-200`

**Mobile overlay**: When sidebar is open on mobile, a `fixed inset-0 bg-black/40 z-40` overlay appears behind it.

#### 5.3.1 Sidebar Header
- Container: `flex items-center gap-3 px-5 py-5 border-b border-slate-700`
- Logo box: `w-9 h-9 rounded-lg bg-blue-500 flex items-center justify-center font-bold text-sm` — displays "TS"
- Title: `font-bold text-sm leading-tight` — "Ticketing System"
- Subtitle: `text-[11px] text-slate-400` — "Multi-Department"
- Close button (mobile only): `ml-auto lg:hidden text-slate-400 hover:text-white` — X icon (20px)

#### 5.3.2 Navigation Items
- Container: `flex-1 py-4 px-3 space-y-1 overflow-y-auto`
- Each nav item is a `<Link>` with: `flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors`

**Navigation items (5 total):**

| # | Path | Label | Icon (Lucide) | Badge |
|---|------|-------|---------------|-------|
| 1 | `/` | Dashboard | LayoutDashboard | — |
| 2 | `/tickets` | Ticket Queue | Ticket | Shows open ticket count (blue pill badge) |
| 3 | `/tickets/create` | Create Ticket | PlusCircle | — |
| 4 | `/services` | Service Catalogue | BookOpen | — |
| 5 | `/reports` | Reports | BarChart3 | — |

**Active state**: `bg-blue-600 text-white`
**Inactive state**: `text-slate-300 hover:bg-slate-800 hover:text-white`

**Active detection logic**:
- For `/` (Dashboard): exact match `pathname === "/"`
- For all others: starts-with match `pathname.startsWith(item.path)`

**Badge on "Ticket Queue"**: 
- Shows count of tickets where status is NOT "Resolved" or "Closed"
- Style: `ml-auto bg-blue-500 hover:bg-blue-500 text-white text-[10px] px-1.5 py-0`
- Only shown when count > 0

#### 5.3.3 Sidebar Footer (User Info)
- Container: `px-4 py-4 border-t border-slate-700`
- Avatar: `w-8 h-8 rounded-full bg-slate-600 flex items-center justify-center text-xs font-bold` — displays "AD"
- Name: `text-xs font-medium` — "Admin User"
- Role: `text-[10px] text-slate-400` — "Operations Manager"

### 5.4 Top Bar (Header)

- Container: `h-14 bg-white border-b border-slate-200 flex items-center px-4 gap-3 shrink-0`
- Height: 56px (h-14)
- Background: white
- Border bottom: 1px `border-slate-200`

**Elements (left to right):**

1. **Hamburger button** (mobile only): `lg:hidden text-slate-600 hover:text-slate-900` — Menu icon (22px)
2. **Search input**: 
   - Container: `relative flex-1 max-w-md`
   - Search icon: `absolute left-3 top-1/2 -translate-y-1/2 text-slate-400` (16px)
   - Input: `pl-9 h-9 text-sm bg-slate-50 border-slate-200`
   - Placeholder: "Search tickets, services..."
3. **Notification bell** (right side):
   - Container: `ml-auto flex items-center gap-2`
   - Button: `variant="ghost" size="icon"`
   - Bell icon: 18px, `text-slate-600`
   - Red dot indicator: `absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full` — shown when SLA breach count > 0

### 5.5 Main Content Area
- Container: `flex-1 overflow-y-auto p-4 md:p-6`
- Padding: 16px on mobile, 24px on md+
- Scrollable vertically

---

## 6. Page 1: Dashboard (/)

**Route**: `/`
**Controller Action**: `HomeController.Index()`
**View**: `Views/Home/Index.cshtml`

### 6.1 Page Header
```html
<h1 class="text-2xl font-bold text-slate-900">Dashboard</h1>
<p class="text-sm text-slate-500 mt-1">Overview of ticketing operations — April 15, 2026</p>
```

### 6.2 KPI Cards Row (4 cards)

**Grid**: `grid grid-cols-2 lg:grid-cols-4 gap-4`
- 2 columns on mobile, 4 on large screens
- Gap: 16px

Each KPI card structure:
```
Card with border-l-4 border-l-{color}
  └── CardContent p-4
       └── flex items-center justify-between
            ├── div (left)
            │    ├── p.text-xs.text-slate-500.font-medium.uppercase.tracking-wide → label
            │    └── p.text-3xl.font-bold.text-slate-900.mt-1 → value
            └── div.w-10.h-10.rounded-lg.bg-{color}-50.flex.items-center.justify-center (right)
                 └── Icon (20px) text-{color}-600
```

**4 KPI Cards:**

| # | Label | Value Source | Left Border | Icon | Icon Color | Value Color |
|---|-------|-------------|-------------|------|-----------|-------------|
| 1 | "Active Tickets" | Count of tickets NOT Resolved/Closed | `border-l-blue-500` | Ticket (20px) | `text-blue-600` on `bg-blue-50` | `text-slate-900` |
| 2 | "SLA Breaches" | Count of tickets where slaBreached=true | `border-l-red-500` | AlertTriangle (20px) | `text-red-500` on `bg-red-50` | `text-red-600` |
| 3 | "Resolved Today" | Count of tickets resolved today | `border-l-green-500` | CheckCircle2 (20px) | `text-green-600` on `bg-green-50` | `text-slate-900` |
| 4 | "Avg Resolution" | Hardcoded "14h" + subtitle "840 min avg" | `border-l-indigo-500` | Clock (20px) | `text-indigo-600` on `bg-indigo-50` | `text-slate-900` |

Card 4 has extra subtitle: `text-[10px] text-slate-400` showing "840 min avg"

### 6.3 Middle Row (3-column grid)

**Grid**: `grid lg:grid-cols-3 gap-6`

#### 6.3.1 Tickets by Status (left, 1 column)

**Card**: `lg:col-span-1`
- **Header**: `text-sm font-semibold` → "Tickets by Status"
- **Content**: `space-y-2`

For each of the 8 statuses, render a row:
```
flex items-center gap-3
  ├── Status Icon (18px) — see icon mapping below
  ├── span.text-sm.text-slate-700.flex-1 → status display label
  ├── Progress bar container: w-24 h-2 bg-slate-100 rounded-full overflow-hidden
  │    └── Inner bar: h-full bg-blue-500 rounded-full, width = (count/total)*100%
  └── span.text-sm.font-semibold.text-slate-900.w-6.text-right → count number
```

**Status Icons:**

| Status | Icon | Color Class |
|--------|------|-------------|
| Open | Ticket (18px) | `text-blue-600` |
| Assigned | ArrowRightLeft (18px) | `text-indigo-600` |
| InProgress | Activity (18px) | `text-yellow-600` |
| Paused | Pause (18px) | `text-gray-500` |
| Resolved | CheckCircle2 (18px) | `text-green-600` |
| Closed | CheckCircle2 (18px) | `text-slate-500` |
| PendingArbitration | AlertTriangle (18px) | `text-orange-600` |
| PendingClarification | HelpCircle (18px) | `text-purple-600` |

#### 6.3.2 Recent Activity (right, 2 columns)

**Card**: `lg:col-span-2`
- **Header**: `text-sm font-semibold flex items-center gap-2` with TrendingUp icon (16px) → "Recent Activity"
- **Content**: `space-y-3`

Gathers ALL history entries from ALL tickets, sorts by date descending, takes first 8.

Each activity row:
```
flex items-start gap-3 pb-3 border-b border-slate-100 last:border-0 last:pb-0
  ├── div.w-2.h-2.rounded-full.bg-blue-500.mt-2.shrink-0 → blue dot indicator
  ├── div.flex-1.min-w-0 (content)
  │    ├── p.text-sm.text-slate-800
  │    │    ├── span.font-semibold → action name (e.g. "Ticket Created")
  │    │    ├── " — "
  │    │    └── Link to /tickets/{id} → ticket number (text-blue-600 hover:underline)
  │    ├── p.text-xs.text-slate-500.mt-0.5.truncate → notes
  │    └── p.text-[10px].text-slate-400.mt-0.5 → "{performer} · {formatted date}"
  └── Badge (if newStatus exists) → text-[10px] with statusColors[newStatus]
```

### 6.4 Bottom Row (2-column grid)

**Grid**: `grid lg:grid-cols-2 gap-6`

#### 6.4.1 Tickets by Department (left)

- **Header**: "Tickets by Department"
- **Content**: `space-y-3`
- Sorted by count descending

Each department row:
```
flex items-center gap-3
  ├── span.text-sm.text-slate-700.flex-1 → department name
  ├── Progress bar: w-32 h-3 bg-slate-100 rounded-full overflow-hidden
  │    └── Inner bar: h-full bg-indigo-500 rounded-full, width = (count/total)*100%
  └── span.text-sm.font-semibold.text-slate-900.w-6.text-right → count
```

#### 6.4.2 Service Frequency (right)

- **Header**: "Service Frequency"
- **Content**: `space-y-3`
- Shows top 6 services, sorted by frequency descending

Each service row:
```
flex items-center gap-3
  ├── span.text-xs.font-mono.text-slate-400.w-4 → "{index}."
  ├── span.text-sm.text-slate-700.flex-1.truncate → service name
  └── Badge variant="secondary" text-xs → "{count} ticket(s)"
```

### 6.5 Priority Overview (full width)

- **Header**: "Active Tickets by Priority"
- **Content Grid**: `grid grid-cols-2 md:grid-cols-4 gap-4`

For each priority (Critical, High, Medium, Low):
```
div.rounded-lg.border.p-4.text-center.{priorityColors[priority]}
  ├── p.text-2xl.font-bold → count of active tickets with this priority
  └── p.text-xs.font-medium.mt-1 → priority name
```

"Active" = status NOT in ["Resolved", "Closed"]

---

## 7. Page 2: Ticket Queue (/tickets)

**Route**: `/tickets`
**Controller Action**: `TicketsController.Index()`
**View**: `Views/Tickets/Index.cshtml`

### 7.1 Page Header
```
<h1 class="text-2xl font-bold text-slate-900">Ticket Queue</h1>
<p class="text-sm text-slate-500 mt-1">{filtered count} of {total count} tickets</p>
```

### 7.2 Filter Bar

**Container**: `flex flex-col sm:flex-row gap-3`

3 filter controls:

1. **Search Input** (flex-1):
   - Container: `relative flex-1`
   - Search icon: `absolute left-3 top-1/2 -translate-y-1/2 text-slate-400` (16px)
   - Input: `pl-9 h-9 text-sm`
   - Placeholder: "Search by ticket #, title, requester, service..."
   - Searches: ticketNo, title, requesterName, serviceName (case-insensitive)

2. **Status Dropdown** (`w-full sm:w-48 h-9 text-sm`):
   - Default: "All Statuses"
   - Options: All 8 status labels + "All Statuses"

3. **Priority Dropdown** (`w-full sm:w-40 h-9 text-sm`):
   - Default: "All Priorities"
   - Options: Critical, High, Medium, Low + "All Priorities"

### 7.3 Ticket Table

**Card wrapping a Table** with `p-0` content padding.

**10 Columns:**

| # | Header | Width | Content |
|---|--------|-------|---------|
| 1 | Ticket # | `w-32` | Link to `/tickets/{id}`, `font-mono text-xs text-blue-600 hover:underline font-medium` |
| 2 | Title | — | `text-sm font-medium text-slate-800 truncate`, max-width 200px |
| 3 | Service | — | `text-sm text-slate-600`. If isOtherService: `italic text-orange-600` showing "Other" |
| 4 | Requester | — | Name: `text-sm text-slate-700`, Type below: `text-[10px] text-slate-400` |
| 5 | Priority | — | Badge with `text-[10px]` + priorityColors |
| 6 | Status | — | Badge with `text-[10px]` + statusColors |
| 7 | SLA | — | If breached: red AlertTriangle icon (13px) + "Breached" (`text-red-600 text-xs font-semibold`). If resolved/closed: "—" (`text-xs text-slate-400`). Else: formatted remaining time (`text-xs text-slate-600`) |
| 8 | Assigned | — | `text-sm text-slate-600` or "Unassigned" (`text-slate-400 text-xs`) |
| 9 | Created | `w-20` | `text-xs text-slate-500`, formatted date |
| 10 | (action) | `w-10` | Ghost button with ExternalLink icon (14px, `text-slate-400`), links to detail |

**Table row**: `hover:bg-slate-50`

**Empty state**: `colSpan={10} text-center py-10 text-slate-400` → "No tickets match your filters"

---

## 8. Page 3: Ticket Detail (/tickets/:id)

**Route**: `/tickets/:id`
**Controller Action**: `TicketsController.Detail(int id)`
**View**: `Views/Tickets/Detail.cshtml`

### 8.1 Not Found State

If ticket not found:
```
flex items-center justify-center h-64
  └── text-center
       ├── p.text-slate-500.text-lg → "Ticket not found"
       └── Link to /tickets → "Back to Ticket Queue" (text-blue-600 hover:underline text-sm)
```

### 8.2 Header Section

**Container**: `flex flex-col sm:flex-row sm:items-center gap-3`

- **Back link**: `flex items-center gap-1 text-sm text-slate-500 hover:text-slate-700` with ArrowLeft icon (16px) → "Back"
- **Title area** (flex-1):
  - Row: `flex items-center gap-3 flex-wrap`
    - `h1.text-xl.font-bold.text-slate-900` → ticket number
    - Status Badge with statusColors
    - Priority Badge with priorityColors
    - If slaBreached: `Badge bg-red-600 text-white hover:bg-red-600` with AlertTriangle (12px) → "SLA Breached"
    - If isParentBlocked: `Badge bg-amber-500 text-white hover:bg-amber-500` with Pause (12px) → "Blocked"
  - `h2.text-base.text-slate-600.mt-1` → ticket title

### 8.3 Action Buttons Bar

Only shown when ticket is active (status NOT "Resolved" or "Closed").

**Card with CardContent p-3**, containing `flex flex-wrap gap-2`.

**Conditional action buttons based on status:**

| Current Status | Button | Icon | Label | Color |
|---------------|--------|------|-------|-------|
| Open | ActionButton | UserPlus (14px) | "Assign" | blue |
| Assigned | ActionButton | Play (14px) | "Start Work" | green |
| InProgress | ActionButton | Pause (14px) | "Pause" | gray |
| InProgress | ActionButton | CheckCircle2 (14px) | "Resolve" | green |
| Paused | ActionButton | Play (14px) | "Resume" | blue |
| Resolved + requiresQualityReview | ActionButton | ShieldCheck (14px) | "Quality Review" | indigo |

**Always-available dialog buttons (when active):**

| Button | Icon | Label | Color | Dialog Title | Dialog Description |
|--------|------|-------|-------|-------------|-------------------|
| DialogButton | GitBranch (14px) | "Create Child Ticket" | purple | "Create Child Ticket" | "This will create a dependent child ticket linked to this parent." |
| DialogButton | MessageSquare (14px) | "Request Clarification" | amber | "Request Clarification" | "Request missing information from the requester or another unit." |
| DialogButton | Scale (14px) | "Raise Arbitration" | red | "Raise Arbitration Case" | "Dispute the scope/routing of this ticket. This will be sent to an arbitrator." |

**ActionButton style**: `h-8 text-xs gap-1.5` + color class
**Color map:**
```
blue:   "bg-blue-600 hover:bg-blue-700 text-white"
green:  "bg-green-600 hover:bg-green-700 text-white"
gray:   "bg-slate-200 hover:bg-slate-300 text-slate-700"
indigo: "bg-indigo-600 hover:bg-indigo-700 text-white"
purple: "bg-purple-600 hover:bg-purple-700 text-white"
amber:  "bg-amber-500 hover:bg-amber-600 text-white"
red:    "bg-red-600 hover:bg-red-700 text-white"
```

**DialogButton**: Opens a modal dialog with:
- DialogHeader with title
- Description paragraph: `text-sm text-slate-500`
- Textarea: `placeholder="Add notes or details..." rows={4}`
- Footer: `flex justify-end gap-2`
  - Cancel button: `variant="outline" size="sm"`
  - Submit button: `size="sm"` with matching color + ChevronRight icon (14px)

### 8.4 Main Content (3-column grid)

**Grid**: `grid lg:grid-cols-3 gap-5`

#### LEFT COLUMN (lg:col-span-2, space-y-5)

##### 8.4.1 Description Card
- **Header**: "Description"
- **Content**: `text-sm text-slate-700 leading-relaxed` → ticket description text

##### 8.4.2 Related Tickets Card (conditional)
Only shown if parentTicket exists OR childTickets.length > 0.

- **Header**: `text-sm font-semibold flex items-center gap-2` with GitBranch icon (15px) → "Related Tickets"

**Parent ticket row** (if exists):
```
flex items-center gap-3 p-2 bg-blue-50 rounded-lg
  ├── span.text-[10px].uppercase.font-bold.text-blue-600.bg-blue-100.px-2.py-0.5.rounded → "Parent"
  ├── Link → parent ticketNo (text-sm text-blue-600 hover:underline font-mono)
  ├── span.text-sm.text-slate-600.truncate.flex-1 → parent title
  └── Badge with statusColors → parent status
```

**Child ticket rows** (for each child):
```
flex items-center gap-3 p-2 bg-purple-50 rounded-lg
  ├── span.text-[10px].uppercase.font-bold.text-purple-600.bg-purple-100.px-2.py-0.5.rounded → "Child"
  ├── Link → child ticketNo
  ├── span.text-sm.text-slate-600.truncate.flex-1 → child title
  └── Badge with statusColors → child status
```

##### 8.4.3 Arbitration Cases Card (conditional)
Only shown if arbitration cases exist for this ticket.

- **Card**: `border-orange-200`
- **Header**: `text-sm font-semibold flex items-center gap-2 text-orange-700` with Scale icon (15px) → "Arbitration Cases"

Each case:
```
div.p-3.bg-orange-50.rounded-lg.text-sm.space-y-2
  ├── Row: flex items-center justify-between
  │    ├── span.font-semibold.text-orange-800 → "Case #{id}"
  │    └── Badge → status (Open: bg-orange-200 text-orange-800, else: bg-green-100 text-green-800)
  ├── p.text-slate-600 → reason
  ├── Row: flex gap-4 text-xs text-slate-500
  │    ├── "Raised by: {raisedBy}"
  │    ├── "Arbitrator: {arbitrator}"
  │    └── "Opened: {formatted date}"
  └── (if decision): p.text-sm.font-medium.text-green-700 → "Decision: {decision} → {decisionTarget}"
```

##### 8.4.4 Clarification Requests Card (conditional)
Only shown if clarification requests exist.

- **Card**: `border-purple-200`
- **Header**: `text-sm font-semibold flex items-center gap-2 text-purple-700` with MessageSquare icon (15px) → "Clarification Requests"

Each request:
```
div.p-3.bg-purple-50.rounded-lg.text-sm.space-y-2
  ├── Row: flex items-center justify-between
  │    ├── span.font-semibold.text-purple-800 → "Request #{id}"
  │    └── Badge → status
  │         Open: bg-purple-200 text-purple-800
  │         Responded: bg-blue-100 text-blue-800
  │         Closed: bg-green-100 text-green-800
  ├── p.text-slate-600 → "Reason: {reason}" (with span.font-medium for "Reason:")
  ├── p.text-slate-700.bg-white.p-2.rounded.border.border-purple-100 → requestNotes
  ├── (if responseNotes): p.text-slate-700.bg-green-50.p-2.rounded.border.border-green-100
  │    └── span.font-medium.text-green-700 "Response: " + responseNotes
  └── Row: flex gap-4 text-xs text-slate-500 → "From: {requestedBy}", "To: {targetUser}", "{date}"
```

##### 8.4.5 Quality Reviews Card (conditional)
Only shown if quality reviews exist.

- **Card**: `border-indigo-200`
- **Header**: `text-sm font-semibold flex items-center gap-2 text-indigo-700` with ShieldCheck icon (15px) → "Quality Reviews"

Each review:
```
div.p-3.bg-indigo-50.rounded-lg.text-sm.space-y-2
  ├── Row: flex items-center justify-between
  │    ├── span.font-semibold.text-indigo-800 → "Review #{id}"
  │    └── Badge → result
  │         null/Pending: bg-indigo-200 text-indigo-800 → "Pending"
  │         Approved: bg-green-100 text-green-800
  │         ReturnedForCorrection/Rejected: bg-red-100 text-red-800
  ├── p.text-slate-600 → notes
  └── Row: flex gap-4 text-xs text-slate-500 → "Reviewer: {reviewer}", "{date}"
```

##### 8.4.6 Audit Trail Card (always shown)

- **Header**: `text-sm font-semibold flex items-center gap-2` with Clock icon (15px) → "Audit Trail"

**Timeline structure**:
```
div.relative.pl-6
  ├── Vertical line: absolute left-2 top-2 bottom-2 w-0.5 bg-slate-200
  └── For each history entry:
       div.relative.pb-5.last:pb-0
         ├── Dot: absolute left-[-18px] w-3 h-3 rounded-full border-2 border-white
         │    Last entry: bg-blue-500, others: bg-slate-300
         └── Content div:
              ├── Row: flex items-center gap-2 flex-wrap
              │    ├── span.text-sm.font-semibold.text-slate-800 → action
              │    └── (if newStatus): Badge text-[10px] with statusColors
              ├── p.text-xs.text-slate-500.mt-0.5 → notes
              └── p.text-[10px].text-slate-400.mt-1 → "{performer} · {formatted datetime}"
```

**Empty state**: `text-sm text-slate-400 text-center py-4` → "No history entries available for this ticket"

#### RIGHT COLUMN (space-y-5)

##### 8.4.7 Ticket Information Card

- **Header**: "Ticket Information"
- **Content**: `space-y-3 text-sm`

Uses `InfoRow` component for each field:
```
flex items-center justify-between
  ├── span.text-slate-500.text-xs → label
  └── span.font-medium.text-right.text-slate-800 → value
       (if muted: text-slate-400 italic)
```

**Fields in order:**
1. Service → serviceName (or "Other (Manual)" if isOtherService)
2. Requester → requesterName
3. Requester Type → requesterType
4. `<Separator />` (horizontal line)
5. Department → department
6. Division → division
7. Section → section
8. Current Queue → currentQueue
9. `<Separator />`
10. Assigned To → assignedUser or "Unassigned" (muted)
11. `<Separator />`
12. **Location row** (special layout):
```
flex items-start gap-2
  ├── MapPin icon (14px) text-slate-400 mt-0.5 shrink-0
  └── div
       ├── p.text-[10px].text-slate-400.uppercase → "Location"
       └── p.text-slate-700 → location text
```

##### 8.4.8 SLA Status Card

- **Header**: "SLA Status"

**SLA display box**:
```
div.p-3.rounded-lg.text-center
  If breached: bg-red-50 border border-red-200
  If not breached: bg-green-50 border border-green-200

  ├── p.text-[10px].uppercase.font-semibold.text-slate-500 → "Completion SLA"
  ├── p.text-xl.font-bold.mt-1
  │    If breached: text-red-600
  │    If not: text-green-700
  │    Value: If Resolved/Closed → "Completed", else → formatMinutes(slaCompletionRemainMin)
  └── (if breached): p.text-xs.text-red-500.mt-1.flex.items-center.justify-center.gap-1
       └── AlertTriangle (12px) + "SLA Breached"
```

##### 8.4.9 Pause Sessions Card (conditional)
Only shown if pause sessions exist.

- **Card**: `border-amber-200`
- **Header**: `text-sm font-semibold flex items-center gap-2 text-amber-700` with Pause icon (14px) → "Pause Sessions"

Each session:
```
div.p-2.bg-amber-50.rounded.text-xs.space-y-1
  ├── Row: flex items-center justify-between
  │    ├── span.font-semibold.text-amber-800 → reason (CamelCase split with spaces)
  │    └── Badge: if ended → bg-green-100 text-green-700 "Ended", else → bg-amber-200 text-amber-800 "Active"
  ├── p.text-slate-600 → notes
  └── p.text-slate-400 → "Started: {formatted datetime}"
```

**Reason display**: CamelCase is split by inserting space before uppercase letters.
Example: "ChildDependency" → "Child Dependency"

##### 8.4.10 Dates Card

- **Header**: "Dates"
- **Content**: `space-y-2 text-sm`

InfoRow items:
1. "Created" → formatDateTime(createdAt)
2. "Last Updated" → formatDateTime(updatedAt)
3. (if resolvedAt): "Resolved" → formatDateTime(resolvedAt)
4. (if closedAt): "Closed" → formatDateTime(closedAt)

---

## 9. Page 4: Create Ticket (/tickets/create)

**Route**: `/tickets/create`
**Controller Action**: `TicketsController.Create()` (GET) + `TicketsController.Create(model)` (POST)
**View**: `Views/Tickets/Create.cshtml`

### 9.1 Success State

After submission, shows a centered success card:
```
flex items-center justify-center h-[60vh]
  └── Card max-w-md w-full text-center
       └── CardContent py-10 space-y-4
            ├── Green circle: w-16 h-16 rounded-full bg-green-100 flex items-center justify-center mx-auto
            │    └── CheckCircle2 (32px) text-green-600
            ├── h2.text-xl.font-bold.text-slate-900 → "Ticket Created!"
            ├── p.text-sm.text-slate-500 → "Your ticket has been submitted successfully. Ticket number: "
            │    └── span.font-mono.font-bold.text-blue-600 → "TKT-2026-0011"
            ├── (if isOther): Warning box
            │    flex items-center gap-2 justify-center text-xs text-orange-600 bg-orange-50 p-2 rounded
            │    └── AlertCircle (14px) + "This ticket will be routed to an arbitrator for classification."
            └── Button row: flex gap-3 justify-center pt-2
                 ├── Link to /tickets → Button variant="outline" size="sm" → "View Queue"
                 └── Button size="sm" onClick=reset → "Create Another"
```

### 9.2 Form Layout

**Container**: `max-w-2xl mx-auto space-y-5`

#### 9.2.1 Form Header
```
flex items-center gap-3
  ├── Back link → ArrowLeft (16px) + "Back" (same style as ticket detail)
  └── div
       ├── h1.text-2xl.font-bold.text-slate-900 → "Create New Ticket"
       └── p.text-sm.text-slate-500.mt-0.5 → "Submit a new service request or report an issue"
```

#### 9.2.2 Card: Requester Type
- **Header**: "Requester Type"
- **Content**: RadioGroup with `flex gap-4`
  - Option 1: value="Resident", label="Resident / Beneficiary"
  - Option 2: value="Internal", label="Internal User"
  - Each: `flex items-center space-x-2` with RadioGroupItem + Label (`text-sm cursor-pointer`)

#### 9.2.3 Card: Requester Information
- **Header**: "Requester Information"
- **Content**: `space-y-4`
  - Label: `text-xs text-slate-500` → "Full Name" (if Resident) or "Employee Name" (if Internal)
  - Input with placeholder: "Enter resident name" or "Enter employee name", `mt-1`

#### 9.2.4 Card: Service Selection
- **Header**: "Service"
- **Content**: `space-y-4`
  - Label: `text-xs text-slate-500` → "Select Service"
  - Select dropdown (`mt-1`):
    - Placeholder: "Choose a service..."
    - Options: All active services formatted as "{nameEn} — {department}"
    - Last option: value="other" → "⚠️ Other (describe manually)"
  
  - **If "Other" selected**: Warning box
    ```
    flex items-center gap-2 text-xs text-orange-600 bg-orange-50 p-3 rounded-lg
      └── AlertCircle (14px shrink-0) + "This ticket will be sent to an arbitrator for classification and routing."
    ```
  
  - **If a real service selected**: Auto-routing info box
    ```
    div.bg-slate-50.rounded-lg.p-3.text-xs.space-y-1
      ├── p.font-semibold.text-slate-700 → "Auto-routing: {department} → {division} → {section}"
      └── p.text-slate-500 → "Default Priority: {priority} · SLA Completion: {hours}h"
    ```

#### 9.2.5 Card: Ticket Details
- **Header**: "Ticket Details"
- **Content**: `space-y-4`
  1. **Title**: Label "Title" (`text-xs text-slate-500`), Input placeholder "Brief summary of the issue" (`mt-1`)
  2. **Description**: Label "Description", Textarea placeholder "Provide detailed description of the issue or request..." rows=4 (`mt-1`)
  3. **Two-column grid**: `grid grid-cols-2 gap-4`
     - **Priority**: Label "Priority", Select dropdown (`mt-1`) with options: Critical, High, Medium, Low. Default: "Medium"
     - **Location**: Label "Location", Input placeholder "Building, floor, room..." (`mt-1`)

#### 9.2.6 Submit Row
```
flex items-center justify-between pb-8
  ├── Link to /tickets → Button variant="outline" → "Cancel"
  └── Button onClick=handleSubmit disabled={!canSubmit} className="gap-2"
       └── Send icon (15px) + "Submit Ticket"
```

**canSubmit logic**: title.trim() AND description.trim() AND requesterName.trim() AND serviceId is selected

---

## 10. Page 5: Service Catalogue (/services)

**Route**: `/services`
**Controller Action**: `ServicesController.Index()`
**View**: `Views/Services/Index.cshtml`

### 10.1 Page Header Row

```
flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3
  ├── div
  │    ├── h1.text-2xl.font-bold.text-slate-900 → "Service Catalogue"
  │    └── p.text-sm.text-slate-500.mt-1 → "{total} services · {active count} active"
  └── Search input (w-full sm:w-72):
       relative container with Search icon + Input pl-9 h-9 text-sm
       placeholder: "Search services..."
```

Search filters by: nameEn, code, department (case-insensitive)

### 10.2 Service Table

**Card with Table, p-0 content.**

**7 Columns:**

| # | Header | Content |
|---|--------|---------|
| 1 | Code (`w-24`) | `font-mono text-xs text-slate-500` → service code |
| 2 | Service Name | `font-medium text-sm` → nameEn |
| 3 | Department | `text-sm text-slate-600` → department |
| 4 | Division / Section | `text-sm text-slate-600` → "{division} / {section}" |
| 5 | Priority | Badge `text-[10px]` + priorityColors → defaultPriority |
| 6 | Status (text-center) | If active: CheckCircle icon (16px) `text-green-500 inline`. If inactive: XCircle icon (16px) `text-slate-400 inline` |
| 7 | Actions (`text-center w-20`) | Ghost button `h-8 w-8` with Eye icon (15px) `text-slate-500` → opens detail dialog |

**Table row**: `hover:bg-slate-50`
**Empty state**: `colSpan={7} text-center py-10 text-slate-400` → "No services found"

### 10.3 Service Detail Dialog (Modal)

Triggered by clicking the Eye button on any service row.

**Dialog** (`max-w-lg`):
- **Header**: 
  ```
  flex items-center gap-2
    ├── span.font-mono.text-sm.text-slate-400 → service code
    └── service nameEn
  ```

**Content** (`space-y-5`):

#### Card 1: Default Routing Rule
- **Header**: `text-xs font-semibold uppercase tracking-wide text-slate-500` → "Default Routing Rule"
- **Content**: `grid grid-cols-3 gap-3 text-sm`
  - Column 1: Label `text-[10px] text-slate-400 uppercase` "Department", Value `font-medium`
  - Column 2: Label "Division", Value
  - Column 3: Label "Section", Value

#### Card 2: SLA Policy
- **Header**: `text-xs font-semibold uppercase tracking-wide text-slate-500` → "SLA Policy (Default Priority: {priority})"
- **Content**: `grid grid-cols-2 gap-3 text-sm`

4 SLA metric boxes:

| # | Label | Color | Value |
|---|-------|-------|-------|
| 1 | "First Response" | `bg-blue-50`, label `text-blue-600`, value `text-blue-800` | formatMinutes(slaResponseMin) |
| 2 | "Assignment" | `bg-indigo-50`, label `text-indigo-600`, value `text-indigo-800` | formatMinutes(slaAssignMin) |
| 3 | "Completion" | `bg-yellow-50`, label `text-yellow-700`, value `text-yellow-800` | formatMinutes(slaCompletionMin) |
| 4 | "Final Closure" | `bg-green-50`, label `text-green-600`, value `text-green-800` | formatMinutes(slaClosureMin) |

Each box structure:
```
div.rounded-lg.p-3.text-center.bg-{color}-50
  ├── p.text-[10px].text-{color}-600.uppercase.font-semibold → label
  └── p.text-lg.font-bold.text-{color}-800 → formatted value
```

#### Footer row:
```
flex items-center justify-between text-xs text-slate-400
  ├── "Status: " + (Active: text-green-600 font-medium, Inactive: text-slate-500 font-medium)
  └── "ID: {id}"
```

---

## 11. Page 6: Reports & Analytics (/reports)

**Route**: `/reports`
**Controller Action**: `ReportsController.Index()`
**View**: `Views/Reports/Index.cshtml`

### 11.1 Page Header
```
h1.text-2xl.font-bold.text-slate-900 → "Reports & Analytics"
p.text-sm.text-slate-500.mt-1 → "Operational insights and performance metrics"
```

### 11.2 Summary KPI Row (5 cards)

**Grid**: `grid grid-cols-2 lg:grid-cols-5 gap-4`

Uses `MiniKPI` component:
```
Card with border-l-4 border-l-{color}-500
  └── CardContent p-3 flex items-center gap-3
       ├── Icon container: w-8 h-8 rounded-lg flex items-center justify-center bg-{color}-50 text-{color}-600
       │    └── icon (16px)
       └── div
            ├── p.text-xl.font-bold.text-{valueColor} → value
            └── p.text-[10px].text-slate-500.uppercase.tracking-wide → label
```

**5 KPI Cards:**

| # | Label | Value | Icon | Color | Value Color |
|---|-------|-------|------|-------|-------------|
| 1 | "Total Tickets" | total count | BarChart3 | blue | text-slate-900 |
| 2 | "SLA Breaches" | breached count | AlertTriangle | red | text-red-600 |
| 3 | "Near Overdue" | overdue count (active + slaCompletionRemainMin < 240) | Clock | amber | text-amber-600 |
| 4 | "Open Arbitrations" | open arbitration count | Scale | orange | text-orange-600 |
| 5 | "Open Clarifications" | open clarification count | MessageSquare | purple | text-purple-600 |

### 11.3 Two-Column Charts

**Grid**: `grid lg:grid-cols-2 gap-6`

#### 11.3.1 Ticket Status Distribution (left)

- **Header**: TrendingUp icon (15px) + "Ticket Status Distribution"

For each of 8 statuses:
```
flex items-center gap-3
  ├── span.text-xs.text-slate-600.w-32.truncate → status label
  └── Bar container: flex-1 h-6 bg-slate-100 rounded overflow-hidden relative
       ├── Bar: h-full rounded {statusBarColor}, width = (count/maxCount)*100%
       └── (if count > 0): span.absolute.inset-0.flex.items-center.pl-2.text-[11px].font-bold.text-white.mix-blend-difference → count
```

#### 11.3.2 Service Request Frequency (right)

- **Header**: "Service Request Frequency"

For each service (all, sorted by frequency):
```
flex items-center gap-3
  ├── span.text-xs.font-mono.text-slate-400.w-5 → "{index}."
  ├── span.text-xs.text-slate-600.w-40.truncate → service name
  ├── Bar: flex-1 h-5 bg-slate-100 rounded overflow-hidden
  │    └── Inner: h-full bg-indigo-500 rounded, width = (count/maxCount)*100%
  └── span.text-xs.font-bold.text-slate-700.w-6.text-right → count
```

### 11.4 Department Workload Table

**Card with Table, p-0 content.**

**5 Columns:**

| Header | Content |
|--------|---------|
| Department | `font-medium text-sm` |
| Total (text-center) | `text-sm` → total ticket count |
| Active (text-center) | `text-sm` → active (non-resolved/closed) count |
| SLA Breached (text-center) | If > 0: Badge `bg-red-100 text-red-700` with count. If 0: `text-slate-400 text-sm` "0" |
| Health (text-center) | 0 breaches: Badge `bg-green-100 text-green-700` "Healthy". 1 breach: Badge `bg-yellow-100 text-yellow-700` "Warning". 2+: Badge `bg-red-100 text-red-700` "Critical" |

Sorted by total count descending.

### 11.5 Overdue & At-Risk Tickets Table

- **Card Header**: `text-sm font-semibold flex items-center gap-2 text-amber-700` with Clock icon (15px) → "Overdue & At-Risk Tickets"
- **Filter**: Active tickets where slaCompletionRemainMin < 240

**7 Columns:**

| Header | Content |
|--------|---------|
| Ticket # | `font-mono text-xs text-blue-600 font-medium` |
| Title | `text-sm max-w-[200px] truncate` |
| Priority | Badge `text-[10px]` + priorityColors |
| Status | Badge `text-[10px]` + statusColors |
| SLA Remaining | If slaCompletionRemainMin <= 0: `text-red-600 text-xs font-semibold` with AlertTriangle (12px) + "Breached". Else: `text-amber-600 text-xs font-semibold` + formatMinutes |
| Department | `text-sm text-slate-600` |
| Created | `text-xs text-slate-500` + formatDate |

**Row highlight**: If slaBreached → `bg-red-50`
**Empty state**: `colSpan={7} text-center py-8 text-slate-400` → "No overdue or at-risk tickets"

### 11.6 SLA Breached Tickets Section (conditional)

Only shown if breached tickets exist.

- **Card**: `border-red-200`
- **Header**: `text-sm font-semibold flex items-center gap-2 text-red-700` with AlertTriangle (15px) → "SLA Breached Tickets"

Each breached ticket:
```
flex items-center gap-3 p-3 bg-red-50 rounded-lg
  ├── span.font-mono.text-xs.text-red-700.font-bold → ticketNo
  ├── span.text-sm.text-slate-700.flex-1.truncate → title
  ├── Badge text-[10px] + priorityColors → priority
  ├── Badge text-[10px] + statusColors → status
  └── span.text-xs.text-slate-500 → department
```

---

## 12. Reusable UI Components

### 12.1 Component Library (Shadcn/ui equivalents needed)

| Component | Usage | C# MVC Equivalent |
|-----------|-------|--------------------|
| Card, CardContent, CardHeader, CardTitle | Everywhere | `<div class="card">` with Bootstrap or custom CSS |
| Badge | Status/priority pills | `<span class="badge">` |
| Button | Actions, navigation | `<button>` or `<a>` with classes |
| Input | Search, form fields | `<input class="form-control">` |
| Label | Form labels | `<label>` |
| Textarea | Description, notes | `<textarea>` |
| Select, SelectContent, SelectItem, SelectTrigger, SelectValue | Dropdowns | `<select class="form-select">` |
| RadioGroup, RadioGroupItem | Requester type | `<input type="radio">` |
| Table, TableBody, TableCell, TableHead, TableHeader, TableRow | Data tables | `<table class="table">` |
| Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger | Modals | Bootstrap modal or custom |
| Separator | Horizontal dividers | `<hr>` |
| Tooltip, TooltipProvider | Hover tips | Bootstrap tooltip |

### 12.2 Icon Library (Lucide Icons Used)

All icons from `lucide-react`. For C# MVC, use Lucide SVGs or Bootstrap Icons.

**Icons used across the app:**

| Icon Name | Size(s) Used | Where |
|-----------|-------------|-------|
| LayoutDashboard | 18px | Sidebar nav |
| BookOpen | 18px | Sidebar nav |
| Ticket | 18px, 20px | Sidebar nav, Dashboard KPI, Status icon |
| PlusCircle | 18px | Sidebar nav |
| BarChart3 | 18px, 16px | Sidebar nav, Reports KPI |
| Menu | 22px | Mobile hamburger |
| X | 20px | Mobile sidebar close |
| Bell | 18px | Top bar notification |
| Search | 16px | Search inputs |
| AlertTriangle | 12px, 13px, 15px, 18px, 20px | SLA breach indicators |
| Clock | 15px, 16px, 20px | Time/SLA indicators |
| CheckCircle2 | 14px, 18px, 20px, 32px | Resolved/success indicators |
| Pause | 12px, 14px, 18px | Paused status |
| ArrowRightLeft | 18px | Assigned status icon |
| HelpCircle | 18px | Pending clarification icon |
| TrendingUp | 16px | Recent activity header |
| Activity | 18px | In Progress status icon |
| ArrowLeft | 16px | Back navigation |
| User | — | (imported but used contextually) |
| MapPin | 14px | Location display |
| UserPlus | 14px | Assign action |
| Play | 14px | Start Work / Resume |
| GitBranch | 14px, 15px | Child ticket / Related tickets |
| MessageSquare | 14px, 15px, 16px | Clarification |
| Scale | 14px, 15px, 16px | Arbitration |
| ShieldCheck | 14px, 15px | Quality review |
| ChevronRight | 14px | Dialog submit button |
| ExternalLink | 14px | Table row action |
| Send | 15px | Submit ticket button |
| AlertCircle | 14px | Warning messages |
| Eye | 15px | View service detail |
| CheckCircle | 16px | Service active status |
| XCircle | 16px | Service inactive status |

### 12.3 InfoRow Component (Ticket Detail)

```html
<!-- Reusable key-value row -->
<div class="flex items-center justify-between">
  <span class="text-slate-500 text-xs">{label}</span>
  <span class="font-medium text-right {muted ? 'text-slate-400 italic' : 'text-slate-800'}">
    {value}
  </span>
</div>
```

### 12.4 ActionButton Component (Ticket Detail)

```html
<button class="h-8 text-xs gap-1.5 inline-flex items-center px-3 rounded-md {colorClass}">
  {icon} {label}
</button>
```

### 12.5 MiniKPI Component (Reports)

See Section 11.2 for full structure.

---

## 13. Routing Map

| Route | Page | Description |
|-------|------|-------------|
| `/` | Dashboard | KPI overview, status distribution, activity feed |
| `/tickets` | Ticket Queue | Filterable table of all tickets |
| `/tickets/create` | Create Ticket | Form to submit new ticket |
| `/tickets/:id` | Ticket Detail | Full ticket view with actions, history, related data |
| `/services` | Service Catalogue | Table of all services with detail modal |
| `/reports` | Reports & Analytics | Charts, tables, KPIs for operational insights |

---

## 14. Mock Data (Seed Data)

### 14.1 Services (10 records)

| ID | Code | Name | Department | Division | Section | Priority | Active | SLA Resp | SLA Assign | SLA Complete | SLA Close |
|----|------|------|-----------|----------|---------|----------|--------|----------|-----------|-------------|-----------|
| 1 | SVC-001 | Water Faucet Repair | Maintenance | Plumbing | Residential | Medium | Yes | 60m | 120m | 1440m | 2880m |
| 2 | SVC-002 | Electrical Wiring Inspection | Maintenance | Electrical | Safety | High | Yes | 30m | 60m | 720m | 1440m |
| 3 | SVC-003 | AC Unit Maintenance | Maintenance | HVAC | Cooling | Medium | Yes | 60m | 180m | 2880m | 4320m |
| 4 | SVC-004 | Office Furniture Request | Admin Services | Procurement | Furniture | Low | Yes | 120m | 480m | 10080m | 14400m |
| 5 | SVC-005 | Network Access Setup | IT | Infrastructure | Network | High | Yes | 15m | 30m | 480m | 720m |
| 6 | SVC-006 | Parking Permit Issuance | Admin Services | Facilities | Parking | Low | Yes | 240m | 480m | 4320m | 5760m |
| 7 | SVC-007 | Fire Alarm System Check | Safety | Fire Safety | Inspection | Critical | Yes | 15m | 30m | 240m | 480m |
| 8 | SVC-008 | Elevator Maintenance | Maintenance | Mechanical | Elevators | High | Yes | 30m | 60m | 1440m | 2880m |
| 9 | SVC-009 | Landscaping Request | Facilities | Grounds | Landscaping | Low | No | 480m | 960m | 20160m | 28800m |
| 10 | SVC-010 | Security Badge Replacement | Security | Access Control | Badges | Medium | Yes | 60m | 120m | 1440m | 2160m |

### 14.2 Tickets (10 records)

| ID | TicketNo | Title | Status | Priority | Requester | Service | Dept | Assigned | SLA Breached |
|----|----------|-------|--------|----------|-----------|---------|------|----------|-------------|
| 1 | TKT-2026-0001 | Leaking faucet in Building A, Floor 3 | InProgress | Medium | Ahmed Al-Rashid (Resident) | Water Faucet Repair | Maintenance | Omar Hassan | No |
| 2 | TKT-2026-0002 | Electrical sparks in server room | Assigned | Critical | Fatima Al-Sayed (Internal) | Electrical Wiring Inspection | Maintenance | Khalid Ibrahim | No |
| 3 | TKT-2026-0003 | AC not cooling in executive office | PendingClarification | High | Nora Al-Fahad (Internal) | AC Unit Maintenance | Maintenance | Yusuf Malik | Yes |
| 4 | TKT-2026-0004 | Unknown issue with building entrance gate | PendingArbitration | High | Layla Mahmoud (Resident) | Other | Unassigned | null | No |
| 5 | TKT-2026-0005 | Order replacement faucet parts from warehouse | Open | Medium | Omar Hassan (Internal) | Office Furniture Request | Admin Services | null | No |
| 6 | TKT-2026-0006 | Setup VPN access for new employee | Resolved | High | Sara Al-Dosari (Internal) | Network Access Setup | IT | Ali Reza | No |
| 7 | TKT-2026-0007 | Fire alarm false trigger in cafeteria | Closed | Critical | Mohammed Al-Harbi (Internal) | Fire Alarm System Check | Safety | Hassan Noor | No |
| 8 | TKT-2026-0008 | Elevator stuck between floors | InProgress | Critical | Reem Al-Qahtani (Resident) | Elevator Maintenance | Maintenance | Tariq Aziz | No |
| 9 | TKT-2026-0009 | Request new security badge - lost | Open | Medium | Huda Al-Mutairi (Internal) | Security Badge Replacement | Security | null | No |
| 10 | TKT-2026-0010 | Parking permit for new contractor | Paused | Low | Majid Al-Otaibi (Internal) | Parking Permit Issuance | Admin Services | Salma Youssef | No |

**Parent-Child relationships:**
- Ticket 1 (parent) → Ticket 5 (child). Ticket 1 has isParentBlocked=true.

### 14.3 Ticket Histories

**Ticket 1 (6 entries):**
1. "Ticket Created" → Open (System, Apr 10 08:30)
2. "Routed to Queue" → Open (System, Apr 10 08:30:05)
3. "Assigned" → Assigned (Supervisor Ali, Apr 10 10:00)
4. "Work Started" → InProgress (Omar Hassan, Apr 11 08:00)
5. "Child Ticket Created" → InProgress (Omar Hassan, Apr 12 14:00)
6. "Paused" → Paused (System, Apr 12 14:00:05)

**Ticket 2 (2 entries):**
1. "Ticket Created" → Open (System, Apr 11 09:15)
2. "Assigned" → Assigned (Supervisor Nabil, Apr 11 09:30)

**Ticket 6 (4 entries):**
1. "Ticket Created" → Open (System, Apr 8 13:00)
2. "Assigned" → Assigned (IT Manager, Apr 8 14:00)
3. "Work Started" → InProgress (Ali Reza, Apr 9 09:00)
4. "Resolved" → Resolved (Ali Reza, Apr 14 16:00)

### 14.4 Arbitration Cases (1 record)
- Case 1: Ticket 4, raised by System, reason "Unknown service", status Open, arbitrator "Central Operations Manager"

### 14.5 Clarification Requests (1 record)
- Request 1: Ticket 3, by Yusuf Malik → Nora Al-Fahad, reason "Missing technical specifications", status Open

### 14.6 Quality Reviews (2 records)
- Review 1: Ticket 6, reviewer "Quality Team Lead", result null (Pending)
- Review 2: Ticket 7, reviewer "Safety Inspector", result "Approved"

### 14.7 Pause Sessions (2 records)
- Session 1: Ticket 1, reason "ChildDependency", related child ticket 5, active
- Session 2: Ticket 10, reason "ApprovalDelay", active

---

## 15. Recommendations for C# MVC Rebuild

### 15.1 Project Structure

```
TicketingSystem/
├── Controllers/
│   ├── HomeController.cs          → Dashboard (/)
│   ├── TicketsController.cs       → Ticket Queue, Detail, Create
│   ├── ServicesController.cs      → Service Catalogue
│   └── ReportsController.cs       → Reports
├── Models/
│   ├── Service.cs
│   ├── Ticket.cs
│   ├── TicketHistory.cs
│   ├── ArbitrationCase.cs
│   ├── ClarificationRequest.cs
│   ├── QualityReview.cs
│   ├── PauseSession.cs
│   └── Enums.cs                   → All enum definitions
├── ViewModels/
│   ├── DashboardViewModel.cs
│   ├── TicketListViewModel.cs
│   ├── TicketDetailViewModel.cs
│   ├── CreateTicketViewModel.cs
│   ├── ServiceCatalogueViewModel.cs
│   └── ReportsViewModel.cs
├── Data/
│   ├── ApplicationDbContext.cs
│   └── SeedData.cs                → Seed mock data
├── Views/
│   ├── Shared/
│   │   ├── _Layout.cshtml         → AppLayout (sidebar + topbar + content)
│   │   └── _ViewImports.cshtml
│   ├── Home/
│   │   └── Index.cshtml           → Dashboard
│   ├── Tickets/
│   │   ├── Index.cshtml           → Ticket Queue
│   │   ├── Detail.cshtml          → Ticket Detail
│   │   └── Create.cshtml          → Create Ticket
│   ├── Services/
│   │   └── Index.cshtml           → Service Catalogue
│   └── Reports/
│       └── Index.cshtml           → Reports
├── wwwroot/
│   ├── css/
│   │   └── site.css               → Custom styles + Tailwind overrides
│   ├── js/
│   │   └── site.js                → Client-side interactions
│   └── lib/
│       └── (Tailwind CDN or compiled CSS)
└── Program.cs
```

### 15.2 Key Implementation Notes

1. **Layout (_Layout.cshtml)**: Replicate the sidebar + topbar exactly as described in Section 5. Use `@RenderBody()` for the content area.

2. **Tailwind CSS**: Use Tailwind CSS CDN (`<script src="https://cdn.tailwindcss.com"></script>`) for rapid prototyping, or install via npm for production.

3. **Icons**: Use Lucide icons via CDN: `<script src="https://unpkg.com/lucide@latest"></script>` and use `<i data-lucide="icon-name"></i>`.

4. **Badges**: Create a helper method or partial view that takes status/priority and returns the correct CSS classes.

5. **Dialogs/Modals**: Use Bootstrap modals or a custom modal implementation. The dialog buttons on the Ticket Detail page should trigger modals with a textarea and submit/cancel buttons.

6. **Filtering**: For the Ticket Queue, implement server-side filtering via query parameters, or use JavaScript for client-side filtering.

7. **Responsive Design**: The sidebar collapses on mobile (< lg breakpoint = 1024px). Use the same Tailwind responsive prefixes.

8. **Data Access**: Use Entity Framework Core with the MSSQL database. Create DbContext with DbSet for each model.

9. **Seed Data**: Use `HasData()` in `OnModelCreating` or a separate seed method to populate the database with the mock data from Section 14.

10. **Date Formatting**: Use C# `DateTime.ToString("MMM d, yyyy")` for dates and `DateTime.ToString("MMM d, hh:mm tt")` for datetimes.

11. **formatMinutes Helper**: Create a static helper method in C#:
```csharp
public static string FormatMinutes(int min)
{
    if (min <= 0) return "Overdue";
    if (min < 60) return $"{min}m";
    if (min < 1440) return $"{min / 60}h {min % 60}m";
    return $"{min / 1440}d {(min % 1440) / 60}h";
}
```

---

## Appendix: Complete CSS Class Reference

### Background Colors Used
```
bg-slate-50, bg-slate-100, bg-slate-200, bg-slate-600, bg-slate-900
bg-white, bg-black/40
bg-blue-50, bg-blue-100, bg-blue-500, bg-blue-600, bg-blue-700
bg-red-50, bg-red-100, bg-red-500, bg-red-600, bg-red-700
bg-green-50, bg-green-100, bg-green-600, bg-green-700
bg-indigo-50, bg-indigo-100, bg-indigo-500, bg-indigo-600, bg-indigo-700
bg-yellow-50, bg-yellow-100, bg-yellow-500
bg-orange-50, bg-orange-100, bg-orange-200, bg-orange-500
bg-purple-50, bg-purple-100, bg-purple-200, bg-purple-500, bg-purple-600, bg-purple-700
bg-amber-50, bg-amber-200, bg-amber-500, bg-amber-600
bg-gray-200, bg-gray-400
```

### Text Colors Used
```
text-white, text-black
text-slate-400, text-slate-500, text-slate-600, text-slate-700, text-slate-800, text-slate-900
text-blue-600, text-blue-800
text-red-500, text-red-600, text-red-700, text-red-800
text-green-600, text-green-700, text-green-800
text-indigo-600, text-indigo-700, text-indigo-800
text-yellow-600, text-yellow-700, text-yellow-800
text-orange-600, text-orange-800
text-purple-600, text-purple-700, text-purple-800
text-amber-600, text-amber-700, text-amber-800
text-gray-500, text-gray-700
```

### Border Colors Used
```
border-slate-100, border-slate-200, border-slate-700
border-red-200, border-red-300
border-orange-200, border-orange-300
border-yellow-300
border-green-100, border-green-200, border-green-300
border-purple-100, border-purple-200
border-indigo-200
border-amber-200
border-l-blue-500, border-l-red-500, border-l-green-500, border-l-indigo-500
border-l-amber-500, border-l-orange-500, border-l-purple-500
```

---

*End of Blueprint Document*
*Generated from the Atoms-built Multi-Department Ticketing System prototype*
*Date: April 15, 2026*
