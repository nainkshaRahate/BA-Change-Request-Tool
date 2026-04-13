# BA Change Request Tool — msapp Build & Production Validation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a production-ready `CRTool.msapp` from source, fix Dashboard UI rendering issue, and validate all workflows execute end-to-end against live SharePoint.

**Architecture:** Three-phase approach: (1) validate source structure and formulas, fix Dashboard text visibility; (2) build msapp using PackTool; (3) test all 10 screens against production SharePoint lists (CRRequests, CRUserAdmin, CRStakeholderReviews, AIPSGMeetings).

**Tech Stack:** C# PackTool (.NET 8.0/10.0), Power Apps Canvas App, SharePoint REST API, YAML source format

---

## Phase 1: Pre-Build Validation

### Task 1: Audit Data Source Configuration

**Files:**
- Inspect: `CRTool/DataSources/CRRequests.json`
- Inspect: `CRTool/DataSources/CRUserAdmin.json`
- Inspect: `CRTool/DataSources/CRStakeholderReviews.json`
- Inspect: `CRTool/DataSources/AIPSGMeetings.json`

- [ ] **Step 1: Read CRRequests.json and verify SharePoint site URL**

File: `CRTool/DataSources/CRRequests.json`

Check that the `dataSources` array contains an entry with:
- `name`: "CRRequests"
- `settings.url` or `entity.sourceUrl`: Contains `https://baplc.sharepoint.com/sites/Engprog`
- Schema includes columns: `ID`, `Title`, `CRStatus`, `SubmittedBy`, `SubmissionDeadline`, `ProgrammeName`

Expected output: JSON object with valid SharePoint URL pointing to correct site.

If URL is missing or incorrect, **flag as BLOCKER** and note it for fixes before build.

- [ ] **Step 2: Verify CRUserAdmin.json data source configuration**

File: `CRTool/DataSources/CRUserAdmin.json`

Check:
- `dataSources[0].name` = "CRUserAdmin"
- URL points to `https://baplc.sharepoint.com/sites/Engprog`
- Schema includes: `ID`, `Email`, `Role` (must support values: "PMO", "Stakeholder", "User")

Expected: Properly configured data source matching CRUserAdmin list.

- [ ] **Step 3: Verify CRStakeholderReviews.json lookup field configuration**

File: `CRTool/DataSources/CRStakeholderReviews.json`

Check:
- URL points to correct site
- Schema includes: `ID`, `CR_ID` (lookup to CRRequests), `StakeholderEmail`, `RAGRating`
- `CR_ID` is marked as a lookup field

Expected: Lookup field properly configured to CRRequests.

- [ ] **Step 4: Verify AIPSGMeetings.json configuration**

File: `CRTool/DataSources/AIPSGMeetings.json`

Check:
- URL points to correct site
- Schema includes: `ID`, `MeetingDate`

Expected: Simple data source without lookups.

- [ ] **Step 5: Document findings**

Create a text summary (in your notes or comment) stating:
- ✅ All 4 data sources point to correct SharePoint site
- ✅ All required columns present in each data source
- OR: List any mismatches found

**Outcome:** Go/No-Go on data source config. If blockers, note them for Phase 1, Task 2 (fixes).

---

### Task 2: Scan All Screen YAML for Formula Errors

**Files:**
- Inspect: `CRTool/Src/App.fx.yaml`
- Inspect: `CRTool/Src/Home Screen.fx.yaml`
- Inspect: `CRTool/Src/Dashboard Screen.fx.yaml`
- Inspect: `CRTool/Src/View CRs Screen.fx.yaml`
- Inspect: `CRTool/Src/Submit CR Screen.fx.yaml`
- Inspect: `CRTool/Src/Submit CR B Screen.fx.yaml`
- Inspect: `CRTool/Src/CR Detail Screen.fx.yaml`
- Inspect: `CRTool/Src/PMO Consolidation Screen.fx.yaml`
- Inspect: `CRTool/Src/Programme Meeting Screen.fx.yaml`
- Inspect: `CRTool/Src/Stakeholder Assessment Screen.fx.yaml`
- Inspect: `CRTool/Src/User Admin Screen.fx.yaml`

- [ ] **Step 1: Check App.fx.yaml for global variable initialization**

File: `CRTool/Src/App.fx.yaml`

Look for `OnStart` formula. Verify:
- `gblIsPMO` is initialized (Set or Patch to a boolean based on CRUserAdmin lookup)
- `gblUserEmail` or similar is set to current user
- Any collection initialization (e.g., `ClearCollect(colProgrammeStats, ...)`)

Expected: All global variables properly initialized with formulas.

- [ ] **Step 2: Scan Dashboard Screen for formula issues**

