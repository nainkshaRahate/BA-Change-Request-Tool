# BA CR Tool — Screen Fixes & BA Brand Enhancement

**Date:** 2026-04-08  
**Branch:** feature/screen-fixes  
**Status:** ALL COMPLETE ✅ — `CRTool_v1.msapp` packed (~56,709 bytes), ready to import.

---

## Formula Fixes — All Implemented

| # | Screen | Control | Fix |
|---|--------|---------|-----|
| 1 | Submit CR | `dteAIPSGSCS`, `dteDeadlineSCS` | `SelectedDate` → `DefaultDate` (settable property) |
| 2 | All 11 | All Navigate calls | `None` → `ScreenTransition.None` (28 occurrences) |
| 3 | Submit CR | `btnContinueSCS`, `btnSaveDraftSCS` | `IsBlank(cmb.Selected)` → `IsBlank(cmb.Selected.Email)` |
| 4 | Dashboard | `lblStatusTileLblDS` | `ThisItem.Value` → `ThisItem` (string array gallery) |
| 5 | Dashboard | `lblTileOverdueCountDS` | Colour red → white (was invisible on red tile) |
| 6 | Dashboard | `lblProgRejectedDS` | `Align.Center.Center` → `Align.Center` |
| 7 | Home | `btnUserAdminHS` | Removed `Visible: =gblIsAdmin` |
| 8 | Submit CR | `btnContinueSCS` | Text → `"Next →"` |
| 9 | Submit CR B | `btnBackSCB` | Text → `"← Previous"` |
| 10 | View CRs | `lblDaysOpenVCS` | Added `If(IsBlank(SubmittedDate), "—", ...)` guard |

---

## BA Brand UI Enhancements — All Implemented

### Global colour updates
| Old | New | Where |
|-----|-----|-------|
| `RGBA(31, 55, 100)` | `RGBA(1, 37, 84)` — BA Midnight Navy | All headers (42 instances) |
| `RGBA(24, 44, 82)` | `RGBA(0, 22, 55)` — BA Deep Navy | All sub-navs (22 instances) |
| `RGBA(110, 140, 176)` | `RGBA(0, 75, 135)` — BA Mid-Blue | CTA buttons, status pills |
| `RGBA(200, 200, 200)` | `RGBA(180, 196, 218)` — BA Blue-tinted | Form input borders (34 instances) |

### BA Gold `RGBA(186, 150, 46, 1)`
- 4px gold strip at top of Home Screen
- Gold subtitle text on Home Screen
- 3px gold accent at Y=47 of every content screen header (9 screens)
- Dashboard button fill
- User Admin button border + text

### Home Screen redesign
- Gold top accent + gold subtitle + slim gold divider
- Buttons: View CRs → BA mid-blue, Templates → BA teal, Dashboard → BA gold, PMO → BA mid-blue, Programme Meeting → refined purple, User Admin → dark slate with gold border
- Role badge → pill-shaped (14px radius)

### Global polish
- All button corners: 4px → 6px radius

---

## Formula Rules Confirmed

| Rule | Wrong | Right |
|------|-------|-------|
| DatePicker initial value | `SelectedDate: =formula` | `DefaultDate: =formula` |
| Navigate transition | `Navigate(Screen, None)` | `Navigate(Screen, ScreenTransition.None)` |
| ComboBox null check | `IsBlank(cmb.Selected)` | `IsBlank(cmb.Selected.Email)` |
| Gallery string array | `ThisItem.Value` | `ThisItem` |
| Align property | `Align.Center.Center` | `Align.Center` |
| OnSelect comments | `// comment` | `/* comment */` |

---

## Pack Command

```bash
cd /tmp/PackTool && BASE="/Users/dhammadeepborkar/Library/CloudStorage/OneDrive-ABSOLUTELABS/Dhamma/Office/Projects/BA/BA Change Request Tool/Repositories/BA-Change-Request-Tool" && /opt/homebrew/bin/dotnet run -- "$BASE/CRTool" "$BASE/CRTool_v1.msapp" 2>&1
```

Expected: `✓ Saved ... Size: ~56,000–57,000 bytes`
