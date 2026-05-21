---
name: qlik-sense-theme
description: Qlik Sense custom theme development - full reference covering theme.json properties, CSS overrides, font loading, color palettes, scales, chart-specific styling for all 18 chart types, visualization extension theming, and deployment. Use when creating or editing Qlik Sense themes (theme.json, theme.css, .qext files) or building visualization extensions that consume theme properties.
---

# Qlik Sense Custom Theme Development

> **Quick Guide:** A Qlik Sense theme is a folder containing a `.qext` manifest, `theme.json` (all styling definitions), optional `theme.css` (CSS overrides), and bundled assets (fonts, images). All colors in theme.json should use hex. Variables are `@`-prefixed. Charts set to auto-coloring use `primaryColor` for single-color charts and `palettes.data[0]` for multi-color charts.

---

## Theme File Structure

```
my-theme/
├── my-theme.qext        # Extension manifest
├── theme.json           # All styling definitions
├── theme.css            # Custom CSS overrides (optional)
├── fonts/               # Custom font files (.ttf, .woff, .woff2)
└── images/              # Background images, logos (optional)
```

### Deployment

Zip the theme folder and upload to Qlik Cloud as an extension.

---

## .qext Manifest (Required)

The `.qext` filename must match the `name` field. The file must be valid JSON (validate at jsonlint.com). QEXT file extension must be lowercase.

**Mandatory properties:** `name`, `type`

```json
{
  "name": "my-custom-theme",
  "description": "My custom theme description",
  "type": "theme",
  "version": "1.0.0",
  "author": "Author Name"
}
```

Prefix custom theme names to prevent conflicts with themes from other developers.

---

## theme.json Reference

### Inheritance

```json
"_inherit": true
```

| Value | Behavior |
|-------|----------|
| `true` | Inherit all properties from the default Qlik Sense theme; override only what you define |
| `false` | Start from scratch; you must define all properties |

---

### Variables (`_variables`)

Variables are symbolic names defined in `_variables`. Names **must** be prefixed with `@`. Colors should use **hexadecimal values**.

```json
"_variables": {
  "@grayscale-100": "#FFFFFF",
  "@grayscale-98": "#FBFBFB",
  "@grayscale-95": "#F2F2F2",
  "@grayscale-90": "#E6E6E6",
  "@grayscale-85": "#D9D9D9",
  "@grayscale-80": "#CCCCCC",
  "@grayscale-75": "#BFBFBF",
  "@grayscale-70": "#B3B3B3",
  "@grayscale-65": "#A6A6A6",
  "@grayscale-60": "#999999",
  "@grayscale-55": "#8C8C8C",
  "@grayscale-50": "#808080",
  "@grayscale-45": "#737373",
  "@grayscale-40": "#666666",
  "@grayscale-35": "#595959",
  "@grayscale-30": "#4D4D4D",
  "@grayscale-28": "#474747",
  "@grayscale-25": "#404040",
  "@grayscale-20": "#333333",
  "@grayscale-15": "#262626",
  "@grayscale-10": "#1A1A1A",
  "@grayscale-5": "#0D0D0D",
  "@grayscale-0": "#000000",
  "@text": "13px"
}
```

Variables are referenced by name (including `@` prefix) throughout the theme JSON.

---

### Top-Level Properties

These set defaults for the entire app. Lower-level definitions override them.

| Property | Description | Example |
|----------|-------------|---------|
| `color` | All font colors in the app | `"@grayscale-20"` |
| `fontSize` | Default font size | `"@text"` |
| `fontFamily` | Default font family | `"Arial"` or custom font name |
| `backgroundColor` | Background of all visualizations | `"@grayscale-95"` |

---

### Custom CSS (`customStyles`)

Load a CSS file and add a class to the `body` element:

```json
"customStyles": [
  {
    "cssRef": "theme.css",
    "classRef": "sense-theme"
  }
]
```

**Warning:** DOM selectors in custom CSS are not a supported pattern. The DOM is subject to change at any time. Use theme JSON properties as the primary styling mechanism.

---

### Sheet Title Styling (`sheet`)

Controls the sheet title bar background. Three states: `private`, `approved`, `published`.

| Property | Description |
|----------|-------------|
| `titleBackgroundColor` | Background color of the sheet title |
| `titleBackgroundGradientColor` | Gradient color within the sheet title |