File: `CRTool/Src/Dashboard Screen.fx.yaml`

Search for these patterns and verify they are **correct**:
- `SortOrder.Ascending` (not bare `Ascending`)
- `CountRows()` function with valid Filter() arguments
- Collection `colProgrammeStats` referenced in OnVisible
- **All labels (lblTileAllLblDS, lblTileAllCountDS, etc.) are properly declared**

Expected: No unqualified enums, no missing collection references.

Red flags to note:
- Bare enum values: `Ascending`, `Days`, `Left`, `Center` (should be qualified)
- Forward references to undefined controls or collections
- Incorrect ThisItem usage

- [ ] **Step 3: Verify View CRs Screen gallery formula**

File: `CRTool/Src/View CRs Screen.fx.yaml`

Find the gallery control's `Items` property. Verify:
- Uses `Filter()` or `Sort()` on `CRRequests` data source
- No cross-screen references to other Gallery.Selected
- Data passed via context record only

Expected: Gallery formula is scoped correctly.

- [ ] **Step 4: Check Submit CR and Submit CR B OnSuccess formulas**

Files: `CRTool/Src/Submit CR Screen.fx.yaml`, `CRTool/Src/Submit CR B Screen.fx.yaml`

Look for form button OnSuccess formulas. Verify:
- `SubmitForm()` or `Patch()` call is valid
- No forward references to non-existent fields
- Error handling checks `IsEmpty(Errors(...))`

Expected: Forms submit without reference errors.

- [ ] **Step 5: Verify CR Detail Screen workflow button formulas**

File: `CRTool/Src/CR Detail Screen.fx.yaml`

Find buttons like "Send to PMO", "Approve", "Reject". Verify:
- Each button's `OnSelect` formula patches `CRRequests` with new status
- Status values match SharePoint list choices (e.g., "Submitted", "In Assessment", "Approved", "Rejected", "Closed")
- No typos in field names

Expected: Buttons reference correct fields and values.

- [ ] **Step 6: Check PMO Consolidation guard logic**

File: `CRTool/Src/PMO Consolidation Screen.fx.yaml`

Find `OnVisible` formula. Verify:
- Guard logic: `If(Not(gblIsPMO), Navigate('Home Screen', ScreenTransition.None))`
- Redirect happens immediately if not PMO
- No errors in Navigate() call

Expected: Guard logic is syntactically correct.

- [ ] **Step 7: Verify PMO Consolidation overdue alert formula**

File: `CRTool/Src/PMO Consolidation Screen.fx.yaml`

Find `recOverdueBannerPCS` rectangle and `lblOverdueBannerPCS` label. Verify:
- `Visible` property: `CountRows(Filter(CRRequests, SubmissionDeadline < Today(), Not(IsDraft), CRStatus.Value = "Submitted")) > 0`
- `CRStatus.Value` correctly references the lookup field
- `IsDraft` field is referenced correctly

Expected: Overdue alert formula is syntactically correct and references valid fields.

- [ ] **Step 8: Check User Admin and Stakeholder Assessment screens**

Files: `CRTool/Src/User Admin Screen.fx.yaml`, `CRTool/Src/Stakeholder Assessment Screen.fx.yaml`

Verify:
- User Admin loads `CRUserAdmin` data source correctly
- Stakeholder Assessment can read/write to `CRStakeholderReviews`
- Any role checks reference valid Role values

Expected: Both screens reference correct data sources and fields.

- [ ] **Step 9: Document formula scan results**

Create a summary:
- ✅ All enums are fully qualified (SortOrder.Ascending, TimeUnit.Days, etc.)
- ✅ No red-dot formula errors detected
- OR: List specific errors found (with file:line if possible)

**Outcome:** Go/No-Go on formulas. If errors found, flag for fixing in Task 3 (Dashboard fix).

---

### Task 3: Fix Dashboard Screen Text Visibility (Z-Order Issue)

**Files:**
- Modify: `CRTool/Src/Dashboard Screen.fx.yaml` (lines ~89–200, all 6 tiles)

**Issue:** Labels for metric tiles are hidden behind rectangle backgrounds. Root cause: Z-order — rectangles declared before labels in YAML, so they render on top.

**Fix Strategy:** Reorder YAML so labels are declared *after* rectangles. In YAML, later declarations have higher Z-index.

- [ ] **Step 1: Understand current tile structure**

File: `CRTool/Src/Dashboard Screen.fx.yaml` (around line 89+)

