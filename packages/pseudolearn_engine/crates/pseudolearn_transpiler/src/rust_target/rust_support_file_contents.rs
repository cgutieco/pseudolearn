pub(crate) const FILE_TYPE: &str = r#"#[derive(Clone)]
struct File {
    state: Rc<FileState>,
}

struct FileState {
    handle: RefCell<Option<std::fs::File>>,
    readable: bool,
    writable: bool,
}

impl File {
    fn with_handle<T>(&self, writing: bool, action: impl FnOnce(&mut std::fs::File) -> Result<T, IoError>) -> Result<T, IoError> {
        let mut handle = self.state.handle.borrow_mut();
        let Some(handle) = handle.as_mut() else {
            return Err(host_error("capacidad_cerrada"));
        };
        let allowed = if writing { self.state.writable } else { self.state.readable };
        if !allowed {
            return Err(host_error("permiso_denegado"));
        }
        action(handle)
    }
}"#;

pub(crate) const FILE_OPEN: &str = r#"fn file_open(directory: &Directory, path: &str, mode: &str) -> Result<File, IoError> {
    let (readable, writable) = directory.granted(mode)?;
    let target = directory.target(path)?;
    let mut options = std::fs::OpenOptions::new();
    options.read(readable);
    if writable {
        options.write(true).create(true).truncate(!readable);
    }
    let handle = options.open(target).map_err(host_failure)?;
    let state = FileState { handle: RefCell::new(Some(handle)), readable, writable };
    Ok(File { state: Rc::new(state) })
}"#;

pub(crate) const FILE_READ_BYTES: &str = r#"fn file_read_bytes(file: &File) -> Result<Vec<u8>, IoError> {
    use std::io::{Read, Seek};
    file.with_handle(false, |handle| {
        let mut bytes = Vec::new();
        handle
            .seek(std::io::SeekFrom::Start(0))
            .and_then(|_| handle.read_to_end(&mut bytes))
            .map_err(host_failure)?;
        Ok(bytes)
    })
}"#;

pub(crate) const FILE_READ_TEXT: &str = r#"fn file_read_text(file: &File) -> Result<String, IoError> {
    String::from_utf8(file_read_bytes(file)?).map_err(|_| host_error("utf8_invalido"))
}"#;

pub(crate) const FILE_WRITE_BYTES: &str = r#"fn file_write_bytes(file: &File, bytes: &[u8]) -> Result<i64, IoError> {
    use std::io::{Seek, Write};
    file.with_handle(true, |handle| {
        handle
            .set_len(0)
            .and_then(|_| handle.seek(std::io::SeekFrom::Start(0)))
            .and_then(|_| handle.write_all(bytes))
            .and_then(|_| handle.sync_all())
            .map_err(|_| IoError::new("interrumpido", true))?;
        Ok(bytes.len() as i64)
    })
}"#;

pub(crate) const FILE_WRITE_TEXT: &str = r#"fn file_write_text(file: &File, text: &str) -> Result<i64, IoError> {
    file_write_bytes(file, text.as_bytes())
}"#;

pub(crate) const FILE_APPEND_BYTES: &str = r#"fn file_append_bytes(file: &File, bytes: &[u8]) -> Result<i64, IoError> {
    use std::io::{Seek, Write};
    file.with_handle(true, |handle| {
        handle
            .seek(std::io::SeekFrom::End(0))
            .and_then(|_| handle.write_all(bytes))
            .and_then(|_| handle.sync_all())
            .map_err(|_| IoError::new("interrumpido", true))?;
        Ok(bytes.len() as i64)
    })
}"#;

pub(crate) const FILE_APPEND_TEXT: &str = r#"fn file_append_text(file: &File, text: &str) -> Result<i64, IoError> {
    file_append_bytes(file, text.as_bytes())
}"#;

pub(crate) const FILE_CLOSE: &str = r#"fn file_close(file: &File) -> Result<bool, IoError> {
    match file.state.handle.borrow_mut().take() {
        Some(_) => Ok(true),
        None => Err(host_error("capacidad_cerrada")),
    }
}"#;
