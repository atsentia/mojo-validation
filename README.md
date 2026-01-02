# mojo-validation

Input validation and schema enforcement for Mojo applications. A pure Mojo alternative to Python's Pydantic.

## Features

- **Field Constraints**: Required, min/max length, range, patterns
- **Format Validators**: Email, URL, alpha, numeric, alphanumeric
- **Schema Validation**: Pydantic-style model validation
- **Rich Errors**: Detailed error messages with field names and values

## Installation

Add to your `pixi.toml`:

```toml
[workspace.dependencies]
mojo-validation = { path = "../mojo-libs/mojo-validation" }
```

## Usage

### Quick Validation

```mojo
from mojo_validation import validate_required, validate_email, validate_range

# These raise on failure
validate_required("name", user_name)
validate_email("email", user_email)
validate_range("age", user_age, 0, 150)
```

### Check Validators (Return Optional[FieldError])

```mojo
from mojo_validation import check_required, check_email, check_positive

var err = check_required("name", "")
if err:
    print("Error:", err.value())

var email_err = check_email("email", "invalid")
if email_err:
    print("Invalid email:", email_err.value().message)
```

### Field Constraints

```mojo
from mojo_validation import StringField, IntField, FloatField

# String field with constraints
var email_field = StringField("email")
    .set_required()
    .set_email()
    .set_max_length(255)

var errors = email_field.validate(user_input)
if errors.has_errors():
    print(errors)

# Int field with range
var age_field = IntField("age")
    .set_required()
    .set_range(0, 150)

# Float field with bounds
var rate_field = FloatField("rate")
    .set_positive()
    .set_lte(100.0)
```

### Schema Validation

```mojo
from mojo_validation import SchemaValidator, StringField, IntField

var validator = SchemaValidator()

# Define fields
var email = StringField("email")
    .set_required()
    .set_email()
validator.add_string_field(email)

var username = StringField("username")
    .set_required()
    .set_min_length(3)
    .set_max_length(20)
    .set_alphanumeric()
validator.add_string_field(username)

var age = IntField("age")
    .set_gte(18)
    .set_lte(120)
validator.add_int_field(age)

# Validate inputs
validator.validate_string("email", user_email)
validator.validate_string("username", user_name)
validator.validate_int("age", user_age)

if validator.is_valid():
    print("All inputs valid!")
else:
    print(validator.errors())
```

### Validation Result

```mojo
from mojo_validation import ValidationResult

fn parse_and_validate(data: String) -> ValidationResult[UserData]:
    var errors = ValidationError()

    # ... validation logic ...

    if errors.has_errors():
        return ValidationResult[UserData](errors)

    return ValidationResult[UserData](parsed_user)

var result = parse_and_validate(input)
if result.is_valid():
    process(result.value())
else:
    handle_errors(result.errors())
```

## API Reference

### Validator Functions

| Function | Description |
|----------|-------------|
| `check_required(field, value)` | Check value is not empty |
| `check_min_length(field, value, min)` | Check minimum length |
| `check_max_length(field, value, max)` | Check maximum length |
| `check_length(field, value, min, max)` | Check length in range |
| `check_gt(field, value, threshold)` | Check value > threshold |
| `check_gte(field, value, threshold)` | Check value >= threshold |
| `check_lt(field, value, threshold)` | Check value < threshold |
| `check_lte(field, value, threshold)` | Check value <= threshold |
| `check_range(field, value, min, max)` | Check value in range |
| `check_positive(field, value)` | Check value > 0 |
| `check_non_negative(field, value)` | Check value >= 0 |
| `check_email(field, value)` | Check email format |
| `check_url(field, value)` | Check URL format |
| `check_alpha(field, value)` | Check alphabetic only |
| `check_alphanumeric(field, value)` | Check alphanumeric only |
| `check_numeric(field, value)` | Check numeric string |
| `check_one_of(field, value, options)` | Check value in list |

### StringField Methods

| Method | Description |
|--------|-------------|
| `set_required()` | Mark as required |
| `set_min_length(n)` | Set minimum length |
| `set_max_length(n)` | Set maximum length |
| `set_length(min, max)` | Set length range |
| `set_email()` | Validate as email |
| `set_url()` | Validate as URL |
| `set_alpha()` | Alphabetic only |
| `set_alphanumeric()` | Alphanumeric only |
| `set_numeric()` | Numeric string only |
| `set_one_of(values)` | Restrict to list |
| `validate(value)` | Run all validations |

### IntField Methods

| Method | Description |
|--------|-------------|
| `set_required()` | Mark as required |
| `set_gt(n)` | Greater than |
| `set_gte(n)` | Greater than or equal |
| `set_lt(n)` | Less than |
| `set_lte(n)` | Less than or equal |
| `set_range(min, max)` | Value in range |
| `set_positive()` | Positive only (> 0) |
| `set_non_negative()` | Non-negative (>= 0) |
| `validate(value, is_set)` | Run all validations |

### FloatField Methods

| Method | Description |
|--------|-------------|
| `set_required()` | Mark as required |
| `set_gt(n)` | Greater than |
| `set_gte(n)` | Greater than or equal |
| `set_lt(n)` | Less than |
| `set_lte(n)` | Less than or equal |
| `set_range(min, max)` | Value in range |
| `set_positive()` | Positive only |
| `validate(value, is_set)` | Run all validations |

## Error Handling

```mojo
from mojo_validation import ValidationError, FieldError

var errors = ValidationError()
errors.add("email", "is required")
errors.add("age", "must be positive", "-5")

print(errors.count())       # 2
print(errors.has_errors())  # True
print(errors.first_error()) # "email: is required"
print(errors)               # Full error report
```

## License

Apache 2.0

## Part of mojo-contrib

This library is part of [mojo-contrib](https://github.com/atsentia/mojo-contrib), a collection of pure Mojo libraries.
