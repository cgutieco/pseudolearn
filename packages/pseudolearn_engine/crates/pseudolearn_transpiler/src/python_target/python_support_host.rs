pub(crate) const HOST_ERROR: &str = r#"class HostError(Exception):
    def __init__(self, code, uncertain=False):
        super().__init__(code)
        self.code = code
        self.uncertain = uncertain


def system_error_code(error):
    if isinstance(error, FileNotFoundError):
        return "no_encontrado"
    if isinstance(error, PermissionError):
        return "permiso_denegado"
    if isinstance(error, FileExistsError):
        return "ya_existe"
    if isinstance(error, (NotADirectoryError, IsADirectoryError)) or error.errno == errno.EINVAL:
        return "ruta_invalida"
    if error.errno == errno.ENOTEMPTY:
        return "peticion_invalida"
    return "interrumpido"


def host_operation(operation):
    def guarded(*arguments):
        try:
            return Ok(operation(*arguments))
        except HostError as error:
            return Err(IoError(error.code, error.uncertain))
        except OSError as error:
            return Err(IoError(system_error_code(error), False))
    return guarded"#;

pub(crate) const CONSOLE_TYPE: &str = r#"class Console:
    pass"#;

pub(crate) const REQUEST_CONSOLE: &str = r#"@host_operation
def request_console():
    return Console()"#;

pub(crate) const CONSOLE_WRITE: &str = r#"@host_operation
def console_write(console, text):
    sys.stdout.write(text)
    return len(text.encode())"#;

pub(crate) const CONSOLE_WRITE_ERROR: &str = r#"@host_operation
def console_write_error(console, text):
    sys.stdout.flush()
    sys.stderr.write(text)
    sys.stderr.flush()
    return len(text.encode())"#;

pub(crate) const CONSOLE_SET_EXIT_CODE: &str = r#"EXIT_CODE = [0]


@host_operation
def console_set_exit_code(console, code):
    if not 0 <= code <= 255:
        raise HostError("peticion_invalida")
    EXIT_CODE[0] = code
    return code"#;

pub(crate) const ARGUMENTS_TYPE: &str = r#"class Arguments:
    pass"#;

pub(crate) const REQUEST_ARGUMENTS: &str = r#"@host_operation
def request_arguments():
    return Arguments()"#;

pub(crate) const ARGUMENTS_VALUES: &str = r#"@host_operation
def arguments_values(arguments):
    try:
        return [value.encode().decode() for value in sys.argv[1:]]
    except UnicodeError:
        raise HostError("utf8_invalido")"#;

pub(crate) const ENVIRONMENT_TYPE: &str = r#"class Environment:
    pass"#;

pub(crate) const REQUEST_ENVIRONMENT: &str = r#"@host_operation
def request_environment():
    return Environment()"#;

pub(crate) const ENVIRONMENT_GET: &str = r#"@host_operation
def environment_get(environment, name):
    if name == "" or "=" in name or "\0" in name:
        raise HostError("peticion_invalida")
    value = os.environ.get(name)
    if value is None:
        return Nothing()
    try:
        return Some(value.encode().decode())
    except UnicodeError:
        raise HostError("utf8_invalido")"#;

pub(crate) const CLOCK_TYPE: &str = r#"class Clock:
    pass"#;

pub(crate) const REQUEST_CLOCK: &str = r#"@host_operation
def request_clock():
    return Clock()"#;

pub(crate) const CLOCK_NOW: &str = r#"@host_operation
def clock_now(clock):
    return time.time_ns()"#;

pub(crate) const TIMER_TYPE: &str = r#"class Timer:
    pass"#;

pub(crate) const REQUEST_TIMER: &str = r#"@host_operation
def request_timer():
    return Timer()"#;

pub(crate) const TIMER_WAIT: &str = r#"async def timer_wait(timer, nanoseconds):
    if nanoseconds < 0:
        return Err(IoError("tiempo_agotado", False))
    await asyncio.sleep(nanoseconds / 1_000_000_000)
    return Ok(time.time_ns())"#;

pub(crate) const TIMER_WAIT_BLOCKING: &str = r#"@host_operation
def timer_wait_blocking(timer, nanoseconds):
    if nanoseconds < 0:
        raise HostError("tiempo_agotado")
    time.sleep(nanoseconds / 1_000_000_000)
    return time.time_ns()"#;
