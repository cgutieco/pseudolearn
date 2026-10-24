include!(concat!(env!("OUT_DIR"), "/generated_messages.rs"));

pub fn help_text(locale: &str) -> String {
    ["usageLine", "helpCommands", "helpOptions"]
        .iter()
        .map(|key| template(key, locale))
        .collect()
}

pub fn render(key: &str, locale: &str, arguments: &[(&str, &str)]) -> String {
    let mut remaining = template(key, locale);
    let mut output = String::new();
    while let Some(opening) = remaining.find('{') {
        output.push_str(remaining.get(..opening).unwrap_or(""));
        let suffix = remaining.get(opening.saturating_add(1)..).unwrap_or("");
        let Some(closing) = suffix.find('}') else {
            output.push_str(remaining);
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

pub fn missing_command(locale: &str) -> &'static str {
    template("missingCommand", locale)
}
pub fn missing_input(locale: &str) -> &'static str {
    template("missingInput", locale)
}
pub fn missing_entry(locale: &str) -> &'static str {
    template("missingEntry", locale)
}
pub fn unknown_command(locale: &str, command: &str) -> String {
    render("unknownCommand", locale, &[("command", command)])
}
pub fn unknown_option(locale: &str, option: &str) -> String {
    render("unknownOption", locale, &[("option", option)])
}
pub fn invalid_option_value(locale: &str, option: &str, choice: &str) -> String {
    render(
        "invalidOptionValue",
        locale,
        &[("option", option), ("value", choice)],
    )
}
pub fn unreadable_input(locale: &str, path: &str) -> String {
    render("unreadableInput", locale, &[("path", path)])
}
pub fn preference_saved(locale: &str, language: &str) -> String {
    render("preferenceSaved", locale, &[("language", language)])
}
pub fn invalid_preference_value(locale: &str, property: &str, choice: &str) -> String {
    let property = if matches!(property, "idioma" | "language") {
        if locale == "en" { "language" } else { "idioma" }
    } else {
        property
    };
    invalid_option_value(locale, property, choice)
}

pub fn format_diagnostic_line(
    locale: &str,
    target: &str,
    position: (u32, u32),
    diagnostic: &pseudolearn_api::ApiDiagnostic,
) -> String {
    let key = match diagnostic.severity.as_str() {
        "warning" => "diagnosticWarning",
        "info" => "diagnosticInfo",
        _ => "diagnosticError",
    };
    let line = position.0.to_string();
    let column = position.1.to_string();
    let message = pseudolearn_api::render_diagnostic(diagnostic, locale);
    render(
        key,
        locale,
        &[
            ("path", target),
            ("line", &line),
            ("column", &column),
            ("message", &message),
            ("code", &diagnostic.code),
        ],
    )
}
