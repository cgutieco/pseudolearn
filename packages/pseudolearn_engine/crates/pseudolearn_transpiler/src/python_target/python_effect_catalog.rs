use super::python_support_files as files;
use super::python_support_host as host;
use super::python_support_library as library;
use super::python_support_time as time;

pub(crate) const EFFECT_ORDER: &[&str] = &[
    "host_error",
    "console_type",
    "request_console",
    "console_write",
    "console_write_error",
    "console_set_exit_code",
    "arguments_type",
    "request_arguments",
    "arguments_values",
    "environment_type",
    "request_environment",
    "environment_get",
    "clock_type",
    "request_clock",
    "clock_now",
    "timer_type",
    "request_timer",
    "timer_wait",
    "timer_wait_blocking",
    "directory_type",
    "request_directory",
    "directory_derive",
    "directory_close",
    "directory_exists",
    "directory_is_directory",
    "directory_list",
    "directory_delete",
    "directory_rename",
    "directory_create",
    "file_type",
    "file_open",
    "file_read_bytes",
    "file_read_text",
    "file_store",
    "file_write_bytes",
    "file_write_text",
    "file_append_bytes",
    "file_append_text",
    "file_close",
    "text_contains",
    "text_starts_with",
    "text_ends_with",
    "text_trim",
    "text_join",
    "text_to_upper",
    "text_to_lower",
    "text_padding",
    "text_pad_left",
    "text_pad_right",
    "text_decimals",
    "real_minimum",
    "real_maximum",
    "bytes_new",
    "bytes_length",
    "bytes_at",
    "bytes_utf8",
    "bytes_from_text",
    "bytes_segment",
    "bytes_join",
    "date_time_type",
    "clock_local_now",
    "date_time_utc",
    "date_time_of",
    "date_time_parse",
    "date_time_iso_format",
    "date_time_iso_format_precise",
    "date_time_year",
    "date_time_month",
    "date_time_day",
    "date_time_hour",
    "date_time_minute",
    "date_time_second",
    "date_time_nanosecond",
    "date_time_weekday",
    "date_time_utc_offset",
    "date_time_instant",
];

pub(crate) fn effect_dependencies(name: &str) -> &'static [&'static str] {
    match name {
        "host_error" => &["errno", "variants"],
        "request_console" | "console_write" | "console_write_error" | "console_set_exit_code" => {
            &["console_type", "host_error", "sys"]
        }
        "request_arguments" | "arguments_values" => &["arguments_type", "host_error", "sys"],
        "request_environment" | "environment_get" => &["environment_type", "host_error", "os"],
        "request_clock" | "clock_now" => &["clock_type", "host_error", "time"],
        "request_timer" | "timer_wait_blocking" => &["timer_type", "host_error", "time"],
        "timer_wait" => &["timer_type", "host_error", "time", "asyncio"],
        "directory_type" => &["host_error", "os"],
        "file_type" => &["host_error"],
        "file_open" => &["file_type", "directory_type"],
        "file_read_text" => &["file_read_bytes"],
        "file_write_bytes" | "file_write_text" | "file_append_bytes" | "file_append_text" => {
            &["file_store"]
        }
        "file_read_bytes" | "file_store" | "file_close" => &["file_type", "os"],
        "text_pad_left" | "text_pad_right" => &["text_padding"],
        "clock_local_now" => &["date_time_type", "clock_type", "host_error", "time"],
        "date_time_type" => &["variants"],
        "date_time_parse" => &["date_time_type", "re"],
        name if name.starts_with("date_time_") => &["date_time_type"],
        "text_decimals" | "real_minimum" | "real_maximum" => &["math", "decimal"],
        "bytes_utf8" => &["variants"],
        name if name.starts_with("directory_") || name == "request_directory" => {
            &["directory_type"]
        }
        _ => &[],
    }
}

pub(crate) fn effect_source(name: &str) -> Option<String> {
    host_source(name)
        .or_else(|| file_source(name))
        .or_else(|| library_source(name))
        .or_else(|| time_source(name))
        .map(str::to_owned)
        .or_else(|| time::date_time_field(name))
}

