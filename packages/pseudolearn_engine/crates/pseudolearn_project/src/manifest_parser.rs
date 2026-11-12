use crate::manifest_cursor::Cursor;
use crate::manifest_error::{Location, ManifestError, ManifestErrorCode};
use crate::manifest_scalars::key;
use crate::manifest_value::{Entry, Located, Node, Table};
use crate::manifest_values::value;

struct Parser {
    cursor: Cursor,
    root: Table,
    current: Option<Vec<String>>,
    duplicates: Vec<ManifestError>,
}

pub(crate) fn parse(text: &str, max_bytes: usize) -> Result<Table, Vec<ManifestError>> {
    if text.len() > max_bytes {
        return Err(vec![ManifestError::new(
            ManifestErrorCode::ManifestTooLarge,
            "",
            Location::START,
        )]);
    }
    let mut parser = Parser {
        cursor: Cursor::new(text),
        root: Table::new(Location::START, true),
        current: Some(Vec::new()),
        duplicates: Vec::new(),
    };
    parser.run().map_err(|error| vec![error])?;
    if parser.root.entries.is_empty() {
        return Err(vec![ManifestError::new(
            ManifestErrorCode::ManifestEmpty,
            "",
            Location::START,
        )]);
    }
    if !parser.duplicates.is_empty() {
        ManifestError::sort(&mut parser.duplicates);
        return Err(parser.duplicates);
    }
    Ok(parser.root)
}

impl Parser {
    fn run(&mut self) -> Result<(), ManifestError> {
        loop {
            self.cursor.skip_trivia()?;
            match self.cursor.peek() {
                None => return Ok(()),
                Some('[') => self.header()?,
                Some(_) => self.assignment()?,
            }
        }
    }

    fn header(&mut self) -> Result<(), ManifestError> {
        let position = self.cursor.location();
        self.cursor.expect('[')?;
        let mut path = Vec::new();
        loop {
            self.cursor.skip_spaces();
            path.push(key(&mut self.cursor)?);
            self.cursor.skip_spaces();
            if self.cursor.peek() != Some('.') {
                break;
            }
            self.cursor.bump();
        }
        self.cursor.expect(']')?;
        self.cursor.end_of_line()?;
        self.open(&path, position);
        Ok(())
    }

    fn open(&mut self, path: &[Located<String>], position: Location) {
        if define(&mut self.root, path, position) {
            self.current = Some(path.iter().map(|segment| segment.value.clone()).collect());
            return;
        }
        let field: Vec<&str> = path.iter().map(|segment| segment.value.as_str()).collect();
        self.duplicates.push(ManifestError::new(
            ManifestErrorCode::DuplicateKey,
            &field.join("."),
            position,
        ));
        self.current = None;
    }

    fn assignment(&mut self) -> Result<(), ManifestError> {
        let name = key(&mut self.cursor)?;
        self.cursor.skip_spaces();
        self.cursor.expect('=')?;
        self.cursor.skip_spaces();
        let parsed = value(&mut self.cursor, &mut self.duplicates)?;
        self.cursor.end_of_line()?;
        let Some(path) = self.current.clone() else {
            return Ok(());
        };
        let Some(table) = resolve(&mut self.root, &path) else {
            return Ok(());
        };
        if table.entries.contains_key(&name.value) {
            let mut field = path;
            field.push(name.value);
            self.duplicates.push(ManifestError::new(
                ManifestErrorCode::DuplicateKey,
                &field.join("."),
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
}

fn define(root: &mut Table, path: &[Located<String>], header: Location) -> bool {
    let mut table = root;
    for (position, segment) in path.iter().enumerate() {
        let last = position.saturating_add(1) == path.len();
        let entry = table
            .entries
            .entry(segment.value.clone())
            .or_insert_with(|| Entry {
                key_at: segment.position,
                node: Node::Table(Table::new(header, false)),
            });
        let Node::Table(next) = &mut entry.node else {
            return false;
        };
        if last {
            if next.defined {
                return false;
            }
            next.defined = true;
            next.position = header;
        }
        table = next;
    }
    true
}

fn resolve<'table>(root: &'table mut Table, path: &[String]) -> Option<&'table mut Table> {
    let mut table = root;
    for name in path {
        match table.entries.get_mut(name).map(|entry| &mut entry.node) {
            Some(Node::Table(next)) => table = next,
            _ => return None,
        }
    }
    Some(table)
}
