use crate::diagnostic::Diagnostic;

pub fn render(diagnostic: &Diagnostic, locale: &str) -> String {
    let template = diagnostic.code.template(locale);
    let mut rendered = template.to_owned();
    for (key, replacement) in &diagnostic.arguments {
        let pattern = format!("{{{key}}}");
        rendered = rendered.replace(&pattern, replacement);
    }
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