```json
"sheet": {
  "title": {
    "private": {
      "titleBackgroundColor": "#ff0000",
      "titleBackgroundGradientColor": "#ffffff"
    },
    "approved": {
      "titleBackgroundColor": "#00ff00",
      "titleBackgroundGradientColor": "#000000"
    },
    "published": {
      "titleBackgroundColor": "#0000ff",
      "titleBackgroundGradientColor": "#ff0000"
    }
  }
}
```

---

### Data Colors (`dataColors`)

#### Chart Data Colors

| Property | Description |
|----------|-------------|
| `primaryColor` | Default color for data when using auto colors. Used for single-color charts (e.g., one-dimensional bar charts). |
| `othersColor` | Color for "Others" group (shown when dimension limits are set) |
| `nullColor` | Color for null values |
| `errorColor` | Color for error states |

```json
"dataColors": {
  "primaryColor": "@grayscale-28",
  "othersColor": "@grayscale-55",
  "errorColor": "@grayscale-90",
  "nullColor": "@grayscale-85"
}
```

#### Selection State Colors

These colors appear in the selection bar and all listboxes/filter panes.

| Property | Description | Where Visible |
|----------|-------------|---------------|
| `selected` | Selected values | Selection bar, listboxes, Straight/Pivot tables |
| `alternative` | Alternative values | Selection bar, listboxes |
| `excluded` | Excluded values | Selection bar, listboxes |
| `selectedExcluded` | Selected excluded values | Selection bar, listboxes |
| `possible` | Possible values | Listboxes |

```json
"dataColors": {
  "selected": "#0363ff",
  "alternative": "#a8c9ff",
  "excluded": "#ffaf03",
  "selectedExcluded": "#ffe58f",
  "possible": "#ffffff"
}
```

---

### Color Palettes (`palettes`)

#### Where Palettes Are Used

| Location | Color Source |
|----------|-------------|
| Sheet title background/font color | `palettes.ui[0]` |
| Properties panel - Auto | `palettes.data[0]` (first data palette) |
| Properties panel - Single color | `palettes.ui[0]` |
| Properties panel - Color by Dimension | `palettes.data[...]` |
| Properties panel - Color by Measure | `scales[...]` |
| Master items - measure/dimension/value colors | `palettes.ui[0]` |
| Storytelling - shape background | `palettes.ui[0]` |

#### Data Palettes (`palettes.data`)

Used for **Color by Dimension**. Colors should use hex values.

| Property | Description |
|----------|-------------|
| `name` | Internal palette name |
| `translation` | Display name in the UI |
| `propertyValue` | Unique identifier (must be unique across all palettes) |
| `type` | `"row"` for categorical palettes |
| `scale` | Array of hex color values |

```json
"palettes": {
  "data": [
    {
      "name": "Dark colors",
      "translation": "Dark colors",
      "propertyValue": "12",
      "type": "row",
      "scale": [
        "#808080", "#737373", "#666666", "#595959",
        "#4D4D4D", "#474747", "#404040", "#333333",
        "#262626", "#1A1A1A", "#0D0D0D", "#000000"
      ]
    },
    {
      "name": "Light colors",
      "translation": "Light colors",
      "propertyValue": "11",
      "type": "row",
      "scale": [
        "#FFFFFF", "#FBFBFB", "#F2F2F2", "#E6E6E6",
        "#D9D9D9", "#CCCCCC", "#BFBFBF", "#B3B3B3",
        "#A6A6A6", "#999999", "#8C8C8C"
      ]
    }
  ],
  "ui": [
    {
      "name": "Palette",
      "colors": [
        "#FFFFFF", "#FBFBFB", "#F2F2F2", "#D9D9D9",
        "#BFBFBF", "#A6A6A6", "#8C8C8C", "#808080",
        "#737373", "#595959", "#474747", "#404040",
        "#262626", "#0D0D0D", "#000000"
      ]
    }
  ]
}
```

Though you can define multiple UI palettes, only `ui[0]` is used by the color picker.

---

### Color Scales (`scales`)

Used for **Color by Measure**. If you define two colors, Qlik generates a scale between them.

| Type | Behavior |
|------|----------|
| `"gradient"` | Smooth continuous gradient between scale colors |
| `"class"` | Discrete stepped classes between scale colors |

