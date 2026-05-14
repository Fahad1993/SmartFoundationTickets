---
name: create-smart-component
description: Create modular UI components within SmartFoundation ecosystem while maintaining a strict separation between HTML (Alpine.js enabled), ViewModels, ViewComponents, and static assets.
---

# Create Smart Foundation Component

## Goal

Create modular UI components within SmartFoundation ecosystem while maintaining a strict separation between HTML (Alpine.js enabled), ViewModels, ViewComponents, and static assets.

## Architectural Rules & Path Mapping

When generating a new component (e.g., SlaPanel), follow these exact pathing and logic constraints:

### 1. UI Markup (The "Skin")

**Path:** `\SmartFoundation.UI\Views\Shared\Components\[ComponentName]\Default.cshtml`

**Logic:**
- Contains only HTML and Alpine.js attributes for reactivity (e.g., `x-data`, `x-show`).
- Use utility classes (Tailwind/Bootstrap) for styling.
- **STRICT BAN:** No `<style>` tags and no `<script>` tags inside this file.

### 2. ViewComponent Logic (The "Brain")

**Path:** `\SmartFoundation.UI\ViewComponents\[ComponentName]\[ComponentName]ViewComponent.cs`

**Logic:**
- Namespace: `SmartFoundation.UI.ViewComponents.[ComponentName]`
- Inherits from `ViewComponent`.
- Simple one-liner: `public IViewComponentResult Invoke([ComponentName]Config model) => View("Default", model);`
- **NO** `InvokeAsync`, **NO** `Task<IViewComponentResult>`

### 3. ViewModel Definition (The "Data")

**Path:** `\SmartFoundation.UI\ViewModels\SmartPage\SmartPageViewModel.cs`

**Logic:**
- Define properties and data structures here that will be passed into the component.
- Ensure proper C# naming conventions (PascalCase).

### 4. Static Assets (The "External Dependencies")

**JavaScript:** `\SmartFoundation.Mvc\wwwroot\js\[ComponentName].js`

- Use this for complex logic that Alpine.js cannot handle.

**CSS:** `\SmartFoundation.Mvc\wwwroot\css\[ComponentName].css`

- Use this for custom animations or styles not covered by global classes.

## Instructions for AI Agent

To be precise and specific, the agent must:

### Scan Context

Read existing files in:
- `\SmartFoundation.UI\ViewComponents\` - to ensure naming consistency and avoid property collisions
- `\SmartFoundation.UI\ViewModels\SmartPage\` - to check for existing properties

### Strict File Generation

When asked for a "New Component," output code for **four separate files** corresponding to the paths above:

1. `ViewComponents\[ComponentName]\[ComponentName]ViewComponent.cs` - namespace: `SmartFoundation.UI.ViewComponents.[ComponentName]`
2. `Views\Shared\Components\[ComponentName]\Default.cshtml`
3. `ViewModels\SmartPage\SmartPageViewModel.cs` (add property only)
4. `wwwroot\js\[ComponentName].js` (if needed)
5. `wwwroot\css\[ComponentName].css` (if needed)

### Alpine.js Only

- In `Default.cshtml`, only use Alpine.js for client-side state.
- If user asks for a "Function," place it in the `.js` path provided in rule #4.
- **NO** inline `<script>` tags in Razor views
- **NO** inline `<style>` tags in Razor views
- **NO** inline `onclick`, `onchange`, or other JavaScript event handlers

## Component File Templates

### ViewComponent Template

```csharp
using Microsoft.AspNetCore.Mvc;
using SmartFoundation.UI.ViewModels.SmartPage;

namespace SmartFoundation.UI.ViewComponents.[ComponentName]
{
    public class [ComponentName]ViewComponent : ViewComponent
    {
        public IViewComponentResult Invoke([ComponentName]Config model) => View("Default", model);
    }
}
```

### Default.cshtml Template

```razor
@using SmartFoundation.UI.ViewModels.SmartPage
@using System.Text.Json

@model [ComponentName]Config

@{
    var webJson = new JsonSerializerOptions(JsonSerializerDefaults.Web);

    var componentConfig = new
    {
        // Map model properties here
        Property1 = Model.Property1,
        Property2 = Model.Property2
    };
}

<!-- Alpine.js component - NO inline scripts or styles -->
<div x-data='[ComponentName](@Html.Raw(JsonSerializer.Serialize(componentConfig, webJson)))'
     x-init="init()" x-cloak>

    <!-- Component HTML using utility classes -->
    <div class="component-container">
        <!-- Your HTML here -->
    </div>

</div>
```

### JavaScript Template

```javascript
(function () {
    function [ComponentName](config) {
        return {
            // Reactive properties from config
            ...config,

            // Component state
            loading: false,
            error: null,

            // Methods
            init() {
                console.log('[ComponentName] initialized');
            },

            // Add your methods here
            someMethod() {
                // Complex logic here
            }
        };
    }

    // Register with Alpine.js
    if (window.Alpine) {
        window.Alpine.data('[ComponentName]', [ComponentName]);
    }
})();
```

### CSS Template

```css
/* Component container */
.[component-name] {
    /* Styles not covered by utility classes */
}

/* Element styles */
.[component-name]__element {

}

/* RTL support */
.[component-name][dir="rtl"] {
    /* RTL-specific styles */
}
```

## Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| **Component Name** | PascalCase | `SlaPanel`, `TicketList` |
| **CSS/JS Filename** | PascalCase | `SlaPanel.js`, `SlaPanel.css` |
| **CSS Class Prefix** | kebab-case | `.sla-panel` |
| **Alpine Component** | PascalCase | `SlaPanel` |

## Usage Example

After creating the component, use it in a view:

```razor
@await Component.InvokeAsync("[ComponentName]", new [ComponentName]Config {
    Property1 = "value1",
    Property2 = "value2"
})
```

Or in controller:

```csharp
viewModel.[ComponentName] = new [ComponentName]Config {
    Property1 = "value1",
    Property2 = "value2"
};
```

## Checklist

Before declaring component complete, verify:

- [ ] ViewComponent class inherits from `ViewComponent`
- [ ] ViewComponent namespace is `SmartFoundation.UI.ViewComponents.[ComponentName]`
- [ ] ViewComponent uses `Invoke` method (NOT `InvokeAsync`)
- [ ] `Default.cshtml` contains NO `<script>` or `<style>` tags
- [ ] `Default.cshtml` uses only Alpine.js for interactivity
- [ ] Property added to `SmartPageViewModel.cs` with PascalCase naming
- [ ] JS file wrapped in IIFE and registered with Alpine.js
- [ ] CSS file uses kebab-case class names
- [ ] All paths match the exact architectural rules above

## Important Reminders

1. **ALWAYS** scan existing ViewComponents and ViewModel files first
2. **NEVER** write inline JavaScript or CSS in Razor views
3. **ALWAYS** use Alpine.js for client-side state
4. **ALWAYS** use utility classes (Tailwind/Bootstrap) for styling
5. **ENSURE** proper C# PascalCase naming in ViewModels
6. **ENSURE** RTL support for Arabic interface in CSS
