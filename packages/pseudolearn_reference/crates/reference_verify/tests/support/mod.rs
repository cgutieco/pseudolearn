use reference_corpus::Corpus;
use reference_model::SourceDocument;

const EXPORT: &str = r#"{
  "resources": {
    "vocabulary": {
      "ifKeyword": {"alias": {"en": [], "es": []}, "lexemas": {"en": "if", "es": "Si"}},
      "endIf": {"alias": {"en": [], "es": []}, "lexemas": {"en": "endIf", "es": "FinSi"}},
      "integerType": {"alias": {"en": [], "es": []}, "lexemas": {"en": "integer", "es": "Entero"}}
    },
    "diagnostics": {"integerOverflow": {"clase": "runtime", "severidad": "error", "mensajes": {"en": "Overflow", "es": "Desbordamiento"}}},
    "helpCatalog": {"cards": [{"id": "help.conditional", "category": "block", "anchors": [{"specification": "LANG.CONTROL.IF"}], "content": {"es": {"title": "Si"}, "en": {"title": "If"}}}]}
  },
  "specifications": [
    {"hash": "abc", "metadata": {"id": "LANG.CONTROL.IF", "titulo": "Condicional"}, "blocks": [{"kind": "regla", "fields": {"id": "R1", "texto": "x"}}]},
    {"hash": "def", "metadata": {"id": "LIB.CORE.TEXT", "titulo": "Texto"}, "blocks": []}
  ]
}"#;

pub fn corpus() -> Corpus {
    Corpus::from_export(EXPORT).unwrap_or_default()
}

pub fn fixture(relative: &str) -> SourceDocument {
    let path = format!("{}/../../fixtures/{relative}", env!("CARGO_MANIFEST_DIR"));
    let text = std::fs::read_to_string(&path).unwrap_or_default();
    let parsed = reference_format::parse_document(relative, &text);
    assert!(parsed.is_ok(), "{relative} must parse");
    parsed.unwrap_or_else(|_| empty_document())
}

fn empty_document() -> SourceDocument {
    let parsed = reference_format::parse_document(
        "empty.md",
        "---\nid: vacio\nnumero: \"0\"\ntipo: apendice\ntitulo: Vacío\n---\n",
    );
    assert!(parsed.is_ok());
    parsed.unwrap_or_else(|_| unreachable_document())
}

fn unreachable_document() -> SourceDocument {
    SourceDocument {
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
    }
}
