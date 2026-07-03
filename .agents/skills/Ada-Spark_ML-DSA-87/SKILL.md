```markdown
# Ada-Spark_ML-DSA-87 Development Patterns

> Auto-generated skill from repository analysis

## Overview
This skill provides guidance for contributing to the Ada-Spark_ML-DSA-87 TypeScript codebase. It covers the project's coding conventions, file organization, and testing patterns. While no specific automation workflows are detected, this guide helps maintain consistency and quality in development.

## Coding Conventions

### File Naming
- Use **PascalCase** for all file names.
  - Example: `DataProcessor.ts`, `UserService.ts`

### Import Style
- Use **relative imports** for referencing modules.
  - Example:
    ```typescript
    import { User } from './User';
    import { processData } from '../utils/DataUtils';
    ```

### Export Style
- Use **named exports** for all modules.
  - Example:
    ```typescript
    // In DataProcessor.ts
    export function processData(data: any): any {
      // implementation
    }

    export const DATA_VERSION = '1.0';
    ```

### Commit Messages
- Freeform style, no enforced prefixes.
- Average commit message length: ~60 characters.

## Workflows

_No automated workflows detected in this repository. Below are suggested manual workflows for common tasks._

### Running Tests
**Trigger:** When you need to verify code correctness.
**Command:** `/run-tests`

1. Identify test files matching the `*.test.*` pattern.
2. Use your preferred TypeScript-compatible test runner (e.g., Jest, Mocha).
3. Run the test suite and review results.

#### Example:
```bash
npx jest
```
or
```bash
npx mocha "**/*.test.ts"
```

### Adding a New Module
**Trigger:** When adding new functionality.
**Command:** `/add-module`

1. Create a new file using PascalCase (e.g., `NewFeature.ts`).
2. Use relative imports for dependencies.
3. Export functions or constants using named exports.
4. Write corresponding tests in a `NewFeature.test.ts` file.

#### Example:
```typescript
// NewFeature.ts
export function newFeature() {
  // implementation
}
```
```typescript
// NewFeature.test.ts
import { newFeature } from './NewFeature';

test('newFeature works', () => {
  expect(newFeature()).toBeDefined();
});
```

## Testing Patterns

- Test files follow the `*.test.*` naming convention (e.g., `DataProcessor.test.ts`).
- The specific test framework is not enforced; choose one compatible with TypeScript (e.g., Jest, Mocha).
- Place tests alongside implementation files or in a dedicated `tests` directory.

#### Example Test File:
```typescript
// DataProcessor.test.ts
import { processData } from './DataProcessor';

test('processData returns expected result', () => {
  const input = [1, 2, 3];
  const output = processData(input);
  expect(output).toEqual([/* expected result */]);
});
```

## Commands
| Command      | Purpose                                  |
|--------------|------------------------------------------|
| /run-tests   | Run all test files in the repository     |
| /add-module  | Scaffold a new module with tests         |
```
