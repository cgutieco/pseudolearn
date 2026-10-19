use crate::{ApiDiagnostic, ApiSession};
use serde_json::Value;

impl ApiSession {
    pub(crate) fn remember_locale(&mut self, analysis: u64, arguments: &Value) {
        if let Some(locale) = arguments.get("locale").and_then(Value::as_str) {
            self.locales.insert(analysis, locale.to_owned());
        }
    }

    pub(crate) fn locale_of(&self, analysis: u64) -> Option<&str> {
        self.locales.get(&analysis).map(String::as_str)
    }
}

pub(crate) fn relocalize(report: &mut Value, locale: &str) {
    let Some(diagnostics) = report.get_mut("diagnostics").and_then(Value::as_array_mut) else {
        return;
    };
    for entry in diagnostics {
        let Ok(mut diagnostic) = serde_json::from_value::<ApiDiagnostic>(entry.clone()) else {
            continue;
        };
        diagnostic.message = crate::render_diagnostic(&diagnostic, locale);
        if let Ok(rendered) = serde_json::to_value(&diagnostic) {
            *entry = rendered;
        }
    }
}
