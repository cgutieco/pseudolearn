pub(crate) const DIRECTORY_TYPE: &str = r#"#[derive(Clone)]
struct Directory {
    state: Rc<DirectoryState>,
}

struct DirectoryState {
    path: std::path::PathBuf,
    confined: bool,
    readable: bool,
    writable: bool,
    closed: std::cell::Cell<bool>,
}

impl Directory {
    fn new(path: std::path::PathBuf, confined: bool, (readable, writable): (bool, bool)) -> Self {
        let closed = std::cell::Cell::new(false);
        Directory { state: Rc::new(DirectoryState { path, confined, readable, writable, closed }) }
    }

    fn allowed(&self, (readable, writable): (bool, bool)) -> Result<(), IoError> {
        if self.state.closed.get() {
            return Err(host_error("capacidad_cerrada"));
        }
        if (readable && !self.state.readable) || (writable && !self.state.writable) {
            return Err(host_error("permiso_denegado"));
        }
        Ok(())
    }

    fn granted(&self, mode: &str) -> Result<(bool, bool), IoError> {
        self.allowed((false, false))?;
        let wanted = match mode {
            "read" | "lectura" => (true, false),
            "write" | "escritura" => (false, true),
            "read_write" | "lectura_escritura" => (true, true),
            _ => return Err(host_error("ruta_invalida")),
        };
        self.allowed(wanted)?;
        Ok(wanted)
    }

    fn target(&self, path: &str) -> Result<std::path::PathBuf, IoError> {
        if path.is_empty() || path.contains('\0') {
            return Err(host_error("ruta_invalida"));
        }
        if !self.state.confined {
            return Ok(self.state.path.join(path));
        }
        checked_path(path)?;
        let target = self.state.path.join(path);
        let root = std::fs::canonicalize(&self.state.path).map_err(host_failure)?;
        let resolved = match (std::fs::canonicalize(&target), target.parent(), target.file_name()) {
            (Ok(found), _, _) => found,
            (Err(_), Some(parent), Some(name)) => std::fs::canonicalize(parent).map_err(host_failure)?.join(name),
            (Err(error), _, _) => return Err(host_failure(error)),
        };
        if resolved.starts_with(root) { Ok(target) } else { Err(host_error("permiso_denegado")) }
    }
}

fn checked_path(path: &str) -> Result<(), IoError> {
    let valid = !path.is_empty()
        && !path.starts_with('/')
        && !path.contains(['\\', ':', '\0'])
        && path.split('/').all(|part| !part.is_empty() && part != "..");
    if valid { Ok(()) } else { Err(host_error("ruta_invalida")) }
}"#;

pub(crate) const REQUEST_DIRECTORY: &str = r#"fn request_directory(path: &str) -> Result<Directory, IoError> {
    if path.is_empty() || path.contains('\0') {
        return Err(host_error("ruta_invalida"));
    }
    let path = std::path::Path::new(".").join(path);
    let metadata = std::fs::metadata(&path).map_err(host_failure)?;
    if !metadata.is_dir() {
        return Err(host_error("ruta_invalida"));
    }
    Ok(Directory::new(path, false, (true, true)))
}"#;

pub(crate) const DIRECTORY_DERIVE: &str = r#"fn directory_derive(directory: &Directory, path: &str, mode: &str) -> Result<Directory, IoError> {
    let rights = directory.granted(mode)?;
    checked_path(path)?;
    let target = directory.target(path)?;
    let metadata = std::fs::metadata(&target).map_err(host_failure)?;
    if !metadata.is_dir() {
        return Err(host_error("ruta_invalida"));
    }
    Ok(Directory::new(target, true, rights))
}"#;

pub(crate) const DIRECTORY_CLOSE: &str = r#"fn directory_close(directory: &Directory) -> Result<bool, IoError> {
    directory.allowed((false, false))?;
    directory.state.closed.set(true);
    Ok(true)
}"#;

pub(crate) const DIRECTORY_EXISTS: &str = r#"fn directory_exists(directory: &Directory, path: &str) -> Result<bool, IoError> {
    directory.allowed((true, false))?;
    Ok(entry_kind(&directory.target(path)?)?.is_some())
}"#;

pub(crate) const DIRECTORY_IS_DIRECTORY: &str = r#"fn directory_is_directory(directory: &Directory, path: &str) -> Result<bool, IoError> {
    directory.allowed((true, false))?;
    Ok(entry_kind(&directory.target(path)?)? == Some(true))
}"#;

pub(crate) const ENTRY_KIND: &str = r#"fn entry_kind(target: &std::path::Path) -> Result<Option<bool>, IoError> {
    match std::fs::metadata(target) {
        Ok(metadata) => Ok(Some(metadata.is_dir())),
        Err(error) if error.kind() == std::io::ErrorKind::NotFound => Ok(None),
        Err(error) => Err(host_failure(error)),
    }
}"#;

pub(crate) const DIRECTORY_LIST: &str = r#"fn directory_list(directory: &Directory, path: &str) -> Result<Rc<RefCell<Vec<String>>>, IoError> {
    directory.allowed((true, false))?;
    let mut names = Vec::new();
    for entry in std::fs::read_dir(directory.target(path)?).map_err(host_failure)? {
        let name = entry.map_err(host_failure)?.file_name();
        names.push(name.into_string().map_err(|_| host_error("utf8_invalido"))?);
    }
    names.sort();
    Ok(Rc::new(RefCell::new(names)))
}"#;

pub(crate) const DIRECTORY_DELETE: &str = r#"fn directory_delete(directory: &Directory, path: &str) -> Result<bool, IoError> {
    directory.allowed((false, true))?;
    let target = directory.target(path)?;
    let removed = match entry_kind(&target)? {
        None => return Err(host_error("no_encontrado")),
        Some(true) => std::fs::remove_dir(&target),
        Some(false) => std::fs::remove_file(&target),
    };
    removed.map_err(host_failure)?;
    Ok(true)
}"#;

pub(crate) const DIRECTORY_RENAME: &str = r#"fn directory_rename(directory: &Directory, source: &str, destination: &str) -> Result<bool, IoError> {
    directory.allowed((false, true))?;
    let (source, destination) = (directory.target(source)?, directory.target(destination)?);
    let present = |path: &std::path::Path| match std::fs::symlink_metadata(path) {
        Ok(_) => Ok(true),
        Err(error) if error.kind() == std::io::ErrorKind::NotFound => Ok(false),
        Err(error) => Err(host_failure(error)),
    };
    if !present(&source)? {
        return Err(host_error("no_encontrado"));
    }
    if present(&destination)? {
        return Err(host_error("ya_existe"));
    }
    std::fs::rename(source, destination).map_err(host_failure)?;
    Ok(true)
}"#;

pub(crate) const DIRECTORY_CREATE: &str = r#"fn directory_create(directory: &Directory, path: &str) -> Result<bool, IoError> {
    directory.allowed((false, true))?;
    std::fs::create_dir(directory.target(path)?).map_err(host_failure)?;
    Ok(true)
}"#;
