# Create Ticket — Pixel-Perfect Implementation Details

> **Purpose**: This document captures every visual and structural detail of the "Create Ticket" page so that another developer (or AI agent) can reproduce it **identically** in any stack (C# MVC / Razor / plain HTML+CSS / etc.).

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
9. [Form Logic & Validation](#9-form-logic--validation)
10. [Complete CSS Class Reference](#10-complete-css-class-reference)

---

## 1. Page Overview

The Create Ticket page (`/tickets/create`) is a **multi-section form** for submitting new service requests. It includes:
- **Header** — Back link + page title
- **Requester Type** — Radio group (Resident / Internal)
- **Requester Information** — Name input
- **Service Selection** — Dropdown with "Other" option + auto-routing preview
- **Ticket Details** — Title, description, priority, location
- **Submit Bar** — Cancel + Submit buttons
- **Success State** — Confirmation card after submission

The form is centered with a max-width of 672px (`max-w-2xl`).

---

## 2. Page Structure

### 2.1 Form State
```
<AppLayout>
  <div class="max-w-2xl mx-auto space-y-5">
    <!-- Header -->
    <div class="flex items-center gap-3">
      <BackLink />
      <div>
        <h1>Create New Ticket</h1>
        <p>Submit a new service request or report an issue</p>
      </div>
    </div>

    <!-- Card: Requester Type -->
    <!-- Card: Requester Information -->
    <!-- Card: Service -->
    <!-- Card: Ticket Details -->

    <!-- Submit Bar -->
    <div class="flex items-center justify-between pb-8">
      <CancelButton />
      <SubmitButton />
    </div>
  </div>
</AppLayout>
```

### 2.2 Success State
```
<AppLayout>
  <div class="flex items-center justify-center h-[60vh]">
    <Card class="w-full max-w-md text-center">
      <CardContent class="py-10 space-y-4">
        <SuccessIcon />
        <h2>Ticket Created!</h2>
        <p>...ticket number...</p>
        <ArbitrationNotice />  <!-- conditional -->
        <ButtonRow />
      </CardContent>
    </Card>
  </div>
</AppLayout>
```

---

## 3. Layout & Dimensions

### 3.1 Form Container
| Property | Value | Tailwind Class |
|----------|-------|----------------|
| Max width | 672px | `max-w-2xl` |
| Horizontal centering | auto margins | `mx-auto` |
| Vertical gap | 20px | `space-y-5` |

### 3.2 Header
| Property | Value | Tailwind Class |
|----------|-------|----------------|
| Layout | flex, center aligned | `flex items-center gap-3` |
| Gap | 12px | `gap-3` |

### 3.3 Card Sections
| Property | Value | Tailwind Class |
|----------|-------|----------------|
| Card header padding-bottom | 12px | `pb-3` |
| Card content internal gap | 16px | `space-y-4` |
| Input margin-top | 4px | `mt-1` |

### 3.4 Priority + Location Grid
| Property | Value | Tailwind Class |
|----------|-------|----------------|
| Columns | 2 | `grid-cols-2` |
| Gap | 16px | `gap-4` |

### 3.5 Submit Bar
| Property | Value | Tailwind Class |
|----------|-------|----------------|
| Layout | flex, space-between | `flex items-center justify-between` |
| Bottom padding | 32px | `pb-8` |

### 3.6 Success Card
| Property | Value | Tailwind Class |
|----------|-------|----------------|
| Container height | 60vh | `h-[60vh]` |
| Card max-width | 448px | `max-w-md` |
| Card width | 100% | `w-full` |
| Content padding | 40px vertical | `py-10` |
| Content gap | 16px | `space-y-4` |
| Success icon circle | 64×64px | `w-16 h-16` |

---

## 4. Color Systems

### 4.1 Text Colors
| Usage | Color | HEX | Tailwind |
|-------|-------|-----|----------|
| Page title | slate-900 | `#0F172A` | `text-slate-900` |
| Subtitle | slate-500 | `#64748B` | `text-slate-500` |
| Back link | slate-500 → slate-700 | `#64748B` → `#334155` | `text-slate-500 hover:text-slate-700` |
| Card title | inherits | — | `text-sm font-semibold` |
| Label | slate-500 | `#64748B` | `text-xs text-slate-500` |
| Input text | slate-900 | `#0F172A` | (default) |
| Radio label | inherits | — | `text-sm` |
| Auto-routing text | slate-700 | `#334155` | `text-slate-700` |
| Auto-routing sub | slate-500 | `#64748B` | `text-slate-500` |
| "Other" warning text | orange-600 | `#EA580C` | `text-orange-600` |
| "Other" warning bg | orange-50 | `#FFF7ED` | `bg-orange-50` |
| Success title | slate-900 | `#0F172A` | `text-slate-900` |
| Success body | slate-500 | `#64748B` | `text-slate-500` |
| Ticket number in success | blue-600 | `#2563EB` | `text-blue-600` |

### 4.2 Success State Colors
| Element | Color | HEX |
|---------|-------|-----|
| Icon circle bg | green-100 | `#DCFCE7` |
| Icon color | green-600 | `#16A34A` |

### 4.3 Auto-Routing Preview
| Element | Color | HEX |
|---------|-------|-----|
| Background | slate-50 | `#F8FAFC` |
| Border-radius | 8px | `rounded-lg` |
| Padding | 12px | `p-3` |

### 4.4 Button Colors
| Button | Style | Tailwind |
|--------|-------|---------|
| Cancel | outline variant | `variant="outline"` |
| Submit | default (primary) | default + `gap-2` |
| Submit disabled | opacity reduced | `disabled` attribute |
| View Queue (success) | outline, small | `variant="outline" size="sm"` |
| Create Another (success) | default, small | `size="sm"` |

---

## 5. Typography

| Element | Font Size | Font Weight | Tailwind Classes |
|---------|-----------|-------------|-----------------|
| Page title | 24px | 700 | `text-2xl font-bold text-slate-900` |
| Subtitle | 14px | 400 | `text-sm text-slate-500 mt-0.5` |
| Back link | 14px | 400 | `text-sm` |
| Card section title | 14px | 600 | `text-sm font-semibold` |
| Form label | 12px | 400 | `text-xs text-slate-500` |
| Radio label | 14px | 400 | `text-sm` |
| Input text | 14px | 400 | (default) |
| Textarea text | 14px | 400 | (default) |
| Auto-routing title | 12px | 600 | `text-xs font-semibold text-slate-700` |
| Auto-routing detail | 12px | 400 | `text-xs text-slate-500` |
| Warning text | 12px | 400 | `text-xs text-orange-600` |
| Success title | 20px | 700 | `text-xl font-bold text-slate-900` |
| Success body | 14px | 400 | `text-sm text-slate-500` |
| Ticket number | 14px | 700 (mono) | `font-mono font-bold text-blue-600` |
| Arbitration notice | 12px | 400 | `text-xs text-orange-600` |

---

## 6. UI Components & Icons

### 6.1 Components Used

| Component | Source | Purpose |
|-----------|--------|---------|
| `Card`, `CardContent`, `CardHeader`, `CardTitle` | shadcn/ui | Form section containers |
| `Button` | shadcn/ui | Cancel, Submit, View Queue, Create Another |
| `Input` | shadcn/ui | Name, title, location text fields |
| `Label` | shadcn/ui | Form field labels |
| `Textarea` | shadcn/ui | Description field (4 rows) |
| `RadioGroup`, `RadioGroupItem` | shadcn/ui | Requester type selection |
| `Select`, `SelectTrigger`, `SelectContent`, `SelectItem`, `SelectValue` | shadcn/ui | Service and priority dropdowns |
| `Badge` | shadcn/ui | (imported but not directly used in form) |
| `Link` | react-router-dom | Back link, View Queue link |

### 6.2 Icon Library — Lucide React

| Icon Name | Size (px) | Usage | Color |
|-----------|-----------|-------|-------|
| `ArrowLeft` | 16 | Back navigation link | slate-500 |
| `Send` | 15 | Submit button icon | white (inherits) |
| `AlertCircle` | 14 | "Other" service warning icon | orange-600 |
| `CheckCircle2` | 32 | Success state icon | green-600 |

---

## 7. Section-by-Section Specification

### 7.1 Header
```
Container: flex items-center gap-3
  Back link: flex items-center gap-1 text-sm text-slate-500 hover:text-slate-700
    ArrowLeft (16px) + "Back"
  Content:
    h1: text-2xl font-bold text-slate-900 → "Create New Ticket"
    p: text-sm text-slate-500 mt-0.5 → "Submit a new service request or report an issue"
```

### 7.2 Requester Type Card
```
Card:
  CardHeader pb-3:
    CardTitle text-sm font-semibold → "Requester Type"
  CardContent:
    RadioGroup: flex gap-4
      Option 1: flex items-center space-x-2
        RadioGroupItem value="Resident" id="resident"
        Label htmlFor="resident" text-sm cursor-pointer → "Resident / Beneficiary"
      Option 2: flex items-center space-x-2
        RadioGroupItem value="Internal" id="internal"
        Label htmlFor="internal" text-sm cursor-pointer → "Internal User"
```

**RadioGroupItem**: shadcn/ui radio button — 16×16px circle, border: slate-300, checked: blue-600 fill

### 7.3 Requester Information Card
```
Card:
  CardHeader pb-3:
    CardTitle text-sm font-semibold → "Requester Information"
  CardContent space-y-4:
    Field:
      Label text-xs text-slate-500 → dynamic ("Full Name" or "Employee Name")
      Input mt-1 placeholder=dynamic
```

### 7.4 Service Card
```
Card:
  CardHeader pb-3:
    CardTitle text-sm font-semibold → "Service"
  CardContent space-y-4:
    Field:
      Label text-xs text-slate-500 → "Select Service"
      Select mt-1:
        SelectTrigger → placeholder "Choose a service..."
        SelectContent:
          For each active service: "{nameEn} — {department}"
          Last item: "⚠️ Other (describe manually)"

    If "Other" selected:
      Warning: flex items-center gap-2 text-xs text-orange-600 bg-orange-50 p-3 rounded-lg
        AlertCircle (14px) shrink-0
        "This ticket will be sent to an arbitrator for classification and routing."

    If service selected (not "Other"):
      Preview: bg-slate-50 rounded-lg p-3 text-xs space-y-1
        Line 1: font-semibold text-slate-700
          "Auto-routing: {department} → {division} → {section}"
        Line 2: text-slate-500
          "Default Priority: {defaultPriority} · SLA Completion: {hours}h"
```

### 7.5 Ticket Details Card
```
Card:
  CardHeader pb-3:
    CardTitle text-sm font-semibold → "Ticket Details"
  CardContent space-y-4:
    Title field:
      Label text-xs text-slate-500 → "Title"
      Input mt-1 placeholder="Brief summary of the issue"

    Description field:
      Label text-xs text-slate-500 → "Description"
      Textarea mt-1 rows=4 placeholder="Provide detailed description..."

    Grid grid-cols-2 gap-4:
      Priority field:
        Label text-xs text-slate-500 → "Priority"
        Select mt-1:
          Options: Critical, High, Medium, Low
          Default: "Medium"

      Location field:
        Label text-xs text-slate-500 → "Location"
        Input mt-1 placeholder="Building, floor, room..."
```

### 7.6 Submit Bar
```
Container: flex items-center justify-between pb-8
  Cancel: Link to="/tickets" → Button variant="outline" → "Cancel"
  Submit: Button onClick=handleSubmit disabled={!canSubmit} gap-2
    Send (15px) + "Submit Ticket"
```

### 7.7 Success State
```
Outer: flex items-center justify-center h-[60vh]
Card: max-w-md w-full text-center
  CardContent: py-10 space-y-4
    Icon circle: w-16 h-16 rounded-full bg-green-100 flex items-center justify-center mx-auto
      CheckCircle2 (32px) text-green-600
    h2: text-xl font-bold text-slate-900 → "Ticket Created!"
    p: text-sm text-slate-500
      "Your ticket has been submitted successfully. Ticket number: "
      span: font-mono font-bold text-blue-600 → "TKT-2026-0011"

    If "Other" was selected:
      Notice: flex items-center gap-2 justify-center text-xs text-orange-600 bg-orange-50 p-2 rounded
        AlertCircle (14px)
        "This ticket will be routed to an arbitrator for classification."

    Button row: flex gap-3 justify-center pt-2
      Link to="/tickets" → Button variant="outline" size="sm" → "View Queue"
      Button size="sm" onClick=reset → "Create Another"
```

---

## 8. Styling Methodology

### 8.1 Form Design Principles
1. **Centered narrow layout**: `max-w-2xl mx-auto` (672px) keeps the form scannable
2. **Card-per-section**: Each logical group is a separate Card for visual separation
3. **Consistent label style**: All labels use `text-xs text-slate-500` for a subtle, form-like appearance
4. **Input spacing**: `mt-1` (4px) between label and input for tight but readable pairing
5. **Contextual feedback**: Auto-routing preview appears when a service is selected; warning appears for "Other"
6. **Disabled state**: Submit button is disabled until required fields are filled

### 8.2 Success State Design
- Full-height centering (`h-[60vh]`) for dramatic reveal
- Large green checkmark icon (32px in 64px circle) as visual confirmation
- Monospace ticket number for professional appearance
- Two clear next-action buttons

---

## 9. Form Logic & Validation

### 9.1 Form State
```javascript
requesterType: "Resident" | "Internal"  // default: "Resident"
serviceId: string                        // "" = not selected, "other" = Other, "1"-"10" = service ID
priority: "Critical" | "High" | "Medium" | "Low"  // default: "Medium"
title: string
description: string
requesterName: string
location: string
submitted: boolean                       // default: false
```

### 9.2 Derived Values
```javascript
isOther = serviceId === "other";
selectedService = services.find(s => s.id === Number(serviceId));
activeServices = services.filter(s => s.isActive);
canSubmit = title.trim() && description.trim() && requesterName.trim() && serviceId;
```

### 9.3 Validation Rules
| Field | Required | Validation |
|-------|----------|------------|
| Requester Name | Yes | Non-empty after trim |
| Service | Yes | Must be selected (any value) |
| Title | Yes | Non-empty after trim |
| Description | Yes | Non-empty after trim |
| Priority | No (has default) | Always "Medium" by default |
| Location | No | Optional |

### 9.4 Submit Behavior
```javascript
handleSubmit = () => {
  if (canSubmit) setSubmitted(true);
};
```

### 9.5 Reset Behavior (Create Another)
```javascript
setSubmitted(false);
setTitle("");
setDescription("");
setRequesterName("");
setLocation("");
setServiceId("");
// requesterType and priority retain their values
```

### 9.6 Dynamic Label
```javascript
// Label changes based on requesterType:
requesterType === "Resident" ? "Full Name" : "Employee Name"
// Placeholder changes similarly:
requesterType === "Resident" ? "Enter resident name" : "Enter employee name"
```

### 9.7 Service Dropdown Items
- All active services (where `isActive === true`): displayed as "{nameEn} — {department}"
- Last item: "⚠️ Other (describe manually)" with value "other"

### 9.8 Auto-Routing Preview
When a real service is selected (not "Other"):
```
"Auto-routing: {department} → {division} → {section}"
"Default Priority: {defaultPriority} · SLA Completion: {Math.floor(slaCompletionMin / 60)}h"
```

---

## 10. Complete CSS Class Reference

### 10.1 Form Container
```
max-w-2xl mx-auto space-y-5
```

### 10.2 Header
```
Container: flex items-center gap-3
Back link: flex items-center gap-1 text-sm text-slate-500 hover:text-slate-700
Title: text-2xl font-bold text-slate-900
Subtitle: text-sm text-slate-500 mt-0.5
```

### 10.3 Card Sections
```
CardHeader: pb-3
CardTitle: text-sm font-semibold
CardContent: space-y-4
Label: text-xs text-slate-500
Input: mt-1
Textarea: mt-1
Select trigger: mt-1
```

### 10.4 Radio Group
```
RadioGroup: flex gap-4
Option: flex items-center space-x-2
Label: text-sm cursor-pointer
```

### 10.5 Warning Banner
```
Container: flex items-center gap-2 text-xs text-orange-600 bg-orange-50 p-3 rounded-lg
Icon: shrink-0
```

### 10.6 Auto-Routing Preview
```
Container: bg-slate-50 rounded-lg p-3 text-xs space-y-1
Title: font-semibold text-slate-700
Detail: text-slate-500
```

### 10.7 Priority + Location Grid
```
Grid: grid grid-cols-2 gap-4
```

### 10.8 Submit Bar
```
Container: flex items-center justify-between pb-8
Cancel: variant="outline"
Submit: gap-2 (disabled when !canSubmit)
```

### 10.9 Success State
```
Outer: flex items-center justify-center h-[60vh]
Card: max-w-md w-full text-center
CardContent: py-10 space-y-4
Icon circle: w-16 h-16 rounded-full bg-green-100 flex items-center justify-center mx-auto
Title: text-xl font-bold text-slate-900
Body: text-sm text-slate-500
Ticket #: font-mono font-bold text-blue-600
Notice: flex items-center gap-2 justify-center text-xs text-orange-600 bg-orange-50 p-2 rounded
Buttons: flex gap-3 justify-center pt-2
```

---

## Appendix A: Equivalent Pure CSS

```css
/* Form container */
.form-container {
  max-width: 672px;
  margin: 0 auto;
}

/* Form card */
.form-card {
  background: white;
  border: 1px solid #E2E8F0;
  border-radius: 8px;
  box-shadow: 0 1px 2px rgba(0,0,0,0.05);
  margin-bottom: 20px;
}
.form-card-header {
  padding: 24px 24px 12px;
}
.form-card-title {
  font-size: 14px;
  font-weight: 600;
}
.form-card-content {
  padding: 0 24px 24px;
}

/* Form label */
.form-label {
  font-size: 12px;
  color: #64748B;
  display: block;
  margin-bottom: 4px;
}

/* Form input */
.form-input {
  width: 100%;
  height: 36px;
  padding: 8px 12px;
  font-size: 14px;
  border: 1px solid #E2E8F0;
  border-radius: 6px;
  outline: none;
}
.form-input:focus {
  border-color: #3B82F6;
  box-shadow: 0 0 0 2px rgba(59,130,246,0.2);
}

/* Textarea */
.form-textarea {
  width: 100%;
  padding: 8px 12px;
  font-size: 14px;
  border: 1px solid #E2E8F0;
  border-radius: 6px;
  resize: vertical;
}

/* Radio group */
.radio-group {
  display: flex;
  gap: 16px;
}
.radio-option {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

/* Auto-routing preview */
.routing-preview {
  background: #F8FAFC;
  border-radius: 8px;
  padding: 12px;
  font-size: 12px;
}

/* Warning banner */
.warning-banner {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: #EA580C;
  background: #FFF7ED;
  padding: 12px;
  border-radius: 8px;
}

/* Success state */
.success-container {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 60vh;
}
.success-icon {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  background: #DCFCE7;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto;
}

/* Submit bar */
.submit-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-bottom: 32px;
}
```

---

*End of Create Ticket Implementation Report*