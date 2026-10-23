use crate::manifest_cursor::Cursor;
use crate::manifest_error::{Location, ManifestError};
use crate::manifest_value::{Located, Scalar};

pub(crate) fn key(cursor: &mut Cursor) -> Result<Located<String>, ManifestError> {
    let position = cursor.location();
    if cursor.peek() == Some('"') {
        let text = quoted(cursor)?;
        return Ok(Located {
            position,
            value: text,
        });
    }
    let mut name = String::new();
    while let Some(character) = cursor.peek() {
        if !(character.is_ascii_alphanumeric() || character == '-' || character == '_') {
            break;
        }
        name.push(character);
        cursor.bump();
    }
    if name.is_empty() {
        return Err(cursor.syntax());
    }
    Ok(Located {
        position,
        value: name,
    })
}

pub(crate) fn scalar(cursor: &mut Cursor) -> Result<Located<Scalar>, ManifestError> {
    let position = cursor.location();
    match cursor.peek() {
        Some('"') => Ok(Located {
            position,
            value: Scalar::Text(quoted(cursor)?),
        }),
        Some(digit) if digit.is_ascii_digit() => Ok(Located {
            position,
            value: Scalar::Integer(integer(cursor, position)?),
        }),
        _ => Err(cursor.syntax()),
    }
}

fn integer(cursor: &mut Cursor, position: Location) -> Result<u64, ManifestError> {
    let mut value: u64 = 0;
    let mut digits = 0_usize;
    let leading_zero = cursor.peek() == Some('0');
    while let Some(digit) = cursor.peek().and_then(|character| character.to_digit(10)) {
        value = value
            .checked_mul(10)
            .and_then(|scaled| scaled.checked_add(u64::from(digit)))
            .ok_or_else(|| overflow(position))?;
        digits = digits.saturating_add(1);
        cursor.bump();
    }
    if leading_zero && digits > 1 {
        return Err(overflow(position));
    }
    Ok(value)
}

fn overflow(position: Location) -> ManifestError {
    ManifestError::new(
        crate::manifest_error::ManifestErrorCode::ManifestSyntax,
        "",
        position,
    )
}

fn quoted(cursor: &mut Cursor) -> Result<String, ManifestError> {
    cursor.expect('"')?;
    let mut text = String::new();
    loop {
        match cursor.peek() {
            Some('"') => {
                cursor.bump();
                return Ok(text);
            }
            Some('\\') => {
                cursor.bump();
                text.push(escape(cursor)?);
            }
            Some(character) if !character.is_control() || character == '\t' => {
                text.push(character);
                cursor.bump();
            }
            _ => return Err(cursor.syntax()),
        }
    }
}

fn escape(cursor: &mut Cursor) -> Result<char, ManifestError> {
    let escaped = match cursor.peek() {
        Some('"') => '"',
        Some('\\') => '\\',
        Some('n') => '\n',
        Some('t') => '\t',
        Some('u') => {
            cursor.bump();
            return unicode(cursor);
        }
        _ => return Err(cursor.syntax()),
    };
    cursor.bump();
    Ok(escaped)
}

fn unicode(cursor: &mut Cursor) -> Result<char, ManifestError> {
    let position = cursor.location();
    let mut code: u32 = 0;
    for _ in 0..4 {
        let digit = cursor
            .peek()
            .and_then(|character| character.to_digit(16))
            .ok_or_else(|| cursor.syntax())?;
        code = code.saturating_mul(16).saturating_add(digit);
        cursor.bump();
    }
    char::from_u32(code).ok_or_else(|| overflow(position))
}
