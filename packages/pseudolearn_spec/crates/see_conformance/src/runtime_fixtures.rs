use crate::requests::{self, Selection};
use see_model::{Block, Corpus, contract::Vocabulary, strings};
use serde_json::{Value, json};

pub fn cases(corpus: &Corpus, vocabulary: &Vocabulary) -> Result<Vec<Value>, String> {
    collect(corpus, vocabulary, &["execute"])
}

pub fn execution_cases(corpus: &Corpus, vocabulary: &Vocabulary) -> Result<Vec<Value>, String> {
    collect(corpus, vocabulary, &["execute", "trace"])
}

fn collect(
    corpus: &Corpus,
    vocabulary: &Vocabulary,
    operations: &[&str],
) -> Result<Vec<Value>, String> {
    let mut fixtures = Vec::new();
    for specification in corpus {
        for case in &specification.blocks {
            if case.kind == "caso" && operations.contains(&requests::operation(case)) {
                append(
                    case,
                    (&specification.metadata.id, vocabulary),
                    &mut fixtures,
                )?;
            }
        }
    }
    Ok(fixtures)
}

fn append(
    case: &Block,
    (identity, vocabulary): (&str, &Vocabulary),
    fixtures: &mut Vec<Value>,
) -> Result<(), String> {
    for profile in strings(case.fields.get("perfiles")) {
        for strictness in strings(case.fields.get("rigor")) {
            let expected = case
                .fields
                .get("esperas")
                .and_then(|values| values.get(profile))
                .or_else(|| case.fields.get("espera"))
                .ok_or("Missing runtime expectation")?
                .clone();
            let expected = crate::execution::resolved_expected(expected, profile, vocabulary)?;
            let selection = Selection {
                profile,
                strictness,
                expected: &expected,
            };
            let request = requests::build(case, &selection, vocabulary)?;
            fixtures.push(json!({"specification":identity,"case":case.fields.get("id"),"request":request,"expected":expected}));
        }
    }
    Ok(())
}
