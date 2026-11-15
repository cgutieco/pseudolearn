use super::rust_support_channels::{CANCELLATION, SLEEP_UNTIL};
use super::rust_support_file_contents as contents;
use super::rust_support_files as files;
use super::rust_support_host as host;
use super::rust_support_library as library;
use super::rust_support_time as time;

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
        "cancellation" => CANCELLATION,
        "sleep_until" => SLEEP_UNTIL,
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
        "now_nanoseconds" => host::NOW_NANOSECONDS,
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
        "entry_kind" => files::ENTRY_KIND,
        "directory_exists" => files::DIRECTORY_EXISTS,
        "directory_is_directory" => files::DIRECTORY_IS_DIRECTORY,
        "directory_list" => files::DIRECTORY_LIST,
        "directory_delete" => files::DIRECTORY_DELETE,
        "directory_rename" => files::DIRECTORY_RENAME,
        "directory_create" => files::DIRECTORY_CREATE,
        "file_type" => contents::FILE_TYPE,
        "file_open" => contents::FILE_OPEN,
        "file_read_bytes" => contents::FILE_READ_BYTES,
        "file_read_text" => contents::FILE_READ_TEXT,
        "file_write_bytes" => contents::FILE_WRITE_BYTES,
        "file_write_text" => contents::FILE_WRITE_TEXT,
        "file_append_bytes" => contents::FILE_APPEND_BYTES,
        "file_append_text" => contents::FILE_APPEND_TEXT,
        "file_close" => contents::FILE_CLOSE,
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
