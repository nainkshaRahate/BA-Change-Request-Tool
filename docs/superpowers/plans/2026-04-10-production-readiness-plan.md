# BA Change Request Tool — Production Readiness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prepare BA Change Request Tool Power Apps Canvas App for production deployment with zero formula errors, verified SharePoint connections, tested workflows, and final msapp package.

**Architecture:** The app uses 10 Power Apps Canvas screens with BA brand styling (midnight navy/gold), connecting to 4 SharePoint lists on baplc.sharepoint.com/sites/Engprog. Source files are in CRTool/Src/ as .fx.yaml files.

**Tech Stack:** Power Apps Canvas (Power Fx), SharePoint Lists, Power Apps CLI (pac), YAML source format.

---

## File Structure

```
CRTool/
├── Src/
│   ├── App.fx.yaml
│   ├── Home Screen.fx.yaml
│   ├── View CRs Screen.fx.yaml
│   ├── Submit CR Screen.fx.yaml
│   ├── Submit CR B Screen.fx.yaml
│   ├── CR Detail Screen.fx.yaml
│   ├── Stakeholder Assessment Screen.fx.yaml
│   ├── PMO Consolidation Screen.fx.yaml
│   ├── Programme Meeting Screen.fx.yaml
│   ├── Dashboard Screen.fx.yaml
│   └── User Admin Screen.fx.yaml
├── DataSources/
│   ├── CRRequests.json
│   ├── CRStakeholderReviews.json
│   ├── CRUserAdmin.json
│   └── AIPSGMeetings.json
└── CanvasManifest.json
```

---

## Phase 1: Formula Error Scan and Fix

### Task 1: Scan all screens for formula errors using parallel agents

