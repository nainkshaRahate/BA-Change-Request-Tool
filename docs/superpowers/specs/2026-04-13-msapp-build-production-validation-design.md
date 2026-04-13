# BA Change Request Tool — msapp Build & Production Validation Design

**Date:** 13 April 2026  
**Author:** Claude (AI Developer)  
**Status:** Design Review  
**Scope:** Approach 2 — Pre-Build Validation + Build + Live Test

---

## 1. Overview

Build a production-ready `CRTool.msapp` from the current source files (`CRTool/Src/`) using PackTool, incorporating all screen fixes and BA brand styling. Validate structurally, package, and test end-to-end workflows against live SharePoint lists.

**Success Criteria (Level C):**
- ✅ msapp builds without errors and is structurally valid
- ✅ App runs in Power Apps player without formula errors
- ✅ All core workflows execute end-to-end against live SharePoint
- ✅ Data persists correctly after each action

**Live SharePoint Environment:**
- CRRequests: https://baplc.sharepoint.com/sites/Engprog/Lists/CRRequests/AllItems.aspx
- CRUserAdmin: https://baplc.sharepoint.com/sites/Engprog/Lists/CRUserAdmin/AllItems.aspx
- CRStakeholderReviews: https://baplc.sharepoint.com/sites/Engprog/Lists/CRStakeholderReviews/AllItems.aspx
- AIPSGMeetings: https://baplc.sharepoint.com/sites/Engprog/Lists/AIPSGMeetings/AllItems.aspx

---

## 2. Scope

### In Scope
1. Pre-build validation of CRTool source structure and data sources
2. Build msapp using PackTool (tools/PackTool/Program.cs)
3. Live test all 10 screens against production SharePoint lists
4. **Dashboard Screen UI Fix**: Resolve hidden text in metric tiles (Z-order issue)
5. **PMO Consolidation Screen**: Verify guard logic, overdue alert, two-panel layout
6. Core workflow validation (CR submit, view, detail, status transitions)

### Out of Scope
- SharePoint list/column creation (already complete)
- Power Automate flow creation
- User acceptance testing beyond core workflows

---

## 3. Architecture & Components

### Source Structure
```
CRTool/
├── Src/                         # YAML screen definitions
│   ├── App.fx.yaml             # App config, OnStart, global variables
│   ├── Home Screen.fx.yaml     # Navigation hub
│   ├── Dashboard Screen.fx.yaml # KPI tiles (UI fix needed)
│   ├── View CRs Screen.fx.yaml
│   ├── Submit CR Screen.fx.yaml
│   ├── Submit CR B Screen.fx.yaml
│   ├── CR Detail Screen.fx.yaml
│   ├── PMO Consolidation Screen.fx.yaml (guard logic, two-panel)
│   ├── Programme Meeting Screen.fx.yaml
│   ├── Stakeholder Assessment Screen.fx.yaml
│   └── User Admin Screen.fx.yaml
├── DataSources/                # SharePoint config
│   ├── CRRequests.json
│   ├── CRUserAdmin.json
│   ├── CRStakeholderReviews.json
│   └── AIPSGMeetings.json
├── CanvasManifest.json         # App metadata
├── Themes.json                 # BA brand colors
├── ControlTemplates.json       # Control definitions
└── Entropy/Entropy.json        # Control state

PackTool/
├── Program.cs                  # Pack logic: reads Src/, assembles msapp
├── PackTool.csproj            # .NET project (net8.0 + net10.0 targets)
└── bin/Release/               # Compiled tool
```

### Build Tool: PackTool
- **Language:** C# (.NET 8.0 / 10.0)
- **Input:** CRTool/Src/ directory
- **Output:** CRTool.msapp (ZIP archive with manifest, screens, data sources)
- **Status:** Pre-built binaries available in `tools/PackTool/bin/Release/`

### Data Flow
```
SharePoint Lists (baplc.sharepoint.com/sites/Engprog)
        ↓
CRTool/DataSources/*.json (connection config)
        ↓
CRTool.msapp (packaged by PackTool)
        ↓
Power Apps Studio / Player (user opens app)
        ↓
Live CRUD operations on SharePoint
```

---

## 4. Phase 1: Pre-Build Validation (20–25 min)

### 4.1 Data Source Audit

**Check each file in `CRTool/DataSources/`:**

| File | List | Site | Key Columns |
|------|------|------|------------|
| CRRequests.json | CRRequests | baplc.sharepoint.com/sites/Engprog | ID, Title, CRStatus, SubmittedBy, SubmissionDeadline, ProgrammeName |
| CRUserAdmin.json | CRUserAdmin | baplc.sharepoint.com/sites/Engprog | ID, Email, Role (PMO, Stakeholder, User) |
| CRStakeholderReviews.json | CRStakeholderReviews | baplc.sharepoint.com/sites/Engprog | ID, CR_ID (lookup), StakeholderEmail, RAGRating |
| AIPSGMeetings.json | AIPSGMeetings | baplc.sharepoint.com/sites/Engprog | ID, MeetingDate |

