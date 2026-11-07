use reference_corpus::Corpus;
use reference_model::{
    CodeEngine, EngineDiagnostic, ExecutionReport, ExecutionRequest, Profile, RawToken,
    SourceDocument, TraceRecord,
};
use reference_resolve::{AliasTable, CategoryTable, LanguagePack, SectionIndex};
use std::cell::Cell;
use std::collections::BTreeMap;

const EXPORT: &str = r#"{
  "resources": {
    "vocabulary": {
      "ifKeyword": {"alias": {"en": [], "es": []}, "lexemas": {"en": "if", "es": "Si"}},
      "then": {"alias": {"en": [], "es": []}, "lexemas": {"en": "then", "es": "Entonces"}},
      "endIf": {"alias": {"en": [], "es": []}, "lexemas": {"en": "endIf", "es": "FinSi"}},
      "write": {"alias": {"en": [], "es": []}, "lexemas": {"en": "write", "es": "Escribir"}},
      "subroutine": {"alias": {"en": ["function"], "es": ["Funcion"]}, "lexemas": {"en": "subroutine", "es": "SubProceso"}}
    },
    "contextualVocabulary": {"vectorAppend": {"lexemas": {"en": "append", "es": "Agregar"}}},
    "functions": {"textLength": {"alias": {"en": [], "es": []}, "family": "text", "lexemas": {"en": "length", "es": "Longitud"}, "parametros": ["text"], "retorno": "integer"}},
    "diagnostics": {"integerOverflow": {"clase": "runtime", "severidad": "error", "mensajes": {"en": "Overflow of {lexeme}", "es": "Desbordamiento de {lexeme}"}}},
    "grammar": {"producciones": {"conditional": "@ifKeyword, expression, @then, line, body, @endIf"}}
  },
  "specifications": []
}"#;

pub const KEYWORDS: [(&str, &str); 6] = [
    ("Si", "ifKeyword"),
    ("Entonces", "then"),
    ("FinSi", "endIf"),
    ("Escribir", "write"),
    ("SubProceso", "subroutine"),
    ("Funcion", "subroutine"),
];

#[derive(Default)]
pub struct FakeEngine {
    pub executions: Cell<usize>,
}

impl CodeEngine for FakeEngine {
    fn tokenize(&self, code: &str, _profile: Profile) -> Vec<RawToken> {
        let mut tokens = Vec::new();
        let mut start = None;
        for (index, character) in code.chars().chain(std::iter::once(' ')).enumerate() {
            match (character.is_alphanumeric(), start) {
                (true, None) => start = Some(index),
                (false, Some(first)) => {
                    tokens.push(word_token(code, first, index));
                    start = None;
                }
                _ => {}
            }
            if character == '.' {
                tokens.push(RawToken {
                    kind: "punctuation".to_owned(),
                    keyword: None,
                    start: index,
                    end: index.saturating_add(1),
                });
            }
        }
        tokens
    }

    fn translate(&self, code: &str, _target: Profile) -> Result<String, String> {
        if code.contains("roto") {
            return Err("ParseFailure".to_owned());
        }
        Ok(code.replace("Escribir", "Write"))
    }

    fn execute(&self, request: &ExecutionRequest) -> ExecutionReport {
        self.executions.set(self.executions.get().saturating_add(1));
        let failed = request.code.contains("roto");
        ExecutionReport {
            output: if failed {
                String::new()
            } else {
                "1\n".to_owned()
            },
            termination: if failed { "rejected" } else { "completed" }.to_owned(),
            diagnostics: if failed {
                vec![EngineDiagnostic {
                    code: "integerOverflow".to_owned(),
                    severity: "error".to_owned(),
                    line: 1,
                    column: 1,
                    spanish: "Desbordamiento".to_owned(),
                    english: "Overflow".to_owned(),
                }]
            } else {
                Vec::new()
            },
            trace: vec![
                TraceRecord {
                    line: 1,
                    class: "statement_entered".to_owned(),
                    detail: "null".to_owned(),
                },
                TraceRecord {
                    line: 1,
                    class: "statement_exited".to_owned(),
                    detail: "null".to_owned(),
                },
                TraceRecord {
                    line: 2,
                    class: "output".to_owned(),
                    detail: "{\"texto\":\"1\\n\"}".to_owned(),
                },
            ],
        }
    }

