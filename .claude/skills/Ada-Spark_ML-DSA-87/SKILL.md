```markdown
# Ada-Spark_ML-DSA-87 Development Patterns

> Auto-generated skill from repository analysis

## Overview
This skill provides guidance for contributing to the Ada-Spark_ML-DSA-87 TypeScript codebase. It covers coding conventions, file organization, commit patterns, and project-specific workflows, including how to update the project's engineering status sheet. The repository does not use a specific framework and follows clear, consistent conventions for code structure and collaboration.

## Coding Conventions

### File Naming
- **PascalCase** is used for file names.
  - **Example:**  
    `DataProcessor.ts`, `UserProfile.test.ts`

### Import Style
- **Relative imports** are used for referencing other modules.
  - **Example:**
    ```typescript
    import { processData } from './DataProcessor';
    ```

### Export Style
- **Named exports** are preferred.
  - **Example:**
    ```typescript
    // In DataProcessor.ts
    export function processData(data: any) { ... }
    ```

### Commit Patterns
- Commits use freeform messages, sometimes prefixed with `changelog` or `deoxys`.
- Average commit message length: ~44 characters.
  - **Examples:**
    ```
    changelog: update status sheet for Q2
    deoxys: refactor data validation logic
    Fix bug in feature extraction
    ```

## Workflows

### Update Changelog Status Sheet
**Trigger:** When you need to record project status changes, add new features, or update compliance notes in the engineering status sheet.  
**Command:** `/update-status-sheet`

1. Open `changelog/lthing-status.html`.
2. Add or update status information, feature rows, or compliance notes directly in the HTML file.
   - **Example:**
     ```html
     <tr>
       <td>2024-06-10</td>
       <td>Added new ML feature extraction module</td>
       <td>In Progress</td>
     </tr>
     ```
3. Embed any new constants, parameters, or notes as needed in the HTML.
4. If necessary, refresh loader metadata (such as epoch or stage) within the file.
5. Save and commit your changes with a descriptive message, e.g.,  
   `changelog: update status sheet for new milestone`.

## Testing Patterns

- Test files follow the pattern: `*.test.*` (e.g., `UserProfile.test.ts`).
- The testing framework is not explicitly specified.
- Tests are typically colocated with the code they test.
  - **Example:**
    ```
    src/
      UserProfile.ts
      UserProfile.test.ts
    ```

## Commands

| Command              | Purpose                                                        |
|----------------------|----------------------------------------------------------------|
| /update-status-sheet | Update the engineering status sheet with new project changes.   |
```