fn time_source(name: &str) -> Option<&'static str> {
    Some(match name {
        "date_time_type" => time::DATE_TIME_TYPE,
        "clock_local_now" => time::CLOCK_LOCAL_NOW,
        "date_time_utc" => time::DATE_TIME_UTC,
        "date_time_of" => time::DATE_TIME_OF,
        "date_time_parse" => time::DATE_TIME_PARSE,
        "date_time_iso_format" => time::DATE_TIME_ISO_FORMAT,
        "date_time_iso_format_precise" => time::DATE_TIME_ISO_FORMAT_PRECISE,
        _ => return None,
    })
}

fn host_source(name: &str) -> Option<&'static str> {
    Some(match name {
        "host_error" => host::HOST_ERROR,
        "console_type" => host::CONSOLE_TYPE,
        "request_console" => host::REQUEST_CONSOLE,
        "console_write" => host::CONSOLE_WRITE,
        "console_write_error" => host::CONSOLE_WRITE_ERROR,
        "console_set_exit_code" => host::CONSOLE_SET_EXIT_CODE,
        "arguments_type" => host::ARGUMENTS_TYPE,
        "request_arguments" => host::REQUEST_ARGUMENTS,
        "arguments_values" => host::ARGUMENTS_VALUES,
        "environment_type" => host::ENVIRONMENT_TYPE,
        "request_environment" => host::REQUEST_ENVIRONMENT,
        "environment_get" => host::ENVIRONMENT_GET,
        "clock_type" => host::CLOCK_TYPE,
        "request_clock" => host::REQUEST_CLOCK,
        "clock_now" => host::CLOCK_NOW,
        "timer_type" => host::TIMER_TYPE,
        "request_timer" => host::REQUEST_TIMER,
        "timer_wait" => host::TIMER_WAIT,
        "timer_wait_blocking" => host::TIMER_WAIT_BLOCKING,
        _ => return None,
    })
}

fn file_source(name: &str) -> Option<&'static str> {
    Some(match name {
        "directory_type" => files::DIRECTORY_TYPE,
        "request_directory" => files::REQUEST_DIRECTORY,
        "directory_derive" => files::DIRECTORY_DERIVE,
        "directory_close" => files::DIRECTORY_CLOSE,
        "directory_exists" => files::DIRECTORY_EXISTS,
        "directory_is_directory" => files::DIRECTORY_IS_DIRECTORY,
        "directory_list" => files::DIRECTORY_LIST,
        "directory_delete" => files::DIRECTORY_DELETE,
        "directory_rename" => files::DIRECTORY_RENAME,
        "directory_create" => files::DIRECTORY_CREATE,
        "file_type" => files::FILE_TYPE,
        "file_open" => files::FILE_OPEN,
        "file_read_bytes" => files::FILE_READ_BYTES,
        "file_read_text" => files::FILE_READ_TEXT,
        "file_store" => files::FILE_STORE,
        "file_write_bytes" => files::FILE_WRITE_BYTES,
        "file_write_text" => files::FILE_WRITE_TEXT,
        "file_append_bytes" => files::FILE_APPEND_BYTES,
        "file_append_text" => files::FILE_APPEND_TEXT,
        "file_close" => files::FILE_CLOSE,
        _ => return None,
    })
}

fn library_source(name: &str) -> Option<&'static str> {
    Some(match name {
        "text_contains" => library::TEXT_CONTAINS,
        "text_starts_with" => library::TEXT_STARTS_WITH,
        "text_ends_with" => library::TEXT_ENDS_WITH,
        "text_trim" => library::TEXT_TRIM,
        "text_join" => library::TEXT_JOIN,
        "text_to_upper" => library::TEXT_TO_UPPER,
        "text_to_lower" => library::TEXT_TO_LOWER,
        "text_padding" => library::TEXT_PADDING,
        "text_pad_left" => library::TEXT_PAD_LEFT,
        "text_pad_right" => library::TEXT_PAD_RIGHT,
        "text_decimals" => library::TEXT_DECIMALS,
        "bytes_new" => library::BYTES_NEW,
        "bytes_length" => library::BYTES_LENGTH,
        "bytes_at" => library::BYTES_AT,
        "bytes_utf8" => library::BYTES_UTF8,
        "bytes_from_text" => library::BYTES_FROM_TEXT,
        "bytes_segment" => library::BYTES_SEGMENT,
        "bytes_join" => library::BYTES_JOIN,
        "real_minimum" => library::REAL_MINIMUM,
        "real_maximum" => library::REAL_MAXIMUM,
        _ => return None,
    })
}
