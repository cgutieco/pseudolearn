use crate::physical_error::{HostError, committed};
use crate::physical_host::PhysicalHost;
use crate::physical_request::{
    Argument, READ, Request, WRITE, checked_path, mode_rights,
};
use cap_std::fs::{Dir, File, OpenOptions};
use serde_json::{Value, json};
use std::io::{Read, Seek, SeekFrom, Write};

pub(crate) enum Resource {
    Plain,
    Directory(Dir),
    File(File),
}

pub(crate) struct Entry {
    generation: u64,
    rights: u8,
    resource: Resource,
}

impl PhysicalHost {
    pub(crate) fn register_plain(&mut self, request: &Request) -> Result<Value, HostError> {
        self.register(request, 0, Resource::Plain)
    }

    pub(crate) fn request_root(&mut self, request: &Request) -> Result<Value, HostError> {
        if request.text(0)? != "root" {
            return Err(HostError::NOT_FOUND);
        }
        let (directory, granted) = self.root.as_ref().ok_or(HostError::PERMISSION_DENIED)?;
        let rights = request.result()?.rights;
        if rights & !granted != 0 {
            return Err(HostError::PERMISSION_DENIED);
        }
        let clone = directory.try_clone().map_err(|error| HostError::from_io(&error))?;
        self.register(request, rights, Resource::Directory(clone))
    }

    pub(crate) fn file_operation(&mut self, request: &Request) -> Result<Value, HostError> {
        match request.operation.as_str() {
            "file_open" => self.open_file(request),
            "directory_derive" => self.derive_directory(request),
            "file_read_bytes" => self.read_all(request).map(|bytes| committed("bytes", json!(bytes))),
            "file_read_text" => self.read_text(request),
            "file_write_bytes" | "file_write_text" => self.write_all(request),
            "file_close" | "directory_close" => self.close(request),
            _ => Err(HostError::INTERRUPTED),
        }
    }

    fn register(
        &mut self,
        request: &Request,
        rights: u8,
        resource: Resource,
    ) -> Result<Value, HostError> {
        let capability = request.result()?;
        self.entries.insert(
            capability.slot,
            Entry {
                generation: capability.generation,
                rights,
                resource,
            },
        );
        Ok(committed(
            "capability",
            json!({"slot":capability.slot,"generation":capability.generation,"rights":capability.rights,"kind":capability.kind}),
        ))
    }

    fn entry(&mut self, request: &Request) -> Result<&mut Entry, HostError> {
        let receiver = request.receiver()?;
        self.entries
            .get_mut(&receiver.slot)
            .filter(|entry| entry.generation == receiver.generation)
            .ok_or(HostError::CLOSED)
    }

    fn open_file(&mut self, request: &Request) -> Result<Value, HostError> {
        let path = checked_path(request.text(0)?)?;
        let wanted = mode_rights(request.text(1)?)?;
        let file = {
            let (directory, rights) = directory_of(self.entry(request)?)?;
            if wanted & !rights != 0 {
                return Err(HostError::PERMISSION_DENIED);
            }
            directory
                .open_with(path, &options(wanted))
                .map_err(|error| HostError::from_io(&error))?
        };
        self.register(request, wanted, Resource::File(file))
    }

    fn derive_directory(&mut self, request: &Request) -> Result<Value, HostError> {
        let path = checked_path(request.text(0)?)?;
        let wanted = mode_rights(request.text(1)?)?;
        let child = {
            let (directory, rights) = directory_of(self.entry(request)?)?;
            if wanted & !rights != 0 {
                return Err(HostError::PERMISSION_DENIED);
            }
            directory
                .open_dir(path)
                .map_err(|error| HostError::from_io(&error))?
        };
        self.register(request, wanted, Resource::Directory(child))
    }

    fn read_all(&mut self, request: &Request) -> Result<Vec<u8>, HostError> {
        let (file, rights) = file_of(self.entry(request)?)?;
        if rights & READ == 0 {
            return Err(HostError::PERMISSION_DENIED);
        }
        let mut bytes = Vec::new();
        file.seek(SeekFrom::Start(0))
            .and_then(|_| file.read_to_end(&mut bytes))
            .map_err(|error| HostError::from_io(&error))?;
        Ok(bytes)
    }

    fn read_text(&mut self, request: &Request) -> Result<Value, HostError> {
        let bytes = self.read_all(request)?;
        let text = String::from_utf8(bytes).map_err(|_| HostError::INVALID_UTF8)?;
        Ok(committed("text", json!(text)))
    }

    fn write_all(&mut self, request: &Request) -> Result<Value, HostError> {
        let bytes = match request.arguments.first() {
            Some(Argument::Text(text)) => text.as_bytes().to_vec(),
            Some(Argument::Bytes(bytes)) => bytes.clone(),
            _ => return Err(HostError::INVALID_PATH),
        };
        let (file, rights) = file_of(self.entry(request)?)?;
        if rights & WRITE == 0 {
            return Err(HostError::PERMISSION_DENIED);
        }
        replace_content(file, &bytes).map_err(|_| HostError::UNCERTAIN_INTERRUPTED)?;
        let count = i64::try_from(bytes.len()).map_err(|_| HostError::INTERRUPTED)?;
        Ok(committed("integer", json!(count)))
    }

    fn close(&mut self, request: &Request) -> Result<Value, HostError> {
        self.entry(request)?;
        self.entries.remove(&request.receiver()?.slot);
        Ok(committed("boolean", json!(true)))
    }
}

fn replace_content(file: &mut File, bytes: &[u8]) -> std::io::Result<()> {
    file.set_len(0)?;
    file.seek(SeekFrom::Start(0))?;
    file.write_all(bytes)?;
    file.sync_all()
}

fn options(rights: u8) -> OpenOptions {
    let mut chosen = OpenOptions::new();
    chosen.read(rights & READ != 0);
    if rights & WRITE != 0 {
        chosen.write(true).create(true).truncate(true);
    }
    chosen
}

fn directory_of(entry: &mut Entry) -> Result<(&Dir, u8), HostError> {
    match &entry.resource {
        Resource::Directory(directory) => Ok((directory, entry.rights)),
        _ => Err(HostError::PERMISSION_DENIED),
    }
}

fn file_of(entry: &mut Entry) -> Result<(&mut File, u8), HostError> {
    match &mut entry.resource {
        Resource::File(file) => Ok((file, entry.rights)),
        _ => Err(HostError::PERMISSION_DENIED),
    }
}
