#Requires -Modules PnP.PowerShell
<#
.SYNOPSIS
    Creates all 4 SharePoint lists for the BA CR Tool on the Engprog site.

.DESCRIPTION
    Creates CRRequests, CRStakeholderReviews, CRUserAdmin, and AIPSGMeetings
    with all columns, choice values, defaults, and version history enabled.

.NOTES
    Requires PnP.PowerShell module.
    Install: Install-Module PnP.PowerShell -Scope CurrentUser
    Run:     .\Create-CRToolLists.ps1
#>

$SiteUrl = "https://baplc.sharepoint.com/sites/Engprog"

Write-Host "Connecting to $SiteUrl..." -ForegroundColor Cyan
Connect-PnPOnline -Url $SiteUrl -Interactive

Write-Host "Connected. Creating CR Tool lists..." -ForegroundColor Green

# ─────────────────────────────────────────────────────────────────────────────
# HELPER FUNCTION
# ─────────────────────────────────────────────────────────────────────────────
function Add-ColumnIfNotExists {
    param(
        [string]$ListName,
        [string]$DisplayName,
        [string]$InternalName,
        [string]$Type,            # Text, Note, DateTime, Boolean, Choice, Lookup, User
        [bool]$Required = $false,
        [string]$DefaultValue = "",
        [string[]]$Choices = @(),
        [string]$LookupListName = "",
        [string]$LookupField = "Title",
        [bool]$RichText = $false
    )

    $existing = Get-PnPField -List $ListName -Identity $InternalName -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "  [skip] Column '$InternalName' already exists." -ForegroundColor DarkGray
        return
    }

    $params = @{
        List        = $ListName
        DisplayName = $DisplayName
        InternalName = $InternalName
        Required    = $Required
        AddToDefaultView = $true
    }

    switch ($Type) {
        "Text" {
            $params["Type"] = "Text"
        }
        "Note" {
            $params["Type"] = "Note"
            if ($RichText) { $params["RichText"] = $true }
        }
        "DateTime" {
            $params["Type"] = "DateTime"
            $params["DateOnly"] = $true
        }
        "Boolean" {
            $params["Type"] = "Boolean"
            if ($DefaultValue -ne "") { $params["DefaultValue"] = $DefaultValue }
        }
        "Choice" {
            $params["Type"] = "Choice"
            $params["Choices"] = $Choices
            if ($DefaultValue -ne "") { $params["DefaultValue"] = $DefaultValue }
        }
        "User" {
            $params["Type"] = "User"
        }
        "Lookup" {
            # Lookup columns need special handling via Add-PnPFieldFromXml
            $lookupList = Get-PnPList -Identity $LookupListName
            if (-not $lookupList) {
                Write-Warning "  Lookup list '$LookupListName' not found. Skipping '$InternalName'."
                return
            }
            $lookupListId = $lookupList.Id.ToString()
            $webId = (Get-PnPWeb).Id.ToString()
            $xml = @"
<Field Type="Lookup" DisplayName="$DisplayName" Name="$InternalName" StaticName="$InternalName"
  Required="$(if($Required){'TRUE'}else{'FALSE'})"
  List="{$lookupListId}" ShowField="$LookupField" />
"@
            Add-PnPFieldFromXml -List $ListName -FieldXml $xml | Out-Null
            Write-Host "  [+] Lookup '$InternalName' -> $LookupListName.$LookupField" -ForegroundColor Green
            return
        }
    }

    Add-PnPField @params | Out-Null
    Write-Host "  [+] $Type '$InternalName'" -ForegroundColor Green
}


# ═════════════════════════════════════════════════════════════════════════════
# LIST 1: CRRequests
# ═════════════════════════════════════════════════════════════════════════════
Write-Host "`n--- Creating CRRequests ---" -ForegroundColor Yellow

$listExists = Get-PnPList -Identity "CRRequests" -ErrorAction SilentlyContinue
if (-not $listExists) {
    New-PnPList -Title "CRRequests" -Template GenericList -EnableVersioning -OnQuickLaunch | Out-Null
    Write-Host "  [+] List 'CRRequests' created." -ForegroundColor Green
} else {
    Write-Host "  [skip] List 'CRRequests' already exists." -ForegroundColor DarkGray
    # Ensure version history is on
    Set-PnPList -Identity "CRRequests" -EnableVersioning $true
}

# Enable attachments (already on by default for GenericList, but ensure it)
Set-PnPList -Identity "CRRequests" -EnableAttachments $true

