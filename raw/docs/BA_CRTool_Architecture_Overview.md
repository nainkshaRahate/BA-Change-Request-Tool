# BA Change Request Tool — Architecture Overview

> Source: code-review-graph knowledge graph (graph.db) + direct analysis of all .fx.yaml source files.
> Graph build: Full build · branch main · commit 0421993 · 07 Apr 2026

---

## 1. Technology Stack

| Layer | Technology |
|---|---|
| Platform | Microsoft Power Apps (Canvas App) |
| Language | Power Fx (.fx.yaml via Power Apps CLI) |
| Data layer | SharePoint Lists |
| Source control | Git — unpacked to CRTool/Src/ |

---

## 2. App Entry Point (App.fx.yaml)

App.OnStart runs once at launch and bootstraps all global state:

  Set(gblCurrentUser)      → LookUp(CRUserAdmin, Email = User().Email)
  Set(gblCurrentUserRole)  → user Role choice value
  Set(gblStakeholderGroup) → user StakeholderGroup choice value
  Set(gblIsPMO)            → true if PMO or Admin
  Set(gblIsAdmin)          → true if Admin
  Set(gblIsProgMgr)        → true if Programme Manager
  Set(gblIsMaker, false)   → developer debug flag
  Set(gblCRMode, "View")
  Set(gblDetailCR, Blank())
  Set(gblConsolidationCR, Blank())
  Set(gblFormError, "")
  StartScreen: Home Screen

---

## 3. SharePoint Data Sources

| List | Purpose |
|---|---|
| CRRequests | Master CR records |
| CRStakeholderReviews | Per-CR per-group RAG ratings and impact statements |
| CRUserAdmin | User registry with roles and stakeholder groups |
| AIPSGMeetings | Active AIPSG meeting dates |

---

## 4. Screen Inventory (10 screens)

| Screen | File | Access | Purpose |
|---|---|---|---|
| Home Screen | Home Screen.fx.yaml | All | Landing pad — navigation tiles |
| View CRs Screen | View CRs Screen.fx.yaml | All | Filterable CR list |
| Submit CR Screen | Submit CR Screen.fx.yaml | All | Form Part A — identification |
| Submit CR B Screen | Submit CR B Screen.fx.yaml | All | Form Part B — content and cost |
| CR Detail Screen | CR Detail Screen.fx.yaml | All / PMO actions | Read-only CR detail + workflow buttons |
| Stakeholder Assessment Screen | Stakeholder Assessment Screen.fx.yaml | PMO + Stakeholders | RAG ratings and impact statements |
| PMO Consolidation Screen | PMO Consolidation Screen.fx.yaml | PMO / Admin only | Two-panel PMO review workspace |
| Programme Meeting Screen | Programme Meeting Screen.fx.yaml | PMO / Admin | Attendance and progression for meeting CRs |
| Dashboard Screen | Dashboard Screen.fx.yaml | All | KPI tiles + programme breakdown table |
| User Admin Screen | User Admin Screen.fx.yaml | Admin only | Role and group management |

---

## 5. Screen Navigation (from graph.db CALLS edges)

App → Home Screen (StartScreen)

Home Screen
  → View CRs Screen        (btnViewCRsHS, line 68)
  → Submit CR Screen       (btnSubmitCRHS, lines 86-89, sets gblCRMode=New)
  → Dashboard Screen       (btnDashboardHS, line 125)
  → User Admin Screen      (btnUserAdminHS, line 144, Admin only)

View CRs Screen
  → Home Screen            (btnHomeVCS, line 57)
  → Submit CR Screen       (btnAddCRVCS, lines 75-78, sets gblCRMode=New)
  → CR Detail Screen       (galCRsVCS OnSelect, lines 151-152, sets gblDetailCR)

Submit CR Screen (Part A)
  → Home Screen            (btnHomeSCS, line 57)
  → View CRs Screen        (btnCancelSCS, line 69)
  → View CRs Screen        (btnSaveDraftSCS on success, line 106)
  → Submit CR B Screen     (btnContinueSCS on validation pass, line 154)

Submit CR B Screen (Part B)
  → Home Screen            (btnHomeSCB, line 56)
  → Submit CR Screen       (btnBackSCB, line 68)
  → View CRs Screen        (btnSubmitSCB on success, line 148)

CR Detail Screen
  → Home Screen            (btnHomeCDS, line 60)
  → View CRs Screen        (btnBackCDS, line 72)
  → View CRs Screen        (btnDeleteCDS on confirm, line 166)
  → Stakeholder Assessment (btnPartBCDS, line 89)

Stakeholder Assessment Screen
  → Home Screen            (btnHomeSAS, line 57)
  → CR Detail Screen       (btnBackSAS, line 69)

Dashboard Screen
  → Home Screen            (btnHomeDS, line 68)

PMO Consolidation Screen
  → Home Screen            (guard redirect OnVisible if not PMO, line 12)
  → Home Screen            (btnHomePCS, line 60)

