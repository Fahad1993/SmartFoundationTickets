# Reports and Analytics — Pixel-Perfect Implementation Details

> **Purpose**: This document captures every visual and structural detail of the "Reports and Analytics" page so that another developer (or AI agent) can reproduce it **identically** in any stack (C# MVC / Razor / plain HTML+CSS / etc.).

---

## Table of Contents

1. [Page Overview](#1-page-overview)
2. [Page Structure](#2-page-structure)
3. [Layout and Dimensions](#3-layout-and-dimensions)
4. [Color Systems](#4-color-systems)
5. [Typography](#5-typography)
6. [UI Components and Icons](#6-ui-components-and-icons)
7. [Section-by-Section Specification](#7-section-by-section-specification)
8. [Styling Methodology](#8-styling-methodology)
9. [Data and Logic](#9-data-and-logic)
10. [Complete CSS Class Reference](#10-complete-css-class-reference)

---

## 1. Page Overview

The Reports page (`/reports`) provides **operational analytics and performance metrics** with:
- **5 Mini KPI Cards** — Total Tickets, SLA Breaches, Near Overdue, Open Arbitrations, Open Clarifications
- **Status Distribution Chart** — Horizontal bar chart with count overlays
- **Service Request Frequency** — Ranked horizontal bars
- **Department Workload Table** — Table with health indicators
- **Overdue and At-Risk Tickets Table** — Filtered ticket list
- **SLA Breached Tickets** — Red-highlighted breached ticket cards (conditional)

---

## 2. Page Structure

```
AppLayout
  div.space-y-6
    -- Page Header --
    div
      h1: Reports and Analytics
      p: Operational insights and performance metrics

    -- Mini KPI Row --
    div.grid.grid-cols-2.lg:grid-cols-5.gap-4
      MiniKPI: Total Tickets
      MiniKPI: SLA Breaches
      MiniKPI: Near Overdue
      MiniKPI: Open Arbitrations
      MiniKPI: Open Clarifications

    -- Charts Row --
    div.grid.lg:grid-cols-2.gap-6
      Card: Status Distribution Chart
      Card: Service Request Frequency

    -- Department Workload Table --
    Card: Department Workload

    -- Overdue and At-Risk Tickets Table --
    Card: Overdue and At-Risk

    -- SLA Breached Tickets (conditional) --
    Card: SLA Breached
```

---

## 3. Layout and Dimensions

### 3.1 Page Content Spacing
| Element | Property | Value | Tailwind Class |
|---------|----------|-------|----------------|
| Content wrapper | vertical gap | 24px | `space-y-6` |

### 3.2 Mini KPI Grid
| Property | Value | Tailwind Class |
|----------|-------|----------------|
| Columns (mobile) | 2 | `grid-cols-2` |
| Columns (lg+) | 5 | `lg:grid-cols-5` |
| Gap | 16px | `gap-4` |

### 3.3 Mini KPI Card Internal Layout
| Element | Property | Value | Tailwind Class |
|---------|----------|-------|----------------|
| Card | left border | 4px | `border-l-4` |
| CardContent | padding | 12px | `p-3` |
| Inner | layout | flex, center | `flex items-center gap-3` |
| Icon box | size | 32x32px | `w-8 h-8` |
| Icon box | border-radius | 8px | `rounded-lg` |

### 3.4 Charts Grid
| Property | Value | Tailwind Class |
|----------|-------|----------------|
| Columns (lg+) | 2 | `lg:grid-cols-2` |
| Gap | 24px | `gap-6` |

### 3.5 Status Distribution Bar
| Element | Property | Value | Tailwind Class |
|---------|----------|-------|----------------|
| Label width | 128px | `w-32` |
| Bar height | 24px | `h-6` |
| Bar track bg | slate-100 | `bg-slate-100` |
| Bar border-radius | 4px | `rounded` |
| Count overlay | position | absolute inside bar | `absolute inset-0` |

### 3.6 Service Frequency Bar
| Element | Property | Value | Tailwind Class |
|---------|----------|-------|----------------|
| Rank width | 20px | `w-5` |
| Label width | 160px | `w-40` |
| Bar height | 20px | `h-5` |
| Count width | 24px | `w-6` |

### 3.7 Department Workload Table Columns
| Column | Alignment | Tailwind |
|--------|-----------|---------|
| Department | left | default |
| Total | center | `text-center` |
| Active | center | `text-center` |
| SLA Breached | center | `text-center` |
| Health | center | `text-center` |

### 3.8 Overdue Table Columns
| Column | Width/Notes |
|--------|-------------|
| Ticket No | auto |
| Title | max 200px, truncate |
| Priority | auto |
| Status | auto |
| SLA Remaining | auto |
| Department | auto |
| Created | auto |

---

## 4. Color Systems

### 4.1 Mini KPI Card Colors
| Card | Border | Number | Icon BG | Icon Color |
|------|--------|--------|---------|------------|
| Total Tickets | `#3B82F6` blue-500 | `#0F172A` slate-900 | `#EFF6FF` blue-50 | `#2563EB` blue-600 |
| SLA Breaches | `#EF4444` red-500 | `#DC2626` red-600 | `#FEF2F2` red-50 | `#EF4444` red-500 |
| Near Overdue | `#F59E0B` amber-500 | `#D97706` amber-600 | `#FFFBEB` amber-50 | `#D97706` amber-600 |
| Open Arbitrations | `#F97316` orange-500 | `#EA580C` orange-600 | `#FFF7ED` orange-50 | `#EA580C` orange-600 |
| Open Clarifications | `#A855F7` purple-500 | `#9333EA` purple-600 | `#FAF5FF` purple-50 | `#9333EA` purple-600 |

### 4.2 Status Bar Chart Colors
| Status | Bar Color | Tailwind |
|--------|-----------|---------|
| Open | `#3B82F6` blue-500 | `bg-blue-500` |
| Assigned | `#6366F1` indigo-500 | `bg-indigo-500` |
| InProgress | `#EAB308` yellow-500 | `bg-yellow-500` |
| Paused | `#9CA3AF` gray-400 | `bg-gray-400` |
| Resolved | `#22C55E` green-500 | `bg-green-500` |
| Closed | `#94A3B8` slate-400 | `bg-slate-400` |
| PendingArbitration | `#F97316` orange-500 | `bg-orange-500` |
| PendingClarification | `#A855F7` purple-500 | `bg-purple-500` |

### 4.3 Service Frequency Bar
| Element | Color | HEX |
|---------|-------|-----|
| Bar fill | indigo-500 | `#6366F1` |
| Bar track | slate-100 | `#F1F5F9` |

### 4.4 Department Health Badges
| Health | Background | Text |
|--------|-----------|------|
| Healthy | `#DCFCE7` green-100 | `#15803D` green-700 |
| Warning | `#FEF9C3` yellow-100 | `#A16207` yellow-700 |
| Critical | `#FEE2E2` red-100 | `#B91C1C` red-700 |

### 4.5 SLA Breached Badge
| Element | Background | Text |
|---------|-----------|------|
| Breach count | `#FEE2E2` red-100 | `#B91C1C` red-700 |

### 4.6 Overdue Table Colors
| Element | Color | HEX |
|---------|-------|-----|
| Breached row bg | red-50 | `#FEF2F2` |
| Breached SLA text | red-600 | `#DC2626` |
| At-risk SLA text | amber-600 | `#D97706` |
| Ticket number | blue-600 | `#2563EB` |

### 4.7 SLA Breached Section Colors
| Element | Color | HEX |
|---------|-------|-----|
| Card border | red-200 | `#FECACA` |
| Card title | red-700 | `#B91C1C` |
| Item bg | red-50 | `#FEF2F2` |
| Ticket number | red-700 | `#B91C1C` |
| Title text | slate-700 | `#334155` |
| Department | slate-500 | `#64748B` |

### 4.8 Bar Chart Count Overlay
| Element | Color | Notes |
|---------|-------|-------|
| Count text | white | `text-white` |
| Blend mode | difference | `mix-blend-difference` |

---

## 5. Typography

| Element | Font Size | Font Weight | Tailwind Classes |
|---------|-----------|-------------|-----------------|
| Page title | 24px | 700 | `text-2xl font-bold text-slate-900` |
| Subtitle | 14px | 400 | `text-sm text-slate-500 mt-1` |
| Mini KPI number | 20px | 700 | `text-xl font-bold` |
| Mini KPI label | 10px | 400 | `text-[10px] text-slate-500 uppercase tracking-wide` |
| Card title | 14px | 600 | `text-sm font-semibold` |
| Status label (chart) | 12px | 400 | `text-xs text-slate-600 w-32 truncate` |
| Bar count overlay | 11px | 700 | `text-[11px] font-bold text-white mix-blend-difference` |
| Service rank | 12px | 400 mono | `text-xs font-mono text-slate-400 w-5` |
| Service name | 12px | 400 | `text-xs text-slate-600 w-40 truncate` |
| Service count | 12px | 700 | `text-xs font-bold text-slate-700 w-6 text-right` |
| Dept table name | 14px | 500 | `font-medium text-sm` |
| Dept table numbers | 14px | 400 | `text-sm` |
| Zero breaches | 14px | 400 | `text-slate-400 text-sm` |
| Overdue ticket number | 12px | 500 mono | `font-mono text-xs text-blue-600 font-medium` |
| Overdue title | 14px | 400 | `text-sm` |
| Overdue SLA text | 12px | 600 | `text-xs font-semibold` |
| Overdue dept | 14px | 400 | `text-sm text-slate-600` |
| Overdue date | 12px | 400 | `text-xs text-slate-500` |
| Breached ticket number | 12px | 700 mono | `font-mono text-xs text-red-700 font-bold` |
| Breached title | 14px | 400 | `text-sm text-slate-700` |
| Breached dept | 12px | 400 | `text-xs text-slate-500` |

---

## 6. UI Components and Icons

### 6.1 Components Used

| Component | Source | Purpose |
|-----------|--------|---------|
| Card, CardContent, CardHeader, CardTitle | shadcn/ui | All section containers |
| Badge | shadcn/ui | Priority, status, health, breach count badges |
| Table, TableBody, TableCell, TableHead, TableHeader, TableRow | shadcn/ui | Dept workload and overdue tables |

### 6.2 Icon Library — Lucide React

| Icon Name | Size px | Usage | Color |
|-----------|---------|-------|-------|
| BarChart3 | 16 | Mini KPI: Total Tickets | blue-600 |
| AlertTriangle | 12/15/16 | Mini KPI: SLA Breaches, Overdue SLA indicator, Breached section title | red-500/red-600/red-700 |
| Clock | 15/16 | Mini KPI: Near Overdue, Overdue section title | amber-600/amber-700 |
| Scale | 16 | Mini KPI: Open Arbitrations | orange-600 |
| MessageSquare | 16 | Mini KPI: Open Clarifications | purple-600 |
| TrendingUp | 15 | Status Distribution chart title | inherits |

---

## 7. Section-by-Section Specification

### 7.1 Mini KPI Cards (MiniKPI Component)

Each MiniKPI card structure:
```
Card: border-l-4 + border color
  CardContent: p-3 flex items-center gap-3
    Icon box: w-8 h-8 rounded-lg flex items-center justify-center + icon bg/color
      Icon: size=16
    Content:
      Number: text-xl font-bold + text color
      Label: text-[10px] text-slate-500 uppercase tracking-wide
```

**5 Cards:**

| Card | Label | Icon | Border | Number Color | Icon BG | Icon Color |
|------|-------|------|--------|-------------|---------|------------|
| 1 | Total Tickets | BarChart3 | border-l-blue-500 | text-slate-900 | bg-blue-50 text-blue-600 | blue-600 |
| 2 | SLA Breaches | AlertTriangle | border-l-red-500 | text-red-600 | bg-red-50 text-red-500 | red-500 |
| 3 | Near Overdue | Clock | border-l-amber-500 | text-amber-600 | bg-amber-50 text-amber-600 | amber-600 |
| 4 | Open Arbitrations | Scale | border-l-orange-500 | text-orange-600 | bg-orange-50 text-orange-600 | orange-600 |
| 5 | Open Clarifications | MessageSquare | border-l-purple-500 | text-purple-600 | bg-purple-50 text-purple-600 | purple-600 |

### 7.2 Status Distribution Chart

```
Card:
  CardHeader pb-3:
    CardTitle: text-sm font-semibold flex items-center gap-2
      TrendingUp (15px)
      "Ticket Status Distribution"
  CardContent:
    Container: space-y-3
      For each of 8 statuses:
        Row: flex items-center gap-3
          Label: text-xs text-slate-600 w-32 truncate -> status display name
          Bar container: flex-1 h-6 bg-slate-100 rounded overflow-hidden relative
            Fill: h-full rounded transition-all + statusBarColor, width = (count/maxCount)*100%
            Count overlay (if count > 0):
              span: absolute inset-0 flex items-center pl-2 text-[11px] font-bold text-white mix-blend-difference
```

**Bar width calculation**: `(count / maxCount) * 100` where maxCount is the highest status count (minimum 1).

**Count overlay**: Uses `mix-blend-difference` to ensure white text is readable on any bar color.

### 7.3 Service Request Frequency

```
Card:
  CardHeader pb-3:
    CardTitle: text-sm font-semibold -> "Service Request Frequency"
  CardContent:
    Container: space-y-3
      For each service (all, sorted by count desc):
        Row: flex items-center gap-3
          Rank: text-xs font-mono text-slate-400 w-5 -> "1.", "2.", etc.
          Name: text-xs text-slate-600 w-40 truncate
          Bar: flex-1 h-5 bg-slate-100 rounded overflow-hidden
            Fill: h-full bg-indigo-500 rounded, width = (count/maxSvcCount)*100%
          Count: text-xs font-bold text-slate-700 w-6 text-right
```

**Bar width calculation**: `(count / serviceFreq[0][1]) * 100` — relative to the most frequent service.

### 7.4 Department Workload Table

```
Card:
  CardHeader pb-3:
    CardTitle: text-sm font-semibold -> "Department Workload"
  CardContent p-0:
    Table:
      Headers: Department | Total (center) | Active (center) | SLA Breached (center) | Health (center)
      Rows (sorted by total desc):
        Department: font-medium text-sm
        Total: text-center text-sm
        Active: text-center text-sm
        SLA Breached:
          If > 0: Badge bg-red-100 text-red-700 -> count
          If 0: span text-slate-400 text-sm -> "0"
        Health:
          If breached == 0: Badge bg-green-100 text-green-700 -> "Healthy"
          If breached <= 1: Badge bg-yellow-100 text-yellow-700 -> "Warning"
          If breached > 1: Badge bg-red-100 text-red-700 -> "Critical"
```

### 7.5 Overdue and At-Risk Tickets Table

**Filter**: Tickets where status is NOT "Resolved"/"Closed" AND `slaCompletionRemainMin < 240` (less than 4 hours).

```
Card:
  CardHeader pb-3:
    CardTitle: text-sm font-semibold flex items-center gap-2 text-amber-700
      Clock (15px)
      "Overdue and At-Risk Tickets"
  CardContent p-0:
    Table:
      Headers: Ticket # | Title | Priority | Status | SLA Remaining | Department | Created
      Rows:
        Row class: if slaBreached then "bg-red-50" else ""
        Ticket #: font-mono text-xs text-blue-600 font-medium
        Title: text-sm max-w-[200px] truncate
        Priority: Badge text-[10px] + priorityColors
        Status: Badge text-[10px] + statusColors
        SLA Remaining:
          Container: text-xs font-semibold
          Color: if slaCompletionRemainMin <= 0 then text-red-600 else text-amber-600
          Content:
            If slaBreached: flex items-center gap-1 -> AlertTriangle(12px) + "Breached"
            Else: formatMinutes(slaCompletionRemainMin)
        Department: text-sm text-slate-600
        Created: text-xs text-slate-500 -> formatDate(createdAt)

      Empty state: colSpan=7 text-center py-8 text-slate-400 -> "No overdue or at-risk tickets"
```

### 7.6 SLA Breached Tickets (Conditional Section)

Only shown when `breachedTickets.length > 0`.

```
Card: border-red-200
  CardHeader pb-3:
    CardTitle: text-sm font-semibold flex items-center gap-2 text-red-700
      AlertTriangle (15px)
      "SLA Breached Tickets"
  CardContent:
    Container: space-y-2
      For each breached ticket:
        Row: flex items-center gap-3 p-3 bg-red-50 rounded-lg
          Ticket #: font-mono text-xs text-red-700 font-bold
          Title: text-sm text-slate-700 flex-1 truncate
          Priority Badge: text-[10px] + priorityColors
          Status Badge: text-[10px] + statusColors
          Department: text-xs text-slate-500
```

---

## 8. Styling Methodology

### 8.1 Design Principles
1. **5-column KPI row**: Compact cards with left-border accent, smaller icon boxes (32px vs 40px on Dashboard)
2. **CSS-based bar charts**: No charting library needed — pure div-based horizontal bars with percentage widths
3. **mix-blend-difference**: Ensures count text inside bars is always readable regardless of bar color
4. **Health indicators**: Traffic-light pattern (green/yellow/red) for department health badges
5. **Conditional sections**: SLA Breached section only appears when there are breached tickets
6. **Amber-themed overdue section**: Title uses `text-amber-700` to signal urgency without red-level alarm
7. **Red-themed breached section**: Card border `border-red-200` and title `text-red-700` for highest severity

### 8.2 Bar Chart Technique
```css
/* Pure CSS horizontal bar chart */
.bar-track {
  flex: 1;
  height: 24px;
  background: #F1F5F9;
  border-radius: 4px;
  overflow: hidden;
  position: relative;
}
.bar-fill {
  height: 100%;
  border-radius: 4px;
  transition: width 0.3s;
}
.bar-count {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  padding-left: 8px;
  font-size: 11px;
  font-weight: 700;
  color: white;
  mix-blend-mode: difference;
}
```

---

## 9. Data and Logic

### 9.1 KPI Calculations
```javascript
totalTickets = tickets.length;  // 10

breachedTickets = tickets.filter(t => t.slaBreached);  // slaBreached === true

overdueTickets = tickets.filter(t =>
  !["Resolved", "Closed"].includes(t.status) && t.slaCompletionRemainMin < 240
);  // active tickets with less than 4 hours remaining

openArbitrations = arbitrationCases.filter(a => a.status === "Open").length;

openClarifications = clarificationRequests.filter(c => c.status === "Open").length;
```

### 9.2 Status Distribution
```javascript
statusCounts = getStatusCounts();  // Record of status to count
allStatuses = Object.keys(statusLabels) as TicketStatus[];  // all 8 statuses
maxCount = Math.max(...allStatuses.map(s => statusCounts[s] || 0), 1);  // for bar width calc
```

### 9.3 Service Frequency
```javascript
serviceFreq = getServiceFrequency();  // [serviceName, count][] sorted desc
// All services shown (not limited to top 6 like Dashboard)
maxSvcCount = serviceFreq[0]?.[1] || 1;  // highest count for bar width calc
```

### 9.4 Department Workload
```javascript
deptWorkload: Record<string, { total: number; active: number; breached: number }> = {};
for (const t of tickets) {
  if (!deptWorkload[t.department]) {
    deptWorkload[t.department] = { total: 0, active: 0, breached: 0 };
  }
  deptWorkload[t.department].total++;
  if (!["Resolved", "Closed"].includes(t.status)) deptWorkload[t.department].active++;
  if (t.slaBreached) deptWorkload[t.department].breached++;
}
// Displayed sorted by total descending
```

### 9.5 Health Logic
```javascript
if (breached === 0) -> "Healthy" (green)
else if (breached <= 1) -> "Warning" (yellow)
else -> "Critical" (red)
```

### 9.6 Date Formatting
```javascript
formatDate(iso) -> "MMM D, YYYY"
// e.g., "Apr 10, 2026"
// Uses: new Date(iso).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })

formatMinutes(min):
  if (min <= 0) return "Overdue";
  if (min < 60) return `${min}m`;
  if (min < 1440) return `${Math.floor(min / 60)}h ${min % 60}m`;
  return `${Math.floor(min / 1440)}d ${Math.floor((min % 1440) / 60)}h`;
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
p: text-sm text-slate-500 mt-1
```

### 10.3 Mini KPI Cards
```
Grid: grid grid-cols-2 lg:grid-cols-5 gap-4
Card: border-l-4 + border-l-{color}-500
CardContent: p-3 flex items-center gap-3
Icon box: w-8 h-8 rounded-lg flex items-center justify-center + bg/text color
Icon: size=16
Number: text-xl font-bold + text color
Label: text-[10px] text-slate-500 uppercase tracking-wide
```

### 10.4 Status Distribution Chart
```
CardHeader: pb-3
CardTitle: text-sm font-semibold flex items-center gap-2
Container: space-y-3
Row: flex items-center gap-3
Label: text-xs text-slate-600 w-32 truncate
Bar track: flex-1 h-6 bg-slate-100 rounded overflow-hidden relative
Bar fill: h-full rounded transition-all + statusBarColor
Count: absolute inset-0 flex items-center pl-2 text-[11px] font-bold text-white mix-blend-difference
```

### 10.5 Service Frequency
```
CardHeader: pb-3
CardTitle: text-sm font-semibold
Container: space-y-3
Row: flex items-center gap-3
Rank: text-xs font-mono text-slate-400 w-5
Name: text-xs text-slate-600 w-40 truncate
Bar track: flex-1 h-5 bg-slate-100 rounded overflow-hidden
Bar fill: h-full bg-indigo-500 rounded
Count: text-xs font-bold text-slate-700 w-6 text-right
```

### 10.6 Department Workload
```
CardHeader: pb-3
CardTitle: text-sm font-semibold
CardContent: p-0
Department: font-medium text-sm
Numbers: text-center text-sm
Zero: text-slate-400 text-sm
Breach badge: bg-red-100 text-red-700
Healthy badge: bg-green-100 text-green-700
Warning badge: bg-yellow-100 text-yellow-700
Critical badge: bg-red-100 text-red-700
```

### 10.7 Overdue and At-Risk
```
Card title: text-sm font-semibold flex items-center gap-2 text-amber-700
CardContent: p-0
Breached row: bg-red-50
Ticket #: font-mono text-xs text-blue-600 font-medium
Title: text-sm max-w-[200px] truncate
Priority badge: text-[10px] + priorityColors
Status badge: text-[10px] + statusColors
SLA text: text-xs font-semibold text-red-600 or text-amber-600
Breached indicator: flex items-center gap-1 (AlertTriangle 12px + "Breached")
Department: text-sm text-slate-600
Date: text-xs text-slate-500
Empty: colSpan=7 text-center py-8 text-slate-400
```

### 10.8 SLA Breached Section
```
Card: border-red-200
Title: text-sm font-semibold flex items-center gap-2 text-red-700
Container: space-y-2
Row: flex items-center gap-3 p-3 bg-red-50 rounded-lg
Ticket #: font-mono text-xs text-red-700 font-bold
Title: text-sm text-slate-700 flex-1 truncate
Priority badge: text-[10px] + priorityColors
Status badge: text-[10px] + statusColors
Department: text-xs text-slate-500
```

---

## Appendix A: Equivalent Pure CSS

```css
/* Mini KPI card */
.mini-kpi {
  background: white;
  border: 1px solid #E2E8F0;
  border-left: 4px solid;
  border-radius: 8px;
  box-shadow: 0 1px 2px rgba(0,0,0,0.05);
  padding: 12px;
  display: flex;
  align-items: center;
  gap: 12px;
}
.mini-kpi-icon {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.mini-kpi-number {
  font-size: 20px;
  font-weight: 700;
}
.mini-kpi-label {
  font-size: 10px;
  color: #64748B;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

/* Bar chart */
.bar-track {
  flex: 1;
  background: #F1F5F9;
  border-radius: 4px;
  overflow: hidden;
  position: relative;
}
.bar-fill {
  height: 100%;
  border-radius: 4px;
  transition: width 0.3s;
}
.bar-count-overlay {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  padding-left: 8px;
  font-size: 11px;
  font-weight: 700;
  color: white;
  mix-blend-mode: difference;
}

/* Health badges */
.badge-healthy { background: #DCFCE7; color: #15803D; }
.badge-warning { background: #FEF9C3; color: #A16207; }
.badge-critical { background: #FEE2E2; color: #B91C1C; }

/* Breached row */
.row-breached { background: #FEF2F2; }

/* Breached section */
.breached-card { border-color: #FECACA; }
.breached-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: #FEF2F2;
  border-radius: 8px;
}
.breached-ticket-no {
  font-family: monospace;
  font-size: 12px;
  font-weight: 700;
  color: #B91C1C;
}
```

---

*End of Reports and Analytics Implementation Report*