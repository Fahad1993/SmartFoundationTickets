# Service Catalogue — Pixel-Perfect Implementation Details

> **Purpose**: This document captures every visual and structural detail of the "Service Catalogue" page so that another developer (or AI agent) can reproduce it **identically** in any stack (C# MVC / Razor / plain HTML+CSS / etc.).

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

The Service Catalogue page (`/services`) displays all available services in a **searchable table** with a **detail dialog**. It includes:
- **Header** — Title, subtitle with counts, search input
- **Service Table** — 7 columns (Code, Name, Department, Division/Section, Priority, Status, Actions)
- **Detail Dialog** — Modal showing routing rules and SLA policies for a selected service

---

## 2. Page Structure

```
<AppLayout>
  <div class="space-y-6">                    <!-- 24px vertical gap -->
    <!-- Header Row -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
      <div>
        <h1>Service Catalogue</h1>
        <p>10 services · 9 active</p>
      </div>
      <SearchInput />
    </div>

    <!-- Table Card -->
    <Card>
      <Table>
        <TableHeader>7 columns</TableHeader>
        <TableBody>service rows</TableBody>
      </Table>
    </Card>

    <!-- Detail Dialog (modal, opens on Eye click) -->
    <Dialog>
      <DialogContent>
        <DialogHeader>service code + name</DialogHeader>
        <Card: Routing Rule />
        <Card: SLA Policy />
        <StatusFooter />
      </DialogContent>
    </Dialog>
  </div>
</AppLayout>
```

---

## 3. Layout & Dimensions

### 3.1 Page Content Spacing
| Element | Property | Value | Tailwind Class |
|---------|----------|-------|----------------|
| Content wrapper | vertical gap | 24px | `space-y-6` |

### 3.2 Header Layout
| Property | Value | Tailwind Class |
|----------|-------|----------------|
| Direction | column (mobile), row (sm+) | `flex-col sm:flex-row` |
| Alignment (sm+) | center, space-between | `sm:items-center sm:justify-between` |
| Gap | 12px | `gap-3` |

### 3.3 Search Input
| Property | Value | Tailwind Class |
|----------|-------|----------------|
| Width (mobile) | 100% | `w-full` |
| Width (sm+) | 288px | `sm:w-72` |
| Height | 36px | `h-9` |
| Padding-left | 36px | `pl-9` |
| Icon position | absolute, left: 12px, centered | `absolute left-3 top-1/2 -translate-y-1/2` |
| Icon size | 16px | `size={16}` |
| Icon color | slate-400 | `text-slate-400` |

### 3.4 Table Card
| Property | Value | Tailwind Class |
|----------|-------|----------------|
| CardContent padding | 0 | `p-0` |

### 3.5 Table Columns
| Column | Width | Tailwind Class |
|--------|-------|----------------|
| Code | 96px | `w-24` |
| Service Name | auto | — |
| Department | auto | — |
| Division / Section | auto | — |
| Priority | auto | — |
| Status | auto, centered | `text-center` |
| Actions | 80px, centered | `text-center w-20` |

### 3.6 Detail Dialog
| Property | Value | Tailwind Class |
|----------|-------|----------------|
| Max width | 512px | `max-w-lg` |
| Internal gap | 20px | `space-y-5` |

### 3.7 Routing Rule Grid
| Property | Value | Tailwind Class |
|----------|-------|----------------|
| Columns | 3 | `grid-cols-3` |
| Gap | 12px | `gap-3` |

### 3.8 SLA Policy Grid
| Property | Value | Tailwind Class |
|----------|-------|----------------|
| Columns | 2 | `grid-cols-2` |
| Gap | 12px | `gap-3` |
| SLA box padding | 12px | `p-3` |
| SLA box border-radius | 8px | `rounded-lg` |
| SLA box text-align | center | `text-center` |

---

## 4. Color Systems

### 4.1 Text Colors
| Usage | Color | HEX | Tailwind |
|-------|-------|-----|----------|
| Page title | slate-900 | `#0F172A` | `text-slate-900` |
| Subtitle | slate-500 | `#64748B` | `text-slate-500` |
| Service code | slate-500 | `#64748B` | `text-slate-500` |
| Service name | inherits (dark) | — | `font-medium text-sm` |
| Department | slate-600 | `#475569` | `text-slate-600` |
| Division/Section | slate-600 | `#475569` | `text-slate-600` |
| Empty state | slate-400 | `#94A3B8` | `text-slate-400` |
| Dialog code | slate-400 | `#94A3B8` | `text-slate-400` |
| Routing label | slate-400 | `#94A3B8` | `text-slate-400` |
| Routing value | inherits | — | `font-medium` |
| Footer text | slate-400 | `#94A3B8` | `text-slate-400` |
| Active status text | green-600 | `#16A34A` | `text-green-600` |
| Inactive status text | slate-500 | `#64748B` | `text-slate-500` |

### 4.2 Status Icons
| State | Icon | Color | HEX |
|-------|------|-------|-----|
| Active | CheckCircle | green-500 | `#22C55E` |
| Inactive | XCircle | slate-400 | `#94A3B8` |

### 4.3 Action Button
| Element | Color | HEX |
|---------|-------|-----|
| Eye icon | slate-500 | `#64748B` |
| Button | ghost variant | transparent bg |
| Button size | 32×32px | `h-8 w-8` |

### 4.4 Priority Badge Colors (same as global)
| Priority | Background | Text | Border |
|----------|-----------|------|--------|
| Critical | `#FEE2E2` | `#991B1B` | `#FCA5A5` |
| High | `#FFEDD5` | `#9A3412` | `#FDBA74` |
| Medium | `#FEF9C3` | `#854D0E` | `#FDE047` |
| Low | `#DCFCE7` | `#166534` | `#86EFAC` |

### 4.5 SLA Policy Box Colors
| SLA Type | Background | Label Color | Value Color |
|----------|-----------|-------------|-------------|
| First Response | `#EFF6FF` (blue-50) | `#2563EB` (blue-600) | `#1E40AF` (blue-800) |
| Assignment | `#EEF2FF` (indigo-50) | `#4F46E5` (indigo-600) | `#3730A3` (indigo-800) |
| Completion | `#FEFCE8` (yellow-50) | `#A16207` (yellow-700) | `#854D0E` (yellow-800) |
| Final Closure | `#F0FDF4` (green-50) | `#16A34A` (green-600) | `#166534` (green-800) |

### 4.6 Routing Rule Section
| Element | Color | HEX |
|---------|-------|-----|
| Section title | slate-500 | `#64748B` |
| Label | slate-400 | `#94A3B8` |

---

## 5. Typography

| Element | Font Size | Font Weight | Tailwind Classes |
|---------|-----------|-------------|-----------------|
| Page title | 24px | 700 | `text-2xl font-bold text-slate-900` |
| Subtitle | 14px | 400 | `text-sm text-slate-500 mt-1` |
| Search input | 14px | 400 | `text-sm` |
| Table header | 14px | 500 | (shadcn default) |
| Service code | 12px | 400 (mono) | `font-mono text-xs text-slate-500` |
| Service name | 14px | 500 | `font-medium text-sm` |
| Department | 14px | 400 | `text-sm text-slate-600` |
| Division/Section | 14px | 400 | `text-sm text-slate-600` |
| Priority badge | 10px | 600 | `text-[10px]` |
| Empty state | 14px | 400 | (default) |
| Dialog title | 18px | 600 | (shadcn DialogTitle default) |
| Dialog code | 14px | 400 (mono) | `font-mono text-sm text-slate-400` |
| Routing section title | 12px | 600 | `text-xs font-semibold uppercase tracking-wide text-slate-500` |
| Routing label | 10px | 400 | `text-[10px] text-slate-400 uppercase` |
| Routing value | 14px | 500 | `font-medium` |
| SLA section title | 12px | 600 | `text-xs font-semibold uppercase tracking-wide text-slate-500` |
| SLA label | 10px | 600 | `text-[10px] uppercase font-semibold` |
| SLA value | 18px | 700 | `text-lg font-bold` |
| Footer text | 12px | 400 | `text-xs text-slate-400` |
| Footer active/inactive | 12px | 500 | `font-medium` |

---

## 6. UI Components & Icons

### 6.1 Components Used

| Component | Source | Purpose |
|-----------|--------|---------|
| `Card`, `CardContent`, `CardHeader`, `CardTitle` | shadcn/ui | Table container, dialog sections |
| `Badge` | shadcn/ui | Priority badges |
| `Button` | shadcn/ui | Action button (ghost, icon) |
| `Input` | shadcn/ui | Search field |
| `Dialog`, `DialogContent`, `DialogHeader`, `DialogTitle` | shadcn/ui | Service detail modal |
| `Table`, `TableBody`, `TableCell`, `TableHead`, `TableHeader`, `TableRow` | shadcn/ui | Service list table |

### 6.2 Icon Library — Lucide React

| Icon Name | Size (px) | Usage | Color |
|-----------|-----------|-------|-------|
| `Search` | 16 | Search input prefix | slate-400 |
| `Eye` | 15 | View service detail button | slate-500 |
| `CheckCircle` | 16 | Active service status | green-500 |
| `XCircle` | 16 | Inactive service status | slate-400 |

---

## 7. Section-by-Section Specification

### 7.1 Header
```
Container: flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3
  Left:
    h1: text-2xl font-bold text-slate-900 → "Service Catalogue"
    p: text-sm text-slate-500 mt-1 → "{total} services · {active} active"
  Right:
    Search: relative w-full sm:w-72
      Icon: Search (16px) absolute left-3 top-1/2 -translate-y-1/2 text-slate-400
      Input: pl-9 h-9 text-sm placeholder="Search services..."
```

### 7.2 Service Table

**Table Headers (7 columns):**
| # | Header Text | Width | Alignment |
|---|-------------|-------|-----------|
| 1 | Code | 96px (`w-24`) | left |
| 2 | Service Name | auto | left |
| 3 | Department | auto | left |
| 4 | Division / Section | auto | left |
| 5 | Priority | auto | left |
| 6 | Status | auto | center |
| 7 | Actions | 80px (`w-20`) | center |

**Table Row:**
```
TableRow: hover:bg-slate-50
  Code: font-mono text-xs text-slate-500 → "SVC-001"
  Name: font-medium text-sm → "Water Faucet Repair"
  Department: text-sm text-slate-600 → "Maintenance"
  Division/Section: text-sm text-slate-600 → "Plumbing / Residential"
  Priority: Badge text-[10px] + priorityColors → "Medium"
  Status: text-center
    Active: CheckCircle (16px) text-green-500 inline
    Inactive: XCircle (16px) text-slate-400 inline
  Actions: text-center
    Button variant="ghost" size="icon" h-8 w-8 onClick=openDialog
      Eye (15px) text-slate-500
```

**Empty State:**
```
TableCell colSpan=7 text-center py-10 text-slate-400 → "No services found"
```

### 7.3 Service Detail Dialog

```
Dialog: open={!!selectedService} onOpenChange=close
  DialogContent: max-w-lg
    DialogHeader:
      DialogTitle: flex items-center gap-2
        Code: font-mono text-sm text-slate-400 → "SVC-001"
        Name: → "Water Faucet Repair"

    Content: space-y-5

      Card: Routing Rule
        CardHeader pb-2:
          CardTitle: text-xs font-semibold uppercase tracking-wide text-slate-500
            → "Default Routing Rule"
        CardContent: grid grid-cols-3 gap-3 text-sm
          Department:
            Label: text-[10px] text-slate-400 uppercase → "Department"
            Value: font-medium → "Maintenance"
          Division:
            Label: text-[10px] text-slate-400 uppercase → "Division"
            Value: font-medium → "Plumbing"
          Section:
            Label: text-[10px] text-slate-400 uppercase → "Section"
            Value: font-medium → "Residential"

      Card: SLA Policy
        CardHeader pb-2:
          CardTitle: text-xs font-semibold uppercase tracking-wide text-slate-500
            → "SLA Policy (Default Priority: {priority})"
        CardContent: grid grid-cols-2 gap-3 text-sm
          Box 1: bg-blue-50 rounded-lg p-3 text-center
            Label: text-[10px] text-blue-600 uppercase font-semibold → "First Response"
            Value: text-lg font-bold text-blue-800 → formatted time
          Box 2: bg-indigo-50 rounded-lg p-3 text-center
            Label: text-[10px] text-indigo-600 uppercase font-semibold → "Assignment"
            Value: text-lg font-bold text-indigo-800 → formatted time
          Box 3: bg-yellow-50 rounded-lg p-3 text-center
            Label: text-[10px] text-yellow-700 uppercase font-semibold → "Completion"
            Value: text-lg font-bold text-yellow-800 → formatted time
          Box 4: bg-green-50 rounded-lg p-3 text-center
            Label: text-[10px] text-green-600 uppercase font-semibold → "Final Closure"
            Value: text-lg font-bold text-green-800 → formatted time

      Footer: flex items-center justify-between text-xs text-slate-400
        Left: "Status: Active/Inactive"
        Right: "ID: {id}"
```

---

## 8. Styling Methodology

### 8.1 Design Principles
1. **Clean table layout**: No padding on CardContent (`p-0`) so table fills the card edge-to-edge
2. **Inline status icons**: `CheckCircle`/`XCircle` with `inline` class for centered table cell alignment
3. **Ghost action button**: Transparent background, only icon visible, hover reveals slate-100 bg
4. **Dialog with nested cards**: Cards inside the dialog create visual sections for routing and SLA
5. **Color-coded SLA boxes**: Each SLA type has its own pastel color for quick visual scanning
6. **Uppercase micro-labels**: `text-[10px] uppercase` for routing and SLA labels creates a dashboard feel

---

## 9. Data & Logic

### 9.1 Search Filter
```javascript
filtered = services.filter(s =>
  s.nameEn.toLowerCase().includes(search.toLowerCase()) ||
  s.code.toLowerCase().includes(search.toLowerCase()) ||
  s.department.toLowerCase().includes(search.toLowerCase())
);
```
Searches across: `nameEn`, `code`, `department` (case-insensitive)

### 9.2 Service Data (10 services)

| # | Code | Name | Department | Division | Section | Priority | Active |
|---|------|------|-----------|----------|---------|----------|--------|
| 1 | SVC-001 | Water Faucet Repair | Maintenance | Plumbing | Residential | Medium | ✅ |
| 2 | SVC-002 | Electrical Wiring Inspection | Maintenance | Electrical | Safety | High | ✅ |
| 3 | SVC-003 | AC Unit Maintenance | Maintenance | HVAC | Cooling | Medium | ✅ |
| 4 | SVC-004 | Office Furniture Request | Admin Services | Procurement | Furniture | Low | ✅ |
| 5 | SVC-005 | Network Access Setup | IT | Infrastructure | Network | High | ✅ |
| 6 | SVC-006 | Parking Permit Issuance | Admin Services | Facilities | Parking | Low | ✅ |
| 7 | SVC-007 | Fire Alarm System Check | Safety | Fire Safety | Inspection | Critical | ✅ |
| 8 | SVC-008 | Elevator Maintenance | Maintenance | Mechanical | Elevators | High | ✅ |
| 9 | SVC-009 | Landscaping Request | Facilities | Grounds | Landscaping | Low | ❌ |
| 10 | SVC-010 | Security Badge Replacement | Security | Access Control | Badges | Medium | ✅ |

### 9.3 SLA Values (in minutes)

| Service | Response | Assignment | Completion | Closure |
|---------|----------|------------|------------|---------|
| SVC-001 | 60 | 120 | 1440 | 2880 |
| SVC-002 | 30 | 60 | 720 | 1440 |
| SVC-003 | 60 | 180 | 2880 | 4320 |
| SVC-004 | 120 | 480 | 10080 | 14400 |
| SVC-005 | 15 | 30 | 480 | 720 |
| SVC-006 | 240 | 480 | 4320 | 5760 |
| SVC-007 | 15 | 30 | 240 | 480 |
| SVC-008 | 30 | 60 | 1440 | 2880 |
| SVC-009 | 480 | 960 | 20160 | 28800 |
| SVC-010 | 60 | 120 | 1440 | 2160 |

### 9.4 Time Formatting
```javascript
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
Container: flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3
Title: text-2xl font-bold text-slate-900
Subtitle: text-sm text-slate-500 mt-1
Search wrapper: relative w-full sm:w-72
Search icon: absolute left-3 top-1/2 -translate-y-1/2 text-slate-400
Search input: pl-9 h-9 text-sm
```

### 10.3 Table
```
CardContent: p-0
TableHead (Code): w-24
TableHead (Status): text-center
TableHead (Actions): text-center w-20
TableRow: hover:bg-slate-50
Code cell: font-mono text-xs text-slate-500
Name cell: font-medium text-sm
Dept cell: text-sm text-slate-600
Div/Sec cell: text-sm text-slate-600
Priority: Badge text-[10px] + priorityColors
Status: text-center (CheckCircle/XCircle inline)
Action: text-center, Button variant="ghost" size="icon" h-8 w-8
Eye icon: size=15 text-slate-500
Empty: colSpan=7 text-center py-10 text-slate-400
```

### 10.4 Dialog
```
DialogContent: max-w-lg
DialogTitle: flex items-center gap-2
Code: font-mono text-sm text-slate-400
Content: space-y-5
```

### 10.5 Routing Rule Card
```
CardHeader: pb-2
CardTitle: text-xs font-semibold uppercase tracking-wide text-slate-500
CardContent: grid grid-cols-3 gap-3 text-sm
Label: text-[10px] text-slate-400 uppercase
Value: font-medium
```

### 10.6 SLA Policy Card
```
CardHeader: pb-2
CardTitle: text-xs font-semibold uppercase tracking-wide text-slate-500
CardContent: grid grid-cols-2 gap-3 text-sm
Box: bg-{color}-50 rounded-lg p-3 text-center
Label: text-[10px] text-{color}-600 uppercase font-semibold
Value: text-lg font-bold text-{color}-800
```

### 10.7 Footer
```
Container: flex items-center justify-between text-xs text-slate-400
Active: text-green-600 font-medium
Inactive: text-slate-500 font-medium
```

---

## Appendix A: Equivalent Pure CSS

```css
/* Service table */
.service-table { width: 100%; border-collapse: collapse; }
.service-table th {
  padding: 12px 16px; font-size: 14px; font-weight: 500;
  color: #64748B; text-align: left; border-bottom: 1px solid #E2E8F0;
}
.service-table td {
  padding: 16px; vertical-align: middle; border-bottom: 1px solid #F1F5F9;
}
.service-code { font-family: monospace; font-size: 12px; color: #64748B; }
.service-name { font-size: 14px; font-weight: 500; }

/* SLA box */
.sla-box {
  border-radius: 8px; padding: 12px; text-align: center;
}
.sla-box-blue { background: #EFF6FF; }
.sla-box-indigo { background: #EEF2FF; }
.sla-box-yellow { background: #FEFCE8; }
.sla-box-green { background: #F0FDF4; }
.sla-label {
  font-size: 10px; text-transform: uppercase; font-weight: 600;
}
.sla-value { font-size: 18px; font-weight: 700; }

/* Routing grid */
.routing-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; }
.routing-label { font-size: 10px; text-transform: uppercase; color: #94A3B8; }
.routing-value { font-size: 14px; font-weight: 500; }

/* Status icons */
.status-active { color: #22C55E; }
.status-inactive { color: #94A3B8; }
```

---

*End of Service Catalogue Implementation Report*