use crate::fault::{FaultRecord, render_fault};
use crate::metadata::ExecutableSettings;
use pseudolearn_diagnostics::{DiagnosticCode, DiagnosticSeverity};

pub(crate) fn fill_template(template: &str, arguments: &[(&str, &str)]) -> String {
    let mut remaining = template;
    let mut output = String::new();
    while let Some(opening) = remaining.find('{') {
        output.push_str(remaining.get(..opening).unwrap_or(""));
        let suffix = remaining.get(opening.saturating_add(1)..).unwrap_or("");
        let Some(closing) = suffix.find('}') else {
            output.push_str(remaining.get(opening..).unwrap_or(""));
            return output;
        };
        let name = suffix.get(..closing).unwrap_or("");
        if let Some((_, value)) = arguments.iter().find(|(key, _)| *key == name) {
            output.push_str(value);
        }
        remaining = suffix.get(closing.saturating_add(1)..).unwrap_or("");
    }
    output.push_str(remaining);
    output
}

fn json_text(value: &str) -> String {
    let mut quoted = String::from("\"");
    for character in value.chars() {
        match character {
            '"' => quoted.push_str("\\\""),
            '\\' => quoted.push_str("\\\\"),
            '\n' => quoted.push_str("\\n"),
            '\r' => quoted.push_str("\\r"),
            '\t' => quoted.push_str("\\t"),
            control if u32::from(control) < 0x20 => {
                quoted.push_str(&format!("\\u{:04x}", u32::from(control)));
            }
            other => quoted.push(other),
        }
    }
    quoted.push('"');
    quoted
}

fn limit_of(code: DiagnosticCode, settings: &ExecutableSettings) -> Option<u64> {
    match code.as_str() {
        "cellLimitExceeded" => Some(settings.limits.cells),
        "recursionDepthExceeded" => Some(u64::from(settings.limits.frames)),
        "statementBudgetExhausted" => settings.limits.instruction_units,
        _ => None,
    }
}

fn arguments_json(
    record: &FaultRecord,
    code: DiagnosticCode,
    settings: &ExecutableSettings,
) -> String {
    let mut entries: Vec<String> = record
        .arguments
        .iter()
        .map(|(name, value)| format!("{}:{}", json_text(name), argument_json(code, name, value)))
        .collect();
    if let Some(limit) = limit_of(code, settings) {
        entries.push(format!("\"limit\":{limit}"));
    }
    format!("{{{}}}", entries.join(","))
}

fn template_for(code: DiagnosticCode, settings: &ExecutableSettings) -> &str {
    match code.severity("estricto") {
        DiagnosticSeverity::Error => &settings.error_template,
        DiagnosticSeverity::Warning => &settings.warning_template,
        DiagnosticSeverity::Information => &settings.information_template,
    }
}

pub(crate) fn diagnostic_report(record: &FaultRecord, settings: &ExecutableSettings) -> String {
    let Some(code) = record.code else {
        return fill_template(
            &settings.exhausted_template,
            &[("path", &settings.source_name)],
        );
    };
    let message = render_fault(record, &settings.locale).unwrap_or_default();
    let line = record.range.start_line.to_string();
    let column = record.range.start_column.to_string();
    let source_id = record.range.source_id.to_string();
    let end_line = record.range.end_line.to_string();
    let end_column = record.range.end_column.to_string();
    let arguments = arguments_json(record, code, settings);
    fill_template(
        template_for(code, settings),
        &[
            ("path", &settings.source_name),
            ("source_id", &source_id),
            ("line", &line),
            ("column", &column),
            ("end_line", &end_line),
            ("end_column", &end_column),
            ("message", &message),
            ("code", code.as_str()),
            ("arguments", &arguments),
        ],
    )
}

fn argument_json(code: DiagnosticCode, name: &str, value: &str) -> String {
    if code.argument_kind(name) == Some(pseudolearn_diagnostics::ArgumentKind::Number)
        && value.parse::<i128>().is_ok()
    {
        value.to_owned()
    } else {
        json_text(value)
    }
}