Current structure for "All CRs" tile:
```yaml
recTileAllDS As rectangle:
    Fill: =RGBA(60, 90, 130, 1)
    Height: =70
    ... (rectangle properties)

lblTileAllLblDS As label:
    Color: =RGBA(255, 255, 255, 1)
    Text: ="All CRs"
    ... (label properties)

lblTileAllCountDS As label:
    Color: =RGBA(255, 255, 255, 1)
    Text: =Text(CountRows(CRRequests))
    ... (label properties)
```

The problem: `recTileAllDS` is declared first, so it renders on top of the labels.

**Expected understanding:** YAML declaration order = Z-index (later = higher Z, on top).

- [ ] **Step 2: Restructure first tile (All CRs) to move labels after rectangle**

File: `CRTool/Src/Dashboard Screen.fx.yaml`

Find the section with `recTileAllDS`, `lblTileAllLblDS`, `lblTileAllCountDS`.

Reorder so rectangle is declared first, then labels:

```yaml
recTileAllDS As rectangle:
    Fill: =RGBA(60, 90, 130, 1)
    Height: =70
    RadiusBottomLeft: =6
    RadiusBottomRight: =6
    RadiusTopLeft: =6
    RadiusTopRight: =6
    Width: =418
    X: =16
    Y: =conSubNavDS.Y + conSubNavDS.Height + 13

lblTileAllLblDS As label:
    Color: =RGBA(255, 255, 255, 1)
    Font: =Font.'Segoe UI'
    FontWeight: =FontWeight.Semibold
    Height: =24
    Text: ="All CRs"
    Width: =300
    X: =28
    Y: =recTileAllDS.Y + 8

lblTileAllCountDS As label:
    Color: =RGBA(255, 255, 255, 1)
    Font: =Font.'Segoe UI'
    FontWeight: =FontWeight.Bold
    Height: =32
    Size: =28
    Text: =Text(CountRows(CRRequests))
    Width: =400
    X: =28
    Y: =lblTileAllLblDS.Y + lblTileAllLblDS.Height
```

**Expected result:** Labels moved after rectangle declaration.

- [ ] **Step 3: Apply same reordering to "Open CRs" tile**

File: `CRTool/Src/Dashboard Screen.fx.yaml`

Find `recTileOpenDS`, `lblTileOpenLblDS`, `lblTileOpenCountDS`.

Reorder: rectangle → label title → label count.

```yaml
recTileOpenDS As rectangle:
    Fill: =RGBA(0, 75, 135, 1)
    Height: =70
    RadiusBottomLeft: =6
    RadiusBottomRight: =6
    RadiusTopLeft: =6
    RadiusTopRight: =6
    Width: =418
    X: =474
    Y: =108

lblTileOpenLblDS As label:
    Color: =RGBA(255, 255, 255, 1)
    Font: =Font.'Segoe UI'
    FontWeight: =FontWeight.Semibold
    Height: =24
    Text: ="Open CRs"
    Width: =300
    X: =486
    Y: =116

lblTileOpenCountDS As label:
    Color: =RGBA(255, 255, 255, 1)
    Font: =Font.'Segoe UI'
    FontWeight: =FontWeight.Bold
    Height: =32
    Size: =28
    Text: =Text(CountRows(Filter(CRRequests, Not(CRStatus.Value In ["Closed","Rejected","Approved"]))))
    Width: =400
    X: =486
    Y: =lblTileOpenLblDS.Y + lblTileOpenLblDS.Height
```

- [ ] **Step 4: Repeat reordering for remaining 4 tiles**

File: `CRTool/Src/Dashboard Screen.fx.yaml`

Find and reorder these tile pairs:
1. `recTileInAssessmentDS` + labels
2. `recTileSGReadyDS` + labels
3. `recTileApprovedDS` + labels
4. `recTileRejectedDS` + labels

For each, apply same pattern: rectangle first, then label title, then label count.

**Note:** Copy the exact rectangle and label code from the file; only change declaration order, not properties.

- [ ] **Step 5: Verify all 6 tiles follow correct order**

File: `CRTool/Src/Dashboard Screen.fx.yaml`

Quick scan:
- All CRs: recTile → lblLabel → lblCount ✓
- Open CRs: recTile → lblLabel → lblCount ✓
- In Assessment: recTile → lblLabel → lblCount ✓
- SG Ready: recTile → lblLabel → lblCount ✓
- Approved: recTile → lblLabel → lblCount ✓
- Rejected: recTile → lblLabel → lblCount ✓

**Expected:** All 6 tiles now have correct Z-order (labels on top).

- [ ] **Step 6: Commit Dashboard UI fix**

```bash
git add CRTool/Src/Dashboard\ Screen.fx.yaml
git commit -m "fix: resolve Dashboard Screen text visibility by reordering tile labels above rectangles"
```