**Files:**
- Modify: All CRTool/Src/*.fx.yaml files

- [ ] **Step 1: Launch parallel agents to scan each screen**

Use Agent tool with subagent_type=Explore to scan:
- Home Screen.fx.yaml
- View CRs Screen.fx.yaml
- Submit CR Screen.fx.yaml
- Submit CR B Screen.fx.yaml
- CR Detail Screen.fx.yaml
- Stakeholder Assessment Screen.fx.yaml
- PMO Consolidation Screen.fx.yaml
- Programme Meeting Screen.fx.yaml
- Dashboard Screen.fx.yaml
- User Admin Screen.fx.yaml

For each screen, search for:
- Unqualified enums: "Ascending", "Days", "None" (should be SortOrder.Ascending, TimeUnit.Days, ScreenTransition.None)
- Common errors: IsBlank on wrong types, .Value on non-records, ThisItem on string arrays

- [ ] **Step 2: Compile error list from all agents**

Collect findings and deduplicate.

- [ ] **Step 3: Fix each identified formula error**

For each error:
1. Read the file at the identified line
2. Edit to fix the formula
3. Verify fix is syntactically correct

- [ ] **Step 4: Verify no new errors introduced**

Run: `pac canvas pack --source-dir CRTool --msapp out/CRTool_v1.msapp`
Expected: Success with no errors

---

## Phase 2: Data Connection Verification

### Task 2: Verify SharePoint data source configurations

**Files:**
- Modify: CRTool/DataSources/*.json

- [ ] **Step 1: Read CRRequests.json**

Run: Read CRTool/DataSources/CRRequests.json
Verify: SiteUrl = "https://baplc.sharepoint.com/sites/Engprog"
Verify: ListName = "CRRequests"

- [ ] **Step 2: Read CRStakeholderReviews.json**

Run: Read CRTool/DataSources/CRStakeholderReviews.json
Verify: SiteUrl = "https://baplc.sharepoint.com/sites/Engprog"
Verify: ListName = "CRStakeholderReviews"

- [ ] **Step 3: Read CRUserAdmin.json**

Run: Read CRTool/DataSources/CRUserAdmin.json
Verify: SiteUrl = "https://baplc.sharepoint.com/sites/Engprog"
Verify: ListName = "CRUserAdmin"

- [ ] **Step 4: Read AIPSGMeetings.json**

Run: Read CRTool/DataSources/AIPSGMeetings.json
Verify: SiteUrl = "https://baplc.sharepoint.com/sites/Engprog"
Verify: ListName = "AIPSGMeetings"

- [ ] **Step 5: Cross-reference column names**

For each DataSource JSON, verify columns match SharePoint list columns from docs/SharePoint_Lists_Setup_Guide.md:
- CRRequests: CRNumber, ProgrammeCode, ProgrammeName, CRTitle, CRStatus, IsDraft, etc.
- CRStakeholderReviews: CRNumber (lookup), StakeholderGroup, RAGStatus, ImpactStatement
- CRUserAdmin: Email, Role, StakeholderGroup, IsActive
- AIPSGMeetings: MeetingDate, SubmissionDeadline, IsActive

If mismatches found, note for fix (may require SharePoint column rename or app update).

---

## Phase 3: Workflow Testing

### Task 3: Test Submit CR flow (Part A → Part B → Save)

**Files:**
- Test: Submit CR Screen.fx.yaml, Submit CR B Screen.fx.yaml

- [ ] **Step 1: Review Submit CR Screen Part A**

Read CRTool/Src/Submit CR Screen.fx.yaml lines 90-175
Verify btnSaveDraftSCS and btnContinueSCS OnSelect formulas:
- Patch() to CRRequests
- Required fields: CRNumber, ProgrammeCode, ProgrammeName, CRTitle, ProjectManager, CRSponsor, AIPSGTargetDate
- Validation: IsBlank() checks before proceeding

- [ ] **Step 2: Review Submit CR B Screen**

Read CRTool/Src/Submit CR B Screen.fx.yaml
Verify Part B fields: RE_Delta_PerAircraft, NRE_Delta, TotalCostDelta, Weight fields, CRDescription, etc.

- [ ] **Step 3: Verify error handling**

Check: All Patch() calls followed by IsEmpty(Errors(CRRequests))
Check: Notify() on success and failure

- [ ] **Step 4: Document any workflow issues found**

Note any missing validations or incorrect field mappings.

---

### Task 4: Test View CRs and CR Detail flows

**Files:**
- Test: View CRs Screen.fx.yaml, CR Detail Screen.fx.yaml

- [ ] **Step 1: Review View CRs gallery**

Read CRTool/Src/View CRs Screen.fx.yaml lines 149-170
Verify galCRsVCS Items:
- Filter on CRRequests
- Search: txtSearchVCS.Text in Title or CRNumber
- Status filter: ddlStatusVCS.Selected.Value
- Programme filter: ddlProgrammeVCS.Selected.Value
- AIPSG filter: ddlAIPSGVCS.Selected
- Access control: (Not(IsDraft) OR Originator.Email = User().Email OR gblIsPMO)

- [ ] **Step 2: Review CR Detail Screen**

Read CRTool/Src/CR Detail Screen.fx.yaml
Verify:
- OnVisible: Set(gblDetailCR, LookUp(CRRequests, ID = gblDetailCR.ID))
- Display: All CR fields shown
- PMO buttons: Accept & Distribute, Return to Owner, Mark Ready for SG, etc.
- Visible: =gblIsPMO for PMO-only buttons

- [ ] **Step 3: Verify status transitions**

Check PMO workflow buttons transition to correct statuses:
- Accept & Distribute → "In Assessment"
- Return to Owner → "Submitted"
- Mark Ready for SG → "Pre-SG Distribution" (with Pale Blue gate)
- Close CR → "Closed"

---

## Phase 4: UI Polish

### Task 5: Verify BA brand consistency

**Files:**
- Modify: All CRTool/Src/*.fx.yaml files

- [ ] **Step 1: Check brand colors**

Search for: RGBA(1, 37, 84, 1) - midnight navy (header backgrounds)
Search for: RGBA(186, 150, 46, 1) - gold (accents, buttons)
Search for: RGBA(0, 75, 135, 1) - mid-blue (secondary buttons)
Search for: RGBA(0, 22, 55, 1) - deep navy (sub-navigation)

Verify consistent usage across all screens.

- [ ] **Step 2: Check typography**

Search for: Font.'Segoe UI'
Check: FontWeight.Bold for headers, FontWeight.Semibold for sub-headers

- [ ] **Step 3: Check spacing and radius**

Search for: RadiusBottomLeft: =6, RadiusTopRight: =6
Verify: 6px border radius on buttons and cards

- [ ] **Step 4: Fix any inconsistencies**

Edit any screens that don't follow BA brand guidelines.

---

## Phase 5: Production Build

### Task 6: Build production msapp

**Files:**
- Create: CRTool_v1.msapp (final production package)

- [ ] **Step 1: Run final pack command**

Run: pac canvas pack --source-dir CRTool --msapp CRTool_v1.msapp
Expected: Success message, output file created

- [ ] **Step 2: Verify output file**

Run: ls -la CRTool_v1.msapp
Expected: File exists with reasonable size (~50-80KB for this app)

- [ ] **Step 3: Test unpack (optional verification)**

Run: pac canvas unpack --msapp CRTool_v1.msapp --destination /tmp/test-unpack
Verify: Source files extracted successfully

- [ ] **Step 4: Document final state**

Update docs/superpowers/specs/2026-04-10-production-readiness-design.md:
- Mark all success criteria as complete
- Note final msapp size and date
- Record any issues encountered

---

## Execution Notes

1. **Parallel scanning:** Phase 1 Task 1 can use parallel agents to scan all 10 screens simultaneously - each screen is independent.

2. **Known issues from buglog:** Previous session fixed:
   - SortOrder.Ascending (not Ascending)
   - TimeUnit.Days (not Days)
   - ThisItem.Value → ThisItem for string arrays
   - Filter scope aliases for CRNumber lookups

3. **SharePoint connection:** All 4 DataSources should point to https://baplc.sharepoint.com/sites/Engprog

4. **Testing constraint:** Cannot actually run Power Apps in this environment - testing is by code review of formulas.

---

## Success Criteria

- [ ] All 10 screens have zero formula errors
- [ ] DataSources/*.json point to correct SharePoint site
- [ ] Column names in app match SharePoint list columns
- [ ] Submit CR flow complete (Part A → Part B)
- [ ] View CRs shows filtered data
- [ ] CR Detail shows correct info with role-based buttons
- [ ] BA brand colors consistent across all screens
- [ ] Production msapp packaged successfully