# --- Core identification columns ---
Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "CR Number" -InternalName "CRNumber" `
    -Type "Text" -Required $true

Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "Programme Code" -InternalName "ProgrammeCode" `
    -Type "Text" -Required $true

Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "Programme Name" -InternalName "ProgrammeName" `
    -Type "Text" -Required $true

Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "CR Title" -InternalName "CRTitle" `
    -Type "Text" -Required $true

Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "Supplier" -InternalName "Supplier" `
    -Type "Text" -Required $false

Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "Supplier Reference" -InternalName "SupplierReference" `
    -Type "Text" -Required $false

# --- People columns ---
Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "Project Manager" -InternalName "ProjectManager" `
    -Type "User" -Required $true

Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "CR Sponsor" -InternalName "CRSponsor" `
    -Type "User" -Required $true

Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "Originator" -InternalName "Originator" `
    -Type "User" -Required $true

# --- Date columns ---
Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "AIPSG Target Date" -InternalName "AIPSGTargetDate" `
    -Type "DateTime" -Required $true

Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "Submission Deadline" -InternalName "SubmissionDeadline" `
    -Type "DateTime" -Required $false

Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "Submitted Date" -InternalName "SubmittedDate" `
    -Type "DateTime" -Required $false

Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "Closed Date" -InternalName "ClosedDate" `
    -Type "DateTime" -Required $false

# --- Status choice columns ---
Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "CR Status" -InternalName "CRStatus" `
    -Type "Choice" -Required $true `
    -DefaultValue "Draft" `
    -Choices @(
        "Draft",
        "Submitted",
        "PMO Review",
        "In Assessment",
        "PMO Consolidation",
        "Programme Meeting",
        "Pre-SG Distribution",
        "SG Review",
        "Post-Meeting Edits",
        "Approved",
        "Deferred",
        "Rejected",
        "Closed"
    )

Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "Cost Currency" -InternalName "CostCurrency" `
    -Type "Choice" -Required $false `
    -DefaultValue "USD" `
    -Choices @("USD", "GBP", "EUR")

Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "SG Decision" -InternalName "SGDecision" `
    -Type "Choice" -Required $false `
    -Choices @("Approved", "Deferred", "Rejected")

# --- Description / narrative columns ---
Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "CR Description" -InternalName "CRDescription" `
    -Type "Note" -Required $true

Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "Reason For Change" -InternalName "ReasonForChange" `
    -Type "Note" -Required $false

Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "Do Nothing Option" -InternalName "DoNothingOption" `
    -Type "Note" -Required $false

Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "Additional Information" -InternalName "AdditionalInformation" `
    -Type "Note" -Required $false

Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "PMO Notes" -InternalName "PMONotes" `
    -Type "Note" -Required $false

Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "SG Decision Notes" -InternalName "SGDecisionNotes" `
    -Type "Note" -Required $false

# --- Cost / weight impact columns (text to allow TBC / NA / currency symbols) ---
Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "RE Delta Per Aircraft" -InternalName "RE_Delta_PerAircraft" `
    -Type "Text" -Required $false

Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "NRE Delta" -InternalName "NRE_Delta" `
    -Type "Text" -Required $false

Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "Total Cost Delta" -InternalName "TotalCostDelta" `
    -Type "Text" -Required $false

Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "Weight Delta Per Aircraft" -InternalName "WeightDelta_PerAircraft" `
    -Type "Text" -Required $false

Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "Weight Delta All Aircraft" -InternalName "WeightDelta_AllAircraft" `
    -Type "Text" -Required $false

Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "Annual CoW Impact" -InternalName "AnnualCoWImpact" `
    -Type "Text" -Required $false

# --- Flags / boolean columns ---
Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "Is Draft" -InternalName "IsDraft" `
    -Type "Boolean" -Required $false -DefaultValue "1"

Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "Attendance Confirmed" -InternalName "AttendanceConfirmed" `
    -Type "Boolean" -Required $false -DefaultValue "0"

Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "Is Confidential" -InternalName "IsConfidential" `
    -Type "Boolean" -Required $false -DefaultValue "0"

# --- Programme Meeting columns ---
Add-ColumnIfNotExists -ListName "CRRequests" -DisplayName "Delegate Attending" -InternalName "DelegateAttending" `
    -Type "Text" -Required $false

Write-Host "  [✓] CRRequests complete." -ForegroundColor Green


# ═════════════════════════════════════════════════════════════════════════════
# LIST 2: CRStakeholderReviews
# ═════════════════════════════════════════════════════════════════════════════
Write-Host "`n--- Creating CRStakeholderReviews ---" -ForegroundColor Yellow