**Validation Tasks:**
- Confirm each datasource JSON points to correct SharePoint site URL
- Verify all column names in JSON match actual SharePoint columns
- Check that lookup fields (e.g., CR_ID in CRStakeholderReviews) are correctly configured
- Ensure no column mismatches between source and live lists

**Output:** Go/No-Go on data source config.

---

### 4.2 Formula Scan

**For each screen YAML in `CRTool/Src/`, check:**

1. **Enum Qualifications**
   - All enums must be fully qualified: `SortOrder.Ascending` (not `Ascending`)
   - `TimeUnit.Days`, `Align.Center`, `ImagePosition.Fit`, etc.

2. **Scope & Aliases**
   - Filter gallery items: verify scope aliases don't conflict with global vars
   - Gallery iteration: `ThisItem` for string arrays, `ThisItem.Value` for record lookups

3. **Control References**
   - No cross-screen references to Gallery.Selected or control properties
   - Data passed via context records/maps only

4. **Collection Usage**
   - `colProgrammeStats` (Dashboard): verify populated in OnVisible
   - `colCRList` (View CRs): populated correctly with filter logic

**Screens to Audit:**
- Home Screen: Navigation logic, global vars set
- Dashboard Screen: **Tile formulas, text visibility fix**
- View CRs Screen: Gallery filter, sort, search
- Submit CR / Submit CR B: Form OnSuccess formulas
- CR Detail Screen: Workflow button formulas
- PMO Consolidation: **Guard logic, overdue alert**
- User Admin, Stakeholder Assessment: Role checks, data binding

**Output:** List of any red-dot formula errors found. If none, proceed.

---

### 4.3 Dashboard Screen UI Fix

**Issue:** Text labels in metric tiles (All CRs, Open, In Assessment, SG Ready, Approved, Rejected) are hidden behind rectangle backgrounds.

**Root Cause:** Z-order/layering — rectangles declared before labels, so they render on top.

**Fix Strategy:**
- Ensure each tile's label elements are declared *after* the background rectangle in YAML
- OR restructure tiles into containers where labels are properly nested above backgrounds
- Verify no explicit `Z` property conflicts

**Affected Controls:**
- `recTileAllDS` + `lblTileAllLblDS` + `lblTileAllCountDS`
- `recTileOpenDS` + `lblTileOpenLblDS` + `lblTileOpenCountDS`
- And 4 more tiles for In Assessment, SG Ready, Approved, Rejected

**Test After Fix:** All 6 tile labels render with text visible (not obscured).

---

### 4.4 PMO Consolidation Screen Verification

**Guard Logic:**
```
If(Not(gblIsPMO), Navigate('Home Screen', ScreenTransition.None))
```
- Verify `gblIsPMO` is set in App.OnStart or Home Screen based on CRUserAdmin lookup
- Test: Non-PMO user accessing screen should redirect immediately

**Overdue Alert:**
```
Visible: =CountRows(Filter(CRRequests, SubmissionDeadline < Today(), Not(IsDraft), CRStatus.Value = "Submitted")) > 0
```
- Verify `SubmissionDeadline` column exists in CRRequests list
- Verify `IsDraft` boolean column exists
- Banner text displays count of overdue CRs

**Two-Panel Layout:**
- Left panel: CR action list with filter/sort
- Right panel: Selected CR detail + RAG assessment section
- Verify both panels load without errors and don't overlap

**Output:** Go/No-Go on screen logic and layout.

---

### 4.5 Navigation Wiring

**Verify Home Screen navigates to all 10 screens:**
- Dashboard (tile/menu)
- View CRs (tile/menu)
- Submit CR (tile/menu)
- PMO Consolidation (PMO role only)
- Programme Meeting, Stakeholder Assessment, User Admin (role-based visibility)

**Check:** No broken navigation routes.

---

## 5. Phase 2: Build msapp (5–10 min)

### 5.1 Execute PackTool

```bash
dotnet /path/to/tools/PackTool/bin/Release/net10.0/PackTool.dll \
  /path/to/CRTool/Src \
  /path/to/output/CRTool.msapp
```

Or if using net8.0:
```bash
dotnet /path/to/tools/PackTool/bin/Release/net8.0/PackTool.dll \
  /path/to/CRTool/Src \
  /path/to/output/CRTool.msapp
```

### 5.2 Verify Output

- ✅ Build completes without errors
- ✅ Output file `CRTool.msapp` exists
- ✅ File size > 50 KB (structural integrity check; typical is 100–500 KB)
- ✅ No warnings in PackTool logs about missing data sources or screens

### 5.3 Inspect Logs

