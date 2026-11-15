pub(crate) const DIRECTORY_TYPE: &str = r#"MODES = {
    "read": (True, False),
    "lectura": (True, False),
    "write": (False, True),
    "escritura": (False, True),
    "read_write": (True, True),
    "lectura_escritura": (True, True),
}


def checked_path(path):
    parts = path.split("/")
    if path.startswith("/") or any(mark in path for mark in "\\:\0") or "" in parts or ".." in parts:
        raise HostError("ruta_invalida")


class Directory:
    def __init__(self, path, confined, rights):
        self.path = path
        self.confined = confined
        self.readable, self.writable = rights
        self.closed = False

    def allowed(self, readable, writable):
        if self.closed:
            raise HostError("capacidad_cerrada")
        if (readable and not self.readable) or (writable and not self.writable):
            raise HostError("permiso_denegado")

    def granted(self, mode):
        self.allowed(False, False)
        if mode not in MODES:
            raise HostError("ruta_invalida")
        self.allowed(*MODES[mode])
        return MODES[mode]

    def target(self, path):
        if path == "" or "\0" in path:
            raise HostError("ruta_invalida")
        target = os.path.join(self.path, path)
        if not self.confined:
            return target
        checked_path(path)
        root = os.path.realpath(self.path)
        resolved = os.path.realpath(target)
        if resolved != root and not resolved.startswith(root + os.sep):
            raise HostError("permiso_denegado")
        return target


def entry_kind(target):
    try:
        os.stat(target)
    except FileNotFoundError:
        return None
    return os.path.isdir(target)"#;

pub(crate) const REQUEST_DIRECTORY: &str = r#"@host_operation
def request_directory(path):
    if path == "" or "\0" in path:
        raise HostError("ruta_invalida")
    target = os.path.join(".", path)
    os.stat(target)
    if not os.path.isdir(target):
        raise HostError("ruta_invalida")
    return Directory(target, False, (True, True))"#;

pub(crate) const DIRECTORY_DERIVE: &str = r#"@host_operation
def directory_derive(directory, path, mode):
    rights = directory.granted(mode)
    checked_path(path)
    target = directory.target(path)
    os.stat(target)
    if not os.path.isdir(target):
        raise HostError("ruta_invalida")
    return Directory(target, True, rights)"#;

pub(crate) const DIRECTORY_CLOSE: &str = r#"@host_operation
def directory_close(directory):
    directory.allowed(False, False)
    directory.closed = True
    return True"#;

pub(crate) const DIRECTORY_EXISTS: &str = r#"@host_operation
def directory_exists(directory, path):
    directory.allowed(True, False)
    return entry_kind(directory.target(path)) is not None"#;

pub(crate) const DIRECTORY_IS_DIRECTORY: &str = r#"@host_operation
def directory_is_directory(directory, path):
    directory.allowed(True, False)
    return entry_kind(directory.target(path)) is True"#;

pub(crate) const DIRECTORY_LIST: &str = r#"@host_operation
def directory_list(directory, path):
    directory.allowed(True, False)
    names = os.listdir(directory.target(path))
    try:
        return sorted(name.encode().decode() for name in names)
    except UnicodeError:
        raise HostError("utf8_invalido")"#;

pub(crate) const DIRECTORY_DELETE: &str = r#"@host_operation
def directory_delete(directory, path):
    directory.allowed(False, True)
    target = directory.target(path)
    kind = entry_kind(target)
    if kind is None:
        raise HostError("no_encontrado")
    if kind:
        os.rmdir(target)
    else:
        os.remove(target)
    return True"#;

pub(crate) const DIRECTORY_RENAME: &str = r#"@host_operation
def directory_rename(directory, source, destination):
    directory.allowed(False, True)
    source, destination = directory.target(source), directory.target(destination)
    if not os.path.lexists(source):
        raise HostError("no_encontrado")
    if os.path.lexists(destination):
        raise HostError("ya_existe")
    os.rename(source, destination)
    return True"#;

pub(crate) const DIRECTORY_CREATE: &str = r#"@host_operation
def directory_create(directory, path):
    directory.allowed(False, True)
    os.mkdir(directory.target(path))
    return True"#;

pub(crate) const FILE_TYPE: &str = r#"class File:
    def __init__(self, handle, readable, writable):
        self.handle = handle
        self.readable = readable
        self.writable = writable

    def usable(self, writing):
        if self.handle is None:
            raise HostError("capacidad_cerrada")
        if not (self.writable if writing else self.readable):
            raise HostError("permiso_denegado")
        return self.handle"#;

pub(crate) const FILE_OPEN: &str = r#"@host_operation
def file_open(directory, path, mode):
    readable, writable = directory.granted(mode)
    target = directory.target(path)
    flags = (os.O_RDWR if readable else os.O_WRONLY) if writable else os.O_RDONLY
    if writable:
        flags |= os.O_CREAT | (0 if readable else os.O_TRUNC)
    descriptor = os.open(target, flags, 0o666)
    handle = os.fdopen(descriptor, "r+b" if readable and writable else ("wb" if writable else "rb"))
    return File(handle, readable, writable)"#;

pub(crate) const FILE_READ_BYTES: &str = r#"@host_operation
def file_read_bytes(file):
    handle = file.usable(False)
    handle.seek(0)
    return handle.read()"#;

pub(crate) const FILE_READ_TEXT: &str = r#"def file_read_text(file):
    result = file_read_bytes(file)
    if isinstance(result, Err):
        return result
    try:
        return Ok(result.value.decode())
    except UnicodeDecodeError:
        return Err(IoError("utf8_invalido", False))"#;

pub(crate) const FILE_STORE: &str = r#"@host_operation
def file_store(file, content, appending):
    handle = file.usable(True)
    try:
        if appending:
            handle.seek(0, 2)
        else:
            handle.seek(0)
            handle.truncate()
        handle.write(content)
        handle.flush()
        os.fsync(handle.fileno())
    except OSError:
        raise HostError("interrumpido", True)
    return len(content)"#;

pub(crate) const FILE_WRITE_BYTES: &str = r#"def file_write_bytes(file, content):
    return file_store(file, content, False)"#;

pub(crate) const FILE_WRITE_TEXT: &str = r#"def file_write_text(file, text):
    return file_store(file, text.encode(), False)"#;

pub(crate) const FILE_APPEND_BYTES: &str = r#"def file_append_bytes(file, content):
    return file_store(file, content, True)"#;

pub(crate) const FILE_APPEND_TEXT: &str = r#"def file_append_text(file, text):
    return file_store(file, text.encode(), True)"#;

pub(crate) const FILE_CLOSE: &str = r#"@host_operation
def file_close(file):
    if file.handle is None:
        raise HostError("capacidad_cerrada")
    file.handle.close()
    file.handle = None
    return True"#;