```json
"scales": [
  {
    "name": "Sequential gradient",
    "translation": "Sequential gradient",
    "type": "gradient",
    "propertyValue": "sg",
    "scale": ["#8C8C8C", "#FBFBFB"]
  },
  {
    "name": "Sequential classes",
    "translation": "Sequential classes",
    "type": "class",
    "propertyValue": "sc",
    "scale": ["#8C8C8C", "#FBFBFB"]
  },
  {
    "name": "Diverging gradient",
    "translation": "Diverging gradient",
    "type": "gradient",
    "propertyValue": "dg",
    "scale": ["#737373", "#0D0D0D"]
  },
  {
    "name": "Diverging classes",
    "translation": "Diverging classes",
    "type": "class",
    "propertyValue": "dc",
    "scale": ["#737373", "#0D0D0D"]
  }
]
```

Scale properties:

| Property | Description |
|----------|-------------|
| `name` | Internal scale name |
| `translation` | Display name in the UI |
| `type` | `"gradient"` or `"class"` |
| `propertyValue` | Unique identifier (must be unique across all scales) |
| `scale` | Array of hex colors to interpolate between (minimum 2) |

---

### General Object Styling (`object`)

Styles common chart elements. These apply to all charts unless overridden by chart-specific styling.

```json
"object": {
  "title": {
    "main": {
      "color": "@grayscale-40",
      "fontSize": "20px"
    },
    "subTitle": {
      "color": "@grayscale-40",
      "fontSize": "16px"
    },
    "footer": {
      "color": "@grayscale-15",
      "fontSize": "@text",
      "backgroundColor": "@grayscale-85"
    }
  },
  "label": {
    "name": {
      "color": "@grayscale-35",
      "fontSize": "@text"
    },
    "value": {
      "color": "@grayscale-35",
      "fontSize": "@text"
    }
  },
  "axis": {
    "title": {
      "color": "@grayscale-35",
      "fontSize": "@text"
    },
    "label": {
      "color": "@grayscale-35",
      "fontSize": "@text"
    },
    "line": {
      "major": { "color": "@grayscale-20" },
      "minor": { "color": "@grayscale-40" }
    }
  },
  "grid": {
    "line": {
      "highContrast": { "color": "#999999" },
      "major": { "color": "#CCCCCC" },
      "minor": { "color": "#E6E6E6" }
    }
  },
  "referenceLine": {
    "label": {
      "name": {
        "color": "@grayscale-35",
        "fontSize": "@text"
      }
    },
    "outOfBounds": {
      "color": "@grayscale-35",
      "backgroundColor": "@grayscale-35",
      "fontSize": "@text"
    }
  },
  "legend": {
    "title": {
      "fontSize": "@text",
      "color": "@grayscale-35"
    },
    "label": {
      "fontSize": "@text",
      "color": "@grayscale-35"
    }
  }
}
```

---

### Chart-Specific Styling (18 Chart Types)

Chart-specific styles are nested inside `"object"` and override general object styling for that chart type.

#### Bar Chart (`barChart`)

```json
"barChart": {
  "outOfRange": {
    "color": "@grayscale-40"
  }
}
```

#### Line Chart (`lineChart`)

```json
"lineChart": {
  "outOfRange": {
    "color": "@grayscale-40"
  }
}
```

#### Boxplot (`boxPlot`)

Style whisker/line/box stroke and fill colors.

```json
"boxPlot": {
  "box": {
    "whisker": { "stroke": "@grayscale-35" },
    "line": { "stroke": "@grayscale-35" },
    "box": { "fill": "@grayscale-35", "stroke": "@grayscale-35" }
  }
}
```

#### Distribution Plot (`distributionPlot`)

```json
"distributionPlot": {
  "box": { "fill": "@grayscale-35" }
}
```

#### Filter Pane (`filterpane`)

Title only. Filter pane content is controlled by `listBox` styling.

```json
"filterpane": {
  "title": {
    "main": {
      "color": "@grayscale-35",
      "fontSize": "@text"
    }
  }
}
```

#### Gauge (`gauge`)

```json
"gauge": {
  "label": {
    "value": {
      "color": "@grayscale-35",
      "fontSize": "@text"
    }
  }
}
```

#### Histogram (`histogram`)

```json
"histogram": {
  "label": {
    "value": {
      "color": "@grayscale-35",
      "fontSize": "20px"
    }
  }
}
```

#### KPI (`kpi`)

```json
"kpi": {
  "title": {
    "main": {
      "color": "@grayscale-35",
      "fontSize": "@text"
    }
  }
}
```

