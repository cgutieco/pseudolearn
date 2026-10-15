#![forbid(unsafe_code)]

pub fn help_text(locale: &str) -> String {
    if locale == "en" {
        let usage = "Usage: pseudo <command> [options] <file>...\n";
        let commands =
            "Commands: check (comprobar), run (ejecutar), ir (ri), preferences (preferencias)\n";
        let options = "Options: --help (--ayuda), --language (--idioma), --strictness (--rigor), --vocabulary (--vocabulario), --trace (--traza), --seed (--semilla), --depth (--profundidad), --statements (--sentencias), --cells (--celdas), --json\n";
        format!("{usage}{commands}{options}")
    } else {
        let usage = "Uso: pseudo <orden> [opciones] <archivo>...\n";
        let commands =
            "Órdenes: comprobar (check), ejecutar (run), ri (ir), preferencias (preferences)\n";
        let options = "Opciones: --ayuda (--help), --idioma (--language), --rigor (--strictness), --vocabulario (--vocabulary), --traza (--trace), --semilla (--seed), --profundidad (--depth), --sentencias (--statements), --celdas (--cells), --json\n";
        format!("{usage}{commands}{options}")
    }
}

pub fn missing_command(locale: &str) -> &'static str {
    if locale == "en" {
        "pseudo: missing command; use pseudo --help\n"
    } else {
        "pseudo: falta la orden; use pseudo --ayuda\n"
    }
}

pub fn unknown_command(locale: &str, command_name: &str) -> String {
    if locale == "en" {
        format!("pseudo: unknown command '{command_name}'\n")
    } else {
        format!("pseudo: orden desconocida «{command_name}»\n")
    }
}

pub fn unknown_option(locale: &str, option_name: &str) -> String {
    if locale == "en" {
        format!("pseudo: unknown option '{option_name}'\n")
    } else {
        format!("pseudo: opción desconocida «{option_name}»\n")
    }
}

pub fn invalid_option_value(locale: &str, option_name: &str, choice: &str) -> String {
    if locale == "en" {
        format!("pseudo: invalid value '{choice}' for {option_name}\n")
    } else {
        format!("pseudo: valor no válido «{choice}» para {option_name}\n")
    }
}

pub fn missing_input(locale: &str) -> &'static str {
    if locale == "en" {
        "pseudo: missing input file\n"
    } else {
        "pseudo: falta el archivo de entrada\n"
    }
}

pub fn unreadable_input(locale: &str, target_path: &str) -> String {
    if locale == "en" {
        format!("pseudo: cannot read {target_path}\n")
    } else {
        format!("pseudo: no se puede leer {target_path}\n")
    }
}

pub fn preference_saved(locale: &str, target_language: &str) -> String {
    if locale == "en" {
        format!("pseudo: interface language saved: {target_language}\n")
    } else {
        format!("pseudo: idioma de interfaz guardado: {target_language}\n")
    }
}

pub fn invalid_preference_value(locale: &str, property: &str, choice: &str) -> String {
    if locale == "en" {
        format!("pseudo: invalid value '{choice}' for {property}\n")
    } else {
        format!("pseudo: valor no válido «{choice}» para {property}\n")
    }
}

pub fn format_diagnostic_line(
    locale: &str,
    target_path: &str,
    position: (u32, u32),
    diagnostic: &pseudolearn_api::ApiDiagnostic,
) -> String {
    let (line, column) = position;
    let severity_label = match (locale, diagnostic.severity.as_str()) {
        ("en", "warning") => "warning",
        ("en", "info") => "info",
        ("en", _) => "error",
        (_, "warning") => "advertencia",
        (_, "info") => "información",
        (_, _) => "error",
    };
    let diagnostic_message = &diagnostic.message;
    let diagnostic_code = &diagnostic.code;
    format!(
        "{target_path}:{line}:{column}: {severity_label}: {diagnostic_message} [{diagnostic_code}]\n"
    )
}
