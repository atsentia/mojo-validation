"""
Built-in Validators

Common validation functions for fields.
"""

from .errors import FieldError


fn validate_required(field: String, value: String) -> Optional[FieldError]:
    """Validate that a value is not empty."""
    if len(value) == 0:
        return FieldError(field, "is required")
    return None


fn validate_min_length(field: String, value: String, min_len: Int) -> Optional[FieldError]:
    """Validate minimum string length."""
    if len(value) < min_len:
        return FieldError(
            field,
            "must be at least " + str(min_len) + " characters",
            value
        )
    return None


fn validate_max_length(field: String, value: String, max_len: Int) -> Optional[FieldError]:
    """Validate maximum string length."""
    if len(value) > max_len:
        return FieldError(
            field,
            "must be at most " + str(max_len) + " characters",
            value
        )
    return None


fn validate_length(field: String, value: String, min_len: Int, max_len: Int) -> Optional[FieldError]:
    """Validate string length within range."""
    var length = len(value)
    if length < min_len or length > max_len:
        return FieldError(
            field,
            "must be between " + str(min_len) + " and " + str(max_len) + " characters",
            value
        )
    return None


fn validate_gt(field: String, value: Int, threshold: Int) -> Optional[FieldError]:
    """Validate value is greater than threshold."""
    if value <= threshold:
        return FieldError(
            field,
            "must be greater than " + str(threshold),
            str(value)
        )
    return None


fn validate_gte(field: String, value: Int, threshold: Int) -> Optional[FieldError]:
    """Validate value is greater than or equal to threshold."""
    if value < threshold:
        return FieldError(
            field,
            "must be greater than or equal to " + str(threshold),
            str(value)
        )
    return None


fn validate_lt(field: String, value: Int, threshold: Int) -> Optional[FieldError]:
    """Validate value is less than threshold."""
    if value >= threshold:
        return FieldError(
            field,
            "must be less than " + str(threshold),
            str(value)
        )
    return None


fn validate_lte(field: String, value: Int, threshold: Int) -> Optional[FieldError]:
    """Validate value is less than or equal to threshold."""
    if value > threshold:
        return FieldError(
            field,
            "must be less than or equal to " + str(threshold),
            str(value)
        )
    return None


fn validate_range(field: String, value: Int, min_val: Int, max_val: Int) -> Optional[FieldError]:
    """Validate value is within range (inclusive)."""
    if value < min_val or value > max_val:
        return FieldError(
            field,
            "must be between " + str(min_val) + " and " + str(max_val),
            str(value)
        )
    return None


fn validate_float_gt(field: String, value: Float64, threshold: Float64) -> Optional[FieldError]:
    """Validate float is greater than threshold."""
    if value <= threshold:
        return FieldError(
            field,
            "must be greater than " + str(threshold),
            str(value)
        )
    return None


fn validate_float_gte(field: String, value: Float64, threshold: Float64) -> Optional[FieldError]:
    """Validate float is greater than or equal to threshold."""
    if value < threshold:
        return FieldError(
            field,
            "must be greater than or equal to " + str(threshold),
            str(value)
        )
    return None


fn validate_float_lt(field: String, value: Float64, threshold: Float64) -> Optional[FieldError]:
    """Validate float is less than threshold."""
    if value >= threshold:
        return FieldError(
            field,
            "must be less than " + str(threshold),
            str(value)
        )
    return None


fn validate_float_lte(field: String, value: Float64, threshold: Float64) -> Optional[FieldError]:
    """Validate float is less than or equal to threshold."""
    if value > threshold:
        return FieldError(
            field,
            "must be less than or equal to " + str(threshold),
            str(value)
        )
    return None


fn validate_positive(field: String, value: Int) -> Optional[FieldError]:
    """Validate value is positive (> 0)."""
    return validate_gt(field, value, 0)


fn validate_non_negative(field: String, value: Int) -> Optional[FieldError]:
    """Validate value is non-negative (>= 0)."""
    return validate_gte(field, value, 0)


fn validate_email(field: String, value: String) -> Optional[FieldError]:
    """Basic email validation (contains @)."""
    if "@" not in value or "." not in value:
        return FieldError(field, "must be a valid email address", value)

    var at_pos = value.find("@")
    if at_pos < 1 or at_pos == len(value) - 1:
        return FieldError(field, "must be a valid email address", value)

    return None


fn validate_url(field: String, value: String) -> Optional[FieldError]:
    """Basic URL validation (starts with http:// or https://)."""
    if not value.startswith("http://") and not value.startswith("https://"):
        return FieldError(field, "must be a valid URL", value)
    return None


fn validate_alpha(field: String, value: String) -> Optional[FieldError]:
    """Validate string contains only alphabetic characters."""
    for i in range(len(value)):
        var c = ord(value[i])
        if not ((c >= 65 and c <= 90) or (c >= 97 and c <= 122)):
            return FieldError(field, "must contain only alphabetic characters", value)
    return None


fn validate_alphanumeric(field: String, value: String) -> Optional[FieldError]:
    """Validate string contains only alphanumeric characters."""
    for i in range(len(value)):
        var c = ord(value[i])
        if not ((c >= 65 and c <= 90) or (c >= 97 and c <= 122) or (c >= 48 and c <= 57)):
            return FieldError(field, "must contain only alphanumeric characters", value)
    return None


fn validate_numeric(field: String, value: String) -> Optional[FieldError]:
    """Validate string contains only numeric characters."""
    for i in range(len(value)):
        var c = ord(value[i])
        if not (c >= 48 and c <= 57):
            return FieldError(field, "must contain only numeric characters", value)
    return None


fn validate_one_of(field: String, value: String, allowed: List[String]) -> Optional[FieldError]:
    """Validate value is one of allowed options."""
    for i in range(len(allowed)):
        if value == allowed[i]:
            return None

    var options = String("")
    for i in range(len(allowed)):
        if i > 0:
            options += ", "
        options += allowed[i]

    return FieldError(field, "must be one of: " + options, value)


fn validate_not_empty_list[T: CollectionElement](field: String, value: List[T]) -> Optional[FieldError]:
    """Validate list is not empty."""
    if len(value) == 0:
        return FieldError(field, "must not be empty")
    return None


fn validate_list_size[T: CollectionElement](
    field: String,
    value: List[T],
    min_size: Int,
    max_size: Int
) -> Optional[FieldError]:
    """Validate list size within range."""
    var size = len(value)
    if size < min_size or size > max_size:
        return FieldError(
            field,
            "must have between " + str(min_size) + " and " + str(max_size) + " items",
            str(size) + " items"
        )
    return None