#### List Box (`listBox`)

Controls filter panes, list boxes in the selections tool, and searches of values in charts.

```json
"listBox": {
  "title": {
    "main": {
      "color": "@grayscale-40",
      "fontSize": "@text"
    }
  },
  "content": {
    "color": "@grayscale-35",
    "fontSize": "@text"
  },
  "dataColors": {
    "selected": "#0363ff",
    "alternative": "#a8c9ff",
    "excluded": "#ffaf03",
    "selectedExcluded": "#ffe58f",
    "possible": "#ffffff"
  }
}
```

| `listBox.dataColors` Property | Description |
|-------------------------------|-------------|
| `selected` | Color for selected values |
| `alternative` | Color for alternative values |
| `excluded` | Color for excluded values |
| `selectedExcluded` | Color for selected excluded values |
| `possible` | Color for possible values |

#### Map Chart (`mapChart`)

```json
"mapChart": {
  "backgroundColor": "@grayscale-95",
  "legend": {
    "title": { "color": "@grayscale-35" },
    "label": { "color": "@grayscale-35" }
  },
  "label": {
    "value": {
      "dark": { "color": "@grayscale-20" },
      "light": { "color": "@grayscale-70" },
      "fontSize": "@text"
    }
  }
}
```

#### Pie Chart (`pieChart`)

```json
"pieChart": {
  "axis": {
    "title": { "fontSize": "@text" }
  },
  "label": {
    "name": { "color": "@grayscale-35", "fontSize": "@text" },
    "value": { "color": "@grayscale-35", "fontSize": "@text" }
  }
}
```

#### Pivot Table (`pivotTable`)

```json
"pivotTable": {
  "header": {
    "fontSize": "@text",
    "color": "@grayscale-35"
  },
  "content": {
    "fontSize": "@text",
    "color": "@grayscale-35"
  }
}
```

#### Scatter Plot (`scatterPlot`)

```json
"scatterPlot": {
  "label": {
    "value": {
      "color": "@grayscale-40",
      "fontSize": "14px"
    }
  }
}
```

#### Straight Table (`straightTableV2`)

The theme key is `straightTableV2`. Supports dimension/measure/total/null/grid styling.

```json
"straightTableV2": {
  "dimension": {
    "label": {
      "name": {
        "fontFamily": "Verdana",
        "fontSize": "18px",
        "color": "#ccc",
        "backgroundColor": "#ff0000"
      },
      "value": {
        "fontFamily": "sans-serif",
        "fontSize": "12px",
        "color": "#000000",
        "backgroundColor": "orangered"
      }
    }
  },
  "measure": {
    "label": {
      "value": {
        "fontFamily": "Arial",
        "fontSize": "14px",
        "color": "#ccc",
        "backgroundColor": "#ff0099"
      }
    }
  },
  "total": {
    "label": {
      "value": {
        "fontFamily": "Tahoma",
        "fontSize": "24px",
        "color": "#fff",
        "backgroundColor": "#3399aa"
      }
    }
  },
  "null": {
    "label": {
      "value": {
        "color": "red",
        "backgroundColor": "#ccc"
      }
    }
  },
  "grid": {
    "borderColor": "purple",
    "divider": { "borderColor": "lime" },
    "hover": {
      "color": "orange",
      "backgroundColor": "black"
    }
  }
}
```

#### Table - Legacy (`table`)

The straight table has replaced this as the default. Consider upgrading.

```json
"table": {
  "header": {
    "fontSize": "@text",
    "color": "@grayscale-60"
  },
  "content": {
    "fontSize": "@text",
    "color": "@grayscale-35"
  }
}
```

#### Treemap (`treemap`)

```json
"treemap": {
  "branch": {
    "backgroundColor": "@grayscale-70",
    "label": {
      "color": "@grayscale-35",
      "fontSize": "@text"
    }
  },
  "leaf": {
    "label": { "fontSize": "@text" }
  }
}
```

#### Waterfall Chart (`waterfallChart`)

```json
"waterfallChart": {
  "label": {
    "value": { "fontSize": "20px" }
  },
  "value": {
    "color": {
      "default": "@grayscale-45",
      "dark": "@grayscale-20",
      "light": "@grayscale-70"
    }
  },
  "shape": {
    "positiveValue": { "fill": "@grayscale-70" },
    "negativeValue": { "fill": "@grayscale-45" },
    "subtotal": { "fill": "@grayscale-20" },
    "bridge": { "stroke": "@grayscale-35" }
  }
}
```

