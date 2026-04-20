# How to Build CRTool.msapp from Source

This document explains how to build the Power Apps canvas app (msapp) from the unpacked YAML source files.

## Quick Start

```bash
cd /Users/dhammadeepborkar/Library/CloudStorage/OneDrive-ABSOLUTELABS/Dhamma/Office/Projects/BA/BA\ Change\ Request\ Tool/Repositories/BA-Change-Request-Tool

dotnet tools/PackTool/bin/Release/net10.0/PackTool.dll pack -i CRTool -o CRTool.msapp
```

**Result:** `CRTool.msapp` file created (~119 KB)

---

## What is an msapp?

- **msapp** = Microsoft Power Apps binary format (ZIP archive with compiled controls)
- **Source** = Unpacked YAML files in `CRTool/Src/` directory
- **Build Process** = PackTool reads YAML → compiles → outputs binary msapp

Power Apps Studio recognizes only the binary msapp format. Changes to YAML source files have no effect until repacked via PackTool.

---

## Required Files for Build Success

The `CRTool/` directory must contain these files at the root level:

| File | Purpose | Status |
|------|---------|--------|
| `CanvasManifest.json` | App metadata, screen definitions | ✅ Present |
| `Themes.json` | BA brand color palette (RGBA styling) | ✅ Present |
| `ControlTemplates.json` | Power Apps control definitions | ✅ Present |
| `DataSources.json` | SharePoint connections (wrapped format) | ✅ Present |
| `Entropy/Entropy.json` | Build checksums (auto-generated) | ✅ Auto-updated |
| `Src/*.fx.yaml` | 11 screen definitions | ✅ Present |

### Directory Structure

```
CRTool/
├── CanvasManifest.json              ← Required
├── Themes.json                      ← Required
├── ControlTemplates.json            ← Required
├── DataSources.json                 ← Required (wrapped format)
├── ComponentReferences.json         ← Optional
├── Entropy/
│   └── Entropy.json                 ← Auto-generated on build
└── Src/
    ├── App.fx.yaml
    ├── Dashboard Screen.fx.yaml
    ├── Home Screen.fx.yaml
    ├── View CRs Screen.fx.yaml
    ├── Submit CR Screen.fx.yaml
    ├── Submit CR B Screen.fx.yaml
    ├── CR Detail Screen.fx.yaml
    ├── User Admin Screen.fx.yaml
    ├── PMO Consolidation Screen.fx.yaml
    ├── Stakeholder Assessment Screen.fx.yaml
    ├── Programme Meeting Screen.fx.yaml
    └── pkgs/
        └── [gallery templates if present]
```

---

## DataSources.json Format (Critical)

Must use this exact wrapper structure or PackTool will fail:

```json
{
  "DataSources": [
    {
      "Name": "CRRequests",
      "Type": "SharePoint",
      "Url": "https://baplc.sharepoint.com/sites/Engprog"
    },
    {
      "Name": "CRUserAdmin",
      "Type": "SharePoint",
      "Url": "https://baplc.sharepoint.com/sites/Engprog"
    },
    {
      "Name": "CRStakeholderReviews",
      "Type": "SharePoint",
      "Url": "https://baplc.sharepoint.com/sites/Engprog"
    },
    {
      "Name": "AIPSGMeetings",
      "Type": "SharePoint",
      "Url": "https://baplc.sharepoint.com/sites/Engprog"
    }
  ]
}
```

**Key Rule:** Wrap the array in `{ "DataSources": [...] }` — plain JSON array will fail.

---

## YAML Source Files: Rules to Follow

All screen definitions in `Src/*.fx.yaml` must follow these rules:

### 1. Formula Values Must Start with `=`
✅ Correct:
```yaml
X: =16
Width: =Parent.Width - 32
Text: =Text(CountRows(CRRequests))
```

❌ Wrong:
```yaml
X: 16
Width: Parent.Width - 32
```

### 2. Comments Use `/* */` After Formulas
✅ Correct:
```yaml
Fill: =RGBA(1, 37, 84, 1) /* Midnight Navy */
```

❌ Wrong:
```yaml
Fill: =RGBA(1, 37, 84, 1) // Midnight Navy
```

### 3. Screen Names with Spaces Use Single Quotes
✅ Correct:
```yaml
'Dashboard Screen' As screen:
'User Admin Screen' As screen:
```

❌ Wrong:
```yaml
Dashboard Screen As screen:
```

