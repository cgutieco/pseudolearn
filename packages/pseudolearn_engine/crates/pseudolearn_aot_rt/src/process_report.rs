use crate::fault::{FaultRecord, render_fault};
use crate::metadata::ExecutableSettings;

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

pub(crate) fn fault_report(record: &FaultRecord, settings: &ExecutableSettings) -> String {
    let Some(code) = record.code else {
        return fill_template(
            &settings.exhausted_template,
            &[("path", &settings.source_name)],
        );
    };
    let message = render_fault(record, &settings.locale).unwrap_or_default();
    let line = record.range.start_line.to_string();
    let column = record.range.start_column.to_string();
    fill_template(
        &settings.error_template,
        &[
            ("path", &settings.source_name),
            ("line", &line),
            ("column", &column),
            ("message", &message),
            ("code", code.as_str()),
        ],
    )
}
