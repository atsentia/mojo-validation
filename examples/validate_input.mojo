"""Input validation examples."""
from mojo_validation import Validator, Schema, Rule

fn main() raises:
    # Create validation schema
    var schema = Schema()
    schema.add_field("email", Rule.required().email())
    schema.add_field("age", Rule.required().integer().min(18).max(120))
    schema.add_field("username", Rule.required().min_length(3).max_length(20))
    
    # Validate data
    var data = Dict[String, String]()
    data["email"] = "user@example.com"
    data["age"] = "25"
    data["username"] = "johndoe"
    
    var result = schema.validate(data)
    if result.is_valid():
        print("Validation passed!")
    else:
        print("Errors:", result.errors())
    
    # Invalid data example
    var bad_data = Dict[String, String]()
    bad_data["email"] = "not-an-email"
    bad_data["age"] = "15"
    
    var bad_result = schema.validate(bad_data)
    print("Valid:", bad_result.is_valid())  # False
