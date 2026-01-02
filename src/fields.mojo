"""
Field Constraints

Declarative field validation with fluent API.
"""

from .errors import FieldError, ValidationError
from .validators import (
    validate_required,
    validate_min_length,
    validate_max_length,
    validate_gt,
    validate_gte,
    validate_lt,
    validate_lte,
    validate_email,
    validate_url,
    validate_alpha,
    validate_alphanumeric,
    validate_numeric,
    validate_one_of,
)


@value
struct StringField:
    """String field with validation constraints."""

    var name: String
    var required: Bool
    var min_length: Int
    var max_length: Int
    var is_email: Bool
    var is_url: Bool
    var is_alpha: Bool
    var is_alphanumeric: Bool
    var is_numeric: Bool
    var allowed_values: List[String]

    fn __init__(out self, name: String):
        self.name = name
        self.required = False
        self.min_length = -1
        self.max_length = -1
        self.is_email = False
        self.is_url = False
        self.is_alpha = False
        self.is_alphanumeric = False
        self.is_numeric = False
        self.allowed_values = List[String]()

    fn set_required(inout self) -> Self:
        """Mark field as required."""
        self.required = True
        return self

    fn set_min_length(inout self, length: Int) -> Self:
        """Set minimum length."""
        self.min_length = length
        return self

    fn set_max_length(inout self, length: Int) -> Self:
        """Set maximum length."""
        self.max_length = length
        return self

    fn set_length(inout self, min_len: Int, max_len: Int) -> Self:
        """Set length range."""
        self.min_length = min_len
        self.max_length = max_len
        return self

    fn set_email(inout self) -> Self:
        """Validate as email."""
        self.is_email = True
        return self

    fn set_url(inout self) -> Self:
        """Validate as URL."""
        self.is_url = True
        return self

    fn set_alpha(inout self) -> Self:
        """Validate alphabetic only."""
        self.is_alpha = True
        return self

    fn set_alphanumeric(inout self) -> Self:
        """Validate alphanumeric only."""
        self.is_alphanumeric = True
        return self

    fn set_numeric(inout self) -> Self:
        """Validate numeric only."""
        self.is_numeric = True
        return self

    fn set_one_of(inout self, values: List[String]) -> Self:
        """Restrict to allowed values."""
        self.allowed_values = values
        return self

    fn validate(self, value: String) -> ValidationError:
        """Validate a value against all constraints."""
        var errors = ValidationError()

        # Required check
        if self.required:
            var err = validate_required(self.name, value)
            if err:
                errors.add_error(err.value())
                return errors  # Short-circuit on required failure

        # If empty and not required, skip other validations
        if len(value) == 0:
            return errors

        # Length checks
        if self.min_length >= 0:
            var err = validate_min_length(self.name, value, self.min_length)
            if err:
                errors.add_error(err.value())

        if self.max_length >= 0:
            var err = validate_max_length(self.name, value, self.max_length)
            if err:
                errors.add_error(err.value())

        # Format checks
        if self.is_email:
            var err = validate_email(self.name, value)
            if err:
                errors.add_error(err.value())

        if self.is_url:
            var err = validate_url(self.name, value)
            if err:
                errors.add_error(err.value())

        if self.is_alpha:
            var err = validate_alpha(self.name, value)
            if err:
                errors.add_error(err.value())

        if self.is_alphanumeric:
            var err = validate_alphanumeric(self.name, value)
            if err:
                errors.add_error(err.value())

        if self.is_numeric:
            var err = validate_numeric(self.name, value)
            if err:
                errors.add_error(err.value())

        # Allowed values
        if len(self.allowed_values) > 0:
            var err = validate_one_of(self.name, value, self.allowed_values)
            if err:
                errors.add_error(err.value())

        return errors


