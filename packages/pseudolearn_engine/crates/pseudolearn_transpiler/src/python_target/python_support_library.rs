pub(crate) const TEXT_CONTAINS: &str = r#"def text_contains(text, part):
    return part in text"#;

pub(crate) const TEXT_STARTS_WITH: &str = r#"def text_starts_with(text, part):
    return text.startswith(part)"#;

pub(crate) const TEXT_ENDS_WITH: &str = r#"def text_ends_with(text, part):
    return text.endswith(part)"#;

pub(crate) const TEXT_TRIM: &str = r#"def text_trim(text):
    return text.strip(" \t\n\r")"#;

pub(crate) const TEXT_JOIN: &str = r#"def text_join(parts, separator):
    return separator.join(parts)"#;

pub(crate) const TEXT_TO_UPPER: &str = r#"def text_to_upper(text):
    return text.upper()"#;

pub(crate) const TEXT_TO_LOWER: &str = r#"def text_to_lower(text):
    return text.lower()"#;

pub(crate) const TEXT_PADDING: &str = r#"def padding(text, width, fill):
    if len(fill) != 1:
        raise ValueError("invalidPaddingText")
    if width < 0:
        raise ValueError("paddingWidthOutOfRange")
    return fill * max(width - len(text), 0)"#;

pub(crate) const TEXT_PAD_LEFT: &str = r#"def text_pad_left(text, width, fill):
    return padding(text, width, fill) + text"#;

pub(crate) const TEXT_PAD_RIGHT: &str = r#"def text_pad_right(text, width, fill):
    return text + padding(text, width, fill)"#;

pub(crate) const TEXT_DECIMALS: &str = r#"def text_decimals(value, places):
    if not 0 <= places <= 100:
        raise ValueError("decimalPlacesOutOfRange")
    if math.isnan(value):
        return "NaN"
    if math.isinf(value):
        return "inf" if value > 0 else "-inf"
    context = decimal.Context(prec=1200, rounding=decimal.ROUND_HALF_UP)
    rounded = decimal.Decimal(value).quantize(decimal.Decimal(1).scaleb(-places), context=context)
    text = f"{rounded.copy_abs():f}"
    return ("-" if math.copysign(1.0, value) < 0 else "") + text"#;

pub(crate) const BYTES_NEW: &str = r#"def bytes_new():
    return b"""#;

pub(crate) const BYTES_LENGTH: &str = r#"def bytes_length(content):
    return len(content)"#;

pub(crate) const BYTES_AT: &str = r#"def bytes_at(content, index):
    if not 0 <= index < len(content):
        raise IndexError("bytesIndexOutOfBounds")
    return content[index]"#;

pub(crate) const BYTES_UTF8: &str = r#"def bytes_utf8(content):
    try:
        return Ok(content.decode())
    except UnicodeDecodeError:
        return Err(IoError("utf8_invalido", False))"#;

pub(crate) const BYTES_FROM_TEXT: &str = r#"def bytes_from_text(text):
    return text.encode()"#;

pub(crate) const BYTES_SEGMENT: &str = r#"def bytes_segment(content, start, count):
    if start < 0 or count < 0 or start + count > len(content):
        raise IndexError("bytesRangeOutOfBounds")
    return content[start:start + count]"#;

pub(crate) const BYTES_JOIN: &str = r#"def bytes_join(left, right):
    return left + right"#;

pub(crate) const REAL_MINIMUM: &str = r#"def real_minimum(left, right):
    if left == 0.0 and right == 0.0:
        return left if math.copysign(1.0, left) < 0 else right
    if math.isnan(left) or math.isnan(right):
        return right if math.isnan(left) else left
    return min(left, right)"#;

pub(crate) const REAL_MAXIMUM: &str = r#"def real_maximum(left, right):
    if left == 0.0 and right == 0.0:
        return right if math.copysign(1.0, left) < 0 else left
    if math.isnan(left) or math.isnan(right):
        return right if math.isnan(left) else left
    return max(left, right)"#;
