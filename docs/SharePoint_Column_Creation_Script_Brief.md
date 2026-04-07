# SharePoint Column Creation — JavaScript API Brief

## Context for Claude

You are helping set up SharePoint columns for the **BA Cabin Programme Change Request (CR) Tool** — a Power Apps Canvas App.

The app formulas reference columns by their **SharePoint internal (static) name**, which is fixed at the time the column is first created. The columns were previously created through the SharePoint UI using display names with spaces (e.g. "CR Number"), which caused SharePoint to generate internal names like `CR_x0020_Number`. The app cannot find these columns and shows formula errors.

**The fix:** Delete the incorrectly named columns and recreate them using the JavaScript API, which allows us to set the `StaticName`/`InternalName` explicitly to the camelCase names the app expects (e.g. `CRNumber`).

---

## SharePoint Site

```
https://baplc.sharepoint.com/sites/Engprog
```

---

## Instructions for Claude

Please write a **browser console JavaScript script** (using the SharePoint REST API, no external libraries) that:

1. Deletes each of the listed columns (if they exist) from the relevant list
2. Recreates each column with the correct `StaticName` and `Title` (display name) as specified
3. Handles each list in sequence
4. Logs success/failure for each column to the console

The script should be runnable by pasting it into the browser console while on the SharePoint site (`https://baplc.sharepoint.com/sites/Engprog`).

Use `fetch` with the SharePoint REST API (`/_api/web/lists/getbytitle('{ListName}')/fields`).

To create a column with a specific internal name, POST to:
```
/_api/web/lists/getbytitle('{ListName}')/fields
```
with body including `__metadata`, `Title`, `StaticName`, `FieldTypeKind`, and any other relevant properties.

To delete a field by display name, use:
```
/_api/web/lists/getbytitle('{ListName}')/fields/getbytitle('{DisplayName}')
```
with `DELETE` and `IF-MATCH: *` header.

Use the `X-RequestDigest` from `/_api/contextinfo` for write operations.

---

## List 1: CRRequests

These columns need to be deleted (by current display name) and recreated with the exact `StaticName` shown.

> **Do not touch** the `Title` column (already exists as default) or `Supplier` or `Originator` (these have no spaces and are already correct).

### Single line of text (`FieldTypeKind: 2`)

| Current Display Name (delete) | New StaticName | New Display Name (Title) |
|---|---|---|
| CR Number | `CRNumber` | CR Number |
| Programme Code | `ProgrammeCode` | Programme Code |
| Programme Name | `ProgrammeName` | Programme Name |
| CR Title | `CRTitle` | CR Title |
| Supplier Reference | `SupplierReference` | Supplier Reference |
| RE Delta Per Aircraft | `RE_Delta_PerAircraft` | RE Delta Per Aircraft |
| NRE Delta | `NRE_Delta` | NRE Delta |
| Total Cost Delta | `TotalCostDelta` | Total Cost Delta |
| Weight Delta Per Aircraft | `WeightDelta_PerAircraft` | Weight Delta Per Aircraft |
| Weight Delta All Aircraft | `WeightDelta_AllAircraft` | Weight Delta All Aircraft |
| Annual CoW Impact | `AnnualCoWImpact` | Annual CoW Impact |
| Delegate Attending | `DelegateAttending` | Delegate Attending |

### Multiple lines of text (`FieldTypeKind: 3`)

| Current Display Name (delete) | New StaticName | New Display Name (Title) |
|---|---|---|
| CR Description | `CRDescription` | CR Description |
| Reason For Change | `ReasonForChange` | Reason For Change |
| Do Nothing Option | `DoNothingOption` | Do Nothing Option |
| Additional Information | `AdditionalInformation` | Additional Information |
| PMO Notes | `PMONotes` | PMO Notes |
| SG Decision Notes | `SGDecisionNotes` | SG Decision Notes |

### Person or Group (`FieldTypeKind: 20`)

| Current Display Name (delete) | New StaticName | New Display Name (Title) |
|---|---|---|
| Project Manager | `ProjectManager` | Project Manager |
| CR Sponsor | `CRSponsor` | CR Sponsor |

### Date only (`FieldTypeKind: 4`, `DateTimeCalendarType: 0`, `DisplayFormat: 0`)

| Current Display Name (delete) | New StaticName | New Display Name (Title) |
|---|---|---|
| AIPSG Target Date | `AIPSGTargetDate` | AIPSG Target Date |
| Submission Deadline | `SubmissionDeadline` | Submission Deadline |
| Submitted Date | `SubmittedDate` | Submitted Date |
| Closed Date | `ClosedDate` | Closed Date |

### Choice (`FieldTypeKind: 6`)

**CR Status** — delete "CR Status", recreate as:
- StaticName: `CRStatus`
- Title: `CR Status`
- Choices: `["Draft","Submitted","PMO Review","In Assessment","PMO Consolidation","Programme Meeting","Pre-SG Distribution","SG Review","Post-Meeting Edits","Approved","Deferred","Rejected","Closed"]`
- DefaultValue: `Draft`

