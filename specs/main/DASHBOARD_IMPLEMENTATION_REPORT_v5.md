# Dashboard — Pixel-Perfect Implementation Details

> **Purpose**: This document captures every visual and structural detail of the "Dashboard" page so that another developer (or AI agent) can reproduce it **identically** in any stack (C# MVC / Razor / plain HTML+CSS / etc.).

---

## Table of Contents

1. [Page Overview](#1-page-overview)
2. [Page Structure](#2-page-structure)
3. [Layout & Dimensions](#3-layout--dimensions)
4. [Color Systems](#4-color-systems)
5. [Typography](#5-typography)
6. [UI Components & Icons](#6-ui-components--icons)
7. [Section-by-Section Specification](#7-section-by-section-specification)
8. [Styling Methodology](#8-styling-methodology)
9. [Data & Logic](#9-data--logic)
10. [Complete CSS Class Reference](#10-complete-css-class-reference)

---

## 1. Page Overview

The Dashboard is the **home page** (`/`) of the ticketing system. It provides an at-a-glance operational overview with:
- **4 KPI Cards** — Active Tickets, SLA Breaches, Resolved Today, Avg Resolution
- **Status Distribution** — Horizontal progress bars for each of the 8 ticket statuses
- **Recent Activity Timeline** — Last 8 audit trail entries across all tickets
- **Department Workload** — Bar chart showing tickets per department
- **Service Frequency** — Ranked list of most-requested services
- **Priority Overview** — 4 colored cards showing active ticket count per priority level

---

## 2. Page Structure

```
<AppLayout>
  <div class="space-y-6">                    <!-- 24px vertical gap -->
    <!-- Page Header -->
    <div>
      <h1>Dashboard</h1>
      <p>Overview of ticketing operations — April 15, 2026</p>
    </div>

    <!-- KPI Cards Row -->
    <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
      <KPICard: Active Tickets />
      <KPICard: SLA Breaches />
      <KPICard: Resolved Today />
      <KPICard: Avg Resolution />
    </div>

    <!-- Status + Activity Row -->
    <div class="grid lg:grid-cols-3 gap-6">
      <Card: Tickets by Status (1 col) />
      <Card: Recent Activity (2 cols) />
    </div>

    <!-- Department + Service Row -->
    <div class="grid lg:grid-cols-2 gap-6">
      <Card: Tickets by Department />
      <Card: Service Frequency />
    </div>

    <!-- Priority Overview -->
    <Card: Active Tickets by Priority />
  </div>
</AppLayout>
```

---

## 3. Layout & Dimensions

### 3.1 Page Content Spacing
| Element | Property | Value | Tailwind Class |
|---------|----------|-------|----------------|
| Content wrapper | vertical gap | 24px | `space-y-6` |
| Main content padding | mobile | 16px | `p-4` |
| Main content padding | md+ | 24px | `md:p-6` |

### 3.2 Header Section
| Element | Property | Value | Tailwind Class |
|---------|----------|-------|----------------|
| Title (h1) | margin | 0 | — |
| Subtitle (p) | margin-top | 4px | `mt-1` |

### 3.3 KPI Cards Grid
| Property | Value | Tailwind Class |
|----------|-------|----------------|
| Columns (mobile) | 2 | `grid-cols-2` |
| Columns (lg+) | 4 | `lg:grid-cols-4` |
| Gap | 16px | `gap-4` |

### 3.4 Status + Activity Grid
| Property | Value | Tailwind Class |
|----------|-------|----------------|
| Columns (lg+) | 3 | `lg:grid-cols-3` |
| Gap | 24px | `gap-6` |
| Status card span | 1 column | `lg:col-span-1` |
| Activity card span | 2 columns | `lg:col-span-2` |

### 3.5 Department + Service Grid
| Property | Value | Tailwind Class |
|----------|-------|----------------|
| Columns (lg+) | 2 | `lg:grid-cols-2` |
| Gap | 24px | `gap-6` |

### 3.6 Priority Overview Grid
| Property | Value | Tailwind Class |
|----------|-------|----------------|
| Columns (mobile) | 2 | `grid-cols-2` |
| Columns (md+) | 4 | `md:grid-cols-4` |
| Gap | 16px | `gap-4` |

### 3.7 KPI Card Internal Layout
| Element | Property | Value | Tailwind Class |
|---------|----------|-------|----------------|
| CardContent | padding | 16px | `p-4` |
| Inner container | display | flex, space-between | `flex items-center justify-between` |
| Left-border accent | width | 4px | `border-l-4` |
| Icon box | size | 40×40px | `w-10 h-10` |
| Icon box | border-radius | 8px | `rounded-lg` |

---

## 4. Color Systems

### 4.1 KPI Card Colors
| Card | Left Border | Number Color | Icon | Icon Box BG |
|------|-------------|-------------|------|-------------|
| Active Tickets | `#3B82F6` (blue-500) | `#0F172A` (slate-900) | `#2563EB` (blue-600) | `#EFF6FF` (blue-50) |
| SLA Breaches | `#EF4444` (red-500) | `#DC2626` (red-600) | `#EF4444` (red-500) | `#FEF2F2` (red-50) |
| Resolved Today | `#22C55E` (green-500) | `#0F172A` (slate-900) | `#16A34A` (green-600) | `#F0FDF4` (green-50) |
| Avg Resolution | `#6366F1` (indigo-500) | `#0F172A` (slate-900) | `#4F46E5` (indigo-600) | `#EEF2FF` (indigo-50) |

### 4.2 Status Icon Colors
| Status | Icon | Color | HEX |
|--------|------|-------|-----|
| Open | Ticket | blue-600 | `#2563EB` |
| Assigned | ArrowRightLeft | indigo-600 | `#4F46E5` |
| InProgress | Activity | yellow-600 | `#CA8A04` |
| Paused | Pause | gray-500 | `#6B7280` |
| Resolved | CheckCircle2 | green-600 | `#16A34A` |
| Closed | CheckCircle2 | slate-500 | `#64748B` |
| PendingArbitration | AlertTriangle | orange-600 | `#EA580C` |
| PendingClarification | HelpCircle | purple-600 | `#9333EA` |

### 4.3 Progress Bar Colors
| Element | Color | HEX |
|---------|-------|-----|
| Status bar track | slate-100 | `#F1F5F9` |
| Status bar fill | blue-500 | `#3B82F6` |
| Department bar track | slate-100 | `#F1F5F9` |
| Department bar fill | indigo-500 | `#6366F1` |

### 4.4 Activity Timeline Colors
| Element | Color | HEX |
|---------|-------|-----|
| Dot indicator | blue-500 | `#3B82F6` |
| Border between items | slate-100 | `#F1F5F9` |
| Action text | slate-800 | `#1E293B` |
| Ticket link | blue-600 | `#2563EB` |
| Notes text | slate-500 | `#64748B` |
| Performer/date text | slate-400 | `#94A3B8` |

### 4.5 Priority Card Colors (uses priorityColors from mockData)
| Priority | Background | Text | Border |
|----------|-----------|------|--------|
| Critical | `#FEE2E2` (red-100) | `#991B1B` (red-800) | `#FCA5A5` (red-300) |
| High | `#FFEDD5` (orange-100) | `#9A3412` (orange-800) | `#FDBA74` (orange-300) |
| Medium | `#FEF9C3` (yellow-100) | `#854D0E` (yellow-800) | `#FDE047` (yellow-300) |
| Low | `#DCFCE7` (green-100) | `#166534` (green-800) | `#86EFAC` (green-300) |

### 4.6 General Text Colors
| Usage | Color | HEX | Tailwind |
|-------|-------|-----|----------|
| Page title | slate-900 | `#0F172A` | `text-slate-900` |
| Subtitle | slate-500 | `#64748B` | `text-slate-500` |
| KPI label | slate-500 | `#64748B` | `text-slate-500` |
| KPI sub-note | slate-400 | `#94A3B8` | `text-slate-400` |
| Status label text | slate-700 | `#334155` | `text-slate-700` |
| Status count | slate-900 | `#0F172A` | `text-slate-900` |
| Card title | inherits | — | (shadcn default) |
| Service rank number | slate-400 | `#94A3B8` | `text-slate-400` |
| Service name | slate-700 | `#334155` | `text-slate-700` |

---

## 5. Typography

### 5.1 Font Family
```
font-family: "Inter", ui-sans-serif, system-ui, sans-serif
```

### 5.2 Font Sizes & Weights by Element

| Element | Font Size | Font Weight | Tailwind Classes |
|---------|-----------|-------------|-----------------|
| Page title "Dashboard" | 24px | 700 (bold) | `text-2xl font-bold` |
| Subtitle | 14px | 400 | `text-sm` |
| KPI label (uppercase) | 12px | 500 (medium) | `text-xs font-medium uppercase tracking-wide` |
| KPI number | 30px | 700 (bold) | `text-3xl font-bold` |
| KPI sub-note (840 min avg) | 10px | 400 | `text-[10px]` |
| Card title | 14px | 600 (semibold) | `text-sm font-semibold` |
| Status label in distribution | 14px | 400 | `text-sm` |
| Status count | 14px | 600 (semibold) | `text-sm font-semibold` |
| Activity action text | 14px | 600 (semibold) | `text-sm` + `font-semibold` (inline span) |
| Activity notes | 12px | 400 | `text-xs` |
| Activity performer/date | 10px | 400 | `text-[10px]` |
| Service rank number | 12px | 400 (mono) | `text-xs font-mono` |
| Service name | 14px | 400 | `text-sm` |
| Service badge | 12px | 600 | `text-xs` (Badge variant="secondary") |
| Department name | 14px | 400 | `text-sm` |
| Department count | 14px | 600 | `text-sm font-semibold` |
| Priority card number | 24px | 700 | `text-2xl font-bold` |
| Priority card label | 12px | 500 | `text-xs font-medium` |

---

## 6. UI Components & Icons

### 6.1 Components Used

| Component | Source | Purpose |
|-----------|--------|---------|
| `Card` | shadcn/ui | Container for each section |
| `CardContent` | shadcn/ui | Inner content area |
| `CardHeader` | shadcn/ui | Card header with title |
| `CardTitle` | shadcn/ui | Section title text |
| `Badge` | shadcn/ui | Status badges in activity, service count badges |
| `Link` | react-router-dom | Ticket number links in activity |

### 6.2 Icon Library — Lucide React

| Icon Name | Size (px) | Usage | Color |
|-----------|-----------|-------|-------|
| `Ticket` | 18 / 20 | Status icon (Open) / KPI icon (Active Tickets) | blue-600 |
| `AlertTriangle` | 18 / 20 | Status icon (PendingArbitration) / KPI icon (SLA Breaches) | orange-600 / red-500 |
| `Clock` | 20 | KPI icon (Avg Resolution) | indigo-600 |
| `CheckCircle2` | 18 / 20 | Status icon (Resolved, Closed) / KPI icon (Resolved Today) | green-600 / slate-500 |
| `Pause` | 18 | Status icon (Paused) | gray-500 |
| `ArrowRightLeft` | 18 | Status icon (Assigned) | indigo-600 |
| `HelpCircle` | 18 | Status icon (PendingClarification) | purple-600 |
| `TrendingUp` | 16 | Recent Activity card title icon | (inherits) |
| `Activity` | 18 | Status icon (InProgress) | yellow-600 |

---

## 7. Section-by-Section Specification

### 7.1 KPI Cards (4 cards)

Each KPI card has:
```
Card: border-l-4 border-l-{color}-500
  CardContent: p-4
    Flex container: flex items-center justify-between
      Left side:
        Label: text-xs text-slate-500 font-medium uppercase tracking-wide
        Number: text-3xl font-bold text-{color} mt-1
        (Optional sub-note): text-[10px] text-slate-400
      Right side:
        Icon box: w-10 h-10 rounded-lg bg-{color}-50 flex items-center justify-center
          Icon: size=20, text-{color}-600
```

**Card 1 — Active Tickets**
- Label: "Active Tickets"
- Value: Count of tickets where status ≠ "Resolved" and ≠ "Closed"
- Number color: `text-slate-900`
- Border: `border-l-blue-500`
- Icon: `Ticket` (20px), `text-blue-600`, box: `bg-blue-50`

**Card 2 — SLA Breaches**
- Label: "SLA Breaches"
- Value: Count of tickets where `slaBreached === true`
- Number color: `text-red-600`
- Border: `border-l-red-500`
- Icon: `AlertTriangle` (20px), `text-red-500`, box: `bg-red-50`

**Card 3 — Resolved Today**
- Label: "Resolved Today"
- Value: Count of tickets resolved on current date (April 14, 2026)
- Number color: `text-slate-900`
- Border: `border-l-green-500`
- Icon: `CheckCircle2` (20px), `text-green-600`, box: `bg-green-50`

**Card 4 — Avg Resolution**
- Label: "Avg Resolution"
- Value: "14h" (hardcoded display)
- Sub-note: "840 min avg"
- Number color: `text-slate-900`
- Border: `border-l-indigo-500`
- Icon: `Clock` (20px), `text-indigo-600`, box: `bg-indigo-50`

### 7.2 Tickets by Status (Status Distribution)

```
Card: lg:col-span-1
  CardHeader: pb-3
    CardTitle: text-sm font-semibold → "Tickets by Status"
  CardContent: space-y-2
    For each of 8 statuses:
      Row: flex items-center gap-3
        Icon: status-specific icon (18px)
        Label: text-sm text-slate-700 flex-1 → status display name
        Progress bar: w-24 h-2 bg-slate-100 rounded-full overflow-hidden
          Fill: h-full bg-blue-500 rounded-full, width = (count/total)*100%
        Count: text-sm font-semibold text-slate-900 w-6 text-right
```

**Progress bar dimensions**: width: 96px (`w-24`), height: 8px (`h-2`)
**Track color**: `#F1F5F9` (slate-100)
**Fill color**: `#3B82F6` (blue-500)
**Fill calculation**: `(statusCount / totalTickets) * 100`%

### 7.3 Recent Activity Timeline

```
Card: lg:col-span-2
  CardHeader: pb-3
    CardTitle: text-sm font-semibold flex items-center gap-2
      TrendingUp icon (16px)
      "Recent Activity"
  CardContent:
    Container: space-y-3
      For each of last 8 history entries (sorted newest first):
        Row: flex items-start gap-3 pb-3 border-b border-slate-100 last:border-0 last:pb-0
          Dot: w-2 h-2 rounded-full bg-blue-500 mt-2 shrink-0
          Content: flex-1 min-w-0
            Line 1: text-sm text-slate-800
              Action (bold): font-semibold
              " — "
              Ticket link: text-blue-600 hover:underline
            Line 2: text-xs text-slate-500 mt-0.5 truncate → notes
            Line 3: text-[10px] text-slate-400 mt-0.5 → "performer · date"
          Badge (if newStatus): text-[10px] shrink-0, statusColors applied
```

**Dot**: 8×8px circle, `#3B82F6` (blue-500)
**Border between items**: 1px solid `#F1F5F9` (slate-100), last item has no border
**Date format**: "MMM D, HH:MM AM/PM" (e.g., "Apr 14, 04:00 PM")

### 7.4 Tickets by Department

```
Card:
  CardHeader: pb-3
    CardTitle: text-sm font-semibold → "Tickets by Department"
  CardContent: space-y-3
    For each department (sorted by count descending):
      Row: flex items-center gap-3
        Label: text-sm text-slate-700 flex-1
        Progress bar: w-32 h-3 bg-slate-100 rounded-full overflow-hidden
          Fill: h-full bg-indigo-500 rounded-full, width = (count/total)*100%
        Count: text-sm font-semibold text-slate-900 w-6 text-right
```

**Progress bar dimensions**: width: 128px (`w-32`), height: 12px (`h-3`)
**Fill color**: `#6366F1` (indigo-500)

### 7.5 Service Frequency

```
Card:
  CardHeader: pb-3
    CardTitle: text-sm font-semibold → "Service Frequency"
  CardContent: space-y-3
    For top 6 services (sorted by count descending):
      Row: flex items-center gap-3
        Rank: text-xs font-mono text-slate-400 w-4 → "1.", "2.", etc.
        Name: text-sm text-slate-700 flex-1 truncate
        Badge: variant="secondary" text-xs → "N tickets" or "1 ticket"
```

**Badge variant="secondary"**: bg: `#F1F5F9` (slate-100), text: `#475569` (slate-600), font-weight: 600

### 7.6 Active Tickets by Priority

```
Card:
  CardHeader: pb-3
    CardTitle: text-sm font-semibold → "Active Tickets by Priority"
  CardContent:
    Grid: grid-cols-2 md:grid-cols-4 gap-4
      For each priority (Critical, High, Medium, Low):
        Box: rounded-lg border p-4 text-center + priorityColors[priority]
          Number: text-2xl font-bold → count of active tickets with this priority
          Label: text-xs font-medium mt-1 → priority name
```

**Active = status not in ["Resolved", "Closed"]**

Priority box colors (same as badge colors):
| Priority | Background | Text | Border |
|----------|-----------|------|--------|
| Critical | `bg-red-100` | `text-red-800` | `border-red-300` |
| High | `bg-orange-100` | `text-orange-800` | `border-orange-300` |
| Medium | `bg-yellow-100` | `text-yellow-800` | `border-yellow-300` |
| Low | `bg-green-100` | `text-green-800` | `border-green-300` |

---

## 8. Styling Methodology

### 8.1 Framework
**Tailwind CSS v3.x** with **shadcn/ui** component library.

### 8.2 Soft-UI Design Principles Applied
1. **Left-border accent on KPI cards**: `border-l-4` creates a colored accent strip without overwhelming the card
2. **Pastel icon backgrounds**: `bg-{color}-50` (lightest shade) behind icons creates depth without heaviness
3. **Rounded progress bars**: `rounded-full` on both track and fill for a pill-shaped appearance
4. **Subtle separators**: `border-slate-100` for timeline item borders — nearly invisible
5. **Consistent card structure**: All sections use `Card > CardHeader > CardTitle + CardContent` pattern
6. **Uppercase micro-labels**: `text-xs uppercase tracking-wide font-medium` for KPI labels creates a dashboard feel
7. **Timeline dots**: Small 8px blue circles create visual rhythm in the activity feed

---

## 9. Data & Logic

### 9.1 KPI Calculations
```javascript
// Active Tickets
totalOpen = tickets.filter(t => !["Resolved", "Closed"].includes(t.status)).length;

// SLA Breaches
breached = tickets.filter(t => t.slaBreached).length;

// Resolved Today (hardcoded reference date: April 14, 2026)
resolvedToday = tickets.filter(t =>
  t.resolvedAt && new Date(t.resolvedAt).toDateString() === new Date("2026-04-14").toDateString()
).length;

// Avg Resolution (hardcoded)
avgCompletionMin = 840; // displayed as "14h"
```

### 9.2 Status Counts
```javascript
getStatusCounts() → Record<string, number>
// Iterates all tickets, counts per status
```

### 9.3 Department Counts
```javascript
getDepartmentCounts() → Record<string, number>
// Iterates all tickets, counts per department
// Displayed sorted by count descending
```

### 9.4 Service Frequency
```javascript
getServiceFrequency() → [serviceName, count][]
// Iterates all tickets, counts per serviceName
// Sorted by count descending, top 6 shown
```

### 9.5 Recent Activity
```javascript
// Gather all history entries from ticketHistories (Record<number, HistoryEntry[]>)
allHistory = Object.values(ticketHistories)
  .flat()
  .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
  .slice(0, 8); // Last 8 entries
```

### 9.6 Date Formatting
```javascript
formatDateTime(iso) → "MMM D, HH:MM AM/PM"
// e.g., "Apr 14, 04:00 PM"
// Uses: new Date(iso).toLocaleString("en-US", { month: "short", day: "numeric", hour: "2-digit", minute: "2-digit" })
```

---

## 10. Complete CSS Class Reference

### 10.1 Page Wrapper
```
space-y-6
```

### 10.2 Header
```
h1: text-2xl font-bold text-slate-900
p:  text-sm text-slate-500 mt-1
```

### 10.3 KPI Cards
```
Grid: grid grid-cols-2 lg:grid-cols-4 gap-4

Card: border-l-4 border-l-{color}-500
CardContent: p-4
Inner: flex items-center justify-between
Label: text-xs text-slate-500 font-medium uppercase tracking-wide
Number: text-3xl font-bold text-{color} mt-1
Sub-note: text-[10px] text-slate-400
Icon box: w-10 h-10 rounded-lg bg-{color}-50 flex items-center justify-center
Icon: size=20 text-{color}-600
```

### 10.4 Status Distribution
```
Card: lg:col-span-1
CardHeader: pb-3
CardTitle: text-sm font-semibold
CardContent: space-y-2
Row: flex items-center gap-3
Icon: size=18 text-{status-color}
Label: text-sm text-slate-700 flex-1
Track: w-24 h-2 bg-slate-100 rounded-full overflow-hidden
Fill: h-full bg-blue-500 rounded-full transition-all
Count: text-sm font-semibold text-slate-900 w-6 text-right
```

### 10.5 Recent Activity
```
Card: lg:col-span-2
CardHeader: pb-3
CardTitle: text-sm font-semibold flex items-center gap-2
CardContent: (no extra class)
Container: space-y-3
Row: flex items-start gap-3 pb-3 border-b border-slate-100 last:border-0 last:pb-0
Dot: w-2 h-2 rounded-full bg-blue-500 mt-2 shrink-0
Content: flex-1 min-w-0
Action line: text-sm text-slate-800
Action bold: font-semibold
Link: text-blue-600 hover:underline
Notes: text-xs text-slate-500 mt-0.5 truncate
Meta: text-[10px] text-slate-400 mt-0.5
Badge: text-[10px] shrink-0 + statusColors
```

### 10.6 Department Workload
```
CardContent: space-y-3
Row: flex items-center gap-3
Label: text-sm text-slate-700 flex-1
Track: w-32 h-3 bg-slate-100 rounded-full overflow-hidden
Fill: h-full bg-indigo-500 rounded-full
Count: text-sm font-semibold text-slate-900 w-6 text-right
```

### 10.7 Service Frequency
```
CardContent: space-y-3
Row: flex items-center gap-3
Rank: text-xs font-mono text-slate-400 w-4
Name: text-sm text-slate-700 flex-1 truncate
Badge: variant="secondary" text-xs
```

### 10.8 Priority Overview
```
Grid: grid grid-cols-2 md:grid-cols-4 gap-4
Box: rounded-lg border p-4 text-center + priorityColors[priority]
Number: text-2xl font-bold
Label: text-xs font-medium mt-1
```

---

## Appendix A: Equivalent Pure CSS

```css
/* KPI Card */
.kpi-card {
  background: #FFFFFF;
  border: 1px solid #E2E8F0;
  border-left: 4px solid; /* color varies */
  border-radius: 8px;
  box-shadow: 0 1px 2px rgba(0,0,0,0.05);
  padding: 16px;
}
.kpi-card-inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.kpi-label {
  font-size: 12px;
  font-weight: 500;
  color: #64748B;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
.kpi-number {
  font-size: 30px;
  font-weight: 700;
  margin-top: 4px;
}
.kpi-icon-box {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Progress bar */
.progress-track {
  background: #F1F5F9;
  border-radius: 9999px;
  overflow: hidden;
}
.progress-fill {
  height: 100%;
  border-radius: 9999px;
  transition: width 0.3s;
}

/* Activity timeline item */
.activity-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid #F1F5F9;
}
.activity-item:last-child {
  border-bottom: none;
  padding-bottom: 0;
}
.activity-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #3B82F6;
  margin-top: 8px;
  flex-shrink: 0;
}

/* Priority card */
.priority-card {
  border-radius: 8px;
  border: 1px solid;
  padding: 16px;
  text-align: center;
}
```

---

*End of Dashboard Implementation Report*