def clean_text(value):
    if value is None:
        return ""
    return str(value).strip()


def validate_boolean(value, field_name="value"):
    if not isinstance(value, bool):
        raise ValueError(f"{field_name} must be true or false.")