$listExists = Get-PnPList -Identity "CRStakeholderReviews" -ErrorAction SilentlyContinue
if (-not $listExists) {
    New-PnPList -Title "CRStakeholderReviews" -Template GenericList -OnQuickLaunch | Out-Null
    Write-Host "  [+] List 'CRStakeholderReviews' created." -ForegroundColor Green
} else {
    Write-Host "  [skip] List 'CRStakeholderReviews' already exists." -ForegroundColor DarkGray
}

# Lookup to CRRequests.CRNumber
Add-ColumnIfNotExists -ListName "CRStakeholderReviews" -DisplayName "CR Number" -InternalName "CRNumber" `
    -Type "Lookup" -Required $true `
    -LookupListName "CRRequests" -LookupField "CRNumber"

Add-ColumnIfNotExists -ListName "CRStakeholderReviews" -DisplayName "Stakeholder Group" -InternalName "StakeholderGroup" `
    -Type "Choice" -Required $true `
    -Choices @(
        "Engineering Programmes",
        "Engineering Technical",
        "Onboard Experience",
        "Finance",
        "Procurement",
        "Other"
    )

Add-ColumnIfNotExists -ListName "CRStakeholderReviews" -DisplayName "RAG Status" -InternalName "RAGStatus" `
    -Type "Choice" -Required $true `
    -DefaultValue "Pale Blue" `
    -Choices @("Pale Blue", "Green", "Amber", "Red", "Grey")

Add-ColumnIfNotExists -ListName "CRStakeholderReviews" -DisplayName "Impact Statement" -InternalName "ImpactStatement" `
    -Type "Note" -Required $false

Add-ColumnIfNotExists -ListName "CRStakeholderReviews" -DisplayName "Reviewer" -InternalName "Reviewer" `
    -Type "User" -Required $false

Add-ColumnIfNotExists -ListName "CRStakeholderReviews" -DisplayName "Review Date" -InternalName "ReviewDate" `
    -Type "DateTime" -Required $false

Add-ColumnIfNotExists -ListName "CRStakeholderReviews" -DisplayName "Is Applicable" -InternalName "IsApplicable" `
    -Type "Boolean" -Required $false -DefaultValue "1"

Add-ColumnIfNotExists -ListName "CRStakeholderReviews" -DisplayName "Is Complete" -InternalName "IsComplete" `
    -Type "Boolean" -Required $false -DefaultValue "0"

Write-Host "  [✓] CRStakeholderReviews complete." -ForegroundColor Green


# ═════════════════════════════════════════════════════════════════════════════
# LIST 3: CRUserAdmin
# ═════════════════════════════════════════════════════════════════════════════
Write-Host "`n--- Creating CRUserAdmin ---" -ForegroundColor Yellow

$listExists = Get-PnPList -Identity "CRUserAdmin" -ErrorAction SilentlyContinue
if (-not $listExists) {
    New-PnPList -Title "CRUserAdmin" -Template GenericList -OnQuickLaunch | Out-Null
    Write-Host "  [+] List 'CRUserAdmin' created." -ForegroundColor Green
} else {
    Write-Host "  [skip] List 'CRUserAdmin' already exists." -ForegroundColor DarkGray
}

Add-ColumnIfNotExists -ListName "CRUserAdmin" -DisplayName "Email" -InternalName "Email" `
    -Type "Text" -Required $true

Add-ColumnIfNotExists -ListName "CRUserAdmin" -DisplayName "Role" -InternalName "Role" `
    -Type "Choice" -Required $true `
    -DefaultValue "Stakeholder" `
    -Choices @("Admin", "PMO", "Programme Manager", "Stakeholder")

Add-ColumnIfNotExists -ListName "CRUserAdmin" -DisplayName "Stakeholder Group" -InternalName "StakeholderGroup" `
    -Type "Choice" -Required $false `
    -Choices @(
        "Engineering Programmes",
        "Engineering Technical",
        "Onboard Experience",
        "Finance",
        "Procurement",
        "Other"
    )

Add-ColumnIfNotExists -ListName "CRUserAdmin" -DisplayName "Team" -InternalName "Team" `
    -Type "Text" -Required $false

Add-ColumnIfNotExists -ListName "CRUserAdmin" -DisplayName "Is Active" -InternalName "IsActive" `
    -Type "Boolean" -Required $false -DefaultValue "1"

