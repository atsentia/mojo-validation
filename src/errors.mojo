"""
Validation Errors

Error types for validation failures.
"""


@value
struct FieldError:
    """Error for a specific field."""

    var field: String
    var message: String
    var value: String

    fn __init__(out self, field: String, message: String, value: String = ""):
        self.field = field
        self.message = message
        self.value = value

    fn __str__(self) -> String:
        if len(self.value) > 0:
            return self.field + ": " + self.message + " (got: " + self.value + ")"
        return self.field + ": " + self.message


@value
struct ValidationError:
    """Collection of validation errors."""

    var errors: List[FieldError]

    fn __init__(out self):
        self.errors = List[FieldError]()

    fn __init__(out self, field: String, message: String, value: String = ""):
        self.errors = List[FieldError]()
        self.errors.append(FieldError(field, message, value))

    fn add(inout self, field: String, message: String, value: String = ""):
        """Add a field error."""
        self.errors.append(FieldError(field, message, value))

    fn add_error(inout self, error: FieldError):
        """Add an existing field error."""
        self.errors.append(error)

    fn has_errors(self) -> Bool:
        """Check if there are any errors."""
        return len(self.errors) > 0

    fn count(self) -> Int:
        """Get error count."""
        return len(self.errors)

    fn __str__(self) -> String:
        if len(self.errors) == 0:
            return "No validation errors"

        var result = String("Validation failed with ")
        result += str(len(self.errors))
        result += " error(s):\n"

        for i in range(len(self.errors)):
            result += "  - " + str(self.errors[i]) + "\n"

        return result

    fn first_error(self) -> String:
        """Get first error message."""
        if len(self.errors) > 0:
            return str(self.errors[0])
        return ""


struct ValidationResult[T: CollectionElement]:
    """Result of validation - either valid value or errors."""

    var _value: T
    var _errors: ValidationError
    var _is_valid: Bool

    fn __init__(out self, value: T):
        """Create a valid result."""
        self._value = value
        self._errors = ValidationError()
        self._is_valid = True

    fn __init__(out self, errors: ValidationError):
        """Create an invalid result."""
        self._value = T()
        self._errors = errors
        self._is_valid = False

    fn is_valid(self) -> Bool:
        """Check if validation passed."""
        return self._is_valid

    fn value(self) -> T:
        """Get the validated value. Only call if is_valid() is True."""
        return self._value

    fn errors(self) -> ValidationError:
        """Get validation errors."""
        return self._errors
