```markdown
# Ada-Spark_ML-DSA-87 Development Patterns

> Auto-generated skill from repository analysis

## Overview
This skill covers the core development patterns and conventions used in the Ada-Spark_ML-DSA-87 repository, a TypeScript codebase focused on machine learning and data structure algorithms. It outlines file organization, import/export styles, commit message habits, and testing approaches to help contributors maintain consistency and quality.

## Coding Conventions

### File Naming
- Use **PascalCase** for all file names.
  - Example: `DataProcessor.ts`, `ModelTrainer.ts`

### Imports
- Use **relative imports** for referencing modules within the project.
  - Example:
    ```typescript
    import { DataLoader } from './DataLoader';
    ```

### Exports
- Use **named exports** for all modules.
  - Example:
    ```typescript
    export function trainModel() { ... }
    export const MODEL_VERSION = '1.0';
    ```

### Commit Messages
- Freeform style, no strict prefixing.
- Average length: ~42 characters.
  - Example: `Add utility for matrix normalization`

## Workflows

### Adding a New Module
**Trigger:** When creating a new feature or algorithm module  
**Command:** `/add-module`

1. Create a new TypeScript file using PascalCase (e.g., `NewAlgorithm.ts`).
2. Implement your logic using named exports.
3. Use relative imports for dependencies.
4. Write a corresponding test file (see Testing Patterns).
5. Commit with a clear, concise message.

### Refactoring Existing Code
**Trigger:** When improving or restructuring code  
**Command:** `/refactor`

1. Identify the target file(s).
2. Make changes, ensuring file naming and import/export conventions are followed.
3. Update any affected imports in other modules.
4. Run tests to verify changes.
5. Commit changes with a descriptive message.

### Writing Tests
**Trigger:** When adding or updating functionality  
**Command:** `/write-test`

1. Create a test file named with the pattern `*.test.*` (e.g., `DataLoader.test.ts`).
2. Implement tests for all exported functions.
3. Use the project's test framework (unknown, but follow existing patterns).
4. Run all tests before committing.

## Testing Patterns

- Test files follow the pattern `*.test.*` (e.g., `ModelTrainer.test.ts`).
- Each exported function or constant should have corresponding tests.
- The specific test framework is not detected; follow the structure of existing tests.
- Example test file:
  ```typescript
  import { trainModel } from './ModelTrainer';

  describe('trainModel', () => {
    it('should return a trained model', () => {
      // test implementation
    });
  });
  ```

## Commands
| Command      | Purpose                                         |
|--------------|-------------------------------------------------|
| /add-module  | Scaffold and implement a new module             |
| /refactor    | Refactor existing code with conventions         |
| /write-test  | Create and implement tests for a module         |
```