@value
struct IntField:
    """Integer field with validation constraints."""

    var name: String
    var required: Bool
    var min_value: Int
    var max_value: Int
    var has_min: Bool
    var has_max: Bool

    fn __init__(out self, name: String):
        self.name = name
        self.required = False
        self.min_value = 0
        self.max_value = 0
        self.has_min = False
        self.has_max = False

    fn set_required(inout self) -> Self:
        """Mark field as required."""
        self.required = True
        return self

    fn set_gt(inout self, value: Int) -> Self:
        """Set minimum value (exclusive)."""
        self.min_value = value + 1
        self.has_min = True
        return self

    fn set_gte(inout self, value: Int) -> Self:
        """Set minimum value (inclusive)."""
        self.min_value = value
        self.has_min = True
        return self

    fn set_lt(inout self, value: Int) -> Self:
        """Set maximum value (exclusive)."""
        self.max_value = value - 1
        self.has_max = True
        return self

    fn set_lte(inout self, value: Int) -> Self:
        """Set maximum value (inclusive)."""
        self.max_value = value
        self.has_max = True
        return self

    fn set_range(inout self, min_val: Int, max_val: Int) -> Self:
        """Set value range (inclusive)."""
        self.min_value = min_val
        self.max_value = max_val
        self.has_min = True
        self.has_max = True
        return self

    fn set_positive(inout self) -> Self:
        """Require positive value (> 0)."""
        self.min_value = 1
        self.has_min = True
        return self

    fn set_non_negative(inout self) -> Self:
        """Require non-negative value (>= 0)."""
        self.min_value = 0
        self.has_min = True
        return self

    fn validate(self, value: Int, is_set: Bool = True) -> ValidationError:
        """Validate a value against all constraints."""
        var errors = ValidationError()

        # Required check
        if self.required and not is_set:
            errors.add(self.name, "is required")
            return errors

        if not is_set:
            return errors

        # Range checks
        if self.has_min:
            var err = validate_gte(self.name, value, self.min_value)
            if err:
                errors.add_error(err.value())

        if self.has_max:
            var err = validate_lte(self.name, value, self.max_value)
            if err:
                errors.add_error(err.value())

        return errors


@value
struct FloatField:
    """Float field with validation constraints."""

    var name: String
    var required: Bool
    var min_value: Float64
    var max_value: Float64
    var has_min: Bool
    var has_max: Bool

    fn __init__(out self, name: String):
        self.name = name
        self.required = False
        self.min_value = 0.0
        self.max_value = 0.0
        self.has_min = False
        self.has_max = False

    fn set_required(inout self) -> Self:
        """Mark field as required."""
        self.required = True
        return self

    fn set_gt(inout self, value: Float64) -> Self:
        """Set minimum value (exclusive)."""
        self.min_value = value
        self.has_min = True
        return self

    fn set_gte(inout self, value: Float64) -> Self:
        """Set minimum value (inclusive)."""
        self.min_value = value
        self.has_min = True
        return self

    fn set_lt(inout self, value: Float64) -> Self:
        """Set maximum value (exclusive)."""
        self.max_value = value
        self.has_max = True
        return self

    fn set_lte(inout self, value: Float64) -> Self:
        """Set maximum value (inclusive)."""
        self.max_value = value
        self.has_max = True
        return self

    fn set_range(inout self, min_val: Float64, max_val: Float64) -> Self:
        """Set value range (inclusive)."""
        self.min_value = min_val
        self.max_value = max_val
        self.has_min = True
        self.has_max = True
        return self

    fn set_positive(inout self) -> Self:
        """Require positive value (> 0)."""
        self.min_value = 0.0
        self.has_min = True
        return self

    fn validate(self, value: Float64, is_set: Bool = True) -> ValidationError:
        """Validate a value against all constraints."""
        var errors = ValidationError()

        # Required check
        if self.required and not is_set:
            errors.add(self.name, "is required")
            return errors

        if not is_set:
            return errors

        # Range checks
        if self.has_min and value < self.min_value:
            errors.add(
                self.name,
                "must be greater than or equal to " + str(self.min_value),
                str(value)
            )

        if self.has_max and value > self.max_value:
            errors.add(
                self.name,
                "must be less than or equal to " + str(self.max_value),
                str(value)
            )

        return errors