#### Write Table (`writeTable`)

Same styling as `straightTableV2` plus editable column styling.

**Limitations:** Cannot be embedded via qlik-embed. Custom themes cannot change cell status colors (orange, green, blue).

```json
"writeTable": {
  "dimension": {
    "label": {
      "name": {
        "fontFamily": "Verdana", "fontSize": "18px",
        "color": "#ccc", "backgroundColor": "#ff0000"
      },
      "value": {
        "fontFamily": "sans-serif", "fontSize": "12px",
        "color": "#000000", "backgroundColor": "orangered"
      }
    }
  },
  "measure": {
    "label": {
      "value": {
        "fontFamily": "Arial", "fontSize": "14px",
        "color": "#ccc", "backgroundColor": "#ff0099"
      }
    }
  },
  "total": {
    "label": {
      "value": {
        "fontFamily": "Tahoma", "fontSize": "24px",
        "color": "#fff", "backgroundColor": "#3399aa"
      }
    }
  },
  "null": {
    "label": {
      "value": { "color": "red", "backgroundColor": "#ccc" }
    }
  },
  "grid": {
    "borderColor": "purple",
    "divider": { "borderColor": "lime" },
    "hover": { "color": "orange", "backgroundColor": "black" }
  },
  "editableColumn": {
    "label": {
      "value": { "color": "#5c4a00", "backgroundColor": "#fffbe6" }
    },
    "inputFieldBackground": "#fffbe6",
    "inputFieldHoverColor": "#fff3cc"
  }
}
```

---

### Chart-Specific Styling Quick Reference

| Chart Type | Theme Key | Key Styleable Properties |
|---|---|---|
| Bar chart | `barChart` | `outOfRange.color` |
| Line chart | `lineChart` | `outOfRange.color` |
| Boxplot | `boxPlot` | `box.whisker.stroke`, `box.line.stroke`, `box.box.fill`, `box.box.stroke` |
| Distribution plot | `distributionPlot` | `box.fill` |
| Filter pane | `filterpane` | `title.main.color`, `title.main.fontSize` |
| Gauge | `gauge` | `label.value.color`, `label.value.fontSize` |
| Histogram | `histogram` | `label.value.color`, `label.value.fontSize` |
| KPI | `kpi` | `title.main.color`, `title.main.fontSize` |
| List box | `listBox` | `title.main.*`, `content.*`, `dataColors.*` |
| Map chart | `mapChart` | `backgroundColor`, `legend.*`, `label.value.dark/light.color`, `label.value.fontSize` |
| Pie chart | `pieChart` | `axis.title.fontSize`, `label.name.*`, `label.value.*` |
| Pivot table | `pivotTable` | `header.fontSize`, `header.color`, `content.fontSize`, `content.color` |
| Scatter plot | `scatterPlot` | `label.value.color`, `label.value.fontSize` |
| Straight table | `straightTableV2` | `dimension.label.name/value.*`, `measure.label.value.*`, `total.*`, `null.*`, `grid.*` |
| Table (legacy) | `table` | `header.fontSize`, `header.color`, `content.fontSize`, `content.color` |
| Treemap | `treemap` | `branch.backgroundColor`, `branch.label.*`, `leaf.label.fontSize` |
| Waterfall chart | `waterfallChart` | `label.value.fontSize`, `value.color.default/dark/light`, `shape.*.fill/stroke` |
| Write table | `writeTable` | Same as straightTable + `editableColumn.*` |

### Common Styleable Properties

Each styleable element typically supports:

| Property | Type | Example |
|---|---|---|
| `color` | CSS color or variable | `"@grayscale-35"` or `"#FF0000"` |
| `fontSize` | CSS size or variable | `"@text"` or `"14px"` |
| `fontFamily` | string | `"Verdana"`, `"Arial"`, `"sans-serif"` |
| `backgroundColor` | CSS color or variable | `"@grayscale-95"` or `"#ff0000"` |
| `fill` | CSS color or variable | `"@grayscale-35"` |
| `stroke` | CSS color or variable | `"@grayscale-35"` |

---

## Fonts

### Setting Fonts in theme.json

Use the `fontFamily` property at any level. Top-level sets the default; lower levels override.

