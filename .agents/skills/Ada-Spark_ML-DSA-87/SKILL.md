```markdown
# Ada-Spark_ML-DSA-87 Development Patterns

> Auto-generated skill from repository analysis

## Overview
This skill covers the development patterns and conventions used in the Ada-Spark_ML-DSA-87 repository, a Python-based codebase focused on machine learning and data structure & algorithm (DSA) solutions. The repository emphasizes clean code organization, modular design, and consistent coding style, making it easier to maintain and extend.

## Coding Conventions

### File Naming
- Use **snake_case** for all file names.
  - Example: `data_processor.py`, `model_utils.py`

### Import Style
- Use **relative imports** within the package.
  - Example:
    ```python
    from .data_loader import load_data
    ```

### Export Style
- Use **named exports**; explicitly define what is exported from each module.
  - Example:
    ```python
    __all__ = ['train_model', 'evaluate_model']
    ```

### Commit Messages
- Freeform style, no strict prefixes.
- Average commit message length: ~55 characters.
  - Example: `Add function to preprocess input data for models`

## Workflows

### Adding a New Module
**Trigger:** When you need to introduce new functionality or algorithms.
**Command:** `/add-module`

1. Create a new Python file using snake_case (e.g., `new_algorithm.py`).
2. Implement the required classes or functions.
3. Use relative imports to integrate with existing modules.
4. Define `__all__` for explicit exports.
5. Add corresponding tests in a `*.test.*` file.
6. Commit changes with a descriptive message.

### Running Tests
**Trigger:** To validate code correctness after changes.
**Command:** `/run-tests`

1. Identify test files matching the `*.test.*` pattern.
2. Run tests using your preferred Python test runner (e.g., `pytest`, `unittest`).
   - Example:
     ```bash
     pytest
     ```
3. Review test results and fix any failures.

### Refactoring Code
**Trigger:** To improve code readability or performance.
**Command:** `/refactor`

1. Identify the target module or function.
2. Refactor code using consistent snake_case naming and relative imports.
3. Update or add tests as needed.
4. Commit changes with a clear message.

## Testing Patterns

- Test files follow the `*.test.*` naming pattern.
  - Example: `data_loader.test.py`
- Testing framework is not explicitly defined; use standard Python test frameworks like `pytest` or `unittest`.
- Place tests in the same directory as the code or in a dedicated `tests/` folder.
- Example test structure:
  ```python
  # data_loader.test.py
  import unittest
  from .data_loader import load_data

  class TestDataLoader(unittest.TestCase):
      def test_load_data(self):
          data = load_data('sample.csv')
          self.assertIsNotNone(data)
  ```

## Commands
| Command        | Purpose                                         |
|----------------|-------------------------------------------------|
| /add-module    | Scaffold and integrate a new module             |
| /run-tests     | Execute all test files in the repository        |
| /refactor      | Refactor existing code following conventions    |
```