# OpenWolf

@.wolf/OPENWOLF.md

This project uses OpenWolf for context management. Read and follow .wolf/OPENWOLF.md every session. Check .wolf/cerebrum.md before generating code. Check .wolf/anatomy.md before reading files.


# IAG Tech Power Apps Development Standards & Tools

## 1. Project Context & Role

You are a Senior Power Apps Developer for IAG Tech. Every code snippet, architecture recommendation, and refactoring task must strictly follow the IAG Tech Power Apps Coding Standards (2021).

## 2. Naming Conventions (Mandatory)

- **Screens**: Plain language + spaces + "Screen" (e.g., `Home Screen`, `User Profile Screen`).
- **Data Sources**: PascalCase (e.g., `Office365Users`, `TravelRequests`).
- **Global Variables**: Prefix `gbl` + camelCase (e.g., `gblUserEmail`).
- **Context Variables**: Prefix `loc` + camelCase (e.g., `locIsError`).
- **Collections**: Prefix `col` + camelCase (e.g., `colFlightData`).
- **Controls**: `[3-letter prefix][Purpose][ShortScreenSuffix]` (e.g., `btnSubmitHS`).
  - **Common Prefixes**: Button: `btn`, Label: `lbl`, Gallery: `gal`, Form: `frm`, Container: `con`, Text Input: `txt`, Icon: `ico`, Toggle: `tgl`, Timer: `tim`, Date Picker: `dte`.

## 3. Architecture & Performance

- **Logic Placement**: Use `App.StartScreen` for routing. Use `App.OnStart` only for static themes/roles. Use `Screen.OnVisible` for data refreshing.
- **Encapsulation**: Pass variables via `Maps` context records. **Never** reference `Gallery.Selected` or control properties from a different screen.
- **Performance**: Use `Concurrent()` for multiple data calls. Prioritize delegable functions. Use `ClearCollect` instead of separate `Clear` and `Collect`.
- **UI**: Use Relative Styling (e.g., `Parent.Width`, `Control.Y + 20`). All controls must reside in a **Container** or **Group**.

## 4. Documentation & Debugging

- **Comments**: Start every `OnVisible` with a block comment: `/* Name, Purpose, Author, Date */`. Use `//` for the "Why" behind logic.
- **Error Handling**: Check `IsEmpty(Errors(DataSource))` after `Patch` or `SubmitForm`.
- **Debug**: Implement a `gblIsMaker` check to show/hide developer labels or tools.

---

## 5. MCP Tools: code-review-graph

**IMPORTANT: ALWAYS use the code-review-graph MCP tools BEFORE using Grep/Glob/Read to explore the codebase.** The graph provides structural context (callers, dependents) that file scanning cannot.

### When to use graph tools FIRST

- **Exploring code**: `semantic_search_nodes` or `query_graph` instead of Grep.
- **Understanding impact**: `get_impact_radius` instead of manually tracing imports.
- **Code review**: `detect_changes` + `get_review_context` instead of reading entire files.
- **Architecture questions**: `get_architecture_overview` + `list_communities`.

### Key Tool Reference

| Tool                        | Use when                                               |
| --------------------------- | ------------------------------------------------------ |
| `detect_changes`            | Reviewing code changes — gives risk-scored analysis    |
| `get_review_context`        | Need source snippets for review — token-efficient      |
| `get_impact_radius`         | Understanding blast radius of a change                 |
| `get_affected_flows`        | Finding which execution paths are impacted             |
| `query_graph`               | Tracing callers, callees, imports, tests, dependencies |
| `semantic_search_nodes`     | Finding functions/classes by name or keyword           |
| `get_architecture_overview` | Understanding high-level codebase structure            |
| `refactor_tool`             | Planning renames, finding dead code                    |

### Workflow

1. The graph auto-updates on file changes.
2. Use `detect_changes` for code review.
3. Use `get_affected_flows` to understand impact.
4. Use `query_graph` pattern="tests_for" to check coverage.

---

## 6. Packing the msapp — ALWAYS use `tools/PackTool/` (in-repo)

**NEVER use `/tmp/PackTool/`.** It is an ephemeral duplicate that may be out of date or missing. The authoritative pack tool is checked into the repo at `tools/PackTool/`.

### Build (one-time, or after PackTool source changes)

```bash
cd tools/PackTool && dotnet build
```

### Pack command

`pac canvas pack` / the repo's `CRTool/` tree alone will NOT pack — the repo source lacks `ComponentReferences.json`, `pkgs/galleryTemplate_1.0.xml`, and `Src/EditorState/*.editorstate.json`, and `DataSources/*.json` breaks the schema deserializer. Use this recipe:

```bash
REPO="/Users/dhammadeepborkar/Library/CloudStorage/OneDrive-ABSOLUTELABS/Dhamma/Office/Projects/BA/BA Change Request Tool/Repositories/BA-Change-Request-Tool"

# 1. Unpack current msapp to a disposable canonical tree
pac canvas unpack --msapp CRTool_v1.msapp --sources CRTool_unpacked

# 2. Copy edited .fx.yaml files onto the canonical Src/
cp "CRTool/Src/<file>.fx.yaml" "CRTool_unpacked/Src/"

# 3. Pack via the REPO PackTool
dotnet "$REPO/tools/PackTool/bin/Debug/net10.0/PackTool.dll" pack \
  -i "$PWD/CRTool_unpacked" -o "$PWD/CRTool_v1.msapp"

# 4. Delete the disposable tree (derivable from the msapp)
rm -rf CRTool_unpacked

# 5. Copy to the user's Desktop for import — see "Upload location" below.
cp "$PWD/CRTool_v1.msapp" ~/Desktop/CRTool_v1.msapp
```

Expected terminal output ends with `SUCCESS! Created: …CRTool_v1.msapp (…bytes)`. A `PA2001 Checksum mismatch` warning is normal after edits — ignore.

### Upload location — ALWAYS copy the built msapp to `~/Desktop/`

Power Apps Studio web uses the browser's native file picker. Browser file pickers **hide dot-prefixed folders** (e.g. `.claude/worktrees/…`) by default, so an msapp produced inside a worktree won't be selectable. macOS Finder and OneDrive sync may also stash hidden folder contents in ways that the web picker can't see.

Fix: after every successful pack, copy the msapp to `~/Desktop/CRTool_v1.msapp`. Desktop is always visible, outside the repo, outside OneDrive sync quirks, and outside any `.claude/` worktree. The committed `CRTool_v1.msapp` at the repo root remains the source-controlled artifact; the Desktop copy is purely the upload pickup point.

### Never commit

- `CRTool_unpacked/` (disposable canonical working tree)
- `CRTool/Src/EditorState/`, `CRTool/pkgs/`, `CRTool/ComponentReferences.json` if they ever appear in `CRTool/` — they belong only in the unpacked tree.

### YAML gotcha

A bare `// …` line placed between properties of a control (i.e. at YAML indent level, not inside a `=` formula body or a `|` block) breaks the parser with `PA3003: Missing ':'. If this is a multiline property, use |`. Attach explanatory comments inline as `/* … */` after the `=` value instead, or put them inside a `|` multiline formula block.