```json
"fontFamily": "Arial",
"object": {
  "title": {
    "main": {
      "fontSize": "28px",
      "fontFamily": "Alegreya Black"
    }
  }
}
```

### Loading Custom Fonts via CSS

Define `@font-face` rules in your CSS file and reference it via `customStyles`:

```json
{
  "_inherit": true,
  "customStyles": [
    {
      "cssRef": "my_theme.css",
      "classRef": "theme-style"
    }
  ],
  "fontFamily": "YatraOne",
  "object": {
    "title": {
      "main": {
        "fontSize": "28px",
        "fontFamily": "Alegreya Black"
      }
    }
  }
}
```

```css
/* my_theme.css */
@font-face {
  font-family: "Alegreya Black";
  src: url("Alegreya-Black.ttf") format("truetype");
  font-weight: bold;
  font-style: normal;
}

@font-face {
  font-family: "YatraOne";
  src: url("YatraOne-Regular.ttf") format("truetype");
  font-weight: normal;
  font-style: normal;
}
```

Font file structure:
```
my_theme/
  Alegreya-Black.ttf
  my_theme.css
  my_theme.json
  my_theme.qext
  YatraOne-Regular.ttf
```

**Limitations:** Custom fonts from themes are not supported in cross-domain embeds unless using `<qlik-embed iframe="true">`. Font bundling is not supported in Qlik Cloud mashups.

---

## theme.css Patterns

### Sheet Background Override

```css
.qvt-sheet {
  background: transparent !important;
}
```

### Sheet Title Styling

```css
.sheet-title-container {
  position: relative;
  font-family: "My Font Medium";
}

.sheet-title-container::before {
  content: "Brand Label";
  position: absolute;
  right: 80px;
  color: rgb(255, 255, 255);
  font-weight: 600;
  font-family: "My Font Light";
  font-size: 12px;
  top: 12px;
}

#sheet-title .sheet-title-text {
  flex: 1 1 0px;
  overflow: hidden;
  text-overflow: ellipsis;
  color: white;
  font-family: "My Font Medium";
}
```

### Logo Positioning

```css
#sheet-title.sheet-grid.logo-right .sheet-title-logo-img {
  left: -90px !important;
  position: relative;
}
```

---

## Visualization Extensions

To make custom visualization extensions consume theme properties:

### 1. Define the namespace

```javascript
const extensionNamespace = "object.MyVizExtension";
```

The namespace must be `"object.[Extension name as defined in QEXT file]"`.

### 2. Get theme styling in paint()

```javascript
define(["qlik"], function(qlik) {
  const extensionNamespace = "object.MyVizExtension";

  function renderHtml($element, qtheme) {
    // Get primary data color
    var bgColor = qtheme.properties.dataColors.primaryColor;

    // Get styled properties from theme JSON
    var labelColor = qtheme.getStyle(extensionNamespace, "label.name", "color");
    var labelSize = qtheme.getStyle(extensionNamespace, "label.name", "fontSize");

    var html = "<div style='background-color:" + bgColor + ";display:flex;align-items:center;height:100%'>";
    html += "<div style='flex:1 1 auto;text-align:center;";
    html += " color:" + labelColor + ";";
    html += " font-size:" + labelSize + ";'>";
    html += "My Viz Extension</div></div>";
    $element.html(html);
  }

  return {
    support: {
      snapshot: true,
      export: true,
      exportData: false
    },
    paint: function($element) {
      var app = qlik.currApp(this);
      app.theme.getApplied().then(function(qtheme) {
        renderHtml($element, qtheme);
        return qlik.Promise.resolve();
      });
    }
  };
});
```

### 3. Style the extension in theme.json

Define styling under `"object"` using the extension name as the key:

```json
"object": {
  "MyVizExtension": {
    "backgroundColor": "#eee",
    "label": {
      "name": {
        "color": "#fff",
        "fontSize": "50px"
      }
    }
  }
}
```

### Theme API Reference for Extensions

| API | Description |
|-----|-------------|
| `qtheme.properties.dataColors.primaryColor` | Get primary data color |
| `qtheme.getStyle(namespace, path, property)` | Get a styled property value |
| `app.theme.getApplied()` | Promise resolving to the applied theme |

---

## Full theme.json Example (All Properties)

