use crate::logical_path::{is_prefix, segments};
use crate::manifest_error::{Location, ManifestError, ManifestErrorCode};
use crate::manifest_value::{Entry, Located, Node, Scalar, Table, Value};

pub(crate) struct Checker {
    pub errors: Vec<ManifestError>,
    pub root: Vec<String>,
}

pub(crate) fn join(prefix: &str, name: &str) -> String {
    if prefix.is_empty() {
        name.to_owned()
    } else {
        format!("{prefix}.{name}")
    }
}

impl Checker {
    pub(crate) fn report(&mut self, code: ManifestErrorCode, field: &str, position: Location) {
        self.errors.push(ManifestError::new(code, field, position));
    }

    pub(crate) fn reject_unknown(&mut self, table: &Table, allowed: &[&str], prefix: &str) {
        for (name, entry) in &table.entries {
            if !allowed.contains(&name.as_str()) {
                self.report(
                    ManifestErrorCode::UnknownField,
                    &join(prefix, name),
                    entry.key_at,
                );
            }
        }
    }

    pub(crate) fn require<'table>(
        &mut self,
        table: &'table Table,
        name: &str,
        prefix: &str,
    ) -> Option<&'table Entry> {
        let found = table.entries.get(name);
        if found.is_none() {
            self.report(
                ManifestErrorCode::MissingField,
                &join(prefix, name),
                table.position,
            );
        }
        found
    }

    pub(crate) fn table<'entry>(
        &mut self,
        entry: &'entry Entry,
        field: &str,
    ) -> Option<&'entry Table> {
        match &entry.node {
            Node::Table(table) => Some(table),
            Node::Value(Located {
                value: Value::Inline(table),
                ..
            }) => Some(table),
            Node::Value(located) => {
                self.report(ManifestErrorCode::InvalidValue, field, located.position);
                None
            }
        }
    }

    pub(crate) fn scalar<'entry>(
        &mut self,
        entry: &'entry Entry,
        field: &str,
    ) -> Option<Located<&'entry Scalar>> {
        match &entry.node {
            Node::Value(Located {
                position,
                value: Value::Scalar(scalar),
            }) => Some(Located {
                position: *position,
                value: scalar,
            }),
            Node::Value(located) => {
                self.report(ManifestErrorCode::InvalidValue, field, located.position);
                None
            }
            Node::Table(table) => {
                self.report(ManifestErrorCode::InvalidValue, field, table.position);
                None
            }
        }
    }

    pub(crate) fn text(&mut self, entry: &Entry, field: &str) -> Option<Located<String>> {
        let scalar = self.scalar(entry, field)?;
        match scalar.value {
            Scalar::Text(text) => Some(Located {
                position: scalar.position,
                value: text.clone(),
            }),
            Scalar::Integer(_) => {
                self.report(ManifestErrorCode::InvalidValue, field, scalar.position);
                None
            }
        }
    }

    pub(crate) fn list<'entry>(
        &mut self,
        entry: &'entry Entry,
        field: &str,
    ) -> Option<&'entry [Located<Scalar>]> {
        match &entry.node {
            Node::Value(Located {
                value: Value::List(items),
                ..
            }) => Some(items),
            Node::Value(located) => {
                self.report(ManifestErrorCode::InvalidValue, field, located.position);
                None
            }
            Node::Table(table) => {
                self.report(ManifestErrorCode::InvalidValue, field, table.position);
                None
            }
        }
    }

    pub(crate) fn text_items(
        &mut self,
        items: &[Located<Scalar>],
        field: &str,
    ) -> Vec<(usize, Located<String>)> {
        let mut texts = Vec::new();
        for (position, element) in items.iter().enumerate() {
            match &element.value {
                Scalar::Text(text) => texts.push((
                    position,
                    Located {
                        position: element.position,
                        value: text.clone(),
                    },
                )),
                Scalar::Integer(_) => self.report(
                    ManifestErrorCode::InvalidValue,
                    &format!("{field}[{position}]"),
                    element.position,
                ),
            }
        }
        texts
    }

    pub(crate) fn path_under_root(&mut self, path: &Located<String>, field: &str) -> bool {
        let valid = segments(&path.value).is_some_and(|parts| is_prefix(&self.root, &parts));
        if !valid {
            self.report(ManifestErrorCode::InvalidPath, field, path.position);
        }
        valid
    }
}
