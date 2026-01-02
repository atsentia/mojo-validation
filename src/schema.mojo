"""
Schema Validation

Base schema struct and validation utilities.
Inspired by Pydantic's model validation pattern.
"""

from .errors import ValidationError, FieldError
from .fields import StringField, IntField, FloatField


@value
struct SchemaValidator:
    """Validator that collects field validations.

    Usage:
        var validator = SchemaValidator()
        validator.add_string_field(StringField("name").set_required().set_min_length(1))
        validator.add_int_field(IntField("age").set_gte(0).set_lte(150))

        var errors = validator.validate_string("name", user_name)
        errors = validator.validate_int("age", user_age)

        if errors.has_errors():
            print(errors)
    """

    var string_fields: Dict[String, StringField]
    var int_fields: Dict[String, IntField]
    var float_fields: Dict[String, FloatField]
    var _errors: ValidationError

    fn __init__(out self):
        self.string_fields = Dict[String, StringField]()
        self.int_fields = Dict[String, IntField]()
        self.float_fields = Dict[String, FloatField]()
        self._errors = ValidationError()

    fn add_string_field(inout self, field: StringField):
        """Register a string field for validation."""
        self.string_fields[field.name] = field

    fn add_int_field(inout self, field: IntField):
        """Register an int field for validation."""
        self.int_fields[field.name] = field

    fn add_float_field(inout self, field: FloatField):
        """Register a float field for validation."""
        self.float_fields[field.name] = field

    fn validate_string(inout self, name: String, value: String) -> Bool:
        """Validate a string field value. Returns True if valid."""
        if name not in self.string_fields:
            return True  # No constraints defined

        var field = self.string_fields[name]
        var field_errors = field.validate(value)

        if field_errors.has_errors():
            for i in range(len(field_errors.errors)):
                self._errors.add_error(field_errors.errors[i])
            return False

        return True

    fn validate_int(inout self, name: String, value: Int, is_set: Bool = True) -> Bool:
        """Validate an int field value. Returns True if valid."""
        if name not in self.int_fields:
            return True  # No constraints defined

        var field = self.int_fields[name]
        var field_errors = field.validate(value, is_set)

        if field_errors.has_errors():
            for i in range(len(field_errors.errors)):
                self._errors.add_error(field_errors.errors[i])
            return False

        return True

    fn validate_float(inout self, name: String, value: Float64, is_set: Bool = True) -> Bool:
        """Validate a float field value. Returns True if valid."""
        if name not in self.float_fields:
            return True  # No constraints defined

        var field = self.float_fields[name]
        var field_errors = field.validate(value, is_set)

        if field_errors.has_errors():
            for i in range(len(field_errors.errors)):
                self._errors.add_error(field_errors.errors[i])
            return False

        return True

    fn is_valid(self) -> Bool:
        """Check if all validations passed."""
        return not self._errors.has_errors()

    fn errors(self) -> ValidationError:
        """Get collected errors."""
        return self._errors

    fn reset(inout self):
        """Reset collected errors for reuse."""
        self._errors = ValidationError()


struct ModelValidator:
    """Higher-level validator for model-like validation.

    Usage:
        var v = ModelValidator()

        # Define schema
        v.string("email").required().email()
        v.string("username").required().min_length(3).max_length(20).alphanumeric()
        v.int("age").gte(18).lte(120)

        # Validate
        v.check_string("email", user_email)
        v.check_string("username", user_name)
        v.check_int("age", user_age)

        if v.is_valid():
            # proceed
        else:
            print(v.errors())
    """

    var _validator: SchemaValidator
    var _current_string: StringField
    var _current_int: IntField
    var _current_float: FloatField

    fn __init__(out self):
        self._validator = SchemaValidator()
        self._current_string = StringField("")
        self._current_int = IntField("")
        self._current_float = FloatField("")

    fn string(inout self, name: String) -> ref [self._current_string] StringField:
        """Start defining a string field."""
        self._current_string = StringField(name)
        self._validator.add_string_field(self._current_string)
        return self._current_string

    fn int(inout self, name: String) -> ref [self._current_int] IntField:
        """Start defining an int field."""
        self._current_int = IntField(name)
        self._validator.add_int_field(self._current_int)
        return self._current_int

    fn float(inout self, name: String) -> ref [self._current_float] FloatField:
        """Start defining a float field."""
        self._current_float = FloatField(name)
        self._validator.add_float_field(self._current_float)
        return self._current_float

    fn check_string(inout self, name: String, value: String) -> Bool:
        """Validate a string value."""
        return self._validator.validate_string(name, value)

    fn check_int(inout self, name: String, value: Int, is_set: Bool = True) -> Bool:
        """Validate an int value."""
        return self._validator.validate_int(name, value, is_set)

    fn check_float(inout self, name: String, value: Float64, is_set: Bool = True) -> Bool:
        """Validate a float value."""
        return self._validator.validate_float(name, value, is_set)

    fn is_valid(self) -> Bool:
        """Check if all validations passed."""
        return self._validator.is_valid()

    fn errors(self) -> ValidationError:
        """Get collected errors."""
        return self._validator.errors()

    fn reset(inout self):
        """Reset for reuse."""
        self._validator.reset()


# Convenience functions for quick validation

fn validate_required(field: String, value: String) raises:
    """Raise if value is empty."""
    if len(value) == 0:
        raise Error(field + " is required")


fn validate_email(field: String, value: String) raises:
    """Raise if value is not a valid email."""
    if "@" not in value or "." not in value:
        raise Error(field + " must be a valid email address")

    var at_pos = value.find("@")
    if at_pos < 1 or at_pos == len(value) - 1:
        raise Error(field + " must be a valid email address")


fn validate_url(field: String, value: String) raises:
    """Raise if value is not a valid URL."""
    if not value.startswith("http://") and not value.startswith("https://"):
        raise Error(field + " must be a valid URL")


fn validate_min_length(field: String, value: String, min_len: Int) raises:
    """Raise if value is too short."""
    if len(value) < min_len:
        raise Error(field + " must be at least " + str(min_len) + " characters")


fn validate_max_length(field: String, value: String, max_len: Int) raises:
    """Raise if value is too long."""
    if len(value) > max_len:
        raise Error(field + " must be at most " + str(max_len) + " characters")


fn validate_range(field: String, value: Int, min_val: Int, max_val: Int) raises:
    """Raise if value is outside range."""
    if value < min_val or value > max_val:
        raise Error(field + " must be between " + str(min_val) + " and " + str(max_val))


fn validate_positive(field: String, value: Int) raises:
    """Raise if value is not positive."""
    if value <= 0:
        raise Error(field + " must be positive")
