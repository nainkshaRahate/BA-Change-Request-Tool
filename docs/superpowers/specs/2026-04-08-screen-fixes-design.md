# BA CR Tool — Screen Fixes Design

**Date:** 2026-04-08  
**Branch:** feature/screen-fixes  
**Status:** Fixes 1–3 implemented and packed. Fixes 4–8 approved, pending implementation.

---

## Context

A systematic audit of all 11 Power Apps screen YAML files was performed. Formula errors causing red-dot indicators in Power Apps Studio were identified and categorised. Three batches of fixes have been packed into `CRTool_v1.msapp`.

---

## Fixes Already Implemented (Packed)

### Fix 1 — DatePicker DefaultDate (`Submit CR Screen`)
- **File:** `CRTool/Src/Submit CR Screen.fx.yaml`
- **Controls:** `dteAIPSGSCS`, `dteDeadlineSCS`
- **Problem:** Both used `SelectedDate` as a settable YAML property. `SelectedDate` is read-only output on DatePicker; the settable default is `DefaultDate`.
- **Root cause chain:** Errored datepicker → `dteAIPSGSCS.SelectedDate` reads as blank → `btnContinueSCS` validation always fails → Continue button never navigates.
- **Fix:** `SelectedDate:` → `DefaultDate:` on both controls.

### Fix 2 — ScreenTransition.None (All Screens)
- **Files:** All 11 `*.fx.yaml` files
- **Problem:** All `Navigate()` calls used bare `None` as the transition argument. Power Apps resolves bare `None` as `BorderStyle.None` (wrong enum) → formula errors on every navigation button.
- **Fix:** 28 occurrences replaced: `Navigate('Screen', None)` → `Navigate('Screen', ScreenTransition.None)`.

### Fix 3 — IsBlank on ComboBox Record (`Submit CR Screen`)
- **File:** `CRTool/Src/Submit CR Screen.fx.yaml`
- **Controls:** `btnContinueSCS` (validation), `btnSaveDraftSCS` (inline comment removed)
- **Problem:** `IsBlank(cmbPMSCS.Selected)` and `IsBlank(cmbSponsorSCS.Selected)` pass Record types to `IsBlank()`, which expects a scalar. Type mismatch → red-dot errors.
- **Fix:** Changed to `IsBlank(cmbPMSCS.Selected.Email)` and `IsBlank(cmbSponsorSCS.Selected.Email)`.
- **Also:** Removed `//` inline comment between Patch and If statements in `btnSaveDraftSCS.OnSelect` (can cause parse issues; IAG standard requires `/* */` block style).

---

## Fixes Approved — Pending Implementation

### Fix 4 — Dashboard Screen: `lblStatusTileLblDS` (red-dot)
- **File:** `CRTool/Src/Dashboard Screen.fx.yaml`, line 216
- **Problem:** `Text: =ThisItem.Value` — the gallery `galStatusDS` has `Items` as a plain string array `["Draft","Submitted",...]`. `ThisItem` is a Text value, not a record; `.Value` does not exist.
- **Fix:** `Text: =ThisItem`

### Fix 5 — Dashboard Screen: `lblTileOverdueCountDS` invisible count (red-dot + invisible)
- **File:** `CRTool/Src/Dashboard Screen.fx.yaml`, line 328
- **Problem:** `Color: =RGBA(192, 57, 43, 1)` — red text on a red tile (`recTileOverdueDS` Fill is the same red). Count number is invisible.
- **Fix:** `Color: =RGBA(255, 255, 255, 1)`

### Fix 6 — Dashboard Screen: `lblProgRejectedDS` double enum (red-dot)
- **File:** `CRTool/Src/Dashboard Screen.fx.yaml`, line 625
- **Problem:** `Align: =Align.Center.Center` — double accessor on the enum. Invalid syntax.
- **Fix:** `Align: =Align.Center`

### Fix 7 — Home Screen: `btnUserAdminHS` hidden in Studio preview
- **File:** `CRTool/Src/Home Screen.fx.yaml`, line 188
- **Problem:** `Visible: =gblIsAdmin` — in PA Studio preview, all global variables default to false/blank, making this button invisible. User reports it as "missing".
- **Fix:** Remove the `Visible` property entirely (default is `true`). Role enforcement is already handled by `User Admin Screen.OnVisible` which navigates away if `Not(gblIsAdmin)`.

### Fix 8 — Submit CR Screen: `btnContinueSCS` text wrapping
- **File:** `CRTool/Src/Submit CR Screen.fx.yaml`, line 137
- **Problem:** `Text: ="Continue: Content →"` wraps on 150px button width.
- **Fix:** `Text: ="Next →"`

### Fix 9 — Submit CR B Screen: `btnBackSCB` label rename
- **File:** `CRTool/Src/Submit CR B Screen.fx.yaml`, line 84
- **Problem:** `Text: ="← Part A"` — user wants consistent nav labelling.
- **Fix:** `Text: ="← Previous"`

### Fix 10 — View CRs Screen: `lblDaysOpenVCS` blank date guard
- **File:** `CRTool/Src/View CRs Screen.fx.yaml`, line 303
- **Problem:** `DateDiff(ThisItem.SubmittedDate, Today(), Days)` — Draft CRs have no `SubmittedDate` (only set on formal submission). Returns 0 for all drafts → shows "0 Days" which is misleading.
- **Fix:** `If(IsBlank(ThisItem.SubmittedDate), "—", Text(DateDiff(ThisItem.SubmittedDate, Today(), Days)) & " Days")`

---

## Formula Rules Confirmed in This Session

| Pattern | Wrong | Right |
|---------|-------|-------|
| DatePicker initial value | `SelectedDate: =formula` | `DefaultDate: =formula` |
| Navigate transition | `Navigate(Screen, None)` | `Navigate(Screen, ScreenTransition.None)` |
| ComboBox null check | `IsBlank(cmb.Selected)` | `IsBlank(cmb.Selected.Email)` |
| Gallery string array label | `ThisItem.Value` | `ThisItem` |
| Align property | `Align.Center.Center` | `Align.Center` |
| Comments in OnSelect | `// comment` | `/* comment */` |

---

## Pack Command

```bash
cd /tmp/PackTool && BASE="/Users/dhammadeepborkar/Library/CloudStorage/OneDrive-ABSOLUTELABS/Dhamma/Office/Projects/BA/BA Change Request Tool/Repositories/BA-Change-Request-Tool" && /opt/homebrew/bin/dotnet run -- "$BASE/CRTool" "$BASE/CRTool_v1.msapp" 2>&1
```

Expected output ends with: `✓ Saved ... Size: ~56,000 bytes`