Review PackTool console output for:
- Missing files (DataSources, screens, manifest)
- Theme/control template errors
- Data source URL warnings

**If build fails:** Note error message, return to Phase 1 (fix source), rebuild.

---

## 6. Phase 3: Live Test (35–50 min)

### 6.1 Upload & Publish

1. Open Power Apps Studio → Create app from solution or upload msapp
2. Studio auto-detects SharePoint data sources and establishes connections
3. Publish to your tenant

### 6.2 Test Scenarios

| Screen | Flow | Steps | Success Criteria |
|--------|------|-------|------------------|
| **Home Screen** | Navigation hub | 1. App loads | All 6 nav tiles visible (or role-based menu items) |
| **Dashboard** | KPI overview | 1. Click Dashboard tile 2. Observe metric tiles | All 6 tiles render text visible; counts match CRRequests list |
| **View CRs** | CR browsing | 1. Click View CRs 2. Filter by Status 3. Select a CR | Gallery loads live data; selection opens detail |
| **Submit CR (Part A)** | CR creation start | 1. Click Submit CR 2. Fill: Title, Description, Programme 3. Click Next | Proceeds to Part B without errors |
| **Submit CR (Part B)** | CR creation finish | 1. Fill: Cost, Risk, Impact fields 2. Click Submit | New entry appears in CRRequests list with Status="New" |
| **CR Detail** | CR review | 1. Open a CR from View CRs gallery 2. Verify fields load 3. Try "Send to PMO" button | Detail loads live CR data; button updates Status in SharePoint |
| **PMO Consolidation** | PMO workflow | 1. As PMO user: open screen 2. Left panel shows CR list 3. Right panel shows detail + RAG | Two panels load; PMO can assign RAG ratings; saves to CRStakeholderReviews |
| **PMO Access Guard** | Role-based access | 1. As non-PMO user: try to navigate to PMO Consolidation | Redirected to Home immediately (guard logic works) |
| **Overdue Alert** | PMO alert | 1. If CRs exist with SubmissionDeadline < Today and Status="Submitted" | Red banner appears in PMO Consolidation with correct count |
| **User Admin** | User mgmt | 1. Click User Admin 2. View user list | CRUserAdmin list loads; current user role displays |
| **Stakeholder Assessment** | RAG ratings | 1. Select a CR 2. Go to Assessment section 3. Assign RAG 4. Save | Saves to CRStakeholderReviews list; visible in PMO Consolidation |

### 6.3 Error Handling

**If a test fails:**
1. Note error message (red dot, #Error, blank field, etc.)
2. If formula error: return to Phase 1, fix source YAML, rebuild, re-test
3. If data missing: verify SharePoint list has correct columns and data
4. If navigation broken: check Home Screen routes and screen names

---

## 7. Phase 4: Validation & Sign-Off

### 7.1 Production Readiness Checklist

- [ ] Phase 1 validation complete (data sources, formulas, screens audited)
- [ ] Dashboard Screen UI fix applied (text visible on tiles)
- [ ] PMO Consolidation guard logic & layout verified
- [ ] msapp built successfully by PackTool
- [ ] All Phase 3 test scenarios pass
- [ ] No formula errors in Power Apps player
- [ ] SharePoint data persists correctly after each CRUD operation
- [ ] Navigation between all 10 screens works
- [ ] Role-based access (PMO guard, user visibility) enforced

### 7.2 Deliverables

- **CRTool.msapp**: Final production-ready package
- **Test Report**: Documentation of all Phase 3 test results (pass/fail + screenshots if needed)
- **Known Limitations** (if any): Any features deferred or partially working

---

## 8. Rollback Plan

If live testing reveals critical issues (data not persisting, major workflow broken):

1. **Do Not Republish** — keep old version active if available
2. **Investigate Root Cause**: Formula error? Data source misconfiguration? SharePoint column mismatch?
3. **Fix Source**: Update CRTool/Src YAML
4. **Rebuild**: Run PackTool again
5. **Re-test**: Verify fix before re-publishing

---

## 9. Assumptions

- All 4 SharePoint lists exist with correct columns (verified as of 13 Apr 2026)
- PackTool binaries in `tools/PackTool/bin/Release/` are up-to-date and working
- User has Power Apps Studio access and can upload msapp
- CRTool source files in `CRTool/Src/` are the current, validated version
- BA brand colors (RGBA values) are correctly applied and desired

---

## 10. Notes

- **Dashboard Screen Fix**: This is the primary UI issue to resolve in Phase 1. Expected fix: reorder YAML declarations so labels render above rectangles, or restructure into containers.
- **PMO Consolidation**: Verify `gblIsPMO` initialization before Phase 3 testing.
- **Iterative Testing**: If Phase 3 finds issues, fix source and rebuild — expected 1–2 iteration cycles.

---

**Next Step:** User review. Please confirm this spec is complete and ready for implementation planning.
