use crate::physical_error::{HostError, committed};
use crate::physical_host::PhysicalHost;
use crate::physical_request::{Argument, Request, WRITE};
use serde_json::{Value, json};
use std::io::{Seek, SeekFrom, Write};

impl PhysicalHost {
    pub(crate) fn append_all(&mut self, request: &Request) -> Result<Value, HostError> {
        let bytes = match request.arguments.first() {
            Some(Argument::Text(text)) => text.as_bytes().to_vec(),
            Some(Argument::Bytes(bytes)) => bytes.clone(),
            _ => return Err(HostError::INVALID_PATH),
        };
        let (file, rights) = crate::physical_files::file_of(self.entry(request)?)?;
        if rights & WRITE == 0 {
            return Err(HostError::PERMISSION_DENIED);
        }
        file.seek(SeekFrom::End(0))
            .and_then(|_| file.write_all(&bytes))
            .and_then(|()| file.sync_all())
            .map_err(|_| HostError::UNCERTAIN_INTERRUPTED)?;
        let count = i64::try_from(bytes.len()).map_err(|_| HostError::INTERRUPTED)?;
        Ok(committed("integer", json!(count)))
    }
}
