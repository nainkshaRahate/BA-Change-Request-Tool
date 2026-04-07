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
