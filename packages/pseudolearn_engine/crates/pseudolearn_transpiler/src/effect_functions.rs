const TRANSLATED: &[&str] = &[
    "request_console",
    "console_write",
    "console_write_error",
    "console_set_exit_code",
    "request_arguments",
    "arguments_values",
    "request_environment",
    "environment_get",
    "request_clock",
    "clock_now",
    "request_timer",
    "request_directory",
    "directory_derive",
    "directory_close",
    "directory_exists",
    "directory_is_directory",
    "directory_list",
    "directory_delete",
    "directory_rename",
    "directory_create",
    "file_open",
    "file_read_bytes",
    "file_read_text",
    "file_write_bytes",
    "file_write_text",
    "file_append_bytes",
    "file_append_text",
    "file_close",
    "text_to_upper",
    "text_to_lower",
    "text_pad_left",
    "text_pad_right",
    "text_decimals",
    "bytes_new",
    "bytes_length",
    "bytes_at",
    "bytes_utf8",
    "bytes_from_text",
    "bytes_segment",
    "bytes_join",
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

const SUPPORT_HELPERS: &[&str] = &[
    "timer_wait",
    "timer_wait_blocking",
    "text_contains",
    "text_starts_with",
    "text_ends_with",
    "text_trim",
    "text_join",
    "host_error",
    "host_failure",
    "host_operation",
    "system_error_code",
    "now_nanoseconds",
    "checked_path",
    "entry_kind",
    "padding",
    "real_minimum",
    "real_maximum",
    "days_from_civil",
    "civil_from_days",
    "offset_suffix",
    "date_time_from",
    "file_store",
    "finish_with_exit_code",
    "until_cancelled",
    "unwound",
    "sleep_until",
    "poll_task",
    "cancel_task",
    "current_task",
    "cancelled_task",
    "task_cancelled",
    "has_live_children",
    "wake_next_timers",
    "os",
    "errno",
];

pub(crate) fn is_support_name(name: &str) -> bool {
    TRANSLATED.contains(&name) || SUPPORT_HELPERS.contains(&name)
}

pub(crate) fn effect_function(identity: &str, asynchronous: bool) -> Option<&'static str> {
    let function = match identity {
        "timer_wait" if asynchronous => "timer_wait",
        "timer_wait" => "timer_wait_blocking",
        "substring" => "substring",
        "positionOf" => "text_position",
        "replaceAll" => "replace_all",
        "split" => "split_text",
        "contains" => "text_contains",
        "startsWith" => "text_starts_with",
        "endsWith" => "text_ends_with",
        "trim" => "text_trim",
        "join" => "text_join",
        other => return TRANSLATED.iter().find(|name| **name == other).copied(),
    };
    Some(function)
}

pub(crate) fn sets_exit_code(module: &pseudolearn_semantic::HirModule) -> bool {
    module.expressions.kinds.iter().any(|expression| {
        matches!(expression, pseudolearn_semantic::HirExpression::Effect { operation, .. }
        if pseudolearn_semantic::EFFECT_OPERATIONS.iter().any(|entry| {
            entry.id == *operation && entry.identity == "console_set_exit_code"
        }))
    })
}

pub(crate) fn literal_text(
    view: &crate::module_view::ModuleView<'_>,
    argument: pseudolearn_semantic::ExpressionId,
) -> Option<String> {
    use pseudolearn_semantic::{BuiltinKind, HirExpression, Literal};
    match view.expression(argument) {
        HirExpression::Literal(Literal::String(text)) => Some(text.clone()),
        HirExpression::Builtin {
            function: BuiltinKind::ToText,
            arguments,
        } => match arguments.as_slice() {
            [inner] => match view.expression(*inner) {
                HirExpression::Literal(Literal::Character(character)) => {
                    Some(character.to_string())
                }
                _ => None,
            },
            _ => None,
        },
        _ => None,
    }
}
