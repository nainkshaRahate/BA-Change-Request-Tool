# BA CR Tool — SharePoint Lists Setup Guide

## Context for Claude

You are helping set up SharePoint lists for the **BA Cabin Programme Change Request (CR) Tool** — a Power Apps Canvas App that tracks engineering change requests through a 10-step workflow.

The app is built and ready. It connects to **4 SharePoint lists** on this site:
**`https://baplc.sharepoint.com/sites/Engprog`**

Your job is to walk the user through creating all 4 lists and their columns in the SharePoint browser UI. The user cannot run scripts — everything must be done manually through the SharePoint web interface.

---

## Current Status

| List | Status |
|---|---|
| CRRequests | ✅ List created, no columns yet |
| CRStakeholderReviews | ❌ Not created |
| CRUserAdmin | ❌ Not created |
| AIPSGMeetings | ❌ Not created |

Start with **CRRequests** (list already exists, just needs columns), then create the other three.

---

## How to add a column in SharePoint

1. Open the list → click **+ Add column** (top right of the column headers)
2. Choose the column type
3. Fill in the name and settings
4. Click **Save**

For **Choice** columns: enter each choice value on a separate line in the Choices box.

---

---

# LIST 1: CRRequests

**URL:** `https://baplc.sharepoint.com/sites/Engprog/Lists/CRRequests`

The list already exists. Do the following:

## Step 1 — Rename the default Title column

- Click the **Title** column header → **Column settings → Rename**
- New name: `CR Title (Formatted)`
- This field stores the auto-formatted display title: e.g. `A380: CR123 - UPPER DESK CABIN BED`

## Step 2 — Add columns (in this order)

### Single line of text columns

| Display Name | Required | Notes |
|---|---|---|
| CR Number | ✅ Yes | e.g. CR123, CR05 |
| Programme Code | ✅ Yes | e.g. A380, A32X |
| Programme Name | ✅ Yes | e.g. A380 Vector |
| CR Title | ✅ Yes | Free text title component e.g. UPPER DESK CABIN BED |
| Supplier | No | e.g. Airbus, NAT, BA |
| Supplier Reference | No | e.g. L Bins Offer |
| RE Delta Per Aircraft | No | Text — allows $3,897 / NA / TBC |
| NRE Delta | No | Text — allows values or NA/TBC |
| Total Cost Delta | No | Text — allows values or NA/TBC |
| Weight Delta Per Aircraft | No | Text |
| Weight Delta All Aircraft | No | Text |
| Annual CoW Impact | No | Text |
| Delegate Attending | No | Name of delegate if CR Owner cannot attend Programme Meeting |

### Multiple lines of text columns

| Display Name | Required | Notes |
|---|---|---|
| CR Description | ✅ Yes | Main description of the change request |
| Reason For Change | No | Why this change is needed |
| Do Nothing Option | No | What happens if the CR is not approved |
| Additional Information | No | Any other relevant information |
| PMO Notes | No | Internal PMO notes — not visible to CR Owners |
| SG Decision Notes | No | Notes from the Steering Group decision |

### Person or Group columns

| Display Name | Required | Notes |
|---|---|---|
| Project Manager | ✅ Yes | |
| CR Sponsor | ✅ Yes | |
| Originator | ✅ Yes | Auto-populated on submission |

### Date and time columns

**Important:** For all date columns, set format to **Date only** (not Date & Time).

| Display Name | Required | Notes |
|---|---|---|
| AIPSG Target Date | ✅ Yes | The Tuesday SG meeting date this CR targets |
| Submission Deadline | No | The Wednesday before AIPSG Target Date |
| Submitted Date | No | Auto-populated when CR is formally submitted |
| Closed Date | No | Set when CR Status = Closed |

### Choice columns

**CR Status** (Required)
- Default value: `Draft`
- Choices (enter each on a new line):
```
Draft
Submitted
PMO Review
In Assessment
PMO Consolidation
Programme Meeting
Pre-SG Distribution
SG Review
Post-Meeting Edits
Approved
Deferred
Rejected
Closed
```

**Cost Currency** (Not required)
- Default value: `USD`
- Choices:
```
USD
GBP
EUR
```

**SG Decision** (Not required)
- No default value
- Choices:
```
Approved
Deferred
Rejected
```

### Yes/No columns

| Display Name | Default Value | Notes |
|---|---|---|
| Is Draft | Yes | True = Draft/Pipeline. False = formally submitted |
| Attendance Confirmed | No | CR Owner confirmed attendance at Programme Meeting |
| Is Confidential | No | Marks CR as CONFIDENTIAL vs INTERNAL |
| Is Active | Yes | Deactivate rather than delete |

## Step 3 — Enable Version History

- Go to **List Settings** (gear icon → List Settings)
- Click **Versioning settings**
- Select **Create a version each time you edit an item in this list**
- Click **OK**

---

---

# LIST 2: CRStakeholderReviews

