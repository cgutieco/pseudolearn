use crate::dap_session::{DapSession, Reference};
use serde_json::Value;

impl DapSession {
    pub(crate) fn reference(&mut self, reference: Reference) -> Result<i32, String> {
        if self.references.len() >= 65536 {
            return Err("debug reference table limit exceeded".to_owned());
        }
        let identifier = self
            .next_reference
            .checked_add(1)
            .ok_or("debug references exhausted")?;
        self.next_reference = identifier;
        self.references.insert(identifier, reference);
        Ok(identifier)
    }

    pub(crate) fn frame(&self, identifier: &Value) -> Result<(u64, u64), String> {
        let identifier = identifier
            .as_i64()
            .and_then(|value| i32::try_from(value).ok())
            .ok_or("invalid frame reference")?;
        match self.references.get(&identifier) {
            Some(Reference::Frame {
                task,
                position,
                generation,
            }) if *generation == self.generation() => Ok((*task, *position)),
            _ => Err("stale or foreign frame reference".to_owned()),
        }
    }

    pub(crate) fn variable_reference(
        &self,
        identifier: &Value,
    ) -> Result<(u64, u64, String), String> {
        let identifier = identifier
            .as_i64()
            .and_then(|value| i32::try_from(value).ok())
            .ok_or("invalid variable reference")?;
        match self.references.get(&identifier) {
            Some(Reference::Variables {
                task,
                target,
                query,
                generation,
            }) if *generation == self.generation() => Ok((*task, *target, query.clone())),
            _ => Err("stale or foreign variable reference".to_owned()),
        }
    }
}
