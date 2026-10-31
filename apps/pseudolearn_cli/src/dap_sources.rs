use serde_json::{Value, json};
use std::collections::BTreeMap;

pub(crate) struct SourceSnapshot {
    pub(crate) path: String,
    pub(crate) text: String,
    pub(crate) revision: Option<String>,
}

#[derive(Default)]
pub(crate) struct Sources {
    pub(crate) snapshots: BTreeMap<u32, SourceSnapshot>,
    pub(crate) lines_start_at_one: bool,
    pub(crate) columns_start_at_one: bool,
}

impl Sources {
    pub(crate) fn describe(&self, identifier: u32) -> Value {
        let Some(source) = self.snapshots.get(&identifier) else {
            return Value::Null;
        };
        let reference = u64::from(identifier).saturating_add(1);
        let name = std::path::Path::new(&source.path)
            .file_name()
            .and_then(|name| name.to_str());
        json!({"name":name,"path":source.path,"sourceReference":reference,
            "presentationHint":"deemphasize","origin":"PseudoLearn snapshot",
            "adapterData":{"source_id":identifier,"revision":source.revision}})
    }

    pub(crate) fn identifier(&self, request: &Value) -> Result<u32, String> {
        if let Some(reference) = request.get("sourceReference").and_then(Value::as_u64) {
            return reference
                .checked_sub(1)
                .and_then(|value| u32::try_from(value).ok())
                .filter(|identifier| self.snapshots.contains_key(identifier))
                .ok_or_else(|| "unknown source reference".to_owned());
        }
        let path = request
            .get("path")
            .and_then(Value::as_str)
            .ok_or("missing source")?;
        let canonical = std::fs::canonicalize(path).ok();
        self.snapshots
            .iter()
            .find(|(_, source)| {
                source.path == path
                    || canonical
                        .as_deref()
                        .is_some_and(|resolved| resolved == std::path::Path::new(&source.path))
            })
            .map(|(identifier, _)| *identifier)
            .ok_or_else(|| "source is outside execution snapshot".to_owned())
    }

    pub(crate) fn location(&self, identifier: u32, line: u64, column: u64) -> (u64, u64) {
        let units = self
            .line(identifier, line)
            .chars()
            .take(usize::try_from(column.saturating_sub(1)).unwrap_or(usize::MAX))
            .map(char::len_utf16)
            .sum::<usize>();
        let units = u64::try_from(units).unwrap_or(u64::MAX);
        (
            line.saturating_sub(u64::from(!self.lines_start_at_one)),
            units.saturating_add(u64::from(self.columns_start_at_one)),
        )
    }

    pub(crate) fn core_location(
        &self,
        identifier: u32,
        line: u64,
        column: u64,
    ) -> Result<(u64, u64), String> {
        let line = line
            .checked_add(u64::from(!self.lines_start_at_one))
            .ok_or("invalid line")?;
        let units = column
            .checked_sub(u64::from(self.columns_start_at_one))
            .ok_or("invalid column")?;
        let mut consumed = 0_u64;
        let mut scalars = 1_u64;
        for character in self.line(identifier, line).chars() {
            if consumed == units {
                return Ok((line, scalars));
            }
            consumed = consumed.saturating_add(u64::try_from(character.len_utf16()).unwrap_or(2));
            scalars = scalars.saturating_add(1);
        }
        if consumed == units {
            Ok((line, scalars))
        } else {
            Err("column is not a Unicode boundary".to_owned())
        }
    }

    fn line(&self, identifier: u32, line: u64) -> &str {
        self.snapshots
            .get(&identifier)
            .and_then(|source| {
                source
                    .text
                    .lines()
                    .nth(usize::try_from(line.saturating_sub(1)).unwrap_or(usize::MAX))
            })
            .unwrap_or("")
    }
}
