"""
Tests for mojo-validation library.
"""

from testing import assert_equal, assert_true, assert_false

from mojo_validation import (
    FieldError,
    ValidationError,
    StringField,
    IntField,
    FloatField,
    SchemaValidator,
)
from mojo_validation import (
    check_required,
    check_min_length,
    check_max_length,
    check_email,
    check_url,
    check_gt,
    check_gte,
    check_lt,
    check_lte,
    check_positive,
    check_alpha,
    check_alphanumeric,
    check_numeric,
)


fn test_field_error():
    """Test FieldError creation and string representation."""
    var err = FieldError("email", "is required", "")
    assert_equal(err.field, "email")
    assert_equal(err.message, "is required")

    var err2 = FieldError("age", "must be positive", "-5")
    assert_true("got: -5" in str(err2))


fn test_validation_error():
    """Test ValidationError collection."""
    var errors = ValidationError()
    assert_false(errors.has_errors())
    assert_equal(errors.count(), 0)

    errors.add("name", "is required")
    assert_true(errors.has_errors())
    assert_equal(errors.count(), 1)

    errors.add("age", "must be positive", "-1")
    assert_equal(errors.count(), 2)


fn test_check_required():
    """Test required validation."""
    var err = check_required("name", "")
    assert_true(err is not None)

    var no_err = check_required("name", "John")
    assert_true(no_err is None)


fn test_check_min_length():
    """Test minimum length validation."""
    var err = check_min_length("name", "Jo", 3)
    assert_true(err is not None)

    var no_err = check_min_length("name", "John", 3)
    assert_true(no_err is None)


fn test_check_max_length():
    """Test maximum length validation."""
    var err = check_max_length("code", "ABCDEF", 5)
    assert_true(err is not None)

    var no_err = check_max_length("code", "ABC", 5)
    assert_true(no_err is None)


fn test_check_email():
    """Test email validation."""
    var err1 = check_email("email", "invalid")
    assert_true(err1 is not None)

    var err2 = check_email("email", "missing@dot")
    assert_true(err2 is not None)

    var no_err = check_email("email", "test@example.com")
    assert_true(no_err is None)


fn test_check_url():
    """Test URL validation."""
    var err = check_url("website", "example.com")
    assert_true(err is not None)

    var no_err1 = check_url("website", "http://example.com")
    assert_true(no_err1 is None)

    var no_err2 = check_url("website", "https://example.com")
    assert_true(no_err2 is None)


fn test_check_gt_gte():
    """Test greater than validators."""
    var err1 = check_gt("age", 5, 5)
    assert_true(err1 is not None)

    var no_err1 = check_gt("age", 6, 5)
    assert_true(no_err1 is None)

    var err2 = check_gte("age", 4, 5)
    assert_true(err2 is not None)

    var no_err2 = check_gte("age", 5, 5)
    assert_true(no_err2 is None)


fn test_check_lt_lte():
    """Test less than validators."""
    var err1 = check_lt("score", 10, 10)
    assert_true(err1 is not None)

    var no_err1 = check_lt("score", 9, 10)
    assert_true(no_err1 is None)

    var err2 = check_lte("score", 11, 10)
    assert_true(err2 is not None)

    var no_err2 = check_lte("score", 10, 10)
    assert_true(no_err2 is None)


fn test_check_positive():
    """Test positive number validation."""
    var err1 = check_positive("amount", 0)
    assert_true(err1 is not None)

    var err2 = check_positive("amount", -5)
    assert_true(err2 is not None)

    var no_err = check_positive("amount", 1)
    assert_true(no_err is None)


fn test_check_alpha():
    """Test alphabetic validation."""
    var err = check_alpha("name", "John123")
    assert_true(err is not None)

    var no_err = check_alpha("name", "John")
    assert_true(no_err is None)


fn test_check_alphanumeric():
    """Test alphanumeric validation."""
    var err = check_alphanumeric("code", "ABC-123")
    assert_true(err is not None)

    var no_err = check_alphanumeric("code", "ABC123")
    assert_true(no_err is None)


fn test_check_numeric():
    """Test numeric string validation."""
    var err = check_numeric("pin", "12a4")
    assert_true(err is not None)

    var no_err = check_numeric("pin", "1234")
    assert_true(no_err is None)


fn test_string_field():
    """Test StringField constraints."""
    var field = StringField("email")
    _ = field.set_required()
    _ = field.set_email()
    _ = field.set_min_length(5)

    var errors1 = field.validate("")
    assert_true(errors1.has_errors())

    var errors2 = field.validate("bad")
    assert_true(errors2.has_errors())

    var errors3 = field.validate("test@example.com")
    assert_false(errors3.has_errors())


fn test_int_field():
    """Test IntField constraints."""
    var field = IntField("age")
    _ = field.set_required()
    _ = field.set_range(0, 150)

    var errors1 = field.validate(-1)
    assert_true(errors1.has_errors())

    var errors2 = field.validate(200)
    assert_true(errors2.has_errors())

    var errors3 = field.validate(25)
    assert_false(errors3.has_errors())


fn test_float_field():
    """Test FloatField constraints."""
    var field = FloatField("rate")
    _ = field.set_positive()
    _ = field.set_lte(100.0)

    var errors1 = field.validate(-0.5)
    assert_true(errors1.has_errors())

    var errors2 = field.validate(150.0)
    assert_true(errors2.has_errors())

    var errors3 = field.validate(50.0)
    assert_false(errors3.has_errors())


fn test_schema_validator():
    """Test SchemaValidator with multiple fields."""
    var validator = SchemaValidator()

    var email_field = StringField("email")
    _ = email_field.set_required()
    _ = email_field.set_email()
    validator.add_string_field(email_field)

    var age_field = IntField("age")
    _ = age_field.set_gte(18)
    validator.add_int_field(age_field)

    # Valid inputs
    _ = validator.validate_string("email", "test@example.com")
    _ = validator.validate_int("age", 25)
    assert_true(validator.is_valid())

    # Reset and test invalid
    validator.reset()
    _ = validator.validate_string("email", "invalid")
    _ = validator.validate_int("age", 15)
    assert_false(validator.is_valid())
    assert_equal(validator.errors().count(), 2)


fn main():
    """Run all tests."""
    print("Running mojo-validation tests...")

    test_field_error()
    print("  [PASS] test_field_error")

    test_validation_error()
    print("  [PASS] test_validation_error")

    test_check_required()
    print("  [PASS] test_check_required")

    test_check_min_length()
    print("  [PASS] test_check_min_length")

    test_check_max_length()
    print("  [PASS] test_check_max_length")

    test_check_email()
    print("  [PASS] test_check_email")

    test_check_url()
    print("  [PASS] test_check_url")

    test_check_gt_gte()
    print("  [PASS] test_check_gt_gte")

    test_check_lt_lte()
    print("  [PASS] test_check_lt_lte")

    test_check_positive()
    print("  [PASS] test_check_positive")

    test_check_alpha()
    print("  [PASS] test_check_alpha")

    test_check_alphanumeric()
    print("  [PASS] test_check_alphanumeric")

    test_check_numeric()
    print("  [PASS] test_check_numeric")

    test_string_field()
    print("  [PASS] test_string_field")

    test_int_field()
    print("  [PASS] test_int_field")

    test_float_field()
    print("  [PASS] test_float_field")

    test_schema_validator()
    print("  [PASS] test_schema_validator")

    print("\nAll tests passed!")
