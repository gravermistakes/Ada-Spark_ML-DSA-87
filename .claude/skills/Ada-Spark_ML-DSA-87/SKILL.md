```markdown
# Ada-Spark_ML-DSA-87 Development Patterns

> Auto-generated skill from repository analysis

## Overview
This skill provides a comprehensive guide to the development patterns and conventions used in the Ada-Spark_ML-DSA-87 repository. The codebase is written in Python and focuses on machine learning and data structure algorithms. It emphasizes consistent coding style, modular design, and a clear approach to testing, making it suitable for collaborative and scalable development.

## Coding Conventions

### File Naming
- Use **snake_case** for all file and module names.
  - Example: `data_loader.py`, `model_utils.py`

### Import Style
- Use **relative imports** within the package.
  - Example:
    ```python
    from .utils import preprocess_data
    ```

### Export Style
- Use **named exports** (explicitly define what is exported).
  - Example:
    ```python
    __all__ = ['train_model', 'evaluate_model']
    ```

### Commit Patterns
- Commits use freeform messages, sometimes with prefixes, averaging 68 characters.
  - Example: `Add early stopping to training loop for faster convergence`

## Workflows

### Adding a New Module
**Trigger:** When implementing a new feature or algorithm  
**Command:** `/add-module`

1. Create a new Python file using snake_case (e.g., `feature_selector.py`).
2. Implement the functionality using relative imports for dependencies.
3. Define `__all__` to specify exported functions/classes.
4. Write corresponding tests in a file matching `*.test.*`.
5. Commit changes with a descriptive message.

### Running Tests
**Trigger:** When validating code correctness  
**Command:** `/run-tests`

1. Identify test files matching the `*.test.*` pattern.
2. Run tests using the project's preferred method (framework not specified; use `pytest` or `unittest` as appropriate).
   - Example:
     ```bash
     pytest
     ```
3. Review test output and address any failures.

### Refactoring Code
**Trigger:** When improving code structure or readability  
**Command:** `/refactor`

1. Update file and function names to follow snake_case.
2. Ensure all imports are relative within the package.
3. Update `__all__` in affected modules.
4. Run tests to confirm no regressions.

## Testing Patterns

- Test files follow the pattern `*.test.*` (e.g., `data_loader.test.py`).
- The specific testing framework is not specified; common choices include `pytest` or `unittest`.
- Tests should cover both typical and edge cases for each module.
- Example test structure:
  ```python
  import unittest
  from .data_loader import load_data

  class TestDataLoader(unittest.TestCase):
      def test_load_data_valid(self):
          data = load_data('sample.csv')
          self.assertIsNotNone(data)
  ```

## Commands

| Command       | Purpose                                         |
|---------------|-------------------------------------------------|
| /add-module   | Scaffold and add a new module with tests        |
| /run-tests    | Run all test files in the repository            |
| /refactor     | Refactor code to follow repository conventions  |
```