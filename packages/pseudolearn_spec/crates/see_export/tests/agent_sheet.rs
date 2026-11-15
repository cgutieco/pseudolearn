use see_export::agent_sheet::{SheetLanguage, render};
use see_export::agent_sheet_examples::example;
use see_model::{Block, Corpus, Metadata, Specification};
use serde_json::{Value, json};

fn block(kind: &str, fields: Value) -> Result<Block, String> {
    let fields = serde_json::from_value(fields).map_err(|error| error.to_string())?;
    Ok(Block {
        kind: kind.to_owned(),
        fields,
    })
}

fn corpus(termination: &str) -> Result<Corpus, String> {
    let metadata: Metadata = serde_json::from_value(json!({
        "formato": "see/1", "id": "LANG.SAMPLE", "titulo": "Muestra", "dominio": "lenguaje",
        "estado": "estable", "version": "1.0.0", "duenos": ["responsable"], "sujetos": ["engine"],
        "resumen": "Muestra."
    }))
    .map_err(|error| error.to_string())?;
    let rule = block(
        "regla",
        json!({"id": "R1", "texto": "Los índices empiezan en cero."}),
    )?;
    let case = block(
        "caso",
        json!({
            "id": "C1", "regla": "R1", "perfiles": ["es", "en"], "operacion": "execute",
            "programas": {"es": "Algoritmo P\nFinAlgoritmo\n", "en": "algorithm P\nendAlgorithm\n"},
            "espera": {"salida": "0\n", "terminacion": termination}
        }),
    )?;
    Ok(vec![Specification {
        path: "sample.md".to_owned(),
        metadata,
        blocks: vec![rule, case],
    }])
}

fn resources() -> Value {
    json!({
        "vocabulary": {"algorithm": {"lexemas": {"es": "Algoritmo", "en": "algorithm"}}},
        "functions": {"absoluteValue": {"lexemas": {"es": "abs", "en": "abs"}, "parametros": ["numeric"], "retorno": "real"}},
        "capabilityLibrary": {"operations": [{"es": "SolicitarConsola", "en": "requestConsole", "parameters": [], "result": "console"}]},
        "grammar": {"producciones": {"program": "algorithmUnit"}}
    })
}

fn settings(example_reference: &str, rule_reference: &str) -> Value {
    let keys = [
        "title",
        "introduction",
        "principles",
        "vocabulary",
        "vocabularyNote",
        "identity",
        "library",
        "parameters",
        "result",
        "operations",
        "operationsNote",
        "grammar",
        "grammarNote",
        "differences",
        "rule",
        "examples",
        "examplesNote",
        "expectedOutput",
    ];
    let labels: serde_json::Map<String, Value> = keys
        .iter()
        .map(|key| ((*key).to_owned(), json!(format!("<{key}>"))))
        .collect();
    json!({
        "labels": {"es": labels},
        "principles": {"es": ["Punto y coma."]},
        "differences": [{"rule": rule_reference, "es": "Base cero."}],
        "examples": [example_reference]
    })
}

fn rendered(
    termination: &str,
    example_reference: &str,
    rule_reference: &str,
) -> Result<String, String> {
    let settings = settings(example_reference, rule_reference);
    let labels = settings
        .pointer("/labels/es")
        .cloned()
        .unwrap_or(Value::Null);
    render(
        &corpus(termination)?,
        &resources(),
        &settings,
        &SheetLanguage {
            code: "es",
            labels: &labels,
        },
    )
}

#[test]
fn renders_every_section_with_cited_rules_and_examples() -> Result<(), String> {
    let sheet = rendered("completed", "LANG.SAMPLE#C1", "LANG.SAMPLE#R1")?;
    for expected in [
        "# <title>",
        "| algorithm | `Algoritmo` | `algorithm` |",
        "`abs` | `abs` | numeric | real",
        "`SolicitarConsola` / `requestConsole`",
        "program = algorithmUnit ;",
        "Base cero. <rule> `LANG.SAMPLE#R1`: «Los índices empiezan en cero.»",
        "```pseudolearn\nAlgoritmo P\nFinAlgoritmo\n```",
        "```text\n0\n```",
    ] {
        assert!(sheet.contains(expected), "missing {expected}");
    }
    Ok(())
}

#[test]
fn rejects_an_unknown_rule() -> Result<(), String> {
    let error = rendered("completed", "LANG.SAMPLE#C1", "LANG.SAMPLE#R9")
        .err()
        .unwrap_or_default();
    assert!(error.contains("unknown rule LANG.SAMPLE#R9"));
    Ok(())
}

#[test]
fn rejects_unknown_or_unfinished_examples() -> Result<(), String> {
    let unknown = rendered("completed", "LANG.SAMPLE#C7", "LANG.SAMPLE#R1")
        .err()
        .unwrap_or_default();
    assert!(unknown.contains("unknown case"));
    let trapped = rendered("trapped", "LANG.SAMPLE#C1", "LANG.SAMPLE#R1")
        .err()
        .unwrap_or_default();
    assert!(trapped.contains("no completed output"));
    let malformed = rendered("completed", "LANG.SAMPLE", "LANG.SAMPLE#R1")
        .err()
        .unwrap_or_default();
    assert!(malformed.contains("invalid example"));
    Ok(())
}

#[test]
fn rejects_a_profile_the_case_does_not_declare() -> Result<(), String> {
    let corpus = corpus("completed")?;
    assert!(example(&corpus, "LANG.SAMPLE#C1", "en").is_ok());
    assert!(example(&corpus, "LANG.SAMPLE#C1", "fr").is_err());
    Ok(())
}

#[test]
fn rejects_missing_labels() -> Result<(), String> {
    let settings = settings("LANG.SAMPLE#C1", "LANG.SAMPLE#R1");
    let error = render(
        &corpus("completed")?,
        &resources(),
        &settings,
        &SheetLanguage {
            code: "es",
            labels: &json!({}),
        },
    )
    .err()
    .unwrap_or_default();
    assert!(error.contains("missing label title"));
    Ok(())
}
