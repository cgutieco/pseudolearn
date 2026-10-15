use crate::diagnostic::Diagnostic;

pub fn render(diagnostic: &Diagnostic, locale: &str) -> String {
    let template = diagnostic.code.template(locale);
    let mut remaining = template;
    let mut rendered = String::new();
    while let Some(opening) = remaining.find('{') {
        rendered.push_str(remaining.get(..opening).unwrap_or(""));
        let suffix = remaining.get(opening.saturating_add(1)..).unwrap_or("");
        let Some(closing) = suffix.find('}') else {
            rendered.push_str(remaining);
            return rendered;
        };
        let name = suffix.get(..closing).unwrap_or("");
        if let Some(value) = diagnostic.arguments.get(name) {
            rendered.push_str(&value.text());
        }
        remaining = suffix.get(closing.saturating_add(1)..).unwrap_or("");
    }
    rendered.push_str(remaining);
    rendered
}

pub fn sort_diagnostics(diagnostics: &mut [Diagnostic]) {
    diagnostics.sort_by(|first, second| {
        let start_comparison = first.span.start.cmp(&second.span.start);
        if start_comparison != std::cmp::Ordering::Equal {
            return start_comparison;
        }
        let ending_comparison = first.span.ending.cmp(&second.span.ending);
        if ending_comparison != std::cmp::Ordering::Equal {
            return ending_comparison;
        }
        first.code.as_str().cmp(second.code.as_str())
    });
}
