# CR Tool — Claude Code + Power Platform CLI Build Guide
### How to Build the Power Apps Canvas App Programmatically
**British Airways Cabin Programme | v1.0**

---

## What This Guide Covers

Power Apps Canvas apps have a source code format. When you unpack a `.msapp` file using the Power Platform CLI, it becomes a folder of human-readable YAML files — one per screen, plus configuration files. Claude Code can generate these YAML files from scratch, pack them into a `.msapp` file, and you import that single file into Power Apps Studio. The entire app appears, pre-built.

This guide gives you every command, every file, and every piece of code you need.

---

## Part 1 — Prerequisites & Setup

### 1.1 What You Need Before Starting

| Requirement | How to get it | Notes |
|---|---|---|
| Claude Code | Download from claude.ai/download | Install on Mac or Windows |
| Node.js (v18+) | nodejs.org | Required by Power Platform CLI |
| Power Platform CLI (`pac`) | `npm install -g @microsoft/powerplatform-cli` | Free, published by Microsoft |
| Power Apps account | Already have via BA M365 | make.powerapps.com |
| SharePoint site | `BA-CR-Tool` site already configured | From roadmap Section 2 |

### 1.2 Install the Power Platform CLI

Open a terminal (or Claude Code's terminal) and run:

```bash
npm install -g @microsoft/powerplatform-cli
```

Verify installation:
```bash
pac --version
```

You should see output like: `Microsoft PowerApps CLI 1.x.x`

### 1.3 Authenticate with Power Platform

```bash
pac auth create --environment https://[your-org].crm.dynamics.com
```

For BA's M365 environment, you will be prompted to sign in with your BA credentials in a browser window. This stores the auth token locally.

List available environments to confirm connection:
```bash
pac env list
```

---

## Part 2 — How Canvas App Source Code Works

### 2.1 The File Structure

When Claude Code generates the app, it creates this folder structure:

```
CRTool/
├── CanvasManifest.json          ← App metadata, version, settings
├── DataSources/
│   ├── CRRequests.json          ← SharePoint list connection
│   ├── CRStakeholderReviews.json
│   ├── CRUserAdmin.json
│   └── AIPSGMeetings.json
├── Src/
│   ├── App.fx.yaml              ← App.OnStart formulas, global vars
│   ├── scrHome.fx.yaml          ← Home screen
│   ├── scrViewCRs.fx.yaml       ← View CRs gallery screen
│   ├── scrSubmitCR.fx.yaml      ← Submit/Edit form screen
│   ├── scrCRDetail.fx.yaml      ← CR Detail Part A
│   ├── scrStakeholderAssessment.fx.yaml  ← Part B
│   ├── scrPMOConsolidation.fx.yaml
│   ├── scrProgrammeMeeting.fx.yaml
│   ├── scrDashboard.fx.yaml
│   └── scrUserAdmin.fx.yaml
├── Assets/
│   └── Images/
│       └── BALogo.png           ← Speedbird logo (you provide this)
└── pkgs/
    └── Wadl/                    ← Auto-generated connector descriptors
```

### 2.2 What Each YAML File Contains

Each `.fx.yaml` screen file defines:
- Every control on the screen (its type, name, position, size)
- Every property of every control (Fill, Text, OnSelect, Visible, etc.)
- The Power Fx formulas for each property

---

## Part 3 — The Claude Code Prompt

### 3.1 How to Use Claude Code for This

Open Claude Code and give it the following prompt. It will generate all the source files.

---

**CLAUDE CODE PROMPT — COPY AND USE THIS EXACTLY:**

```
You are building a Power Apps Canvas App from source code. Generate all YAML source files 
for the Power Platform CLI `pac canvas pack` command.

PROJECT: BA Cabin Programme CR (Change Request) Tracking Tool
APP DIMENSIONS: 1366 x 768 (Tablet landscape)
FONT: Segoe UI throughout

COLOUR SYSTEM:
- NavyPrimary: RGBA(31,55,100,1)     #1F3764
- AccentRed: RGBA(192,57,43,1)       #C0392B  
- AccentGreen: RGBA(39,174,96,1)     #27AE60
- AccentAmber: RGBA(243,156,18,1)    #F39C12
- AccentSlate: RGBA(110,140,176,1)   #6E8CB0
- NeutralGrey: RGBA(149,165,166,1)   #95A5A6
- SurfaceWhite: RGBA(255,255,255,1)
- PaleBlue: RGBA(174,214,241,1)      #AED6F1
- TextPrimary: RGBA(33,33,33,1)
- TextMuted: RGBA(117,117,117,1)
- ValidationRed: RGBA(231,76,60,1)

DATA SOURCES (SharePoint Lists on site: https://[tenant].sharepoint.com/sites/BA-CR-Tool):
1. CRRequests - columns: Title, CRNumber, ProgrammeCode, ProgrammeName, CRTitle, Supplier, 
   SupplierReference, ProjectManager(Person), CRSponsor(Person), AIPSGTargetDate(Date), 
   SubmissionDeadline(Date), CRStatus(Choice), CRDescription(MultilineText), 
   ReasonForChange(MultilineText), DoNothingOption(MultilineText), AdditionalInformation(MultilineText),
   RE_Delta_PerAircraft(Text), NRE_Delta(Text), TotalCostDelta(Text), WeightDelta_PerAircraft(Text),
   WeightDelta_AllAircraft(Text), AnnualCoWImpact(Text), CostCurrency(Choice),
   Originator(Person), SubmittedDate(Date), IsDraft(Boolean), AttendanceConfirmed(Boolean),
   DelegateAttending(Text), IsConfidential(Boolean), PMONotes(MultilineText), 
   SGDecision(Choice), SGDecisionNotes(MultilineText), ClosedDate(Date)

2. CRStakeholderReviews - columns: Title, CRNumber(Lookup→CRRequests), 
   StakeholderGroup(Choice: Engineering Programmes|Engineering Technical|Onboard Experience|Finance|Procurement|Other),
   RAGStatus(Choice: Pale Blue|Green|Amber|Red|Grey), ImpactStatement(MultilineText),
   Reviewer(Person), ReviewDate(Date), IsApplicable(Boolean), IsComplete(Boolean)

3. CRUserAdmin - columns: Title, Email(Text), Role(Choice: Admin|PMO|Programme Manager|Stakeholder),
   StakeholderGroup(Choice - same as above), Team(Text), IsActive(Boolean)

4. AIPSGMeetings - columns: Title, MeetingDate(Date), SubmissionDeadline(Date), 
   PreSGDistributionDate(Date), IsActive(Boolean)

APP.ONSTART GLOBAL VARIABLES:
Set(gblCurrentUser, LookUp(CRUserAdmin, Email = User().Email));
Set(gblCurrentUserRole, gblCurrentUser.Role);
Set(gblStakeholderGroup, gblCurrentUser.StakeholderGroup);
Set(gblIsPMO, gblCurrentUserRole = "PMO" Or gblCurrentUserRole = "Admin");
Set(gblIsAdmin, gblCurrentUserRole = "Admin");
Set(gblIsProgMgr, gblCurrentUserRole = "Programme Manager");
Set(gblCRMode, "View");
Set(gblDetailCR, Blank());

GENERATE THESE 9 SCREENS:

--- SCREEN 1: scrHome ---
Full-screen dark navy background (NavyPrimary gradient effect using Rectangle).
BA speedbird logo top-left (Image control, 80x40px, source: BALogo.png).
App title "Change Request Management" centred, white, 20pt, Segoe UI.
5 full-width navigation buttons, centred, max-width 500px, height 52px, 4px border-radius, 
16px vertical gap between each:

Button 1 - "View Change Requests":    Fill=AccentSlate,  Navigate(scrViewCRs, None)
Button 2 - "Submit New Change Request": Fill=AccentRed,  Set(gblCRMode,"New"); Set(gblDetailCR, Defaults(CRRequests)); Navigate(scrSubmitCR, None)
Button 3 - "CR Templates & Docs":     Fill=AccentGreen,  Launch("https://[tenant].sharepoint.com/sites/BA-CR-Tool/CR-Templates")
Button 4 - "Dashboard":               Fill=AccentAmber,  Navigate(scrDashboard, None)
Button 5 - "User Admin":              Fill=NeutralGrey,  Navigate(scrUserAdmin, None), Visible=gblIsAdmin

Role badge: rectangle bottom-left, 80x28px, 
Text=gblCurrentUserRole, 
Fill=Switch(gblCurrentUserRole,"Admin",AccentRed,"PMO",NavyPrimary,"Programme Manager",NavyPrimary,AccentGreen)

Version label: "v1.0" bottom-right, 10pt, white, 50% opacity.

--- SCREEN 2: scrViewCRs ---
HEADER BAR: 50px height, NavyPrimary fill, full width.
  - BA Logo: Image, 40x20px, left-aligned, 8px from left
  - Title "Engineering Change Requests": Label, white, 16pt, centred

SUB-NAV BAR: 45px height, RGBA(24,44,82,1) fill, full width.
  - Home icon button (🏠): 36px square, OnSelect=Navigate(scrHome,None)

FILTER BAR: White, full width, 50px height, horizontal layout:
  - Search TextInput: placeholder "Search CR number or title...", 300px wide
  - Status Dropdown: "All Statuses" default, Items=["All","Draft","Submitted","PMO Review","In Assessment","PMO Consolidation","Programme Meeting","Pre-SG Distribution","SG Review","Post-Meeting Edits","Approved","Deferred","Rejected","Closed"]
  - Programme Dropdown: "All Programmes" default, Items=Distinct(CRRequests, ProgrammeName)
  - AIPSG Dropdown: "All Dates" default, Items=Filter(AIPSGMeetings, IsActive)

GALLERY: Vertical, fills remaining screen height.
Items=Sort(Filter(CRRequests, 
  (IsBlank(txtSearch.Text) Or txtSearch.Text in Title Or txtSearch.Text in CRNumber),
  (ddlStatus.Selected.Value="All" Or CRStatus=ddlStatus.Selected.Value),
  (ddlProgramme.Selected.Value="All" Or ProgrammeName=ddlProgramme.Selected.Value),
  (Not(IsDraft) Or Originator.Email=User().Email Or gblIsPMO)
), AIPSGTargetDate, Ascending)

Each gallery row (height 90px, white background, 1px bottom border #E0E0E0):
  - CRNumber label: 60px wide, left, 14pt bold, NavyPrimary
  - Title label: flexible width, 13pt, TextPrimary, truncate with ellipsis
  - Status pill: Rectangle(60x24, 4px radius) + Label(12pt white) — colour from status switch below
  - AIPSGTargetDate label: 90px, 12pt, colour=If(date<Today() And status not closed, AccentRed, DateDiff(Today(),date,Days)<=14, AccentAmber, TextMuted)
  - ProgrammeName label: 120px, 12pt, TextMuted
  - ProjectManager.DisplayName: 100px, 12pt, TextMuted
  - Days open badge: Rectangle(NavyPrimary,50x22,4px radius) + Label(Text(DateDiff(SubmittedDate,Today(),Days))&" Days", white 11pt)
  
OnSelect for each row: Set(gblDetailCR, ThisItem); Navigate(scrCRDetail, None)

Status pill colour switch:
Switch(ThisItem.CRStatus,
"Draft",RGBA(149,165,166,1),"Submitted",RGBA(110,140,176,1),
"PMO Review",RGBA(31,55,100,1),"In Assessment",RGBA(243,156,18,1),
"PMO Consolidation",RGBA(243,156,18,1),"Programme Meeting",RGBA(31,55,100,1),
"Pre-SG Distribution",RGBA(31,55,100,1),"SG Review",RGBA(31,55,100,1),
"Post-Meeting Edits",RGBA(243,156,18,1),"Approved",RGBA(39,174,96,1),
"Deferred",RGBA(149,165,166,1),"Rejected",RGBA(192,57,43,1),
"Closed",RGBA(149,165,166,1),RGBA(31,55,100,1))

+ button (top right): Navigate to scrSubmitCR with gblCRMode="New", AccentRed, 36px square, "+"

--- SCREEN 3: scrSubmitCR ---
HEADER BAR: Same as scrViewCRs.
SUB-NAV BAR: Home icon | X cancel icon (Navigate(scrViewCRs,None)).
  Right side: "Save as Draft" button (NeutralGrey, 120px) | "Submit Formally" button (AccentRed, 140px)

SCROLLABLE FORM (white background, 16px left/right padding):

SECTION HEADER "IDENTIFICATION" - navy background, white text, full width, 32px height

Label+Input pairs (label: 13pt AccentRed "!" prefix + field name; input below):
  CR Number *          : TextInput, hint "e.g. CR05 or CR123"
  Programme Code *     : TextInput, hint "e.g. A380, A32X"
  Programme Name *     : TextInput, hint "e.g. A380 Horizon"
  [Auto-preview Label] : "Title will display as: " & Upper(txtProgrammeCode.Text) & ": " & txtCRNumber.Text & " - " & Upper(txtCRTitle.Text), italic, TextMuted, 11pt
  CR Title *           : TextInput, hint "Descriptive title (will be uppercased)"
  Supplier             : TextInput
  Supplier Reference   : TextInput
  Project Manager *    : Combo box → CRUserAdmin where IsActive=true
  CR Sponsor *         : Combo box → CRUserAdmin where IsActive=true
  AIPSG Target Date *  : Dropdown → AIPSGMeetings where IsActive=true, DisplayFields=["Title"]

SECTION HEADER "CR CONTENT"

  CR Description *     : TextInput (multiline, height 100px)
  Reason for Change    : TextInput (multiline, height 80px)
  Do Nothing Option    : TextInput (multiline, height 80px)
  Additional Info      : TextInput (multiline, height 80px)

SECTION HEADER "COST IMPACT (optional at submission)"

Two-column grid of 6 TextInputs:
  RE Δ (per aircraft) | NRE Δ
  Total Cost Δ        | Weight Δ (1 a/c)
  Weight Δ (all a/c)  | Annual CoW Impact
  Currency Dropdown: [USD, GBP, EUR]

SECTION HEADER "SETTINGS"
  Confidentiality Dropdown: [Internal, Confidential]
  Attachments control (native SharePoint attachments)

VALIDATION on "Submit Formally":
If(
  IsBlank(txtCRNumber.Text) Or Len(txtCRNumber.Text)<4 Or Left(txtCRNumber.Text,2)<>"CR" Or
  IsBlank(txtProgrammeCode.Text) Or IsBlank(txtProgrammeName.Text) Or IsBlank(txtCRTitle.Text) Or
  IsBlank(cmbProjectManager.Selected) Or IsBlank(cmbSponsor.Selected) Or
  IsBlank(ddlAIPSG.Selected) Or IsBlank(taCRDescription.Text),
  Set(gblFormError,"Please complete all required fields marked *"),
  If(CountRows(Filter(CRRequests,CRNumber=txtCRNumber.Text And ID<>gblDetailCR.ID))>0,
    Set(gblFormError,txtCRNumber.Text & " already exists — check the CR number"),
    Patch(CRRequests, If(gblCRMode="New",Defaults(CRRequests),gblDetailCR), {
      Title: Upper(txtProgrammeCode.Text) & ": " & txtCRNumber.Text & " - " & Upper(txtCRTitle.Text),
      CRNumber: txtCRNumber.Text,
      ProgrammeCode: Upper(txtProgrammeCode.Text),
      ProgrammeName: txtProgrammeName.Text,
      CRTitle: Upper(txtCRTitle.Text),
      Supplier: txtSupplier.Text,
      SupplierReference: txtSupplierRef.Text,
      ProjectManager: cmbProjectManager.Selected,
      CRSponsor: cmbSponsor.Selected,
      AIPSGTargetDate: ddlAIPSG.Selected.MeetingDate,
      SubmissionDeadline: ddlAIPSG.Selected.SubmissionDeadline,
      CRDescription: taCRDescription.Text,
      ReasonForChange: taReason.Text,
      DoNothingOption: taDoNothing.Text,
      AdditionalInformation: taAdditional.Text,
      RE_Delta_PerAircraft: txtRE.Text, NRE_Delta: txtNRE.Text,
      TotalCostDelta: txtTotal.Text, WeightDelta_PerAircraft: txtW1.Text,
      WeightDelta_AllAircraft: txtWAll.Text, AnnualCoWImpact: txtCoW.Text,
      CostCurrency: ddlCurrency.Selected.Value,
      IsConfidential: ddlConfidentiality.Selected.Value="Confidential",
      IsDraft: false, CRStatus: "Submitted",
      Originator: {Claims:"i:0#.f|membership|"&User().Email, DisplayName:User().FullName},
      SubmittedDate: Today()
    });
    PowerAutomateFlow_OnSubmit.Run(txtCRNumber.Text);
    Navigate(scrViewCRs, None);
    Notify(txtCRNumber.Text & " submitted successfully.", NotificationType.Success)
  )
)

--- SCREEN 4: scrCRDetail ---
HEADER BAR: Same pattern.
SUB-NAV BAR: 
  Left: Home | Back(Navigate scrViewCRs)
  Right: "Part B →" button (NavyPrimary, 100px, Navigate scrStakeholderAssessment) |
         Status pill (read-only, colour from status switch) |
         Days-open badge (AccentGreen) |
         Bin icon (AccentRed, visible=gblIsAdmin only)
  
  PMO-only action buttons (Visible=gblIsPMO):
  - If CRStatus="PMO Review": "Accept & Distribute" (AccentGreen) | "Return to Owner" (NeutralGrey)
  - If CRStatus="PMO Consolidation": "Mark Ready for SG" (NavyPrimary) — with Pale Blue block
  - If CRStatus="SG Review": "Record SG Decision" (AccentAmber)
  - If CRStatus="Approved": "Close CR" (NeutralGrey)

TITLE ROW: Full width, 40px, navy background.
  gblDetailCR.Title — white, 14pt bold, left-padded 16px

PROGRAMME HEADER BAR (mimics the CR slide header — 6 columns, teal/navy):
  Background: RGBA(13,71,88,1) for labelled columns, white for value columns
  Labelled: "PROGRAMME" | "SUPPLIER" | "SUPPLIER REF" | "PROJECT MANAGER" | "CR SPONSOR" | "AIPSG DATE"
  Values: gblDetailCR.ProgrammeName | .Supplier | .SupplierReference | .ProjectManager.DisplayName | .CRSponsor.DisplayName | Text(gblDetailCR.AIPSGTargetDate,"dd mmm yyyy")

SECTION: "CR DESCRIPTION" (navy header label, white body)
  Label showing gblDetailCR.CRDescription

SECTION: "REASON FOR CHANGE" (Visible=Not(IsBlank(gblDetailCR.ReasonForChange)))
  Label showing gblDetailCR.ReasonForChange

SECTION: "DO NOTHING OPTION" (Visible=Not(IsBlank(gblDetailCR.DoNothingOption)))
  Label showing gblDetailCR.DoNothingOption

COST IMPACT BAR (navy background, horizontal layout, 60px height):
  Label "COST IMPACT" | 
  "RE Δ (1 a/c)" sublabel + value | 
  "NRE Δ" sublabel + value | 
  "Total Cost Δ" sublabel + value (teal/highlighted) |
  "Weight Δ (1 a/c)" sublabel + value | 
  "Weight Δ (all a/c)" sublabel + value |
  "Annual CoW Impact" sublabel + value
  All showing gblDetailCR field values, "NA" if blank.

CR STATUS BAR (navy background, 60px height, horizontal):
  Label "CR STATUS" |
  Horizontal Gallery bound to Filter(CRStakeholderReviews, CRNumber.CRNumber=gblDetailCR.CRNumber)
  Each item: StakeholderGroup label (white 10pt) + RAG colour rectangle (40x30px):
    Switch(RAGStatus,"Green",AccentGreen,"Amber",AccentAmber,"Red",AccentRed,"Grey",NeutralGrey,PaleBlue)

ATTACHMENTS: Native attachments control at bottom.

"Mark Ready for SG" OnSelect logic:
If(CountRows(Filter(CRStakeholderReviews, 
    CRNumber.CRNumber=gblDetailCR.CRNumber, RAGStatus="Pale Blue"))>0,
  Notify("Cannot proceed — " & 
    Text(CountRows(Filter(CRStakeholderReviews, CRNumber.CRNumber=gblDetailCR.CRNumber, RAGStatus="Pale Blue"))) &
    " stakeholder group(s) are still Pale Blue. All assessments must be complete before SG distribution.",
    NotificationType.Error),
  Patch(CRRequests, gblDetailCR, {CRStatus:"Pre-SG Distribution"});
  PowerAutomateFlow_PreSG.Run(gblDetailCR.CRNumber);
  Set(gblDetailCR, LookUp(CRRequests, CRNumber=gblDetailCR.CRNumber));
  Notify("CR marked ready for Pre-SG Distribution.", NotificationType.Success)
)

--- SCREEN 5: scrStakeholderAssessment ---
HEADER BAR + SUB-NAV BAR: Same pattern. Back = Navigate(scrCRDetail,None).

CR IDENTIFICATION ROW: Same 6-column header as scrCRDetail.

PALE BLUE WARNING BANNER (Visible when any Pale Blue remains):
Background=RGBA(174,214,241,0.3), border=PaleBlue, full width, 40px height.
Text="⚠  " & Text(CountRows(Filter(CRStakeholderReviews, CRNumber.CRNumber=gblDetailCR.CRNumber, RAGStatus="Pale Blue"))) & " stakeholder group(s) still showing Pale Blue. All must be updated before this CR can go to the SG."

STAKEHOLDER TABLE HEADER (navy background):
  "STAKEHOLDER" (200px) | "RAG" (80px) | "IMPACT STATEMENT" (flexible) | "REVIEWER" (150px) | "DATE" (100px)

GALLERY (vertical, one row per stakeholder group):
Items = Filter(CRStakeholderReviews, CRNumber.CRNumber=gblDetailCR.CRNumber)
Row height: 80px, alternating white/#F9F9F9

Each row:
- StakeholderGroup label: 200px, 13pt bold, NavyPrimary, left-padded
- RAG Dropdown: 80px, Items=If(ThisItem.StakeholderGroup="Other",
    ["Pale Blue","Green","Amber","Red","Grey"],["Pale Blue","Green","Amber","Red"]),
  Default=ThisItem.RAGStatus,
  Background colour matching RAG selection,
  DisplayMode=If(gblIsPMO Or gblStakeholderGroup=ThisItem.StakeholderGroup, Edit, View)
- Impact Statement TextInput (multiline): flexible width, 
  Default=ThisItem.ImpactStatement,
  DisplayMode=If(gblIsPMO Or gblStakeholderGroup=ThisItem.StakeholderGroup, Edit, View)
- Reviewer label/input: 150px, 
  Default=If(IsBlank(ThisItem.Reviewer.DisplayName), User().FullName, ThisItem.Reviewer.DisplayName),
  DisplayMode same as above
- ReviewDate label: 100px, Text(ThisItem.ReviewDate,"dd mmm yyyy"), TextMuted 11pt

COMMENTS section (bottom): 
  Label "Comments:" (navy bold) + Multiline TextInput bound to CRRequests.PMONotes
  Visible=gblIsPMO

SAVE button (AccentGreen, "Save Stakeholder Reviews", bottom-right):
ForAll(galStakeholderRows.AllItems,
  Patch(CRStakeholderReviews,
    LookUp(CRStakeholderReviews, CRNumber.CRNumber=gblDetailCR.CRNumber And StakeholderGroup=ThisRecord.StakeholderGroup),
    {RAGStatus: ThisRecord.galRAGDDL.Selected.Value,
     ImpactStatement: ThisRecord.txtImpactStatement.Text,
     Reviewer: {Claims:"i:0#.f|membership|"&User().Email, DisplayName:User().FullName},
     ReviewDate: Today(),
     IsComplete: Not(ThisRecord.galRAGDDL.Selected.Value="Pale Blue") And Not(IsBlank(ThisRecord.txtImpactStatement.Text))}
  )
);
Notify("Stakeholder reviews saved.", NotificationType.Success)

--- SCREEN 6: scrPMOConsolidation --- (Visible: gblIsPMO only, redirect to home if not)

HEADER + SUB-NAV: Same pattern.

OVERDUE BANNER (Visible=CountRows(Filter(CRRequests, SubmissionDeadline<Today(), Not(IsDraft), CRStatus="Submitted"))>0):
AccentRed background, white text: Text(CountRows(...)) & " CR(s) are past their submission deadline and have not been reviewed by PMO."

TWO-PANEL LAYOUT:

LEFT PANEL (400px wide, white, scrollable):
  Header: "CRs Requiring Action" (navy, 40px)
  Vertical Gallery: Filter(CRRequests, CRStatus In ["Submitted","PMO Review","In Assessment","PMO Consolidation"])
  Each row shows: CRNumber | Title | Status pill | AIPSG date
  OnSelect: Set(gblConsolidationCR, ThisItem)

RIGHT PANEL (fills remaining width, light grey background):
  When gblConsolidationCR is blank: "Select a CR from the left panel"
  When selected, shows:
  - CR title and number (navy header)
  - RAG summary: 4 count badges (Green/Amber/Red/PaleBlue counts from CRStakeholderReviews)
  - Stakeholder rows (read-only view, same layout as Part B but View mode)
  - "Consolidation Notes" TextInput (multiline, 100px, for PMO summary)
  - Action buttons:
    "Accept & Distribute" (AccentGreen): Patch status to "In Assessment"; run Flow2
    "Return to Owner" (NeutralGrey): Patch status to "Submitted" + add return note
    "Mark Ready for SG" (NavyPrimary): Pale Blue block check then advance to "Pre-SG Distribution"

--- SCREEN 7: scrProgrammeMeeting ---

HEADER + SUB-NAV: Same pattern. Sub-title: "Programme Meeting View"

Filter: Dropdown for AIPSG date (default = nearest upcoming Tuesday)

Gallery: Filter(CRRequests, CRStatus="Programme Meeting")
Card layout (larger cards, 140px height, white with navy left-border 4px):
  - CRNumber + Title (bold)
  - Programme name + Project Manager
  - RAG status mini-bar (horizontal, 6 coloured squares, 20x20px each)
  - Attendance toggle: "✓ Owner Attending" / "⚠ Delegate:" + name input
  - Action buttons (PMO only): "Defer This CR" (NeutralGrey) | "Proceed to Pre-SG" (AccentGreen)

"Defer This CR" OnSelect:
Patch(CRRequests, ThisItem, {CRStatus:"Deferred", SGDecisionNotes:"Deferred at Programme Meeting - no attendance"});
Notify(ThisItem.CRNumber & " deferred — no attending owner or delegate.", NotificationType.Warning)

"Proceed to Pre-SG" OnSelect:
If(Not(ThisItem.AttendanceConfirmed) And IsBlank(ThisItem.DelegateAttending),
  Notify("Cannot proceed — no attendance confirmed. Per CR Process Guide V1, a CR with no attending owner or delegate cannot be discussed and must be deferred.", NotificationType.Warning),
  Patch(CRRequests, ThisItem, {CRStatus:"Pre-SG Distribution"});
  PowerAutomateFlow_PreSG.Run(ThisItem.CRNumber);
  Notify(ThisItem.CRNumber & " moved to Pre-SG Distribution.", NotificationType.Success)
)

--- SCREEN 8: scrDashboard ---

HEADER + SUB-NAV: Same pattern.

ROW 1 — TOP COUNTS (3 tiles, equal width, NeutralGrey fill):
  All: CountRows(CRRequests)
  Open: CountRows(Filter(CRRequests, Not(CRStatus In ["Closed","Rejected","Approved"])))
  Closed: CountRows(Filter(CRRequests, CRStatus In ["Closed","Rejected","Approved"]))

ROW 2 — STATUS TILES (navy fill, scrollable horizontal):
  Draft | Submitted | In Assessment | PMO Consolidation | Programme Meeting | SG Review | Approved | Rejected | Deferred
  Each: CountRows(Filter(CRRequests, CRStatus=<value>))

ROW 3 — COMPLIANCE (3 tiles):
  On Track (AccentGreen): AIPSGTargetDate>DateAdd(Today(),14,Days) And status not closed
  Due ≤ 2 Weeks (AccentAmber): AIPSGTargetDate<=DateAdd(Today(),14,Days) And >=Today()
  Overdue (AccentRed): AIPSGTargetDate<Today() And status not closed/approved/rejected

ROW 4 — RAG HEALTH (4 tiles using RAG colours):
  All Green | Has Amber | Has Red | Pale Blue Outstanding
  Counts from CRStakeholderReviews joined to open CRs

ROW 5 — PROGRAMME TABLE:
  HTML Text control or Data Table, bound to colProgrammeStats (ClearCollect on OnVisible):
  Columns: Programme | Open | In Assessment | SG Ready | Approved | Rejected
  Dark navy header row, alternating white rows, 13pt Segoe UI

--- SCREEN 9: scrUserAdmin --- (redirect to scrHome if Not(gblIsAdmin))

HEADER + SUB-NAV: Same pattern.

SEARCH: TextInput at top "Search by name..."

GALLERY: Filter(CRUserAdmin, IsBlank(txtUserSearch.Text) Or txtUserSearch.Text in Title)
Each row (60px):
  - Name label (bold, 200px)
  - Team/role info (TextMuted, 150px)
  - Role badge rectangle (70x24, AccentRed for Admin, NavyPrimary for PMO/ProgMgr, AccentGreen for Stakeholder)
  - StakeholderGroup badge (if applicable, NeutralGrey pill)
  - Expand chevron

Expanded row shows:
  Email | Edit Role dropdown | Edit StakeholderGroup dropdown | IsActive toggle | Save button

Save: Patch(CRUserAdmin, ThisItem, {Role: ddlEditRole.Selected.Value, StakeholderGroup: ddlEditGroup.Selected.Value, IsActive: togActive.Value})
Notify("User updated.", NotificationType.Success)

Now generate all YAML source files using the Power Platform Canvas YAML format.
Each screen goes in Src/<screenname>.fx.yaml
App.OnStart goes in Src/App.fx.yaml  
CanvasManifest.json defines the app metadata.
DataSources/*.json defines each SharePoint list connection.
Use exact Power Apps YAML control schema with As, =, and - syntax.
```

---

## Part 4 — Running the Build

### 4.1 Create the Project Folder

After Claude Code generates all the source files, you'll have a `CRTool/` folder. Run:

```bash
# Navigate to the folder Claude Code created:
cd ~/CRTool

# Verify the structure:
ls -la Src/
# Should show: App.fx.yaml, scrHome.fx.yaml, scrViewCRs.fx.yaml ... (9 screens)
```

### 4.2 Pack the App into a .msapp File

```bash
pac canvas pack \
  --sources ./CRTool \
  --msapp ./CRTool_v1.msapp
```

If successful, you'll see:
```
Successfully created CRTool_v1.msapp
```

If there are errors, Claude Code reads the error output and fixes the YAML files automatically. Re-run `pac canvas pack` after each fix.

### 4.3 Import into Power Apps Studio

1. Go to **make.powerapps.com**
2. Click **"+ New app"** → **"Import canvas app"**
3. Upload `CRTool_v1.msapp`
4. The app opens in Studio with all 9 screens pre-built

### 4.4 Connect the Data Sources

After import, Power Apps will show "Data source not found" warnings for the SharePoint lists. Fix this once:

1. In Power Apps Studio, click **Data** (left sidebar, cylinder icon)
2. Click **"+ Add data"**
3. Search for **SharePoint**
4. Paste your SharePoint site URL: `https://[tenant].sharepoint.com/sites/BA-CR-Tool`
5. Select all 4 lists: CRRequests, CRStakeholderReviews, CRUserAdmin, AIPSGMeetings
6. Click **Connect**

Power Apps will re-map all the data source references automatically.

### 4.5 Add the BA Logo

1. In Power Apps Studio, click the **Media** tab (left sidebar)
2. Upload `BALogo.png` (the BA speedbird image)
3. The logo will appear automatically in all header bars where it is referenced

---

## Part 5 — Iteration with Claude Code

The biggest advantage of the source-code approach is that changes are trivial. Instead of clicking around the studio, you tell Claude Code what to change and re-pack.

### Example iterations:

**Change a colour:**
```
In scrViewCRs.fx.yaml, find the "Submitted" status pill fill colour and change it 
from RGBA(110,140,176,1) to RGBA(31,55,100,1). Then run pac canvas pack.
```

**Add a new field:**
```
Add a new field "CRCategory" (Dropdown: Regulatory/Commercial/Safety/Operational/Technical) 
to scrSubmitCR after the CR Title field. Add the corresponding column to the CRRequests 
SharePoint list connection in DataSources/CRRequests.json. Pack the app.
```

**Fix a formula:**
```
The Pale Blue block in scrCRDetail is not firing. Review the OnSelect formula on 
btnMarkReadyForSG in scrCRDetail.fx.yaml and fix the CountRows filter logic. Pack and test.
```

Each fix takes seconds in Claude Code vs. minutes clicking through Power Apps Studio.

---

## Part 6 — Setting Up the Power Automate Flows

The 4 flows must be built manually in Power Automate (make.powerautomate.com). Claude Code can generate the full JSON definition of each flow, which you import directly.

### Flow 1: CR-OnSubmit-NotifyPMO

**Claude Code prompt for this flow:**
```
Generate a Power Automate flow JSON definition for a flow called "CR-OnSubmit-NotifyPMO".
Trigger: SharePoint "When an item is created" on list CRRequests at site https://[tenant].sharepoint.com/sites/BA-CR-Tool
Condition: IsDraft equals false
Action: Send an email (V2) to [pmo-email@ba.com] with:
  Subject: "New CR Submitted: " + CRNumber + " — " + Title
  Body: HTML formatted with CR details and a link to the Power App
```

Import the generated JSON: Power Automate → My Flows → Import → Upload the JSON file.

### Flow 2: CR-OnDistribute-CreateStakeholderRows

**Claude Code prompt:**
```
Generate a Power Automate flow JSON for "CR-OnDistribute-CreateStakeholderRows".
Trigger: SharePoint "When an item is modified" on CRRequests
Condition: CRStatus equals "In Assessment"
Actions:
1. Initialize variable "StakeholderGroups" as Array: ["Engineering Programmes","Engineering Technical","Onboard Experience","Finance","Procurement","Other"]
2. Apply to each item in StakeholderGroups array:
   - Condition: Check if a row exists in CRStakeholderReviews where CRNumber lookup = current CRNumber AND StakeholderGroup = current array item
   - If no: Create item in CRStakeholderReviews with Title=CRNumber+"-"+StakeholderGroup, RAGStatus="Pale Blue", IsComplete=false
3. After loop: Send email to each stakeholder group distribution address notifying them to review
```

### Flow 3: CR-OnPreSGDistribution-EmailSGAttendees

```
Generate flow JSON for "CR-OnPreSGDistribution-EmailSGAttendees".
Trigger: SharePoint "When item modified" on CRRequests
Condition: CRStatus equals "Pre-SG Distribution"
Action: Get items from CRUserAdmin where Role contains "Steering Group" or "PMO"
Apply to each: Send email with CR details and link to app, subject "SG Review Required: " + CRNumber
```

### Flow 4: CR-WeeklyReminder-Monday

```
Generate flow JSON for "CR-WeeklyReminder-Monday".
Trigger: Recurrence, every week on Monday at 07:30 AM GMT
Actions:
1. Get items from CRRequests where CRStatus not in [Closed, Approved, Rejected] and AIPSGTargetDate <= DateAdd(utcNow(), 7, 'day')
2. For each CR: Get count of CRStakeholderReviews rows where RAGStatus = "Pale Blue"
3. Build HTML table of outstanding items
4. Send email to [nainksha.rahate@ba.com] with subject "Weekly CR Status Digest - Monday " + formatDateTime(utcNow(), 'dd MMM yyyy')
```

---

## Part 7 — The Generate Slide Flow

This is the most impactful automation. Claude Code generates the Office Script and the Power Automate flow.

### 7.1 Prepare the PowerPoint Template

1. Open the existing CR slide template
2. Replace every dynamic value with a placeholder in double curly braces:
   - `{{CR_NUMBER}}` in the title
   - `{{PROGRAMME_NAME}}` in the header
   - `{{CR_SPONSOR}}` in the header
   - `{{CR_DESCRIPTION}}` in the body
   - `{{COST_RE_DELTA}}`, `{{COST_NRE_DELTA}}`, `{{COST_TOTAL}}` in the cost bar
   - `{{RAG_ENG_PROG}}`, `{{IMPACT_ENG_PROG}}` for Engineering Programmes row
   - `{{RAG_ENG_TECH}}`, `{{IMPACT_ENG_TECH}}` for Engineering Technical row
   - `{{RAG_OBX}}`, `{{IMPACT_OBX}}` for Onboard Experience row
   - `{{RAG_FINANCE}}`, `{{IMPACT_FINANCE}}` for Finance row
   - `{{RAG_PROCUREMENT}}`, `{{IMPACT_PROCUREMENT}}` for Procurement row
   - `{{RAG_OTHER}}`, `{{IMPACT_OTHER}}` for Other row
3. Save as `CR_Template_Master.pptx` in the `CR-Templates` SharePoint library

### 7.2 Claude Code Prompt for the Generate Slide Flow

```
Generate a Power Automate flow JSON for "CR-GenerateSlide".
Trigger: HTTP Request (so Power Apps can call it via PowerAutomateFlow_GenerateSlide.Run(CRNumber))
Input parameter: CRNumber (string)

Actions:
1. Get item from CRRequests where CRNumber = triggerBody CRNumber
2. Get items from CRStakeholderReviews where CRNumber lookup = that CR's ID
3. Copy file "CR_Template_Master.pptx" from CR-Templates library to CR-Files library, 
   rename to: CRNumber + " - " + ProgrammeName + " - " + CRTitle + ".pptx"
4. Run Office Script "ReplacePlaceholders" on the copied file, passing all CR field values 
   and the 6 stakeholder RAG statuses and impact statements as parameters
5. Return the SharePoint URL of the generated file

The Office Script "ReplacePlaceholders" should:
- Accept all the CR field values as parameters
- Loop through all shapes on all slides
- For each shape with a text frame, replace any {{PLACEHOLDER}} text with the corresponding value
- For RAG colour shapes, find shapes named "RAG_[STAKEHOLDER]" and set their fill colour:
  Green=RGB(39,174,96), Amber=RGB(243,156,18), Red=RGB(192,57,43), Grey=RGB(149,165,166), Pale Blue=RGB(174,214,241)
```

---

## Part 8 — Testing Checklist Before Go-Live

Run through these with Claude Code monitoring the terminal output:

```bash
# 1. Validate the packed app before importing:
pac canvas validate --msapp ./CRTool_v1.msapp

# 2. Check for any formula errors (pac outputs warnings):
pac canvas pack --sources ./CRTool --msapp ./CRTool_v1.msapp --verbose

# 3. After import, run the app in preview mode and test each scenario:
```

| Test | What to check |
|---|---|
| Submit a Draft CR | IsDraft=true, CRStatus="Draft", no flows triggered |
| Submit Formally | IsDraft=false, CRStatus="Submitted", PMO receives email, CR Number zero-padding enforced |
| PMO accepts CR | CRStatus changes to "In Assessment", 6 Pale Blue rows created automatically |
| Stakeholder reviews own row only | Engineering Technical user cannot edit Finance row |
| Pale Blue block | "Mark Ready for SG" button refuses with error if any Pale Blue row exists |
| All Green | "Mark Ready for SG" succeeds, flow sends SG emails |
| Attendance block | Programme Meeting screen refuses "Proceed to Pre-SG" if no attendance confirmed |
| Generate Slide | PPTX produced with correct CR data and RAG colours |
| Weekly Monday email | Digest email arrives with correct outstanding items |
| Dashboard counts | All tiles reflect actual list counts accurately |
| User Admin | Admin can edit roles; non-Admin redirected to Home |

---

## Part 9 — Maintenance with Claude Code

Once live, any change is a Claude Code conversation:

**Add a new field to a screen:**
```
Open scrSubmitCR.fx.yaml and add a new optional field "CRPriority" 
(Dropdown: Critical/High/Medium/Low) after the AIPSG Target Date field. 
Also add CRPriority to the Patch call in the Submit button OnSelect. 
Pack the app and show me the diff.
```

**Change a deadline rule:**
```
The submission deadline is moving from COB Wednesday to COB Tuesday. 
Find all references to SubmissionDeadline in the app source and update 
any deadline calculation or display logic. Pack and validate.
```

**Add a new screen:**
```
Add a new screen scrImplementationTracking between scrProgrammeMeeting and scrDashboard.
It should show all CRs with CRStatus = "Approved" with fields for tracking 
implementation progress. Add a navigation button for it on scrHome.
```

Each of these takes Claude Code under a minute. The same change manually in Power Apps Studio would take 20–30 minutes.

---

## Summary: The Build Sequence

```
Day 1 (2–3 hours):
  └── Install pac CLI
  └── Run Claude Code prompt from Part 3
  └── Claude Code generates all YAML source files
  └── pac canvas pack → CRTool_v1.msapp
  └── Import into Power Apps Studio
  └── Connect SharePoint data sources
  └── Upload BA logo
  └── First working app in Studio

Day 2 (3–4 hours):
  └── Build 4 Power Automate flows using Claude Code JSON generation
  └── Import and test each flow
  └── Wire flow buttons in app (update formula references)
  └── Re-pack and re-import

Day 3 (2–3 hours):
  └── Prepare PPTX template with placeholders
  └── Build Generate Slide flow + Office Script
  └── End-to-end test of full lifecycle

Day 4:
  └── UAT with Nainksha and 2 Programme Managers
  └── Claude Code fixes from feedback (minutes per fix)
  └── Go live
```

Total estimated build time with this approach: **4 working days** vs 3–4 weeks manually in Power Apps Studio.