### 4. Control Names Follow IAG Standards
- Buttons: `btn` + purpose + screen suffix (e.g., `btnSubmitHS`)
- Labels: `lbl` + purpose (e.g., `lblStatusNewCount`)
- Rectangles: `rec` + purpose (e.g., `recStatusNew`)
- Containers: `con` + purpose (e.g., `conStatusTiles`)
- Text Inputs: `txt` + purpose
- Icons: `ico` + purpose

---

## Common Build Issues & Fixes

### Error: "JSON value could not be converted to System.Collections.Generic.List"

**Cause:** DataSources.json not wrapped in `{ "DataSources": [...] }`

**Fix:**
```json
// ❌ WRONG
[
  { "Name": "CRRequests", ... },
  { "Name": "CRUserAdmin", ... }
]

// ✅ CORRECT
{
  "DataSources": [
    { "Name": "CRRequests", ... },
    { "Name": "CRUserAdmin", ... }
  ]
}
```

### Error: "Theme parsing error" or "invalid theme schema"

**Cause:** Themes.json missing required properties

**Fix:** Verify Themes.json contains proper color definitions with RGBA values

### Controls Not Rendering After Build

**Cause:** Z-order issues or container clipping (parent too narrow/short)

**Fix:** Check control X/Y/Width/Height properties. Verify container bounds are large enough to contain children. Example:

```yaml
# ✅ Container spans full parent
conStatusTiles As groupContainer:
    X: =0
    Y: =192
    Width: =Parent.Width           # Full width, not Parent.Width - 32
    Height: =110
    Fill: =RGBA(0, 0, 0, 0)        # Transparent
    
    # Child controls positioned relative to container
    recStatusNew As rectangle:
        X: =16                      # 16px from container left
        Y: =0
        Width: =140
        Height: =100
```

### "YAML syntax error" or "formula error"

**Cause:** Missing `=` at start of formula values

**Fix:** Audit all property values — they must begin with `=` if they contain expressions

---

## After Build: Testing in Power Apps Studio

1. **Upload the msapp:**
   - Open Power Apps Studio: https://make.powerapps.com
   - Select "Open app" or "Upload"
   - Choose the newly built `CRTool.msapp`

2. **Verify connections establish:**
   - App will prompt to connect to SharePoint data sources
   - Confirm connections to `https://baplc.sharepoint.com/sites/Engprog`

3. **Test navigation:**
   - Home Screen loads with 6 main tiles
   - Each tile navigates to correct screen
   - Role-gated screens (PMO Consolidation, Programme Meeting) restrict non-PMO users

4. **Dashboard Screen verification:**
   - All 9 status progression tiles display: New, Submitted, In Assessment, PMO Consolidation, Programme Meeting, Pre-SG Distribution, SG Review, Approved, Rejected
   - Tile counts update with SharePoint data
   - Text labels display on 2 lines where needed (bold formatting)
   - All tiles fit in single row with consistent sizing and margins

5. **Data workflow test:**
   - Submit a test CR via Submit CR Screen
   - Verify new CR appears in CRRequests SharePoint list with Status="New"
   - Check that status flows through workflow states

---

## Build Performance

- **Build Time:** ~2-5 seconds
- **Output Size:** ~119 KB (msapp is compressed ZIP)
- **Incremental Updates:** Each build reads entire source tree (no incremental support)

---

## Troubleshooting: PackTool Not Found

If the command fails with "PackTool not found":

```bash
# Verify PackTool binary exists
ls -la tools/PackTool/bin/Release/net10.0/PackTool.dll

# If missing, rebuild PackTool
cd tools/PackTool
dotnet publish -c Release -f net10.0
```

---

## Related Documentation

- **Architecture:** `docs/BA_CRTool_Architecture_Overview.md`
- **Technical Roadmap:** `docs/CR_Tool_Technical_Roadmap_v2_1.md`
- **Build & Validation Plan:** `docs/superpowers/plans/2026-04-13-msapp-build-production-validation-plan.md`
- **Screen Fixes Design:** `docs/superpowers/specs/2026-04-13-msapp-build-production-validation-design.md`

---

## Quick Reference: One-Liner Build

```bash
cd /Users/dhammadeepborkar/Library/CloudStorage/OneDrive-ABSOLUTELABS/Dhamma/Office/Projects/BA/BA\ Change\ Request\ Tool/Repositories/BA-Change-Request-Tool && dotnet tools/PackTool/bin/Release/net10.0/PackTool.dll pack -i CRTool -o CRTool.msapp && echo "✅ Build complete: CRTool.msapp"
```

**Last Updated:** 13 Apr 2026, 14:45 GMT+1