**Outcome:** Dashboard Screen text is now visible. Ready for build.

---

### Task 4: Verify Navigation Wiring

**Files:**
- Inspect: `CRTool/Src/Home Screen.fx.yaml`
- Inspect: `CRTool/Src/App.fx.yaml` (for screen list)

- [ ] **Step 1: Check Home Screen navigation tiles**

File: `CRTool/Src/Home Screen.fx.yaml`

Verify Home Screen has buttons/tiles that navigate to:
1. Dashboard Screen
2. View CRs Screen
3. Submit CR Screen
4. User Admin Screen (or role-based visibility)
5. Stakeholder Assessment Screen
6. PMO Consolidation Screen (PMO role only)

Look for `OnSelect: =Navigate('Screen Name', ScreenTransition.None)` formulas.

Expected: All 6 nav targets exist.

- [ ] **Step 2: Verify screen names match app manifest**

File: `CRTool/Src/App.fx.yaml` (or CanvasManifest.json)

Check that all screen names referenced in Home Screen navigation match actual screen YAML filenames:
- 'Home Screen' ✓
- 'Dashboard Screen' ✓
- 'View CRs Screen' ✓
- 'Submit CR Screen' ✓
- 'Submit CR B Screen' ✓
- 'CR Detail Screen' ✓
- 'PMO Consolidation Screen' ✓
- 'Programme Meeting Screen' ✓
- 'Stakeholder Assessment Screen' ✓
- 'User Admin Screen' ✓

Expected: All names match YAML filenames.

- [ ] **Step 3: Document navigation check**

Summary:
- ✅ All 10 screens referenced in Home navigation
- ✅ Screen names match YAML filenames
- OR: List any broken navigation routes

**Outcome:** Navigation is wired correctly.

---

## Phase 2: Build msapp

### Task 5: Execute PackTool Build

**Files:**
- Input: `CRTool/Src/` (all YAML screens)
- Input: `CRTool/DataSources/` (all JSON data sources)
- Input: `CRTool/CanvasManifest.json`
- Input: `CRTool/Themes.json`
- Input: `CRTool/ControlTemplates.json`
- Output: `CRTool.msapp` (in project root or specified directory)

- [ ] **Step 1: Verify PackTool binary exists**

File: `tools/PackTool/bin/Release/net10.0/PackTool.dll` (or net8.0 variant)

Run:
```bash
ls -lh tools/PackTool/bin/Release/net10.0/PackTool.dll
```

Expected output:
```
-rw-r--r--  ... PackTool.dll (size > 100 KB)
```

If file not found, use net8.0 path instead:
```bash
ls -lh tools/PackTool/bin/Release/net8.0/PackTool.dll
```

- [ ] **Step 2: Run PackTool to build msapp**

From project root directory:

```bash
cd /Users/dhammadeepborkar/Library/CloudStorage/OneDrive-ABSOLUTELABS/Dhamma/Office/Projects/BA/BA\ Change\ Request\ Tool/Repositories/BA-Change-Request-Tool

dotnet tools/PackTool/bin/Release/net10.0/PackTool.dll CRTool/Src CRTool.msapp
```

If net10.0 not available, try net8.0:
```bash
dotnet tools/PackTool/bin/Release/net8.0/PackTool.dll CRTool/Src CRTool.msapp
```

Expected output:
```
Packing CRTool/Src into CRTool.msapp...
✓ Manifest loaded
✓ Screens packed
✓ Data sources packed
✓ Build complete: CRTool.msapp (XXX bytes)
```

If errors occur, note the error message and proceed to Step 4 (troubleshooting).

- [ ] **Step 3: Verify output file**

Run:
```bash
ls -lh CRTool.msapp
```

Expected output:
```
-rw-r--r--  ... CRTool.msapp (size > 50 KB, typically 100–500 KB)
```

If file is < 50 KB or doesn't exist, flag as build failure.

- [ ] **Step 4: Verify PackTool logs for warnings**

From previous step output, look for:
- Missing files (DataSources, screens, manifest)
- Theme/control template errors
- Data source URL warnings

Expected: No errors, only info-level messages.

If errors present:
1. Note the specific error
2. Go back to Phase 1 (data source or formula issue)
3. Fix source
4. Rebuild

- [ ] **Step 5: Commit build output**

```bash
git add CRTool.msapp
git commit -m "build: pack CRTool.msapp from source with Dashboard UI fix"
```

**Outcome:** CRTool.msapp is built and ready for testing.

---

## Phase 3: Live Test

### Task 6: Upload & Publish msapp to Power Apps

**Files:**
- Upload: `CRTool.msapp`

- [ ] **Step 1: Open Power Apps Studio**