Programme Meeting Screen
  → Home Screen            (btnHomePMS, line 57)

User Admin Screen
  → Home Screen            (guard redirect OnVisible if not Admin, line 11)
  → Home Screen            (btnHomeUAS, line 57)

NOTE: PMO Consolidation and Programme Meeting screens have no inbound
Navigate() link from Home Screen in current source — not yet wired up.

---

## 6. CR Status Lifecycle

Draft
  └─ Submit Formally ──▶ Submitted
                              │
              ┌───────────────┴───────────────┐
         Accept & Distribute           Return to Owner
              │                              │
        In Assessment                  Submitted (loop)
              │
        (Stakeholders complete RAG reviews)
              │
        PMO Consolidation
              │
        Mark Ready for SG
        (BLOCKED if any Pale Blue RAG remaining)
              │
        Pre-SG Distribution
              │
         SG Review
              │
     ┌────────┴────────┐
  Approved          Rejected / Deferred / Post-Meeting Edits
     │
  Close CR
     │
  Closed

Programme Meeting path:
  Programme Meeting ──▶ Deferred  (no attendance)
  Programme Meeting ──▶ Pre-SG Distribution  (attendance confirmed or delegate named)

---

## 7. PMO Workflow Buttons on CR Detail Screen

| Button | Visible when | Transitions to |
|---|---|---|
| Accept & Distribute | gblIsPMO AND status = PMO Review | In Assessment |
| Return to Owner | gblIsPMO AND status = PMO Review | Submitted |
| Mark Ready for SG | gblIsPMO AND status = PMO Consolidation | Pre-SG Distribution (Pale Blue gate) |
| Record SG Decision | gblIsPMO AND status = SG Review | Shows notification |
| Close CR | gblIsPMO AND status = Approved | Closed |
| Delete CR | gblIsAdmin (any status) | Record removed |

---

## 8. Global State Variables

| Variable | Purpose |
|---|---|
| gblCurrentUser | Logged-in user CRUserAdmin record |
| gblCurrentUserRole | Role choice value |
| gblStakeholderGroup | Stakeholder group choice value |
| gblIsPMO | PMO or Admin access flag |
| gblIsAdmin | Admin access flag |
| gblIsProgMgr | Programme Manager flag |
| gblIsMaker | Developer debug flag |
| gblCRMode | "New" / "Edit" / "View" — controls form titles |
| gblDetailCR | Currently selected CR (CR Detail + Stakeholder Assessment) |
| gblConsolidationCR | CR selected in PMO Consolidation right panel |
| gblFormError | Inline validation error message |
| colProgrammeStats | Programme-grouped stats collection (Dashboard) |

---

## 9. Key Design Patterns

1. Role-gated visibility: Sensitive controls use Visible: =gblIsAdmin / gblIsPMO
   — not just DisplayMode.Disabled — so buttons are completely hidden from unauthorised users.

2. Guard redirects on OnVisible: PMO Consolidation and User Admin immediately
   call Navigate('Home Screen', None) if the user lacks the required role.

3. Optimistic patching: All writes use Patch() + If(IsEmpty(Errors(...))) to detect
   failure and surface a Notify() message — no try/catch blocks.

4. Global record passing: gblDetailCR is set before Navigate() so destination
   screens always have context. CR Detail re-fetches on OnVisible to catch concurrent edits.

5. Draft-safe two-phase form: Part A is always persisted to SharePoint before
   navigating to Part B — prevents data loss if the app is closed mid-entry.

6. Pale Blue gate: PMO cannot advance any CR to Pre-SG Distribution if
   CountRows(Filter(CRStakeholderReviews, ..., RAGStatus.Value = "Pale Blue")) > 0.
   Enforced identically in CR Detail Screen and PMO Consolidation Screen.

---

## 10. IAG Tech Coding Standards Compliance (CLAUDE.md)

Reference standard: IAG Tech Power Apps Coding Standards (2021), as documented in CLAUDE.md.

---

### 10.1 Naming Conventions

| Convention | Standard (CLAUDE.md) | Status | Evidence |
|---|---|---|---|
| Screen names | Plain language + spaces + "Screen" | COMPLIANT | "Home Screen", "View CRs Screen", "CR Detail Screen" etc. |
| Global variables | Prefix gbl + camelCase | COMPLIANT | gblCurrentUser, gblIsPMO, gblDetailCR, gblFormError |
| Collections | Prefix col + camelCase | COMPLIANT | colProgrammeStats |
| Context variables | Prefix loc + camelCase | N/A | No context variables used in current implementation |
| Controls | [3-letter prefix][Purpose][ShortScreenSuffix] | COMPLIANT | btnSubmitCRHS, galCRsVCS, lblHeaderCDS, dteAIPSGSCS, tglActiveUAS |
| Data sources | PascalCase | COMPLIANT | CRRequests, CRStakeholderReviews, CRUserAdmin, AIPSGMeetings |

---

### 10.2 Architecture and Performance