```json
{
  "_inherit": false,
  "_variables": {
    "@grayscale-100": "#FFFFFF",
    "@grayscale-98": "#FBFBFB",
    "@grayscale-95": "#F2F2F2",
    "@grayscale-90": "#E6E6E6",
    "@grayscale-85": "#D9D9D9",
    "@grayscale-80": "#CCCCCC",
    "@grayscale-75": "#BFBFBF",
    "@grayscale-70": "#B3B3B3",
    "@grayscale-65": "#A6A6A6",
    "@grayscale-60": "#999999",
    "@grayscale-55": "#8C8C8C",
    "@grayscale-50": "#808080",
    "@grayscale-45": "#737373",
    "@grayscale-40": "#666666",
    "@grayscale-35": "#595959",
    "@grayscale-30": "#4D4D4D",
    "@grayscale-28": "#474747",
    "@grayscale-25": "#404040",
    "@grayscale-20": "#333333",
    "@grayscale-15": "#262626",
    "@grayscale-10": "#1A1A1A",
    "@grayscale-5": "#0D0D0D",
    "@grayscale-0": "#000000",
    "@text": "13px"
  },
  "customStyles": [
    { "cssRef": "theme.css", "classRef": "sense-theme" }
  ],
  "color": "@grayscale-20",
  "fontSize": "@text",
  "backgroundColor": "@grayscale-95",
  "dataColors": {
    "primaryColor": "@grayscale-28",
    "othersColor": "@grayscale-55",
    "errorColor": "@grayscale-90",
    "nullColor": "@grayscale-85",
    "selected": "#0363ff",
    "alternative": "#a8c9ff",
    "excluded": "#ffaf03",
    "selectedExcluded": "#ffe58f",
    "possible": "#ffffff"
  },
  "object": {
    "title": {
      "main": { "color": "@grayscale-40", "fontSize": "20px" },
      "subTitle": { "color": "@grayscale-40", "fontSize": "16px" },
      "footer": { "color": "@grayscale-15", "fontSize": "@text", "backgroundColor": "@grayscale-85" }
    },
    "label": {
      "name": { "color": "@grayscale-35", "fontSize": "@text" },
      "value": { "color": "@grayscale-35", "fontSize": "@text" }
    },
    "axis": {
      "title": { "color": "@grayscale-35", "fontSize": "@text" },
      "label": { "color": "@grayscale-35", "fontSize": "@text" },
      "line": { "major": { "color": "@grayscale-20" }, "minor": { "color": "@grayscale-40" } }
    },
    "grid": {
      "line": {
        "highContrast": { "color": "#999999" },
        "major": { "color": "#CCCCCC" },
        "minor": { "color": "#E6E6E6" }
      }
    },
    "referenceLine": {
      "label": { "name": { "color": "@grayscale-35", "fontSize": "@text" } },
      "outOfBounds": { "color": "@grayscale-35", "backgroundColor": "@grayscale-35", "fontSize": "@text" }
    },
    "legend": {
      "title": { "fontSize": "@text", "color": "@grayscale-35" },
      "label": { "fontSize": "@text", "color": "@grayscale-35" }
    },
    "barChart": { "outOfRange": { "color": "@grayscale-40" } },
    "lineChart": { "outOfRange": { "color": "@grayscale-40" } },
    "boxPlot": {
      "box": {
        "whisker": { "stroke": "@grayscale-35" },
        "line": { "stroke": "@grayscale-35" },
        "box": { "fill": "@grayscale-35", "stroke": "@grayscale-35" }
      }
    },
    "distributionPlot": { "box": { "fill": "@grayscale-35" } },
    "filterpane": { "title": { "main": { "color": "@grayscale-35", "fontSize": "@text" } } },
    "gauge": { "label": { "value": { "color": "@grayscale-35", "fontSize": "@text" } } },
    "histogram": { "label": { "value": { "color": "@grayscale-35", "fontSize": "20px" } } },
    "kpi": { "title": { "main": { "color": "@grayscale-35", "fontSize": "@text" } } },
    "listBox": {
      "title": { "main": { "color": "@grayscale-40", "fontSize": "@text" } },
      "content": { "color": "@grayscale-35", "fontSize": "@text" },
      "dataColors": {
        "selected": "#0363ff", "alternative": "#a8c9ff",
        "excluded": "#ffaf03", "selectedExcluded": "#ffe58f", "possible": "#ffffff"
      }
    },
    "mapChart": {
      "backgroundColor": "@grayscale-95",
      "label": { "value": { "color": "@grayscale-35", "fontSize": "@text" } }
    },
    "pieChart": {
      "axis": { "title": { "fontSize": "@text" } },
      "label": {
        "name": { "color": "@grayscale-35", "fontSize": "@text" },
        "value": { "color": "@grayscale-35", "fontSize": "@text" }
      }
    },
    "pivotTable": {
      "header": { "fontSize": "@text", "color": "@grayscale-35" },
      "content": { "fontSize": "@text", "color": "@grayscale-35" }
    },
    "scatterPlot": { "label": { "value": { "color": "@grayscale-40", "fontSize": "14px" } } },
    "table": {
      "header": { "fontSize": "@text", "color": "@grayscale-60" },
      "content": { "fontSize": "@text", "color": "@grayscale-35" }
    },
    "treemap": {
      "branch": { "backgroundColor": "@grayscale-70", "label": { "color": "@grayscale-35", "fontSize": "@text" } },
      "leaf": { "label": { "fontSize": "@text" } }
    },
    "waterfallChart": {
      "label": { "value": { "fontSize": "20px" } },
      "value": { "color": { "default": "@grayscale-45", "dark": "@grayscale-20", "light": "@grayscale-70" } },
      "shape": {
        "positiveValue": { "fill": "@grayscale-70" },
        "negativeValue": { "fill": "@grayscale-45" },
        "subtotal": { "fill": "@grayscale-20" },
        "bridge": { "stroke": "@grayscale-35" }
      }
    }
  },
  "palettes": {
    "data": [
      {
        "name": "Dark colors",
        "translation": "Dark colors",
        "propertyValue": "12",
        "type": "row",
        "scale": ["#808080","#737373","#666666","#595959","#4D4D4D","#474747","#404040","#333333","#262626","#1A1A1A","#0D0D0D","#000000"]
      },
      {
        "name": "Light colors",
        "translation": "Light colors",
        "propertyValue": "11",
        "type": "row",
        "scale": ["#FFFFFF","#FBFBFB","#F2F2F2","#E6E6E6","#D9D9D9","#CCCCCC","#BFBFBF","#B3B3B3","#A6A6A6","#999999","#8C8C8C"]
      }
    ],
    "ui": [
      {
        "name": "Palette",
        "colors": ["#FFFFFF","#FBFBFB","#F2F2F2","#D9D9D9","#BFBFBF","#A6A6A6","#8C8C8C","#808080","#737373","#595959","#474747","#404040","#262626","#0D0D0D","#000000"]
      }
    ]
  },
  "scales": [
    { "name": "Sequential gradient", "translation": "Sequential gradient", "type": "gradient", "propertyValue": "sg", "scale": ["#8C8C8C","#FBFBFB"] },
    { "name": "Sequential classes", "translation": "Sequential classes", "type": "class", "propertyValue": "sc", "scale": ["#8C8C8C","#FBFBFB"] },
    { "name": "Diverging gradient", "translation": "Diverging gradient", "type": "gradient", "propertyValue": "dg", "scale": ["#737373","#0D0D0D"] },
    { "name": "Diverging classes", "translation": "Diverging classes", "type": "class", "propertyValue": "dc", "scale": ["#737373","#0D0D0D"] }
  ]
}
```

---

## Common Pitfalls

1. **Colors must be hex** in theme.json — use `#RRGGBB`. Avoid `rgb()`, `rgba()`, or named colors (CSS files accept any format).
2. **Variable names must start with `@`** — without the prefix, Qlik won't recognize them.
3. **`.qext` filename must match `name` field** — a mismatch prevents loading.
4. **QEXT extension must be lowercase** — `my-theme.QEXT` won't work; use `my-theme.qext`.
5. **Font paths in CSS are relative to theme root** — use `url("fonts/my-font.ttf")`, not absolute paths.
6. **`_inherit: true` only overrides what you define** — omitted properties fall back to the default theme.
7. **`propertyValue` in palettes/scales must be unique** — duplicate values cause conflicts.
8. **Avoid duplicate colors in palette `scale` arrays** — each color should appear once per palette.
9. **DOM selectors in CSS are unsupported** — the DOM may change between Qlik versions. Prefer theme JSON properties.
10. **Custom fonts don't work in cross-domain embeds** — use `<qlik-embed iframe="true">` if needed.
11. **Write table cannot change cell status colors** (orange, green, blue) via themes.