Navigate to: https://make.powerapps.com

Sign in with your BA email (same tenant as SharePoint).

- [ ] **Step 2: Create new app from msapp**

In Power Apps Studio:
- Select "Open an app" or "Upload"
- Choose `CRTool.msapp` from this repository

OR:

- "New app" → "Canvas" → "Import" → Select `CRTool.msapp`

Expected: App loads in Studio without errors. Studio recognizes SharePoint data sources automatically.

- [ ] **Step 3: Verify data source connections**

In Power Apps Studio, check Data tab:
- CRRequests: Connected to `https://baplc.sharepoint.com/sites/Engprog` ✓
- CRUserAdmin: Connected ✓
- CRStakeholderReviews: Connected ✓
- AIPSGMeetings: Connected ✓

If any data source shows "Not connected" or error, re-connect in Studio:
- Data → Select data source → Refresh or re-authenticate

Expected: All 4 data sources connected.

- [ ] **Step 4: Publish to tenant**

In Studio, click "Publish" (top right).

Expected: App published successfully. You get a confirmation message and a shareable link.

- [ ] **Step 5: Note the published app URL**

After publish, note the app URL:
```
https://make.powerapps.com/apps/play/e/<APP_ID>
```

This is the URL for testing.

**Outcome:** App is published and accessible in Power Apps player.

---

### Task 7: Test Home Screen Navigation

**Prerequisite:** App published (Task 6 complete).

- [ ] **Step 1: Open app in Power Apps player**

Navigate to the published app URL (from Task 6, Step 5).

Expected: Home Screen loads. You see navigation tiles or menu.

- [ ] **Step 2: Verify all nav tiles are visible**

On Home Screen, check for these tiles/buttons:
1. Dashboard ✓
2. View CRs ✓
3. Submit CR ✓
4. User Admin ✓
5. Stakeholder Assessment ✓
6. PMO Consolidation (if user is PMO role) ✓

Expected: All tiles visible (role-based visibility for PMO Consolidation).

- [ ] **Step 3: Test clicking Dashboard tile**

Click "Dashboard" tile.

Expected:
- Page navigates to Dashboard Screen
- No formula errors or #Error displays
- Dashboard loads in < 3 seconds

If error: Note the error message. This may require returning to Phase 1.

- [ ] **Step 4: Navigate back to Home**

Click home button (typically 🏠 icon).

Expected: Returns to Home Screen without error.

- [ ] **Step 5: Test clicking View CRs tile**

Click "View CRs" tile.

Expected:
- Page navigates to View CRs Screen
- No errors
- Gallery or list control is visible

- [ ] **Step 6: Navigate back to Home**

Click home button.

Expected: Returns to Home Screen.

- [ ] **Step 7: Note navigation result**

Summary:
- ✅ All nav tiles present
- ✅ Navigation between Home and Dashboard works
- ✅ Navigation between Home and View CRs works
- OR: List any navigation errors

**Outcome:** Navigation is functional. Proceed to detailed screen tests.

---

### Task 8: Test Dashboard Screen

**Prerequisite:** Home Screen nav test passed (Task 7 complete).

- [ ] **Step 1: Navigate to Dashboard Screen**

From Home Screen, click "Dashboard" tile.

Expected: Dashboard loads.

- [ ] **Step 2: Verify all 6 metric tiles are visible**

Check for these tiles with **visible text labels**:
1. "All CRs" with count number ✓
2. "Open CRs" with count number ✓
3. "In Assessment" with count number ✓
4. "SG Ready" with count number ✓
5. "Approved" with count number ✓
6. "Rejected" with count number ✓

Expected: **All 6 tiles have visible text labels** (the Z-order fix should ensure this).

If text is still hidden: Go back to Phase 1, Task 3. Check that all labels are declared *after* rectangles in YAML. Rebuild and re-test.

- [ ] **Step 3: Verify tile counts are correct**

For each tile, visually compare the displayed count to actual CRRequests list:
- All CRs: Should equal total rows in CRRequests list
- Open CRs: Should count CRs NOT in ["Closed","Rejected","Approved"]
- In Assessment: Should count CRs with Status = "In Assessment"
- SG Ready: Should count CRs with Status in ["Pre-SG Distribution","SG Review"]
- Approved: Should count CRs with Status = "Approved"
- Rejected: Should count CRs with Status = "Rejected"

Expected: Counts match SharePoint list data.

If counts are wrong or 0: Verify data in SharePoint lists. Ensure at least one CR record exists for testing.

- [ ] **Step 4: Verify no formula errors**

Check top of screen or error panel for:
- Red dots (red error indicator)
- #Error messages
- Blank/missing fields

Expected: No errors visible.

