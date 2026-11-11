use pseudolearn_semantic::EffectValueKind;

pub(crate) const EFFECT_ORDER: &[&str] = &[
    "cancellation",
    "sleep_until",
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
    "now_nanoseconds",
    "clock_now",
    "timer_type",
    "request_timer",
    "timer_wait",
    "timer_wait_blocking",
    "directory_type",
    "request_directory",
    "directory_derive",
    "directory_close",
    "entry_kind",
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

pub(crate) const SHARED_SUPPORT: &[&str] = &[
    "arguments_values",
    "directory_type",
    "file_type",
    "directory_list",
    "text_join",
];

pub(crate) fn capability_type(kind: EffectValueKind) -> Option<(&'static str, &'static str)> {
    Some(match kind {
        EffectValueKind::Console => ("Console", "console_type"),
        EffectValueKind::Arguments => ("Arguments", "arguments_type"),
        EffectValueKind::Directory => ("Directory", "directory_type"),
        EffectValueKind::File => ("File", "file_type"),
        EffectValueKind::Clock => ("Clock", "clock_type"),
        EffectValueKind::Timer => ("Timer", "timer_type"),
        EffectValueKind::Environment => ("Environment", "environment_type"),
        EffectValueKind::DateTime => ("DateTime", "date_time_type"),
        _ => return None,
    })
}

pub(crate) fn effect_dependencies(name: &str) -> &'static [&'static str] {
    match name {
        "cancellation" | "sleep_until" => &["tasks"],
        "request_console" | "console_write" | "console_write_error" | "console_set_exit_code" => {
            &["console_type", "host_error"]
        }
        "request_arguments" | "arguments_values" => &["arguments_type", "host_error"],
        "request_environment" | "environment_get" => &["environment_type", "host_error"],
        "request_clock" => &["clock_type", "host_error"],
        "clock_now" => &["clock_type", "now_nanoseconds"],
        "request_timer" => &["timer_type", "host_error"],
        "timer_wait" => &["timer_type", "now_nanoseconds", "sleep_until"],
        "timer_wait_blocking" => &["timer_type", "now_nanoseconds"],
        "now_nanoseconds" | "directory_type" | "file_type" | "entry_kind" => &["host_error"],
        "directory_exists" | "directory_is_directory" | "directory_delete" => {
            &["directory_type", "entry_kind"]
        }
        "file_open" => &["file_type", "directory_type"],
        "file_read_text" => &["file_read_bytes"],
        "file_write_text" => &["file_write_bytes"],
        "file_append_text" => &["file_append_bytes"],
        "text_pad_left" | "text_pad_right" => &["text_padding"],
        name if name.starts_with("date_time_") && name != "date_time_type" => &["date_time_type"],
        other => file_dependencies(other),
    }
}

fn file_dependencies(name: &str) -> &'static [&'static str] {
    match name {
        "request_directory" | "directory_derive" | "directory_close" | "directory_list"
        | "directory_rename" | "directory_create" => &["directory_type"],
        "file_read_bytes" | "file_write_bytes" | "file_append_bytes" | "file_close" => {
            &["file_type"]
        }
        _ => &[],
    }
}

pub(crate) fn is_pending(function: &str) -> bool {
    function == "clock_local_now"
}