**How to create:** Go to `https://baplc.sharepoint.com/sites/Engprog` → **New → List → Blank list**
- Name: `CRStakeholderReviews`
- Click **Create**

This list holds one row per stakeholder group per CR (6 rows per CR). It is created automatically by Power Automate when a CR moves to "In Assessment".

## Columns to add

### Lookup column

**CR Number** (Required)
- Type: **Lookup**
- Get information from: **CRRequests**
- In this column: **CR Number**

### Choice columns

**Stakeholder Group** (Required)
- No default
- Choices:
```
Engineering Programmes
Engineering Technical
Onboard Experience
Finance
Procurement
Other
```

**RAG Status** (Required)
- Default value: `Pale Blue`
- Choices:
```
Pale Blue
Green
Amber
Red
Grey
```

> RAG meaning: Green = acceptable, Amber = adds risk, Red = unacceptable, Grey = not applicable, Pale Blue = not yet reviewed (default)

### Multiple lines of text columns

| Display Name | Required | Notes |
|---|---|---|
| Impact Statement | No | Required before RAG can be changed from Pale Blue |

### Person or Group columns

| Display Name | Required | Notes |
|---|---|---|
| Reviewer | No | The individual who completed the review |

### Date and time columns (Date only)

| Display Name | Required | Notes |
|---|---|---|
| Review Date | No | Auto-set when review is saved |

### Yes/No columns

| Display Name | Default | Notes |
|---|---|---|
| Is Applicable | Yes | If No, RAG is set to Grey automatically |
| Is Complete | No | True when RAG ≠ Pale Blue and Impact Statement is filled |

---

---

# LIST 3: CRUserAdmin

**How to create:** Go to `https://baplc.sharepoint.com/sites/Engprog` → **New → List → Blank list**
- Name: `CRUserAdmin`
- Click **Create**

This is a small reference list that controls who can do what in the app. The default **Title** column stores the user's full name.

## Columns to add

### Single line of text columns

| Display Name | Required | Notes |
|---|---|---|
| Email | ✅ Yes | Must match the user's Microsoft 365 email exactly |
| Team | No | e.g. Cabin Design, Finance |

### Choice columns

**Role** (Required)
- Default value: `Stakeholder`
- Choices:
```
Admin
PMO
Programme Manager
Stakeholder
```

**Stakeholder Group** (Not required)
- No default — only set for users with Role = Stakeholder
- Choices:
```
Engineering Programmes
Engineering Technical
Onboard Experience
Finance
Procurement
Other
```

### Yes/No columns

| Display Name | Default | Notes |
|---|---|---|
| Is Active | Yes | Deactivate rather than delete when someone leaves |

## After creating the list — add your first Admin user

Add a new item:
- **Title:** Your full name
- **Email:** Your BA email address
- **Role:** Admin
- **Is Active:** Yes

---

---

# LIST 4: AIPSGMeetings

**How to create:** Go to `https://baplc.sharepoint.com/sites/Engprog` → **New → List → Blank list**
- Name: `AIPSGMeetings`
- Click **Create**

This is a tiny reference list. CR Owners pick a meeting date from this list rather than entering free-form dates. The default **Title** column stores the meeting name (e.g. "April 2026 AIPSG").

## Columns to add

### Date and time columns (all Date only)

| Display Name | Required | Notes |
|---|---|---|
| Meeting Date | ✅ Yes | The Tuesday SG meeting date |
| Submission Deadline | No | The preceding Wednesday |
| Pre-SG Distribution Date | No | The preceding Monday morning |

### Yes/No columns

| Display Name | Default | Notes |
|---|---|---|
| Is Active | Yes | Hide past meetings from the dropdown in the app |

## After creating the list — add these initial meeting dates

Add one item per row:

| Title | Meeting Date | Submission Deadline | Pre-SG Distribution Date | Is Active |
|---|---|---|---|---|
| April 2026 AIPSG | 08/04/2026 | 01/04/2026 | 06/04/2026 | Yes |
| May 2026 AIPSG | 13/05/2026 | 06/05/2026 | 11/05/2026 | Yes |
| June 2026 AIPSG | 10/06/2026 | 03/06/2026 | 08/06/2026 | Yes |
| July 2026 AIPSG | 08/07/2026 | 01/07/2026 | 06/07/2026 | Yes |
| August 2026 AIPSG | 12/08/2026 | 05/08/2026 | 10/08/2026 | Yes |

---

---

# Final Checklist

Once all 4 lists are created:

- [ ] CRRequests — all 32 columns added, version history enabled
- [ ] CRStakeholderReviews — all 8 columns added, CRNumber lookup confirmed
- [ ] CRUserAdmin — all 5 columns added, first Admin user added
- [ ] AIPSGMeetings — all 4 columns added, 5 meeting dates entered

Then in **Power Apps Studio**:
1. Open the CR Tool app
2. Go to **Data → Add data → SharePoint**
3. Connect to `https://baplc.sharepoint.com/sites/Engprog`
4. Select all 4 lists
5. Replace the existing placeholder connections with the live ones
6. Save and publish