| Standard | Status | Detail |
|---|---|---|
| Use App.StartScreen for routing | COMPLIANT | StartScreen: ='Home Screen' set in App.fx.yaml |
| App.OnStart only for static themes/roles | PARTIAL DEVIATION | Role flags (gblIsPMO, gblIsAdmin) are correct here. However, gblCRMode, gblDetailCR, gblConsolidationCR, and gblFormError are transient state — per the standard these should be reset in each Screen.OnVisible, not initialised in App.OnStart. (They are already being reset in individual OnVisible handlers, so the App.OnStart initialisation is redundant rather than harmful.) |
| Screen.OnVisible for data refreshing | COMPLIANT | All data loads and state resets happen in OnVisible handlers |
| Concurrent() for multiple data calls | COMPLIANT | Dashboard Screen wraps ClearCollect in Concurrent() |
| Prioritise delegable functions | COMPLIANT | Filter, Sort, CountIf, CountRows used throughout — no non-delegable functions detected |
| ClearCollect instead of Clear + Collect | COMPLIANT | ClearCollect(colProgrammeStats, ...) used in Dashboard |
| Encapsulation — pass via Maps context records | PARTIAL DEVIATION | gblDetailCR is used as the cross-screen record carrier, which is the standard global variable pattern and acceptable. However, no Maps/context record pattern is used — context is not isolated per screen call. |
| Never reference controls from a different screen | COMPLIANT | No cross-screen control references found |
| Relative styling (Parent.Width, Control.Y + 20) | PARTIAL DEVIATION | Parent.Width and Parent.Height are used consistently. However, most Y coordinates are hard-coded absolute values (e.g. Y: =210, Y: =278) rather than relative expressions like Control.Y + Control.Height + 8. This makes layout brittle when controls are reordered. |
| All controls must reside in a Container or Group | DEVIATION | No Container or Group controls are present in any screen. All controls float directly on the screen canvas. This is the most significant structural gap relative to the standard. |

---

### 10.3 Documentation and Debugging

| Standard | Status | Detail |
|---|---|---|
| OnVisible block comment (Name, Purpose, Author, Date) | COMPLIANT | Every screen's OnVisible begins with /* Screen Name — OnVisible / Purpose / Author / Date */ |
| Use // for "Why" comments on logic | COMPLIANT | Inline // comments explain intent (e.g. "// Guard: redirect non-PMO users immediately") |
| IsEmpty(Errors(DataSource)) after Patch | COMPLIANT | All Patch() calls immediately check IsEmpty(Errors(...)) |
| gblIsMaker debug flag | COMPLIANT | Set(gblIsMaker, false) in App.OnStart; intended to show/hide developer labels |

---

### 10.4 MCP Tool Usage (code-review-graph)

| Requirement | Status | Detail |
|---|---|---|
| Use graph tools BEFORE Grep/Glob/Read for exploration | NOTE | The code-review-graph MCP tools (get_architecture_overview, list_communities, etc.) are only accessible from MCP-enabled hosts such as Claude Code or OpenCode. For this analysis the graph.db SQLite database was queried directly as a fallback, which surfaces the same underlying data. When working inside an MCP host, always use the tool reference in CLAUDE.md section 5 first. |

---

### 10.5 Summary and Recommended Remediation

#### Compliant (no action needed)
- All naming conventions (screens, variables, controls, data sources)
- App.StartScreen routing
- Screen.OnVisible data loading and state reset
- Concurrent() for parallel data calls
- ClearCollect pattern
- IsEmpty(Errors()) error handling on all Patch() calls
- OnVisible block comment documentation
- gblIsMaker debug flag

#### Requires Attention (prioritised)

**Priority 1 — Container / Group structure (DEVIATION)**
- Impact: High. Without containers, responsive layout is impossible and control reordering is manual.
- Remediation: Wrap logically related controls in named Container controls on each screen.
  Example groupings per screen: HeaderContainer, SubNavContainer, FilterBarContainer, ContentContainer, FooterContainer.

**Priority 2 — Relative Y positioning (PARTIAL DEVIATION)**
- Impact: Medium. Hard-coded Y values mean any inserted control requires manual renumbering of all controls below it.
- Remediation: Chain Y values relatively — e.g. lblSectionContent.Y: =recFilterBar.Y + recFilterBar.Height + 8.
  This is most practical to fix when containers are introduced (Priority 1).

**Priority 3 — Transient state in App.OnStart (PARTIAL DEVIATION)**
- Impact: Low. gblCRMode, gblDetailCR, gblConsolidationCR, and gblFormError are already reset in each relevant Screen.OnVisible, so the App.OnStart initialisations are redundant but harmless.
- Remediation: Remove the four transient variable initialisations from App.OnStart. Keep only the role/user globals (gblCurrentUser, gblCurrentUserRole, gblStakeholderGroup, gblIsPMO, gblIsAdmin, gblIsProgMgr, gblIsMaker) which are genuinely static at launch.
