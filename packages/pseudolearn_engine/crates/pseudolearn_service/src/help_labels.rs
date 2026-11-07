use crate::help_catalog::{HelpCategory, HelpLocale};

pub(crate) struct HelpLabels {
    pub how_to_write: &'static str,
    pub parts: &'static str,
    pub result: &'static str,
    pub rules: &'static str,
    pub common_errors: &'static str,
    pub example: &'static str,
    pub examples: &'static str,
    pub output: &'static str,
    pub omitted: &'static str,
    categories: [&'static str; 6],
}

impl HelpLabels {
    pub(crate) fn category(&self, category: HelpCategory) -> &'static str {
        let index = match category {
            HelpCategory::Block => 0,
            HelpCategory::Instruction => 1,
            HelpCategory::Symbol => 2,
            HelpCategory::Function => 3,
            HelpCategory::Type => 4,
            HelpCategory::Value => 5,
        };
        self.categories.get(index).copied().unwrap_or_default()
    }
}

const SPANISH: HelpLabels = HelpLabels {
    how_to_write: "Cómo se escribe",
    parts: "Cada parte",
    result: "Devuelve",
    rules: "Reglas",
    common_errors: "Errores comunes",
    example: "Ejemplo",
    examples: "Ejemplos",
    output: "Resultado",
    omitted: "Contenido omitido por superar el límite de tamaño.",
    categories: [
        "Bloque",
        "Instrucción",
        "Símbolo",
        "Función",
        "Tipo de dato",
        "Valor",
    ],
};

const ENGLISH: HelpLabels = HelpLabels {
    how_to_write: "How to write it",
    parts: "Each part",
    result: "Returns",
    rules: "Rules",
    common_errors: "Common mistakes",
    example: "Example",
    examples: "Examples",
    output: "Output",
    omitted: "Content omitted because it exceeds the size limit.",
    categories: [
        "Block",
        "Instruction",
        "Symbol",
        "Function",
        "Data type",
        "Value",
    ],
};

pub(crate) fn labels_for(locale: HelpLocale) -> &'static HelpLabels {
    match locale {
        HelpLocale::Spanish => &SPANISH,
        HelpLocale::English => &ENGLISH,
    }
}
