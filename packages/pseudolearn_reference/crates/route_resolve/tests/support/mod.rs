use reference_corpus::Corpus;
use reference_model::{CodeEngine, ExecutionReport, ExecutionRequest, Profile, RawToken};
use reference_resolve::{CategoryTable, IndexedSection, LanguagePack, SectionIndex};
use std::collections::BTreeMap;

pub struct EchoEngine;

impl CodeEngine for EchoEngine {
    fn tokenize(&self, _code: &str, _profile: Profile) -> Vec<RawToken> {
        Vec::new()
    }

    fn translate(&self, code: &str, _target: Profile) -> Result<String, String> {
        Ok(code.replace("Escribir", "Write"))
    }

    fn execute(&self, request: &ExecutionRequest) -> ExecutionReport {
        let output = if request.code.contains('⟦') {
            "⟦0|0⟧\n⟦1|1⟧\n".to_owned()
        } else if request.code.contains("doble") {
            request
                .inputs
                .iter()
                .map(|input| format!("{input}{input}\n"))
                .collect()
        } else {
            request
                .inputs
                .iter()
                .map(|input| format!("{input}\n"))
                .collect()
        };
        ExecutionReport {
            output,
            termination: "completed".to_owned(),
            ..ExecutionReport::default()
        }
    }

    fn intermediate(&self, _code: &str, _profile: Profile) -> Result<String, String> {
        Ok(String::new())
    }

    fn fingerprint(&self) -> String {
        "echo".to_owned()
    }
}

pub fn corpus() -> Corpus {
    Corpus::from_export(r#"{"resources": {}, "specifications": []}"#).unwrap_or_default()
}

pub fn categories() -> CategoryTable {
    CategoryTable::from_json("{}").unwrap_or_default()
}

pub fn pack() -> LanguagePack {
    LanguagePack::from_json(
        r#"{"figures": {"icono": {"titulo": "Icono", "descripcion": "Un icono"}}}"#,
    )
    .unwrap_or_default()
}

pub fn figures() -> BTreeMap<String, String> {
    BTreeMap::from([(
        "icono".to_owned(),
        "<svg viewBox=\"0 0 340 80\"><rect x=\"0\" y=\"0\" width=\"4\" height=\"4\" fill=\"@exito\"/></svg>".to_owned(),
    )])
}

pub fn index() -> SectionIndex {
    SectionIndex {
        sections: BTreeMap::from([(
            "control.si".to_owned(),
            IndexedSection {
                number: "6.1".to_owned(),
                title: "La decisión Si".to_owned(),
                terms: Vec::new(),
                diagnostics: Vec::new(),
            },
        )]),
    }
}