- [ ] **Step 5: Test Dashboard formula recalculation**

If you have access to live SharePoint:
1. Open CRRequests list in another tab
2. Create a new CR record (Status = "New")
3. Return to Dashboard Screen
4. Click refresh or wait a few seconds
5. Check if "All CRs" count increased

Expected: Count updates to reflect new CR.

(If you don't have SharePoint access during testing, skip this step.)

- [ ] **Step 6: Note Dashboard test result**

Summary:
- ✅ All 6 tiles visible with text labels
- ✅ Counts display correctly
- ✅ No formula errors
- OR: List any issues found

**Outcome:** Dashboard Screen passes Level C validation (renders correctly, data shows).

---

### Task 9: Test View CRs Screen

**Prerequisite:** Home & Dashboard tests passed.

- [ ] **Step 1: Navigate to View CRs Screen**

From Home, click "View CRs" tile.

Expected: View CRs Screen loads.

- [ ] **Step 2: Verify gallery loads live CR data**

Check that a gallery or list displays CR records from CRRequests list:
- Column 1: CR Title or ID ✓
- Column 2: Status ✓
- Column 3: Submitted By or Date ✓

Expected: Gallery shows at least 1 CR record (or is empty if no CRs exist in SharePoint).

If gallery is blank and CRRequests list has data: Check the filter/data formula. May require Phase 1 fix.

- [ ] **Step 3: Test filter functionality**

If a filter control exists (dropdown or search):
1. Filter by Status = "New" or another value
2. Gallery updates to show only matching CRs

Expected: Filter works and gallery updates.

If no filter control, skip this step.

- [ ] **Step 4: Test selecting a CR**

Click on a CR record in gallery.

Expected:
- CR is highlighted/selected
- Detail view opens (either on same screen or navigates to CR Detail Screen)
- CR data loads without errors

- [ ] **Step 5: Verify CR detail data**

If detail view opened, check that these fields are populated:
- Title ✓
- Status ✓
- Submitted By ✓
- Description ✓

Expected: All fields show live data from SharePoint.

- [ ] **Step 6: Note View CRs test result**

Summary:
- ✅ Gallery loads live CR data
- ✅ Filter works (if present)
- ✅ Selection and detail view work
- OR: List any issues

**Outcome:** View CRs Screen passes Level C validation.

---

### Task 10: Test Submit CR Workflow (Part A → Part B → Save)

**Prerequisite:** Previous tests passed.

- [ ] **Step 1: Navigate to Submit CR Screen**

From Home, click "Submit CR" tile.

Expected: Submit CR Screen (Part A) loads.

- [ ] **Step 2: Fill Part A form**

Fill in these fields with test data:
- Title: "Test CR - [Your Name]"
- Description: "Test change request for validation"
- Programme: Select an existing programme from dropdown (if available)
- Cost: "High" or similar selection
- Risk: "High"
- Impact: "Medium"

Expected: Form fields accept input without errors.

- [ ] **Step 3: Click Next button**

Click button to proceed to Part B.

Expected:
- No formula errors
- Screen navigates to Submit CR B Screen
- Form data from Part A is retained

- [ ] **Step 4: Fill Part B form**

Fill in remaining fields:
- Additional Cost Detail: "Additional details"
- Impact Area: Select from list
- Any other fields present

Expected: Part B form fields accept input.

- [ ] **Step 5: Click Submit button**

Click "Submit" or "Save" button.

Expected:
- Form submits without errors
- You get confirmation message (e.g., "CR submitted successfully")
- Screen navigates back to Home or View CRs

- [ ] **Step 6: Verify CR saved to SharePoint**

Open CRRequests list in SharePoint (in another tab):
```
https://baplc.sharepoint.com/sites/Engprog/Lists/CRRequests/AllItems.aspx
```

Check for a new row with:
- Title: "Test CR - [Your Name]"
- Status: "New" (or "Submitted" depending on app logic)
- Submitted By: Your name
- Other fields match what you entered

Expected: New CR record visible in SharePoint list.

If new record not visible after 10 seconds, refresh the list page.

- [ ] **Step 7: Note Submit CR test result**

Summary:
- ✅ Part A → Part B navigation works
- ✅ Form submits without errors
- ✅ New CR record created in SharePoint
- OR: List any issues

**Outcome:** Submit CR workflow passes Level C validation (data persists in SharePoint).

---

### Task 11: Test CR Detail Screen & Workflow Buttons

**Prerequisite:** CR record exists (created in Task 10).

- [ ] **Step 1: Navigate to View CRs and select your test CR**

From Home, click "View CRs".

Click on the CR you created in Task 10 ("Test CR - [Your Name]").

Expected: CR Detail Screen opens.

- [ ] **Step 2: Verify CR data loads**

Check that these fields are populated with correct data:
- Title ✓
- Status ✓
- Description ✓
- Cost ✓
- Risk ✓
- Impact ✓

Expected: All fields show data from SharePoint.

- [ ] **Step 3: Find workflow button**

Look for a button like "Send to PMO", "Approve", "Reject", or "Complete".

Expected: At least one workflow button visible.

- [ ] **Step 4: Click workflow button (non-destructive option)**

If a "Send to PMO" button exists, click it.

Expected:
- No formula error
- Button is responsive
- Status may change (depending on app logic)
- Confirmation message may appear

- [ ] **Step 5: Verify status change in SharePoint (if button triggered change)**

Return to CRRequests list in SharePoint. Find your test CR row.

Check if Status field changed (e.g., from "New" to "Submitted" or "In Assessment").

Expected: Status updated in SharePoint if button pressed it.

If Status didn't change, the button may not be wired to actually save. This is a potential issue to flag.

- [ ] **Step 6: Note CR Detail test result**

Summary:
- ✅ CR Detail loads live data correctly
- ✅ Workflow buttons are present and clickable
- ✅ Button actions update Status in SharePoint
- OR: List any issues

**Outcome:** CR Detail Screen passes Level C validation.

---

### Task 12: Test PMO Consolidation Screen & Guard Logic

**Prerequisite:** You have PMO role assigned in CRUserAdmin list OR can test as non-PMO user.

- [ ] **Step 1: Test as non-PMO user (if possible)**

If you have a test user account that's NOT assigned PMO role:
1. Sign out of current session
2. Sign in as non-PMO test user
3. Open the app
4. Try to navigate to PMO Consolidation Screen (e.g., via URL or menu button)

Expected: You are immediately redirected to Home Screen (guard logic works).

If PMO Consolidation Screen opens, the guard logic is broken. Flag this as a blocker.

(If you don't have a non-PMO test account, skip to Step 2.)

- [ ] **Step 2: Test as PMO user**

Sign in as a user with PMO role (or assign yourself PMO role in CRUserAdmin list).

From Home Screen, click "PMO Consolidation" tile or button.

Expected: PMO Consolidation Screen loads.

- [ ] **Step 3: Verify two-panel layout**

Check for:
- **Left panel:** CR action list (gallery or table of CRs needing PMO review)
- **Right panel:** Selected CR detail + RAG assessment section

Expected: Both panels visible side-by-side without overlap.

- [ ] **Step 4: Check overdue alert banner**

Look for a red banner at the top of PMO Consolidation Screen.

If any CRs in CRRequests have:
- SubmissionDeadline < Today()
- IsDraft = false
- CRStatus = "Submitted"

Then the banner should display:
```
"N CR(s) are past their submission deadline and have not been reviewed by PMO."
```

Expected: Banner visible if overdue CRs exist, hidden if none.

If no CRs meet criteria, banner should not appear.

- [ ] **Step 5: Test selecting a CR from left panel**

Click on a CR in the left panel.

Expected:
- CR is highlighted
- Right panel updates to show CR detail + RAG assessment

- [ ] **Step 6: Test assigning RAG rating**

In right panel RAG assessment section:
1. Set RAG to "Red" or "Green" or "Amber" (depending on what's available)
2. Click "Save" or equivalent

Expected:
- No errors
- RAG rating is saved to CRStakeholderReviews list

- [ ] **Step 7: Verify RAG saved to SharePoint**

Open CRStakeholderReviews list in SharePoint:
```
https://baplc.sharepoint.com/sites/Engprog/Lists/CRStakeholderReviews/AllItems.aspx
```

Find the row with your test CR and your email. Check that RAGRating field has the value you set.

Expected: RAG rating persisted to SharePoint.

- [ ] **Step 8: Note PMO Consolidation test result**

Summary:
- ✅ Guard logic redirects non-PMO users
- ✅ Two-panel layout renders correctly
- ✅ Overdue alert appears when appropriate
- ✅ RAG ratings can be assigned and persist
- OR: List any issues

**Outcome:** PMO Consolidation Screen passes Level C validation.

---

### Task 13: Test User Admin & Stakeholder Assessment Screens

**Prerequisite:** App is deployed and accessible.

- [ ] **Step 1: Navigate to User Admin Screen**

From Home, click "User Admin" tile.

Expected: User Admin Screen loads.

- [ ] **Step 2: Verify user list loads**

Check that a gallery or table displays users from CRUserAdmin list:
- Email ✓
- Role ✓
- Other user fields ✓

Expected: At least your own user record visible.

- [ ] **Step 3: Check current user role displays**

Look for a label or field showing "Current User Role: [PMO/Stakeholder/User]".

Expected: Your assigned role displays correctly based on CRUserAdmin.

- [ ] **Step 4: Navigate to Stakeholder Assessment Screen**

From Home, click "Stakeholder Assessment" tile (if available).

Expected: Stakeholder Assessment Screen loads.

- [ ] **Step 5: Test selecting a CR for assessment**

If a CR selection control exists, select a CR.

Expected:
- CR detail loads
- Assessment section shows RAG options (Red, Amber, Green)

- [ ] **Step 6: Test assigning RAG**

Select a RAG option and save.

Expected:
- No errors
- RAG is saved to CRStakeholderReviews

- [ ] **Step 7: Note User Admin & Assessment test result**

Summary:
- ✅ User Admin loads current user and role correctly
- ✅ Stakeholder Assessment can assign RAG ratings
- ✅ Data persists to SharePoint
- OR: List any issues

**Outcome:** Both screens pass Level C validation.

---

### Task 14: Final Validation & Sign-Off

**Prerequisite:** All test scenarios completed (Tasks 7–13).

- [ ] **Step 1: Review Phase 3 Test Report**

Compile your test results from all screens:

| Screen | Test | Result | Notes |
|--------|------|--------|-------|
| Home | Navigation | ✅ Pass | All tiles navigate correctly |
| Dashboard | Rendering | ✅ Pass | All 6 tiles visible, counts correct |
| View CRs | Gallery + Filter | ✅ Pass | Live data loads, filtering works |
| Submit CR A→B | Form Flow | ✅ Pass | Data flows to Part B, no errors |
| Submit CR Save | Persistence | ✅ Pass | New CR created in CRRequests |
| CR Detail | Display | ✅ Pass | CR fields load, workflow button works |
| PMO Consolidation | Guard + Two-Panel | ✅ Pass | Guard redirects non-PMO, panels render |
| PMO Overdue Alert | Visibility | ✅ Pass | Banner shows for overdue CRs |
| PMO RAG | Assignment | ✅ Pass | RAG saved to CRStakeholderReviews |
| User Admin | Role Display | ✅ Pass | Current user role shows |
| Stakeholder Assessment | RAG Assignment | ✅ Pass | RAG persists to SharePoint |

(Update with your actual test results. Mark as ✅ Pass or ❌ Fail.)

- [ ] **Step 2: Check production readiness criteria**

Verify:
- [ ] Phase 1 validation complete (data sources, formulas, screens audited) ✓
- [ ] Dashboard Screen UI fix applied (text visible on tiles) ✓
- [ ] PMO Consolidation guard logic & layout verified ✓
- [ ] msapp built successfully by PackTool ✓
- [ ] All Phase 3 test scenarios pass ✓
- [ ] No formula errors in Power Apps player ✓
- [ ] SharePoint data persists correctly after each CRUD operation ✓
- [ ] Navigation between all 10 screens works ✓
- [ ] Role-based access (PMO guard, user visibility) enforced ✓

If any item is not checked, flag as blocker and return to relevant task.

- [ ] **Step 3: Final commit**

If all tests pass:

```bash
git add CRTool.msapp
git commit -m "test: CRTool.msapp passes Level C production validation

- Dashboard text visibility fixed (Z-order)
- All 10 screens tested against live SharePoint
- Core workflows (Submit CR, View, Detail, PMO consolidation) verified
- Data persistence confirmed
- Role-based access enforced"
```

- [ ] **Step 4: Document deliverables**

Summary for delivery:
- **CRTool.msapp**: Production-ready package (in repo root)
- **Test Report**: All Phase 3 scenarios documented above
- **Status**: PRODUCTION READY ✓

**Outcome:** BA Change Request Tool is built, validated, and ready for deployment.

---

## Rollback Plan

If any Phase 3 test fails critically:

1. **Identify Root Cause:**
   - Formula error? → Fix in CRTool/Src/[Screen].fx.yaml
   - Data source issue? → Fix in CRTool/DataSources/[Source].json
   - Data missing? → Add test data to SharePoint lists

2. **Fix & Rebuild:**
   - Edit source file
   - Run PackTool again (Task 5, Step 2)
   - Re-test the affected scenario

3. **Expected:** 1–2 iteration cycles max before full pass.

---

**Next Step:** Two execution options:

**1. Subagent-Driven (recommended)** — I dispatch a fresh subagent per task, review between tasks, fast iteration. Uses superpowers:subagent-driven-development.

**2. Inline Execution** — Execute tasks in this session using superpowers:executing-plans, batch execution with checkpoints.

Which approach do you prefer?
