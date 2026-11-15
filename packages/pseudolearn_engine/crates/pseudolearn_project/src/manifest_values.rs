use crate::manifest_cursor::Cursor;
use crate::manifest_error::{ManifestError, ManifestErrorCode};
use crate::manifest_scalars::{key, scalar};
use crate::manifest_value::{Entry, Located, Node, Scalar, Table, Value};

pub(crate) fn value(
    cursor: &mut Cursor,
    duplicates: &mut Vec<ManifestError>,
) -> Result<Located<Value>, ManifestError> {
    let position = cursor.location();
    let parsed = match cursor.peek() {
        Some('[') => Value::List(list(cursor)?),
        Some('{') => Value::Inline(inline(cursor, duplicates)?),
        _ => Value::Scalar(scalar(cursor)?.value),
    };
    Ok(Located {
        position,
        value: parsed,
    })
}

fn list(cursor: &mut Cursor) -> Result<Vec<Located<Scalar>>, ManifestError> {
    cursor.expect('[')?;
    let mut items = Vec::new();
    loop {
        cursor.skip_trivia()?;
        if cursor.peek() == Some(']') {
            cursor.bump();
            return Ok(items);
        }
        items.push(scalar(cursor)?);
        cursor.skip_trivia()?;
        match cursor.peek() {
            Some(',') => {
                cursor.bump();
            }
            Some(']') => {}
            _ => return Err(cursor.syntax()),
        }
    }
}

fn inline(
    cursor: &mut Cursor,
    duplicates: &mut Vec<ManifestError>,
) -> Result<Table, ManifestError> {
    let mut table = Table::new(cursor.location(), true);
    cursor.expect('{')?;
    cursor.skip_spaces();
    if cursor.peek() == Some('}') {
        cursor.bump();
        return Ok(table);
    }
    loop {
        cursor.skip_spaces();
        entry(cursor, &mut table, duplicates)?;
        cursor.skip_spaces();
        match cursor.peek() {
            Some(',') => {
                cursor.bump();
            }
            Some('}') => {
                cursor.bump();
                return Ok(table);
            }
            _ => return Err(cursor.syntax()),
        }
    }
}

fn entry(
    cursor: &mut Cursor,
    table: &mut Table,
    duplicates: &mut Vec<ManifestError>,
) -> Result<(), ManifestError> {
    let name = key(cursor)?;
    cursor.skip_spaces();
    cursor.expect('=')?;
    cursor.skip_spaces();
    let position = cursor.location();
    let parsed = Located {
        position,
        value: Value::Scalar(scalar(cursor)?.value),
    };
    if table.entries.contains_key(&name.value) {
        duplicates.push(ManifestError::new(
            ManifestErrorCode::DuplicateKey,
            &name.value,
            name.position,
        ));
        return Ok(());
    }
    table.entries.insert(
        name.value,
        Entry {
            key_at: name.position,
            node: Node::Value(parsed),
        },
    );
    Ok(())
}