**Cost Currency** — delete "Cost Currency", recreate as:
- StaticName: `CostCurrency`
- Title: `Cost Currency`
- Choices: `["USD","GBP","EUR"]`
- DefaultValue: `USD`

**SG Decision** — delete "SG Decision", recreate as:
- StaticName: `SGDecision`
- Title: `SG Decision`
- Choices: `["Approved","Deferred","Rejected"]`
- DefaultValue: *(none)*

### Yes/No (`FieldTypeKind: 8`)

| Current Display Name (delete) | New StaticName | New Display Name (Title) | Default |
|---|---|---|---|
| Is Draft | `IsDraft` | Is Draft | `1` (Yes) |
| Attendance Confirmed | `AttendanceConfirmed` | Attendance Confirmed | `0` (No) |
| Is Confidential | `IsConfidential` | Is Confidential | `0` (No) |
| Is Active | `IsActive` | Is Active | `1` (Yes) |

---

## List 2: CRStakeholderReviews

> **Do not touch** `Title` (default) or `Reviewer` (already correct).

### Lookup (`FieldTypeKind: 7`)

**CR Number** — delete "CR Number", recreate as:
- StaticName: `CRNumber`
- Title: `CR Number`
- LookupList: `CRRequests` (look up the list ID dynamically)
- LookupField: `CRNumber`

### Choice (`FieldTypeKind: 6`)

**Stakeholder Group** — delete "Stakeholder Group", recreate as:
- StaticName: `StakeholderGroup`
- Title: `Stakeholder Group`
- Choices: `["Engineering Programmes","Engineering Technical","Onboard Experience","Finance","Procurement","Other"]`
- DefaultValue: *(none)*

**RAG Status** — delete "RAG Status", recreate as:
- StaticName: `RAGStatus`
- Title: `RAG Status`
- Choices: `["Pale Blue","Green","Amber","Red","Grey"]`
- DefaultValue: `Pale Blue`

### Multiple lines of text (`FieldTypeKind: 3`)

| Current Display Name (delete) | New StaticName | New Display Name (Title) |
|---|---|---|
| Impact Statement | `ImpactStatement` | Impact Statement |

### Date only (`FieldTypeKind: 4`, `DisplayFormat: 0`)

| Current Display Name (delete) | New StaticName | New Display Name (Title) |
|---|---|---|
| Review Date | `ReviewDate` | Review Date |

### Yes/No (`FieldTypeKind: 8`)

| Current Display Name (delete) | New StaticName | New Display Name (Title) | Default |
|---|---|---|---|
| Is Applicable | `IsApplicable` | Is Applicable | `1` (Yes) |
| Is Complete | `IsComplete` | Is Complete | `0` (No) |

---

## List 3: CRUserAdmin

> **Do not touch** `Title`, `Email`, `Team`, or `Role` (these are already correctly named — no spaces).

### Choice (`FieldTypeKind: 6`)

**Stakeholder Group** — delete "Stakeholder Group", recreate as:
- StaticName: `StakeholderGroup`
- Title: `Stakeholder Group`
- Choices: `["Engineering Programmes","Engineering Technical","Onboard Experience","Finance","Procurement","Other"]`
- DefaultValue: *(none)*

### Yes/No (`FieldTypeKind: 8`)

| Current Display Name (delete) | New StaticName | New Display Name (Title) | Default |
|---|---|---|---|
| Is Active | `IsActive` | Is Active | `1` (Yes) |

---

## List 4: AIPSGMeetings

> **Do not touch** `Title` (default).

### Date only (`FieldTypeKind: 4`, `DisplayFormat: 0`)

| Current Display Name (delete) | New StaticName | New Display Name (Title) |
|---|---|---|
| Meeting Date | `MeetingDate` | Meeting Date |
| Submission Deadline | `SubmissionDeadline` | Submission Deadline |
| Pre-SG Distribution Date | `PreSGDistributionDate` | Pre-SG Distribution Date |

### Yes/No (`FieldTypeKind: 8`)

| Current Display Name (delete) | New StaticName | New Display Name (Title) | Default |
|---|---|---|---|
| Is Active | `IsActive` | Is Active | `1` (Yes) |

---

## Important Notes

- **Order matters for CRStakeholderReviews Lookup**: The `CRNumber` column in `CRRequests` must exist (with StaticName `CRNumber`) before creating the lookup in `CRStakeholderReviews`.
- **If a column doesn't exist yet** (i.e. it was never created), skip the delete step and just create it.
- **If a column already has the correct StaticName**, skip it entirely.
- After running the script, go to Power Apps Studio → Data panel → hover over each SharePoint connection → click the refresh icon. The formula errors should resolve.
