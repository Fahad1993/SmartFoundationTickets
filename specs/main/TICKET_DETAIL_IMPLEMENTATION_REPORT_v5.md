# Ticket Detail — Pixel-Perfect Implementation Details

> **Purpose**: This document captures every visual and structural detail of the "Ticket Detail" page so that another developer (or AI agent) can reproduce it **identically** in any stack (C# MVC / Razor / plain HTML+CSS / etc.).

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

The Ticket Detail page (`/tickets/:id`) shows the **full view of a single ticket** with:
- **Header** — Back link, ticket number, status/priority/SLA badges
- **Action Buttons** — Context-sensitive actions (Assign, Start Work, Pause, Resume, Resolve, Create Child, Request Clarification, Raise Arbitration)
- **Description Card** — Full ticket description
- **Related Tickets** — Parent/child ticket relationships
- **Arbitration Cases** — Orange-themed cards for arbitration disputes
- **Clarification Requests** — Purple-themed cards for information requests
- **Quality Reviews** — Indigo-themed cards for QA reviews
- **Audit Trail** — Vertical timeline of all ticket history
- **Right Sidebar** — Ticket info, SLA status, pause sessions, dates

---

## 2. Page Structure

```
<AppLayout>
  <div class="space-y-5">                    <!-- 20px vertical gap -->
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center gap-3">
      <BackLink />
      <TicketNo + Badges />
    </div>

    <!-- Action Buttons (if active) -->
    <Card> action buttons </Card>

    <!-- 3-Column Grid -->
    <div class="grid lg:grid-cols-3 gap-5">
      <!-- Left Column (2/3) -->
      <div class="lg:col-span-2 space-y-5">
        <Card: Description />
        <Card: Related Tickets />      <!-- conditional -->
        <Card: Arbitration Cases />    <!-- conditional -->
        <Card: Clarification Requests /> <!-- conditional -->
        <Card: Quality Reviews />      <!-- conditional -->
        <Card: Audit Trail />
      </div>

      <!-- Right Column (1/3) -->
      <div class="space-y-5">
        <Card: Ticket Information />
        <Card: SLA Status />
        <Card: Pause Sessions />       <!-- conditional -->
        <Card: Dates />
      </div>
    </div>
  </div>
</AppLayout>
```

---

## 3. Layout & Dimensions

### 3.1 Page Content Spacing
| Element | Property | Value | Tailwind Class |
|---------|----------|-------|----------------|
| Content wrapper | vertical gap | 20px | `space-y-5` |

### 3.2 Main Grid
| Property | Value | Tailwind Class |
|----------|-------|----------------|
| Columns (lg+) | 3 | `lg:grid-cols-3` |
| Gap | 20px | `gap-5` |
| Left column span | 2 | `lg:col-span-2` |
| Left column internal gap | 20px | `space-y-5` |
| Right column internal gap | 20px | `space-y-5` |

### 3.3 Header Layout
| Property | Value | Tailwind Class |
|----------|-------|----------------|
| Direction | column (mobile), row (sm+) | `flex-col sm:flex-row` |
| Alignment (sm+) | center | `sm:items-center` |
| Gap | 12px | `gap-3` |

### 3.4 Action Buttons Card
| Property | Value | Tailwind Class |
|----------|-------|----------------|
| CardContent padding | 12px | `p-3` |
| Button container | flex wrap | `flex flex-wrap gap-2` |
| Button height | 32px | `h-8` |
| Button font size | 12px | `text-xs` |
| Button icon gap | 6px | `gap-1.5` |

### 3.5 Card Headers (consistent across all cards)
| Property | Value | Tailwind Class |
|----------|-------|----------------|
| Header padding-bottom | 8px | `pb-2` |
| Title font | 14px, semibold | `text-sm font-semibold` |

### 3.6 InfoRow (Right Sidebar)
| Property | Value | Tailwind Class |
|----------|-------|----------------|
| Layout | flex, space-between | `flex items-center justify-between` |
| Label | 12px, slate-500 | `text-slate-500 text-xs` |
| Value | 14px, medium, slate-800 | `font-medium text-slate-800` |
| Muted value | italic, slate-400 | `text-slate-400 italic` |

### 3.7 Audit Trail Timeline
| Property | Value | Tailwind Class |
|----------|-------|----------------|
| Container | padding-left: 24px | `pl-6` |
| Vertical line | absolute, left: 8px, width: 2px | `absolute left-2 top-2 bottom-2 w-0.5 bg-slate-200` |
| Timeline dot | 12×12px circle | `w-3 h-3 rounded-full border-2 border-white` |
| Dot position | absolute, left: -18px | `absolute left-[-18px]` |
| Latest dot color | blue-500 | `bg-blue-500` |
| Other dot color | slate-300 | `bg-slate-300` |
| Entry spacing | padding-bottom: 20px | `pb-5 last:pb-0` |

---

## 4. Color Systems

### 4.1 Header Badges
| Badge | Background | Text | Tailwind |
|-------|-----------|------|---------|
| Status | varies (statusColors) | varies | `statusColors[ticket.status]` |
| Priority | varies (priorityColors) | varies | `priorityColors[ticket.priority]` |
| SLA Breached | `#DC2626` (red-600) | white | `bg-red-600 text-white hover:bg-red-600` |
| Blocked | `#F59E0B` (amber-500) | white | `bg-amber-500 text-white hover:bg-amber-500` |

### 4.2 Action Button Colors
| Action | Background | Hover | Text |
|--------|-----------|-------|------|
| Assign | `#2563EB` (blue-600) | `#1D4ED8` (blue-700) | white |
| Start Work | `#16A34A` (green-600) | `#15803D` (green-700) | white |
| Pause | `#E2E8F0` (slate-200) | `#CBD5E1` (slate-300) | `#334155` (slate-700) |
| Resume | `#2563EB` (blue-600) | `#1D4ED8` (blue-700) | white |
| Resolve | `#16A34A` (green-600) | `#15803D` (green-700) | white |
| Quality Review | `#4F46E5` (indigo-600) | `#4338CA` (indigo-700) | white |
| Create Child | `#9333EA` (purple-600) | `#7E22CE` (purple-700) | white |
| Request Clarification | `#F59E0B` (amber-500) | `#D97706` (amber-600) | white |
| Raise Arbitration | `#DC2626` (red-600) | `#B91C1C` (red-700) | white |

### 4.3 Related Tickets Colors
| Type | Row BG | Label BG | Label Text |
|------|--------|----------|-----------|
| Parent | `#EFF6FF` (blue-50) | `#DBEAFE` (blue-100) | `#2563EB` (blue-600) |
| Child | `#FAF5FF` (purple-50) | `#F3E8FF` (purple-100) | `#9333EA` (purple-600) |

### 4.4 Arbitration Case Colors
| Element | Color | HEX |
|---------|-------|-----|
| Card border | orange-200 | `#FED7AA` |
| Card title | orange-700 | `#C2410C` |
| Case background | orange-50 | `#FFF7ED` |
| Case title | orange-800 | `#9A3412` |
| Open badge bg | orange-200 | `#FED7AA` |
| Open badge text | orange-800 | `#9A3412` |
| Resolved badge bg | green-100 | `#DCFCE7` |
| Resolved badge text | green-800 | `#166534` |
| Decision text | green-700 | `#15803D` |

### 4.5 Clarification Request Colors
| Element | Color | HEX |
|---------|-------|-----|
| Card border | purple-200 | `#E9D5FF` |
| Card title | purple-700 | `#7E22CE` |
| Request background | purple-50 | `#FAF5FF` |
| Request title | purple-800 | `#6B21A8` |
| Open badge bg | purple-200 | `#E9D5FF` |
| Open badge text | purple-800 | `#6B21A8` |
| Responded badge bg | blue-100 | `#DBEAFE` |
| Responded badge text | blue-800 | `#1E40AF` |
| Request notes bg | white | `#FFFFFF` |
| Request notes border | purple-100 | `#F3E8FF` |
| Response notes bg | green-50 | `#F0FDF4` |
| Response notes border | green-100 | `#DCFCE7` |
| Response label | green-700 | `#15803D` |

### 4.6 Quality Review Colors
| Element | Color | HEX |
|---------|-------|-----|
| Card border | indigo-200 | `#C7D2FE` |
| Card title | indigo-700 | `#4338CA` |
| Review background | indigo-50 | `#EEF2FF` |
| Review title | indigo-800 | `#3730A3` |
| Pending badge bg | indigo-200 | `#C7D2FE` |
| Pending badge text | indigo-800 | `#3730A3` |
| Approved badge bg | green-100 | `#DCFCE7` |
| Approved badge text | green-800 | `#166534` |
| Rejected badge bg | red-100 | `#FEE2E2` |
| Rejected badge text | red-800 | `#991B1B` |

### 4.7 SLA Status Card Colors
| State | Container BG | Container Border | Value Color |
|-------|-------------|-----------------|-------------|
| OK (not breached) | `#F0FDF4` (green-50) | `#BBF7D0` (green-200) | `#15803D` (green-700) |
| Breached | `#FEF2F2` (red-50) | `#FECACA` (red-200) | `#DC2626` (red-600) |

### 4.8 Pause Session Colors
| Element | Color | HEX |
|---------|-------|-----|
| Card border | amber-200 | `#FDE68A` |
| Card title | amber-700 | `#B45309` |
| Session background | amber-50 | `#FFFBEB` |
| Session title | amber-800 | `#92400E` |
| Active badge bg | amber-200 | `#FDE68A` |
| Active badge text | amber-800 | `#92400E` |
| Ended badge bg | green-100 | `#DCFCE7` |
| Ended badge text | green-700 | `#15803D` |

### 4.9 Audit Trail Colors
| Element | Color | HEX |
|---------|-------|-----|
| Vertical line | slate-200 | `#E2E8F0` |
| Latest dot | blue-500 | `#3B82F6` |
| Other dots | slate-300 | `#CBD5E1` |
| Dot border | white | `#FFFFFF` |
| Action text | slate-800 | `#1E293B` |
| Notes text | slate-500 | `#64748B` |
| Performer/date | slate-400 | `#94A3B8` |

---

## 5. Typography

| Element | Font Size | Font Weight | Tailwind Classes |
|---------|-----------|-------------|-----------------|
| Ticket number (h1) | 20px | 700 | `text-xl font-bold text-slate-900` |
| Ticket title (h2) | 16px | 400 | `text-base text-slate-600 mt-1` |
| Back link | 14px | 400 | `text-sm text-slate-500 hover:text-slate-700` |
| Card title | 14px | 600 | `text-sm font-semibold` |
| Description text | 14px | 400 | `text-sm text-slate-700 leading-relaxed` |
| InfoRow label | 12px | 400 | `text-xs text-slate-500` |
| InfoRow value | 14px | 500 | `font-medium text-slate-800` |
| Location label | 10px | 400 | `text-[10px] text-slate-400 uppercase` |
| Location value | 14px | 400 | `text-slate-700` |
| SLA label | 10px | 600 | `text-[10px] uppercase font-semibold text-slate-500` |
| SLA value | 20px | 700 | `text-xl font-bold` |
| SLA breached note | 12px | 400 | `text-xs text-red-500` |
| Related ticket label | 10px | 700 | `text-[10px] uppercase font-bold` |
| Related ticket link | 14px | 400 (mono) | `text-sm text-blue-600 hover:underline font-mono` |
| Related ticket title | 14px | 400 | `text-sm text-slate-600 truncate` |
| Case/request title | 14px | 600 | `font-semibold` |
| Case/request body | 14px | 400 | `text-slate-600` |
| Case/request meta | 12px | 400 | `text-xs text-slate-500` |
| Audit action | 14px | 600 | `text-sm font-semibold text-slate-800` |
| Audit notes | 12px | 400 | `text-xs text-slate-500` |
| Audit performer/date | 10px | 400 | `text-[10px] text-slate-400` |
| Pause reason | 12px | 600 | `font-semibold text-amber-800` |
| Pause notes | 12px | 400 | `text-slate-600` |
| Pause date | 12px | 400 | `text-slate-400` |
| Action button text | 12px | 400 | `text-xs` |
| Not found text | 18px | 400 | `text-lg text-slate-500` |
| Not found link | 14px | 400 | `text-sm text-blue-600 hover:underline` |

---

## 6. UI Components & Icons

### 6.1 Components Used

| Component | Source | Purpose |
|-----------|--------|---------|
| `Card`, `CardContent`, `CardHeader`, `CardTitle` | shadcn/ui | All section containers |
| `Badge` | shadcn/ui | Status, priority, SLA, blocked badges |
| `Button` | shadcn/ui | Action buttons |
| `Separator` | shadcn/ui | Horizontal dividers in info sidebar |
| `Textarea` | shadcn/ui | Notes input in dialog forms |
| `Dialog`, `DialogContent`, `DialogHeader`, `DialogTitle`, `DialogTrigger` | shadcn/ui | Modal dialogs for child ticket, clarification, arbitration |
| `Link` | react-router-dom | Navigation links |

### 6.2 Icon Library — Lucide React

| Icon Name | Size (px) | Usage | Color |
|-----------|-----------|-------|-------|
| `ArrowLeft` | 16 | Back navigation link | slate-500 |
| `User` | — | (imported but not directly rendered) | — |
| `MapPin` | 14 | Location indicator in sidebar | slate-400 |
| `Clock` | 15 | Audit Trail card title | (inherits) |
| `AlertTriangle` | 12 | SLA breached badge, SLA breached note | white / red-500 |
| `Pause` | 12 / 14 | Blocked badge, Pause action button, Pause sessions title | white / slate-700 / amber-700 |
| `Play` | 14 | Start Work / Resume action button | white |
| `CheckCircle2` | 14 | Resolve action button | white |
| `UserPlus` | 14 | Assign action button | white |
| `GitBranch` | 14 / 15 | Create Child button, Related Tickets title | white / (inherits) |
| `MessageSquare` | 14 / 15 | Request Clarification button, Clarification title | white / purple-700 |
| `Scale` | 14 / 15 | Raise Arbitration button, Arbitration title | white / orange-700 |
| `ShieldCheck` | 14 / 15 | Quality Review button, Quality Reviews title | white / indigo-700 |
| `ChevronRight` | 14 | Submit button in dialogs | (inherits) |

### 6.3 Action Button States (Context-Sensitive)

| Ticket Status | Available Actions |
|---------------|-------------------|
| Open | Assign, Create Child, Request Clarification, Raise Arbitration |
| Assigned | Start Work, Create Child, Request Clarification, Raise Arbitration |
| InProgress | Pause, Resolve, Create Child, Request Clarification, Raise Arbitration |
| Paused | Resume, Create Child, Request Clarification, Raise Arbitration |
| Resolved (with QR) | Quality Review, Create Child, Request Clarification, Raise Arbitration |
| Resolved / Closed | No action bar shown |

### 6.4 Dialog Structure
```
Dialog:
  DialogTrigger: Button (same as action button)
  DialogContent:
    DialogHeader:
      DialogTitle: title text
    Body: space-y-4
      Description: text-sm text-slate-500
      Textarea: placeholder="Add notes or details..." rows=4
      Button row: flex justify-end gap-2
        Cancel: variant="outline" size="sm"
        Submit: size="sm" + color class, with ChevronRight icon
```

---

## 7. Section-by-Section Specification

### 7.1 Header
```
Container: flex flex-col sm:flex-row sm:items-center gap-3
  Back link: flex items-center gap-1 text-sm text-slate-500 hover:text-slate-700
    ArrowLeft (16px) + "Back"
  Content: flex-1
    Badge row: flex items-center gap-3 flex-wrap
      h1: text-xl font-bold text-slate-900 → ticket number
      Status Badge: statusColors[status]
      Priority Badge: priorityColors[priority]
      SLA Breached Badge (conditional): bg-red-600 text-white
        AlertTriangle (12px) + "SLA Breached"
      Blocked Badge (conditional): bg-amber-500 text-white
        Pause (12px) + "Blocked"
    h2: text-base text-slate-600 mt-1 → ticket title
```

### 7.2 Related Tickets

**Parent ticket row:**
```
Container: flex items-center gap-3 p-2 bg-blue-50 rounded-lg
  Label: text-[10px] uppercase font-bold text-blue-600 bg-blue-100 px-2 py-0.5 rounded → "Parent"
  Link: text-sm text-blue-600 hover:underline font-mono → ticket number
  Title: text-sm text-slate-600 truncate flex-1
  Status Badge: text-[10px] + statusColors
```

**Child ticket row:**
```
Container: flex items-center gap-3 p-2 bg-purple-50 rounded-lg
  Label: text-[10px] uppercase font-bold text-purple-600 bg-purple-100 px-2 py-0.5 rounded → "Child"
  Link: text-sm text-blue-600 hover:underline font-mono → ticket number
  Title: text-sm text-slate-600 truncate flex-1
  Status Badge: text-[10px] + statusColors
```

### 7.3 SLA Status Card (Right Sidebar)
```
Container: p-3 rounded-lg text-center
  If breached: bg-red-50 border border-red-200
  If OK: bg-green-50 border border-green-200

  Label: text-[10px] uppercase font-semibold text-slate-500 → "Completion SLA"
  Value: text-xl font-bold mt-1
    If breached: text-red-600
    If OK: text-green-700
    If resolved/closed: "Completed"
    Otherwise: formatMinutes(slaCompletionRemainMin)
  Breached note (conditional): text-xs text-red-500 mt-1 flex items-center justify-center gap-1
    AlertTriangle (12px) + "SLA Breached"
```

### 7.4 Ticket Information (Right Sidebar)
```
CardContent: space-y-3 text-sm
  InfoRow: Service
  InfoRow: Requester
  InfoRow: Requester Type
  Separator
  InfoRow: Department
  InfoRow: Division
  InfoRow: Section
  InfoRow: Current Queue
  Separator
  InfoRow: Assigned To (muted if null → "Unassigned")
  Separator
  Location block:
    Container: flex items-start gap-2
      MapPin (14px): text-slate-400 mt-0.5 shrink-0
      Content:
        Label: text-[10px] text-slate-400 uppercase → "Location"
        Value: text-slate-700
```

---

## 8. Styling Methodology

### 8.1 Color-Coded Sections
Each workflow section uses a distinct color theme:
- **Arbitration**: Orange (border-orange-200, bg-orange-50, text-orange-700/800)
- **Clarification**: Purple (border-purple-200, bg-purple-50, text-purple-700/800)
- **Quality Review**: Indigo (border-indigo-200, bg-indigo-50, text-indigo-700/800)
- **Pause Sessions**: Amber (border-amber-200, bg-amber-50, text-amber-700/800)

### 8.2 Consistent Card Pattern
All detail cards follow:
```
Card (optional colored border)
  CardHeader pb-2
    CardTitle text-sm font-semibold (optional icon + color)
  CardContent space-y-3
    Items with p-3 bg-{color}-50 rounded-lg text-sm space-y-2
```

### 8.3 Timeline Design
- Vertical line: 2px wide, `slate-200`, positioned absolutely
- Dots: 12px circles with 2px white border, positioned on the line
- Latest entry dot is blue, others are gray
- Creates a professional audit trail appearance

---

## 9. Data & Logic

### 9.1 Data Sources
```javascript
ticket = tickets.find(t => t.id === Number(id));  // from URL param
history = ticketHistories[ticket.id] || [];
arbitration = arbitrationCases.filter(a => a.ticketId === ticket.id);
clarifications = clarificationRequests.filter(c => c.ticketId === ticket.id);
reviews = qualityReviews.filter(q => q.ticketId === ticket.id);
pauses = pauseSessions.filter(p => p.ticketId === ticket.id);
childTickets = tickets.filter(t => t.parentTicketId === ticket.id);
parentTicket = ticket.parentTicketId ? tickets.find(t => t.id === ticket.parentTicketId) : null;
```

### 9.2 Active Check
```javascript
isActive = !["Resolved", "Closed"].includes(ticket.status);
// Action buttons only shown when isActive === true
```

### 9.3 Pause Reason Formatting
```javascript
p.reason.replace(/([A-Z])/g, " $1").trim()
// "ChildDependency" → "Child Dependency"
// "ApprovalDelay" → "Approval Delay"
```

### 9.4 Not Found State
When ticket ID doesn't match any ticket:
```
Centered container: flex items-center justify-center h-64
  Text: text-slate-500 text-lg → "Ticket not found"
  Link: text-blue-600 hover:underline text-sm mt-2 block → "Back to Ticket Queue"
```

---

## 10. Complete CSS Class Reference

### 10.1 Header
```
Container: flex flex-col sm:flex-row sm:items-center gap-3
Back link: flex items-center gap-1 text-sm text-slate-500 hover:text-slate-700
Badge row: flex items-center gap-3 flex-wrap
Ticket #: text-xl font-bold text-slate-900
Title: text-base text-slate-600 mt-1
SLA badge: bg-red-600 text-white hover:bg-red-600
Blocked badge: bg-amber-500 text-white hover:bg-amber-500
```

### 10.2 Action Buttons
```
Card content: p-3
Container: flex flex-wrap gap-2
Button: h-8 text-xs gap-1.5 + color class
```

### 10.3 Description
```
CardHeader: pb-2
CardTitle: text-sm font-semibold
Text: text-sm text-slate-700 leading-relaxed
```

### 10.4 Related Tickets
```
Parent row: flex items-center gap-3 p-2 bg-blue-50 rounded-lg
Parent label: text-[10px] uppercase font-bold text-blue-600 bg-blue-100 px-2 py-0.5 rounded
Child row: flex items-center gap-3 p-2 bg-purple-50 rounded-lg
Child label: text-[10px] uppercase font-bold text-purple-600 bg-purple-100 px-2 py-0.5 rounded
Link: text-sm text-blue-600 hover:underline font-mono
Title: text-sm text-slate-600 truncate flex-1
Badge: text-[10px] + statusColors
```

### 10.5 Arbitration / Clarification / Quality Review
```
Card: border-{color}-200
CardTitle: text-sm font-semibold flex items-center gap-2 text-{color}-700
Item: p-3 bg-{color}-50 rounded-lg text-sm space-y-2
Title: font-semibold text-{color}-800
Body: text-slate-600
Meta: flex gap-4 text-xs text-slate-500
```

### 10.6 Audit Trail
```
Container: relative pl-6
Line: absolute left-2 top-2 bottom-2 w-0.5 bg-slate-200
Entry: relative pb-5 last:pb-0
Dot: absolute left-[-18px] w-3 h-3 rounded-full border-2 border-white bg-{blue-500|slate-300}
Action: text-sm font-semibold text-slate-800
Badge: text-[10px] + statusColors
Notes: text-xs text-slate-500 mt-0.5
Meta: text-[10px] text-slate-400 mt-1
```

### 10.7 Right Sidebar
```
InfoRow: flex items-center justify-between
Label: text-slate-500 text-xs
Value: font-medium text-slate-800 (or text-slate-400 italic if muted)
Separator: (shadcn Separator component)
Location: flex items-start gap-2
Location label: text-[10px] text-slate-400 uppercase
Location value: text-slate-700
```

### 10.8 SLA Status
```
Container: p-3 rounded-lg text-center
  OK: bg-green-50 border border-green-200
  Breached: bg-red-50 border border-red-200
Label: text-[10px] uppercase font-semibold text-slate-500
Value: text-xl font-bold mt-1 text-{green-700|red-600}
Breach note: text-xs text-red-500 mt-1 flex items-center justify-center gap-1
```

### 10.9 Pause Sessions
```
Card: border-amber-200
Title: text-sm font-semibold flex items-center gap-2 text-amber-700
Item: p-2 bg-amber-50 rounded text-xs space-y-1
Reason: font-semibold text-amber-800
Notes: text-slate-600
Date: text-slate-400
Active badge: bg-amber-200 text-amber-800
Ended badge: bg-green-100 text-green-700
```

---

## Appendix A: Equivalent Pure CSS

```css
/* Action button */
.action-btn {
  height: 32px;
  font-size: 12px;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 0 12px;
  border-radius: 6px;
  font-weight: 500;
  cursor: pointer;
  border: none;
}
.action-btn-blue { background: #2563EB; color: white; }
.action-btn-blue:hover { background: #1D4ED8; }
.action-btn-green { background: #16A34A; color: white; }
.action-btn-green:hover { background: #15803D; }
.action-btn-gray { background: #E2E8F0; color: #334155; }
.action-btn-gray:hover { background: #CBD5E1; }

/* Timeline */
.timeline { position: relative; padding-left: 24px; }
.timeline-line {
  position: absolute; left: 8px; top: 8px; bottom: 8px;
  width: 2px; background: #E2E8F0;
}
.timeline-dot {
  position: absolute; left: -18px;
  width: 12px; height: 12px; border-radius: 50%;
  border: 2px solid white;
}
.timeline-dot-active { background: #3B82F6; }
.timeline-dot-inactive { background: #CBD5E1; }

/* SLA status box */
.sla-box {
  padding: 12px; border-radius: 8px; text-align: center;
}
.sla-ok { background: #F0FDF4; border: 1px solid #BBF7D0; }
.sla-breached { background: #FEF2F2; border: 1px solid #FECACA; }

/* Related ticket row */
.related-parent { background: #EFF6FF; padding: 8px; border-radius: 8px; }
.related-child { background: #FAF5FF; padding: 8px; border-radius: 8px; }
.related-label {
  font-size: 10px; text-transform: uppercase; font-weight: 700;
  padding: 2px 8px; border-radius: 4px;
}
.related-label-parent { background: #DBEAFE; color: #2563EB; }
.related-label-child { background: #F3E8FF; color: #9333EA; }

/* Info row */
.info-row { display: flex; align-items: center; justify-content: space-between; }
.info-label { font-size: 12px; color: #64748B; }
.info-value { font-size: 14px; font-weight: 500; color: #1E293B; }
.info-value-muted { color: #94A3B8; font-style: italic; }
```

---

*End of Ticket Detail Implementation Report*