# BA Change Request Tool — Production Readiness Design

**Date:** 10 April 2026
**Author:** Claude (AI Developer)
**Status:** Draft - awaiting approval

---

## 1. Overview

Prepare the BA Change Request Tool Power Apps Canvas App for production deployment. The app manages engineering change requests through a 10-step workflow with SharePoint List backend.

**Current State:**
- 10 screens built with BA brand UI (midnight navy/gold)
- 4 SharePoint lists configured (CRRequests, CRStakeholderReviews, CRUserAdmin, AIPSGMeetings)
- 6 formula bugs previously fixed (enum qualifications, scope aliases)
- Source files in CRTool/Src/ directory

**Target State:**
- Zero formula errors
- Live SharePoint data connections verified
- Core user flows tested and working
- Production-ready msapp package

---

## 2. Scope

### In Scope
1. Formula error scan and fix across all 10 screens
2. SharePoint data connection verification and any needed updates
3. Core workflow testing (submit CR, view CRs, CR detail, status transitions)
4. Basic UI polish for BA brand consistency
5. Final production msapp build

### Out of Scope
- SharePoint list/column creation (already done per user confirmation)
- Power Automate flow creation (not in app source)
- User acceptance testing (manual business process)

---

## 3. Technical Details

### Data Sources (SharePoint)
| List | Site | Purpose |
|------|------|---------|
| CRRequests | baplc.sharepoint.com/sites/Engprog | Master CR records |
| CRStakeholderReviews | baplc.sharepoint.com/sites/Engprog | RAG ratings per stakeholder |
| CRUserAdmin | baplc.sharepoint.com/sites/Engprog | User roles and permissions |
| AIPSGMeetings | baplc.sharepoint.com/sites/Engprog | Meeting date reference |

### Screens to Review
| Screen | Key Functions |
|--------|---------------|
| Home Screen | Navigation tiles |
| View CRs Screen | Filterable CR gallery |
| Submit CR Screen | Part A - CR identification |
| Submit CR B Screen | Part B - costs/description |
| CR Detail Screen | CR view + PMO workflow buttons |
| Stakeholder Assessment Screen | RAG ratings |
| PMO Consolidation Screen | Two-panel PMO review |
| Programme Meeting Screen | Meeting prep |
| Dashboard Screen | KPIs and stats |
| User Admin Screen | User management |

### Known Fixes (from buglog)
- SortOrder.Ascending (was Ascending)
- TimeUnit.Days (was Days)
- ThisItem.Value → ThisItem for string arrays
- Filter scope aliases for lookup joins

---

## 4. Implementation Plan

### Phase 1: Formula Error Scan (~30 min)
1. Load msapp or source files
2. Check each screen for red-dot errors
3. Fix any formula issues found

### Phase 2: Data Connection Verification (~15 min)
1. Verify DataSources/*.json point to correct SharePoint site
2. Confirm column names match SharePoint list columns
3. Update any mismatched field references

### Phase 3: Workflow Testing (~45 min)
1. Test Submit CR flow (Part A → Part B → Save)
2. Test View CRs (filter, search, select)
3. Test CR Detail (view, workflow buttons)
4. Test role-based access (PMO vs Stakeholder)

### Phase 4: UI Polish (~20 min)
1. Verify BA brand colors consistent
2. Check spacing/padding
3. Verify containers/groups structure

### Phase 5: Production Build (~10 min)
1. Pack final msapp with pac canvas pack
2. Verify output file
3. Document final state

---

## 5. Success Criteria

- [ ] Zero formula errors in all 10 screens
- [ ] Data source connections point to https://baplc.sharepoint.com/sites/Engprog
- [ ] All 4 SharePoint lists referenced correctly
- [ ] Submit CR flow works end-to-end
- [ ] View CRs shows data from SharePoint
- [ ] Role-based navigation works (PMO sees PMO buttons)
- [ ] Production msapp packaged successfully

---

## 6. Risk Mitigation

| Risk | Mitigation |
|------|------------|
| SharePoint list mismatch | Verify column names in DataSources/*.json match lists |
| Permission errors | Test with admin user first, then stakeholder |
| Data loss | App uses Patch with error checking (IsEmpty(Errors())) |
| Pack failure | Use verified pac canvas pack command |

---

## 7. Visual Checkpoints

1. Home Screen: Shows 6-8 navigation tiles with BA branding
2. View CRs Screen: Gallery displays CRs with status colors
3. Submit CR: Form with required field validation
4. Dashboard: KPI tiles + programme breakdown table
5. PMO buttons visible only to PMO/Admin users
