pub(crate) const HOST_ERROR: &str = r#"fn host_error(code: &str) -> IoError {
    IoError::new(code, false)
}

fn host_failure(error: std::io::Error) -> IoError {
    let code = match error.kind() {
        std::io::ErrorKind::NotFound => "no_encontrado",
        std::io::ErrorKind::PermissionDenied => "permiso_denegado",
        std::io::ErrorKind::AlreadyExists => "ya_existe",
        std::io::ErrorKind::InvalidInput
        | std::io::ErrorKind::NotADirectory
        | std::io::ErrorKind::IsADirectory => "ruta_invalida",
        std::io::ErrorKind::DirectoryNotEmpty => "peticion_invalida",
        _ => "interrumpido",
    };
    host_error(code)
}"#;

pub(crate) const CONSOLE_TYPE: &str = r#"#[derive(Clone)]
struct Console;"#;

pub(crate) const REQUEST_CONSOLE: &str = r#"fn request_console() -> Result<Console, IoError> {
    Ok(Console)
}"#;

pub(crate) const CONSOLE_WRITE: &str = r#"fn console_write(_console: &Console, text: &str) -> Result<i64, IoError> {
    print!("{text}");
    Ok(text.len() as i64)
}"#;

pub(crate) const CONSOLE_WRITE_ERROR: &str = r#"fn console_write_error(_console: &Console, text: &str) -> Result<i64, IoError> {
    eprint!("{text}");
    Ok(text.len() as i64)
}"#;

pub(crate) const CONSOLE_SET_EXIT_CODE: &str = r#"thread_local! {
    static EXIT_CODE: std::cell::Cell<i32> = std::cell::Cell::new(0);
}

fn console_set_exit_code(_console: &Console, code: i64) -> Result<i64, IoError> {
    if !(0..=255).contains(&code) {
        return Err(host_error("peticion_invalida"));
    }
    EXIT_CODE.with(|exit_code| exit_code.set(code as i32));
    Ok(code)
}

fn finish_with_exit_code() {
    std::io::Write::flush(&mut std::io::stdout()).ok();
    std::process::exit(EXIT_CODE.with(|exit_code| exit_code.get()));
}"#;

pub(crate) const ARGUMENTS_TYPE: &str = r#"#[derive(Clone)]
struct Arguments;"#;

pub(crate) const REQUEST_ARGUMENTS: &str = r#"fn request_arguments() -> Result<Arguments, IoError> {
    Ok(Arguments)
}"#;

pub(crate) const ARGUMENTS_VALUES: &str = r#"fn arguments_values(_arguments: &Arguments) -> Result<Rc<RefCell<Vec<String>>>, IoError> {
    let values = std::env::args_os()
        .skip(1)
        .map(|value| value.into_string().map_err(|_| host_error("utf8_invalido")))
        .collect::<Result<Vec<String>, IoError>>()?;
    Ok(Rc::new(RefCell::new(values)))
}"#;

pub(crate) const ENVIRONMENT_TYPE: &str = r#"#[derive(Clone)]
struct Environment;"#;

pub(crate) const REQUEST_ENVIRONMENT: &str = r#"fn request_environment() -> Result<Environment, IoError> {
    Ok(Environment)
}"#;

pub(crate) const ENVIRONMENT_GET: &str = r#"fn environment_get(_environment: &Environment, name: &str) -> Result<Option<String>, IoError> {
    if name.is_empty() || name.contains(['=', '\0']) {
        return Err(host_error("peticion_invalida"));
    }
    match std::env::var_os(name) {
        None => Ok(None),
        Some(value) => value.into_string().map(Some).map_err(|_| host_error("utf8_invalido")),
    }
}"#;

pub(crate) const CLOCK_TYPE: &str = r#"#[derive(Clone)]
struct Clock;"#;

pub(crate) const REQUEST_CLOCK: &str = r#"fn request_clock() -> Result<Clock, IoError> {
    Ok(Clock)
}"#;

pub(crate) const NOW_NANOSECONDS: &str = r#"fn now_nanoseconds() -> Result<i64, IoError> {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .ok()
        .and_then(|elapsed| i64::try_from(elapsed.as_nanos()).ok())
        .ok_or_else(|| host_error("interrumpido"))
}"#;

pub(crate) const CLOCK_NOW: &str = r#"fn clock_now(_clock: &Clock) -> Result<i64, IoError> {
    now_nanoseconds()
}"#;

pub(crate) const TIMER_TYPE: &str = r#"#[derive(Clone)]
struct Timer;"#;

pub(crate) const REQUEST_TIMER: &str = r#"fn request_timer() -> Result<Timer, IoError> {
    Ok(Timer)
}"#;

pub(crate) const TIMER_WAIT: &str = r#"async fn timer_wait(_timer: &Timer, nanoseconds: i64) -> Result<i64, IoError> {
    let duration = u64::try_from(nanoseconds).map_err(|_| host_error("tiempo_agotado"))?;
    sleep_until(std::time::Instant::now() + std::time::Duration::from_nanos(duration)).await;
    now_nanoseconds()
}"#;

pub(crate) const TIMER_WAIT_BLOCKING: &str = r#"fn timer_wait_blocking(_timer: &Timer, nanoseconds: i64) -> Result<i64, IoError> {
    let duration = u64::try_from(nanoseconds).map_err(|_| host_error("tiempo_agotado"))?;
    std::thread::sleep(std::time::Duration::from_nanos(duration));
    now_nanoseconds()
}"#;
