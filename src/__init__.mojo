"""
mojo-validation

Input validation and schema enforcement for Mojo applications.
A pure Mojo alternative to Python's Pydantic.

Features:
- Field constraints (required, min_length, max_length, range)
- Format validators (email, url, alpha, numeric)
- Schema-based validation
- Rich error messages

Usage:
    from mojo_validation import StringField, IntField, SchemaValidator
    from mojo_validation import validate_required, validate_email

    # Quick validation
    validate_required("name", user_name)
    validate_email("email", user_email)

    # Schema-based validation
    var validator = SchemaValidator()
    validator.add_string_field(
        StringField("email").set_required().set_email()
    )
    validator.add_int_field(
        IntField("age").set_gte(0).set_lte(150)
    )

    validator.validate_string("email", user_email)
    validator.validate_int("age", user_age)

    if not validator.is_valid():
        print(validator.errors())
"""

# Error types
from .errors import FieldError, ValidationError, ValidationResult

# Field constraints
from .fields import StringField, IntField, FloatField

# Schema validation
from .schema import (
    SchemaValidator,
    ModelValidator,
    validate_required,
    validate_email,
    validate_url,
    validate_min_length,
    validate_max_length,
    validate_range,
    validate_positive,
)

# Built-in validators
from .validators import (
    validate_required as check_required,
    validate_min_length as check_min_length,
    validate_max_length as check_max_length,
    validate_length as check_length,
    validate_gt as check_gt,
    validate_gte as check_gte,
    validate_lt as check_lt,
    validate_lte as check_lte,
    validate_range as check_range,
    validate_positive as check_positive,
    validate_non_negative as check_non_negative,
    validate_email as check_email,
    validate_url as check_url,
    validate_alpha as check_alpha,
    validate_alphanumeric as check_alphanumeric,
    validate_numeric as check_numeric,
    validate_one_of as check_one_of,
)