    fn intermediate(&self, code: &str, _profile: Profile) -> Result<String, String> {
        if code.contains("roto") {
            return Err("unclosed".to_owned());
        }
        Ok("module P\nfunc @main".to_owned())
    }

    fn fingerprint(&self) -> String {
        "fake".to_owned()
    }
}

fn word_token(code: &str, first: usize, index: usize) -> RawToken {
    let word: String = code
        .chars()
        .skip(first)
        .take(index.saturating_sub(first))
        .collect();
    let keyword = KEYWORDS
        .iter()
        .find(|(lexeme, _)| *lexeme == word)
        .map(|(_, identity)| (*identity).to_owned());
    let kind = if keyword.is_some() {
        "keyword"
    } else if word.chars().all(|digit| digit.is_ascii_digit()) {
        "integer_literal"
    } else {
        "identifier"
    };
    RawToken {
        kind: kind.to_owned(),
        keyword,
        start: first,
        end: index,
    }
}

pub fn corpus() -> Corpus {
    Corpus::from_export(EXPORT).unwrap_or_default()
}

pub fn categories() -> CategoryTable {
    CategoryTable::from_json(r#"{"ifKeyword": "keywordStructured", "then": "keywordStructured", "endIf": "keywordStructured", "write": "keywordStructured", "vectorAppend": "identifier"}"#)
        .unwrap_or_default()
}

pub fn pack() -> LanguagePack {
    LanguagePack::from_json(
        r#"{"interface": {"rails.title": "Raíles:", "trace.output": "escribe", "trace.statement_entered": "entra", "table.spanish": "Español"},
            "productions": {"expression": "expresión", "body": "instrucciones", "conditional": "decisión", "line": "línea"},
            "figures": {"caja": {"titulo": "Caja", "descripcion": "Una caja", "nombre": "edad"}}}"#,
    )
    .unwrap_or_default()
}

pub fn figures() -> BTreeMap<String, String> {
    BTreeMap::from([(
        "caja".to_owned(),
        "<svg viewBox=\"0 0 340 40\"><text x=\"1\" y=\"20\">{{t:nombre}} {{lex:ifKeyword}}</text><g data-paso=\"2\"><rect x=\"0\" y=\"0\" width=\"4\" height=\"4\" fill=\"@exito\"/></g></svg>".to_owned(),
    )])
}

pub fn document(body: &str) -> SourceDocument {
    let text = format!(
        "---\nid: prueba\nnumero: \"6.1\"\ntipo: concepto\ntitulo: La decisión `Si`\nanclas: [LANG.CONTROL.IF]\n---\n{body}"
    );
    let parsed = reference_format::parse_document("prueba.md", &text);
    assert!(parsed.is_ok(), "{parsed:?}");
    parsed.unwrap_or_else(|_| panic_free_document())
}

fn panic_free_document() -> SourceDocument {
    reference_format::parse_document(
        "vacio.md",
        "---\nid: vacio\nnumero: \"0\"\ntipo: apendice\ntitulo: V\n---\n",
    )
    .unwrap_or_else(|_| SourceDocument {
        path: String::new(),
        header: reference_model::SectionHeader {
            id: String::new(),
            number: String::new(),
            kind: reference_model::SectionKind::Appendix,
            title: String::new(),
            anchors: Vec::new(),
            cards: Vec::new(),
            diagnostics: Vec::new(),
            terms: Vec::new(),
        },
        title: Vec::new(),
        blocks: Vec::new(),
    })
}

pub fn index() -> SectionIndex {
    SectionIndex {
        sections: BTreeMap::from([(
            "prueba".to_owned(),
            reference_resolve::IndexedSection {
                number: "6.1".to_owned(),
                title: "La decisión Si".to_owned(),
                terms: vec!["rama".to_owned()],
                diagnostics: vec!["integerOverflow".to_owned()],
            },
        )]),
    }
}

pub fn aliases() -> AliasTable {
    AliasTable::from_json(r#"[{"es": "Funcion", "en": "Function"}]"#).unwrap_or_default()
}