Write-Host "  [✓] CRUserAdmin complete." -ForegroundColor Green


# ═════════════════════════════════════════════════════════════════════════════
# LIST 4: AIPSGMeetings
# ═════════════════════════════════════════════════════════════════════════════
Write-Host "`n--- Creating AIPSGMeetings ---" -ForegroundColor Yellow

$listExists = Get-PnPList -Identity "AIPSGMeetings" -ErrorAction SilentlyContinue
if (-not $listExists) {
    New-PnPList -Title "AIPSGMeetings" -Template GenericList -OnQuickLaunch | Out-Null
    Write-Host "  [+] List 'AIPSGMeetings' created." -ForegroundColor Green
} else {
    Write-Host "  [skip] List 'AIPSGMeetings' already exists." -ForegroundColor DarkGray
}

Add-ColumnIfNotExists -ListName "AIPSGMeetings" -DisplayName "Meeting Date" -InternalName "MeetingDate" `
    -Type "DateTime" -Required $true

Add-ColumnIfNotExists -ListName "AIPSGMeetings" -DisplayName "Submission Deadline" -InternalName "SubmissionDeadline" `
    -Type "DateTime" -Required $false

Add-ColumnIfNotExists -ListName "AIPSGMeetings" -DisplayName "Pre-SG Distribution Date" -InternalName "PreSGDistributionDate" `
    -Type "DateTime" -Required $false

Add-ColumnIfNotExists -ListName "AIPSGMeetings" -DisplayName "Is Active" -InternalName "IsActive" `
    -Type "Boolean" -Required $false -DefaultValue "1"

Write-Host "  [✓] AIPSGMeetings complete." -ForegroundColor Green


# ═════════════════════════════════════════════════════════════════════════════
# SEED: AIPSGMeetings with upcoming dates
# ═════════════════════════════════════════════════════════════════════════════
Write-Host "`n--- Seeding AIPSGMeetings with upcoming dates ---" -ForegroundColor Yellow

$meetingDates = @(
    @{ Title = "April 2026 AIPSG";  MeetingDate = "2026-04-08"; SubmissionDeadline = "2026-04-01"; PreSGDist = "2026-04-06" },
    @{ Title = "May 2026 AIPSG";    MeetingDate = "2026-05-13"; SubmissionDeadline = "2026-05-06"; PreSGDist = "2026-05-11" },
    @{ Title = "June 2026 AIPSG";   MeetingDate = "2026-06-10"; SubmissionDeadline = "2026-06-03"; PreSGDist = "2026-06-08" },
    @{ Title = "July 2026 AIPSG";   MeetingDate = "2026-07-08"; SubmissionDeadline = "2026-07-01"; PreSGDist = "2026-07-06" },
    @{ Title = "August 2026 AIPSG"; MeetingDate = "2026-08-12"; SubmissionDeadline = "2026-08-05"; PreSGDist = "2026-08-10" }
)

foreach ($m in $meetingDates) {
    $exists = Get-PnPListItem -List "AIPSGMeetings" -Query "<View><Query><Where><Eq><FieldRef Name='Title'/><Value Type='Text'>$($m.Title)</Value></Eq></Where></Query></View>" -ErrorAction SilentlyContinue
    if ($exists) {
        Write-Host "  [skip] '$($m.Title)' already exists." -ForegroundColor DarkGray
    } else {
        Add-PnPListItem -List "AIPSGMeetings" -Values @{
            Title                  = $m.Title
            MeetingDate            = $m.MeetingDate
            SubmissionDeadline     = $m.SubmissionDeadline
            PreSGDistributionDate  = $m.PreSGDist
            IsActive               = $true
        } | Out-Null
        Write-Host "  [+] '$($m.Title)'" -ForegroundColor Green
    }
}


# ═════════════════════════════════════════════════════════════════════════════
# DONE
# ═════════════════════════════════════════════════════════════════════════════
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  CR Tool lists created successfully." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host @"

Next steps:
  1. Open the CRRequests list → List Settings → Versioning
     → Confirm 'Create a version each time you edit an item' is ON.
  2. In Power Apps Studio, reconnect the SharePoint data source to:
     Site:  https://baplc.sharepoint.com/sites/Engprog
     Lists: CRRequests, CRStakeholderReviews, CRUserAdmin, AIPSGMeetings
  3. Add your first user to CRUserAdmin with Role = Admin.
  4. Update AIPSGMeetings with your actual SG meeting dates.

"@ -ForegroundColor White

Disconnect-PnPOnline
