# Ticket Queue — Pixel-Perfect Implementation Details

> **Purpose**: This document captures every visual and structural detail of the "Ticket Queue" page so that another developer (or AI agent) can reproduce it **identically** in any stack (C# MVC / Razor / plain HTML+CSS / etc.).

---

## Table of Contents

1. [Page Overview](#1-page-overview)
2. [Global Layout (AppLayout)](#2-global-layout-applayout)
3. [Ticket Queue Page Structure](#3-ticket-queue-page-structure)
4. [Layout & Dimensions](#4-layout--dimensions)
5. [Color Systems](#5-color-systems)
6. [Typography](#6-typography)
7. [UI Components & Icons](#7-ui-components--icons)
8. [Styling Methodology](#8-styling-methodology)
9. [Data Model & Mock Data](#9-data-model--mock-data)
10. [Column-by-Column Specification](#10-column-by-column-specification)
11. [Responsive Behavior](#11-responsive-behavior)
12. [Complete CSS Class Reference](#12-complete-css-class-reference)

---

## 1. Page Overview

The Ticket Queue is a **table-based inbox** showing all tickets with:
- A **page header** (title + subtitle count)
- A **filter bar** (search input + 2 dropdown selects)
- A **data table** inside a card, with 10 columns
- Each row is interactive (hover highlight, clickable ticket number, action button)

**Total pages in the application**: 6
1. Dashboard (`/`) — KPI cards, charts, activity timeline
2. **Ticket Queue** (`/tickets`) — This page
3. Ticket Detail (`/tickets/:id`) — Full ticket view with actions
4. Create Ticket (`/tickets/create`) — Ticket creation form
5. Service Catalogue (`/services`) — Service list with SLA policies
6. Reports (`/reports`) — Analytics dashboard

---

## 2. Global Layout (AppLayout)

The entire app is wrapped in `AppLayout` which provides:

### 2.1 Root Container
```
display: flex
height: 100vh (full viewport)
background: #F8FAFC (slate-50)
```

### 2.2 Sidebar (Left)
```
width: 256px (w-64 = 16rem)
background: #0F172A (slate-900)
color: white
position: fixed on mobile, static on desktop (lg breakpoint = 1024px)
flex-direction: column
z-index: 50
transition: transform 200ms
```

#### Sidebar Header
```
padding: 20px horizontal (px-5), 20px vertical (py-5)
border-bottom: 1px solid #334155 (slate-700)
display: flex, align-items: center, gap: 12px
```

- **Logo Box**: 36×36px (w-9 h-9), rounded-lg (border-radius: 8px), bg: #3B82F6 (blue-500), centered text "TS", font-bold, font-size: 14px (text-sm)
- **Title**: font-bold, font-size: 14px (text-sm), line-height: tight (1.25)
- **Subtitle**: font-size: 11px, color: #94A3B8 (slate-400)

#### Navigation Items
```
padding: 16px vertical (py-4), 12px horizontal (px-3)
space-y: 4px (gap between items)
overflow-y: auto
```

Each nav item:
```
display: flex, align-items: center, gap: 12px
padding: 12px horizontal (px-3), 10px vertical (py-2.5)
border-radius: 8px (rounded-lg)
font-size: 14px (text-sm)
font-weight: 500 (medium)
transition: colors
```

- **Active state**: bg: #2563EB (blue-600), color: white
- **Inactive state**: color: #CBD5E1 (slate-300), hover bg: #1E293B (slate-800), hover color: white

Badge on "Ticket Queue":
```
margin-left: auto
background: #3B82F6 (blue-500)
color: white
font-size: 10px
padding: 0 6px (px-1.5 py-0)
```

#### Sidebar Footer (User Info)
```
padding: 16px (px-4 py-4)
border-top: 1px solid #334155 (slate-700)
```
- Avatar circle: 32×32px (w-8 h-8), rounded-full, bg: #475569 (slate-600), text: 12px bold
- Name: font-size: 12px (text-xs), font-weight: 500
- Role: font-size: 10px, color: #94A3B8 (slate-400)

### 2.3 Top Bar (Header)
```
height: 56px (h-14)
background: white
border-bottom: 1px solid #E2E8F0 (slate-200)
display: flex, align-items: center
padding: 0 16px (px-4)
gap: 12px
flex-shrink: 0
```

- **Hamburger** (mobile only, hidden on lg+): icon Menu 22px, color: #475569 (slate-600)
- **Search Input**: max-width: 448px (max-w-md), flex: 1
  - Search icon: 16px, absolute positioned left: 12px, vertically centered, color: #94A3B8 (slate-400)
  - Input: padding-left: 36px (pl-9), height: 36px (h-9), font-size: 14px, bg: #F8FAFC (slate-50), border: #E2E8F0
- **Bell Icon**: ghost button, icon 18px, color: #475569 (slate-600)
  - Red dot indicator: absolute, top: 4px, right: 4px, 8×8px circle, bg: #EF4444 (red-500)

### 2.4 Main Content Area
```
flex: 1
overflow-y: auto
padding: 16px (p-4) on mobile, 24px (p-6) on md+
```

---

## 3. Ticket Queue Page Structure

```
<AppLayout>
  <div class="space-y-5">           <!-- 20px vertical gap between children -->
    <!-- Header Section -->
    <div>
      <h1>Ticket Queue</h1>
      <p>X of Y tickets</p>
    </div>

    <!-- Filter Bar -->
    <div class="flex gap-3">
      <SearchInput />
      <StatusDropdown />
      <PriorityDropdown />
    </div>

    <!-- Table Card -->
    <Card>
      <Table>
        <TableHeader>...</TableHeader>
        <TableBody>
          {rows}
        </TableBody>
      </Table>
    </Card>
  </div>
</AppLayout>
```

---

## 4. Layout & Dimensions

### 4.1 Page Content Spacing
| Element | Property | Value | Tailwind Class |
|---------|----------|-------|----------------|
| Content wrapper | vertical gap | 20px | `space-y-5` |
| Main content padding | mobile | 16px | `p-4` |
| Main content padding | md+ | 24px | `md:p-6` |

### 4.2 Header Section
| Element | Property | Value | Tailwind Class |
|---------|----------|-------|----------------|
| Title (h1) | margin | 0 | — |
| Subtitle (p) | margin-top | 4px | `mt-1` |

### 4.3 Filter Bar
| Element | Property | Value | Tailwind Class |
|---------|----------|-------|----------------|
| Container | display | flex | `flex` |
| Container | direction | column (mobile), row (sm+) | `flex-col sm:flex-row` |
| Container | gap | 12px | `gap-3` |
| Search wrapper | flex | 1 (grow) | `flex-1` |
| Search icon | position | absolute, left: 12px | `absolute left-3` |
| Search icon | vertical | centered | `top-1/2 -translate-y-1/2` |
| Search input | padding-left | 36px | `pl-9` |
| Search input | height | 36px | `h-9` |
| Status dropdown | width | full (mobile), 192px (sm+) | `w-full sm:w-48` |
| Status dropdown | height | 36px | `h-9` |
| Priority dropdown | width | full (mobile), 160px (sm+) | `w-full sm:w-40` |
| Priority dropdown | height | 36px | `h-9` |

### 4.4 Table Card
| Element | Property | Value | Tailwind Class |
|---------|----------|-------|----------------|
| Card content | padding | 0 | `p-0` |
| Card | border-radius | 8px | (shadcn default `rounded-lg`) |
| Card | border | 1px solid #E2E8F0 | (shadcn default) |
| Card | background | white | (shadcn default) |
| Card | box-shadow | `0 1px 2px rgba(0,0,0,0.05)` | (shadcn default `shadow-sm`) |

### 4.5 Table Columns
| Column | Width | Tailwind Class |
|--------|-------|----------------|
| Ticket # | 128px | `w-32` |
| Title | auto (max 200px) | `max-w-[200px]` |
| Service | auto | — |
| Requester | auto | — |
| Priority | auto | — |
| Status | auto | — |
| SLA | auto | — |
| Assigned | auto | — |
| Created | 80px | `w-20` |
| Action (link) | 40px | `w-10` |

### 4.6 Table Cell Padding (shadcn defaults)
```
TableHead: padding: 12px 16px (py-3 px-4), font-weight: 500, font-size: 14px
TableCell: padding: 16px (p-4), vertical-align: middle
TableRow: border-bottom: 1px solid #F1F5F9 (slate-100)
```

### 4.7 Empty State
```
colSpan: 10
text-align: center
padding: 40px vertical (py-10)
color: #94A3B8 (slate-400)
```

---

## 5. Color Systems

### 5.1 Page Background & Surfaces
| Element | Color | HEX |
|---------|-------|-----|
| Page background | slate-50 | `#F8FAFC` |
| Card background | white | `#FFFFFF` |
| Table row hover | slate-50 | `#F8FAFC` |
| Table border | slate-100 | `#F1F5F9` |
| Card border | slate-200 | `#E2E8F0` |

### 5.2 Text Colors
| Usage | Color | HEX | Tailwind |
|-------|-------|-----|----------|
| Page title | slate-900 | `#0F172A` | `text-slate-900` |
| Subtitle / count | slate-500 | `#64748B` | `text-slate-500` |
| Ticket title text | slate-800 | `#1E293B` | `text-slate-800` |
| Requester name | slate-700 | `#334155` | `text-slate-700` |
| Requester type (sub-line) | slate-400 | `#94A3B8` | `text-slate-400` |
| Service name | slate-600 | `#475569` | `text-slate-600` |
| Assigned user | slate-600 | `#475569` | `text-slate-600` |
| Unassigned placeholder | slate-400 | `#94A3B8` | `text-slate-400` |
| Created date | slate-500 | `#64748B` | `text-slate-500` |
| Ticket # link | blue-600 | `#2563EB` | `text-blue-600` |
| "Other" service | orange-600 | `#EA580C` | `text-orange-600` |
| SLA remaining | slate-600 | `#475569` | `text-slate-600` |
| SLA dash (resolved) | slate-400 | `#94A3B8` | `text-slate-400` |
| SLA breached text | red-600 | `#DC2626` | `text-red-600` |
| Empty state text | slate-400 | `#94A3B8` | `text-slate-400` |
| Search placeholder | slate-400 | `#94A3B8` | (input default) |
| Search icon | slate-400 | `#94A3B8` | `text-slate-400` |
| Action icon | slate-400 | `#94A3B8` | `text-slate-400` |

### 5.3 Status Badge Colors (Background / Text)
| Status | Background | Text | Tailwind Classes |
|--------|-----------|------|-----------------|
| Open | `#DBEAFE` (blue-100) | `#1E40AF` (blue-800) | `bg-blue-100 text-blue-800` |
| Assigned | `#E0E7FF` (indigo-100) | `#3730A3` (indigo-800) | `bg-indigo-100 text-indigo-800` |
| In Progress | `#FEF9C3` (yellow-100) | `#854D0E` (yellow-800) | `bg-yellow-100 text-yellow-800` |
| Paused | `#E2E8F0` (gray-200) | `#374151` (gray-700) | `bg-gray-200 text-gray-700` |
| Resolved | `#DCFCE7` (green-100) | `#166534` (green-800) | `bg-green-100 text-green-800` |
| Closed | `#E2E8F0` (slate-200) | `#475569` (slate-600) | `bg-slate-200 text-slate-600` |
| Pending Arbitration | `#FFEDD5` (orange-100) | `#9A3412` (orange-800) | `bg-orange-100 text-orange-800` |
| Pending Clarification | `#F3E8FF` (purple-100) | `#6B21A8` (purple-800) | `bg-purple-100 text-purple-800` |

### 5.4 Priority Badge Colors (Background / Text / Border)
| Priority | Background | Text | Border | Tailwind Classes |
|----------|-----------|------|--------|-----------------|
| Critical | `#FEE2E2` (red-100) | `#991B1B` (red-800) | `#FCA5A5` (red-300) | `bg-red-100 text-red-800 border-red-300` |
| High | `#FFEDD5` (orange-100) | `#9A3412` (orange-800) | `#FDBA74` (orange-300) | `bg-orange-100 text-orange-800 border-orange-300` |
| Medium | `#FEF9C3` (yellow-100) | `#854D0E` (yellow-800) | `#FDE047` (yellow-300) | `bg-yellow-100 text-yellow-800 border-yellow-300` |
| Low | `#DCFCE7` (green-100) | `#166534` (green-800) | `#86EFAC` (green-300) | `bg-green-100 text-green-800 border-green-300` |

### 5.5 SLA Breached State
| Element | Color | HEX |
|---------|-------|-----|
| Icon (AlertTriangle) | red-600 | `#DC2626` |
| Text "Breached" | red-600 | `#DC2626` |

---

## 6. Typography

### 6.1 Font Family
```
font-family: "Inter", ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif
```
(Tailwind default sans-serif stack. The shadcn/ui template uses Inter as the primary font.)

### 6.2 Font Sizes & Weights by Element

| Element | Font Size | Font Weight | Line Height | Tailwind Classes |
|---------|-----------|-------------|-------------|-----------------|
| Page title "Ticket Queue" | 24px | 700 (bold) | 32px | `text-2xl font-bold` |
| Subtitle "X of Y tickets" | 14px | 400 (normal) | 20px | `text-sm` |
| Search input text | 14px | 400 | 20px | `text-sm` |
| Search placeholder | 14px | 400 | 20px | `text-sm` |
| Dropdown trigger text | 14px | 400 | 20px | `text-sm` |
| Table header text | 14px | 500 (medium) | 20px | (shadcn default) |
| Ticket # | 12px | 500 (medium) | 16px | `text-xs font-medium font-mono` |
| Ticket title | 14px | 500 (medium) | 20px | `text-sm font-medium` |
| Service name | 14px | 400 | 20px | `text-sm` |
| Requester name | 14px | 400 | 20px | `text-sm` |
| Requester type | 10px | 400 | 14px | `text-[10px]` |
| Priority badge text | 10px | 400 | 14px | `text-[10px]` |
| Status badge text | 10px | 400 | 14px | `text-[10px]` |
| SLA "Breached" text | 12px | 600 (semibold) | 16px | `text-xs font-semibold` |
| SLA remaining time | 12px | 400 | 16px | `text-xs` |
| SLA dash "—" | 12px | 400 | 16px | `text-xs` |
| Assigned user | 14px | 400 | 20px | `text-sm` |
| "Unassigned" text | 12px | 400 | 16px | `text-xs` |
| Created date | 12px | 400 | 16px | `text-xs` |
| Empty state text | 14px | 400 | 20px | (default) |

### 6.3 Font Families Used
| Usage | Font | Tailwind |
|-------|------|----------|
| General text | Inter (sans-serif) | default |
| Ticket # | Monospace (system) | `font-mono` |

---

## 7. UI Components & Icons

### 7.1 Components Used

| Component | Source | Purpose |
|-----------|--------|---------|
| `Card` | shadcn/ui | Wraps the table in a bordered, rounded container |
| `CardContent` | shadcn/ui | Inner content of card (padding set to 0) |
| `Badge` | shadcn/ui | Status and Priority colored labels |
| `Button` | shadcn/ui | Action button (ghost variant, icon size) |
| `Input` | shadcn/ui | Search text field |
| `Select` | shadcn/ui | Status filter dropdown |
| `SelectTrigger` | shadcn/ui | Dropdown trigger button |
| `SelectContent` | shadcn/ui | Dropdown popup content |
| `SelectItem` | shadcn/ui | Individual dropdown option |
| `SelectValue` | shadcn/ui | Displayed selected value |
| `Table` | shadcn/ui | HTML table wrapper |
| `TableHeader` | shadcn/ui | `<thead>` wrapper |
| `TableBody` | shadcn/ui | `<tbody>` wrapper |
| `TableRow` | shadcn/ui | `<tr>` wrapper |
| `TableHead` | shadcn/ui | `<th>` wrapper |
| `TableCell` | shadcn/ui | `<td>` wrapper |
| `Link` | react-router-dom | Client-side navigation (ticket # and action button) |

### 7.2 Icon Library

**Library**: [Lucide React](https://lucide.dev/) (v0.462.0)

| Icon Name | Size (px) | Usage | Color |
|-----------|-----------|-------|-------|
| `Search` | 16 | Search input prefix icon | `#94A3B8` (slate-400) |
| `ExternalLink` | 14 | Row action button (open ticket) | `#94A3B8` (slate-400) |
| `AlertTriangle` | 13 | SLA breached indicator | `#DC2626` (red-600) |
| `LayoutDashboard` | 18 | Sidebar nav: Dashboard | white / slate-300 |
| `Ticket` | 18 | Sidebar nav: Ticket Queue | white / slate-300 |
| `PlusCircle` | 18 | Sidebar nav: Create Ticket | white / slate-300 |
| `BookOpen` | 18 | Sidebar nav: Service Catalogue | white / slate-300 |
| `BarChart3` | 18 | Sidebar nav: Reports | white / slate-300 |
| `Menu` | 22 | Mobile hamburger menu | `#475569` (slate-600) |
| `X` | 20 | Close sidebar (mobile) | `#94A3B8` (slate-400) |
| `Bell` | 18 | Notification bell in top bar | `#475569` (slate-600) |

### 7.3 Badge Component Details

The `Badge` component from shadcn/ui renders as:
```css
display: inline-flex;
align-items: center;
border-radius: 9999px; /* fully rounded */
padding: 2px 10px; /* px-2.5 py-0.5 */
font-size: 12px; /* text-xs */
font-weight: 600; /* font-semibold */
line-height: 16px;
transition: colors;
border: 1px solid transparent;
```

We override font-size to 10px via `text-[10px]` for status and priority badges.

### 7.4 Button (Action Column)
```
variant: "ghost" — transparent background, hover: slate-100
size: "icon" — square button
height: 28px (h-7)
width: 28px (w-7)
```

---

## 8. Styling Methodology

### 8.1 Framework
**Tailwind CSS v3.x** with the **shadcn/ui** component library.

### 8.2 Why Tailwind + shadcn/ui Creates the "Soft UI" Feel

1. **Subtle shadows**: Cards use `shadow-sm` (`box-shadow: 0 1px 2px rgba(0,0,0,0.05)`) — barely visible, creating depth without harshness.

2. **Rounded corners**: All containers use `rounded-lg` (8px) or `rounded-md` (6px), giving a soft, modern appearance.

3. **Muted color palette**: The slate color scale (blue-gray tones) is softer than pure gray, creating warmth.

4. **Low-contrast borders**: Borders use `slate-200` (#E2E8F0) which is very subtle against white backgrounds.

5. **Pastel badges**: Status/priority badges use `*-100` backgrounds with `*-800` text — soft, readable, non-aggressive.

6. **Hover transitions**: `transition-colors` on interactive elements creates smooth state changes.

7. **Generous whitespace**: `space-y-5` (20px gaps), `p-4`/`p-6` content padding, table cell padding — nothing feels cramped.

8. **Consistent 4px grid**: All spacing values are multiples of 4px (Tailwind's default scale).

### 8.3 Key Tailwind Classes for the "Soft UI" Effect
```
bg-slate-50          → Soft warm gray page background
bg-white             → Clean card surfaces
border-slate-200     → Subtle borders
shadow-sm            → Minimal elevation
rounded-lg           → 8px rounded corners
hover:bg-slate-50    → Gentle row hover
text-slate-900       → Near-black but not pure black text
text-slate-500       → Muted secondary text
```

### 8.4 CSS Reset / Base
Tailwind's Preflight (based on modern-normalize) provides:
- Box-sizing: border-box on all elements
- Margin: 0 on all elements
- Border-style: solid, border-width: 0 by default
- Font inheritance on form elements

---

## 9. Data Model & Mock Data

### 9.1 Ticket Interface (TypeScript)
```typescript
interface Ticket {
  id: number;                    // Unique identifier
  ticketNo: string;              // Display format: "TKT-YYYY-NNNN"
  title: string;                 // Short description
  description: string;           // Full description
  status: TicketStatus;          // One of 8 statuses
  priority: Priority;            // Critical | High | Medium | Low
  requesterType: RequesterType;  // "Resident" | "Internal"
  requesterName: string;         // Full name
  serviceId: number | null;      // FK to Service (null for "Other")
  serviceName: string;           // Display name of service
  isOtherService: boolean;       // True if service was "Other"
  department: string;            // Assigned department
  division: string;              // Assigned division
  section: string;               // Assigned section
  currentQueue: string;          // Current routing queue name
  assignedUser: string | null;   // Assigned technician/agent name
  parentTicketId: number | null; // Parent ticket FK
  childTicketIds: number[];      // Array of child ticket IDs
  isParentBlocked: boolean;      // True if blocked by children
  requiresQualityReview: boolean;
  createdAt: string;             // ISO 8601 datetime
  updatedAt: string;             // ISO 8601 datetime
  resolvedAt: string | null;
  closedAt: string | null;
  slaBreached: boolean;          // True if any SLA is breached
  slaResponseRemainMin: number;  // Minutes remaining for response SLA
  slaCompletionRemainMin: number;// Minutes remaining for completion SLA
  location: string;              // Physical location
}
```

### 9.2 Status Values (8 total)
```
"Open" | "Assigned" | "InProgress" | "Paused" | "Resolved" | "Closed" | "PendingArbitration" | "PendingClarification"
```

### 9.3 Priority Values (4 total)
```
"Critical" | "High" | "Medium" | "Low"
```

### 9.4 Mock Tickets (10 total)

| # | Ticket No | Title | Status | Priority | Requester | Service | Assigned | SLA |
|---|-----------|-------|--------|----------|-----------|---------|----------|-----|
| 1 | TKT-2026-0001 | Leaking faucet in Building A, Floor 3 | InProgress | Medium | Ahmed Al-Rashid (Resident) | Water Faucet Repair | Omar Hassan | OK (720m) |
| 2 | TKT-2026-0002 | Electrical sparks in server room | Assigned | Critical | Fatima Al-Sayed (Internal) | Electrical Wiring Inspection | Khalid Ibrahim | OK (300m) |
| 3 | TKT-2026-0003 | AC not cooling in executive office | PendingClarification | High | Nora Al-Fahad (Internal) | AC Unit Maintenance | Yusuf Malik | **BREACHED** |
| 4 | TKT-2026-0004 | Unknown issue with building entrance gate | PendingArbitration | High | Layla Mahmoud (Resident) | Other | Unassigned | OK (1380m) |
| 5 | TKT-2026-0005 | Order replacement faucet parts | Open | Medium | Omar Hassan (Internal) | Office Furniture Request | Unassigned | OK (9000m) |
| 6 | TKT-2026-0006 | Setup VPN access for new employee | Resolved | High | Sara Al-Dosari (Internal) | Network Access Setup | Ali Reza | — |
| 7 | TKT-2026-0007 | Fire alarm false trigger in cafeteria | Closed | Critical | Mohammed Al-Harbi (Internal) | Fire Alarm System Check | Hassan Noor | — |
| 8 | TKT-2026-0008 | Elevator stuck between floors | InProgress | Critical | Reem Al-Qahtani (Resident) | Elevator Maintenance | Tariq Aziz | OK (1200m) |
| 9 | TKT-2026-0009 | Request new security badge - lost | Open | Medium | Huda Al-Mutairi (Internal) | Security Badge Replacement | Unassigned | OK (1380m) |
| 10 | TKT-2026-0010 | Parking permit for new contractor | Paused | Low | Majid Al-Otaibi (Internal) | Parking Permit Issuance | Salma Youssef | OK (3800m) |

---

## 10. Column-by-Column Specification

### Column 1: Ticket #
- **Width**: 128px (`w-32`)
- **Content**: Clickable link to `/tickets/{id}`
- **Font**: monospace, 12px, weight 500
- **Color**: `#2563EB` (blue-600)
- **Hover**: underline decoration
- **Format**: `TKT-YYYY-NNNN`

### Column 2: Title
- **Width**: auto, max 200px (`max-w-[200px]`)
- **Content**: Single line, truncated with ellipsis
- **Font**: 14px, weight 500
- **Color**: `#1E293B` (slate-800)
- **Overflow**: `text-overflow: ellipsis; overflow: hidden; white-space: nowrap` (Tailwind `truncate`)

### Column 3: Service
- **Width**: auto
- **Font**: 14px, weight 400
- **Color**: `#475569` (slate-600)
- **Special**: If `isOtherService === true`, display "Other" in italic, color `#EA580C` (orange-600)

### Column 4: Requester (Double-Line Layout)
- **Width**: auto
- **Layout**: Two stacked lines (block layout)
- **Line 1 (Name)**: 14px, weight 400, color `#334155` (slate-700)
- **Line 2 (Type)**: 10px, weight 400, color `#94A3B8` (slate-400)
- **HTML Structure**:
  ```html
  <div>
    <p style="font-size:14px; color:#334155;">Ahmed Al-Rashid</p>
    <p style="font-size:10px; color:#94A3B8;">Resident</p>
  </div>
  ```

### Column 5: Priority
- **Content**: Badge component
- **Font**: 10px inside badge
- **Colors**: See Section 5.4 (Priority Badge Colors)
- **Border-radius**: fully rounded (pill shape)
- **Values**: Critical, High, Medium, Low

### Column 6: Status
- **Content**: Badge component
- **Font**: 10px inside badge
- **Colors**: See Section 5.3 (Status Badge Colors)
- **Border-radius**: fully rounded (pill shape)
- **Display labels**: "Open", "Assigned", "In Progress", "Paused", "Resolved", "Closed", "Pending Arbitration", "Pending Clarification"

### Column 7: SLA
- **Three states**:

  **State A — Breached** (`slaBreached === true`):
  ```
  Layout: flex, align-items: center, gap: 4px
  Icon: AlertTriangle, 13px, color: #DC2626 (red-600)
  Text: "Breached", 12px, font-weight: 600, color: #DC2626 (red-600)
  ```

  **State B — Resolved/Closed** (status is "Resolved" or "Closed"):
  ```
  Text: "—" (em dash), 12px, color: #94A3B8 (slate-400)
  ```

  **State C — Active with time remaining**:
  ```
  Text: formatted time (e.g., "12h 0m", "6d 6h"), 12px, color: #475569 (slate-600)
  Format rules:
    - < 60 min: "{min}m"
    - < 1440 min (24h): "{hours}h {min}m"
    - >= 1440 min: "{days}d {hours}h"
    - <= 0: "Overdue"
  ```

### Column 8: Assigned
- **Font**: 14px, weight 400, color: `#475569` (slate-600)
- **If null**: Display "Unassigned", 12px, color: `#94A3B8` (slate-400)

### Column 9: Created
- **Width**: 80px (`w-20`)
- **Font**: 12px, weight 400, color: `#64748B` (slate-500)
- **Format**: "MMM D, YYYY" (e.g., "Apr 10, 2026")
- **Formatting function**: `new Date(iso).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })`

### Column 10: Action
- **Width**: 40px (`w-10`)
- **Content**: Ghost button with ExternalLink icon
- **Button**: 28×28px, ghost variant (transparent bg, hover: slate-100)
- **Icon**: ExternalLink, 14px, color: `#94A3B8` (slate-400)
- **Link**: navigates to `/tickets/{id}`

---

## 11. Responsive Behavior

### Breakpoints (Tailwind defaults)
| Name | Min Width |
|------|-----------|
| sm | 640px |
| md | 768px |
| lg | 1024px |
| xl | 1280px |

### Responsive Rules
| Feature | Mobile (<640px) | sm (640px+) | md (768px+) | lg (1024px+) |
|---------|-----------------|-------------|-------------|--------------|
| Sidebar | Hidden (slide-in overlay) | Hidden | Hidden | Static, always visible |
| Hamburger menu | Visible | Visible | Visible | Hidden |
| Content padding | 16px | 16px | 24px | 24px |
| Filter bar direction | Column (stacked) | Row (horizontal) | Row | Row |
| Status dropdown width | 100% | 192px | 192px | 192px |
| Priority dropdown width | 100% | 160px | 160px | 160px |
| Table | Horizontal scroll if needed | — | — | Full width |

---

## 12. Complete CSS Class Reference

### 12.1 Page Wrapper
```
space-y-5
```

### 12.2 Header
```
h1: text-2xl font-bold text-slate-900
p:  text-sm text-slate-500 mt-1
```

### 12.3 Filter Bar
```
Container: flex flex-col sm:flex-row gap-3
Search wrapper: relative flex-1
Search icon: absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 (size=16)
Search input: pl-9 h-9 text-sm
Status select trigger: w-full sm:w-48 h-9 text-sm
Priority select trigger: w-full sm:w-40 h-9 text-sm
```

### 12.4 Table
```
Card: (default shadcn — bg-white rounded-lg border shadow-sm)
CardContent: p-0
TableHead (Ticket #): w-32
TableHead (Created): w-20
TableHead (Action): w-10
TableRow: hover:bg-slate-50

Ticket # cell:
  Link: font-mono text-xs text-blue-600 hover:underline font-medium

Title cell:
  Container: max-w-[200px]
  Text: text-sm font-medium text-slate-800 truncate

Service cell:
  Normal: text-sm text-slate-600
  Other: italic text-orange-600

Requester cell:
  Name: text-sm text-slate-700
  Type: text-[10px] text-slate-400

Priority badge: text-[10px] + priorityColors[priority]
Status badge: text-[10px] + statusColors[status]

SLA breached:
  Container: flex items-center gap-1 text-red-600
  Icon: AlertTriangle size=13
  Text: text-xs font-semibold

SLA dash: text-xs text-slate-400
SLA remaining: text-xs text-slate-600

Assigned:
  Normal: text-sm text-slate-600
  Unassigned: text-slate-400 text-xs

Created: text-xs text-slate-500

Action button:
  Button: variant="ghost" size="icon" h-7 w-7
  Icon: ExternalLink size=14 text-slate-400
```

---

## Appendix A: Equivalent Pure CSS for Non-Tailwind Stacks

If rebuilding in C# MVC with plain CSS or Bootstrap, here are the key CSS rules:

```css
/* Page background */
body { background-color: #F8FAFC; font-family: 'Inter', sans-serif; }

/* Card */
.card {
  background: #FFFFFF;
  border: 1px solid #E2E8F0;
  border-radius: 8px;
  box-shadow: 0 1px 2px rgba(0,0,0,0.05);
}

/* Table */
.table th {
  padding: 12px 16px;
  font-size: 14px;
  font-weight: 500;
  color: #64748B;
  text-align: left;
  border-bottom: 1px solid #E2E8F0;
}
.table td {
  padding: 16px;
  vertical-align: middle;
  border-bottom: 1px solid #F1F5F9;
}
.table tr:hover { background-color: #F8FAFC; }

/* Badge base */
.badge {
  display: inline-flex;
  align-items: center;
  padding: 2px 10px;
  border-radius: 9999px;
  font-size: 10px;
  font-weight: 600;
  line-height: 14px;
}

/* Status badges */
.badge-open { background: #DBEAFE; color: #1E40AF; }
.badge-assigned { background: #E0E7FF; color: #3730A3; }
.badge-in-progress { background: #FEF9C3; color: #854D0E; }
.badge-paused { background: #E2E8F0; color: #374151; }
.badge-resolved { background: #DCFCE7; color: #166534; }
.badge-closed { background: #E2E8F0; color: #475569; }
.badge-pending-arbitration { background: #FFEDD5; color: #9A3412; }
.badge-pending-clarification { background: #F3E8FF; color: #6B21A8; }

/* Priority badges */
.badge-critical { background: #FEE2E2; color: #991B1B; border: 1px solid #FCA5A5; }
.badge-high { background: #FFEDD5; color: #9A3412; border: 1px solid #FDBA74; }
.badge-medium { background: #FEF9C3; color: #854D0E; border: 1px solid #FDE047; }
.badge-low { background: #DCFCE7; color: #166534; border: 1px solid #86EFAC; }

/* Ticket link */
.ticket-link {
  font-family: monospace;
  font-size: 12px;
  font-weight: 500;
  color: #2563EB;
  text-decoration: none;
}
.ticket-link:hover { text-decoration: underline; }

/* SLA breached */
.sla-breached {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #DC2626;
  font-size: 12px;
  font-weight: 600;
}

/* Requester double-line */
.requester-name { font-size: 14px; color: #334155; }
.requester-type { font-size: 10px; color: #94A3B8; }

/* Search input */
.search-input {
  padding-left: 36px;
  height: 36px;
  font-size: 14px;
  border: 1px solid #E2E8F0;
  border-radius: 6px;
}
.search-icon {
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  color: #94A3B8;
}
```

---

## Appendix B: Sidebar Navigation Specification

For the full application, the sidebar contains these 5 navigation items:

| # | Label | Icon | Route | Badge |
|---|-------|------|-------|-------|
| 1 | Dashboard | LayoutDashboard | `/` | — |
| 2 | Ticket Queue | Ticket | `/tickets` | Active ticket count (blue pill) |
| 3 | Create Ticket | PlusCircle | `/tickets/create` | — |
| 4 | Service Catalogue | BookOpen | `/services` | — |
| 5 | Reports | BarChart3 | `/reports` | — |

Active state detection:
- Dashboard: exact match `pathname === "/"`
- Others: starts-with match `pathname.startsWith(item.path)`

---

## Appendix C: Filter Logic

### Search
Searches across 4 fields (case-insensitive):
1. `ticketNo`
2. `title`
3. `requesterName`
4. `serviceName`

### Status Filter
Dropdown with "All Statuses" + all 8 status values.

### Priority Filter
Dropdown with "All Priorities" + Critical, High, Medium, Low.

### Combined Logic
All three filters are AND-combined:
```
matchSearch AND matchStatus AND matchPriority
```

---

*End of Implementation Report*