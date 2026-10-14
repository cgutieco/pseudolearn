mod contracts;
use serde_json::json;

fn corpus(english_lexeme: &str) -> Result<see_model::Corpus, String> {
    contracts::corpus(
        "TOOL.CLI.CONVENTIONS",
        json!([
            {"kind":"definicion","fields":{"id":"D1","termino":"cliConventions","texto":"Convenciones.","valor":{"codigos_salida":{"0":"éxito"},"aperturas":["algorithm","classKeyword"]}}},
            {"kind":"definicion","fields":{"id":"D2","termino":"vocabulary","texto":"Vocabulario.","valor":{
                "algorithm":{"lexemas":{"es":"Proceso","en":"algorithm"},"alias":{"es":["Algoritmo"],"en":[]}},
                "classKeyword":{"lexemas":{"es":"Clase","en":"class"},"alias":{"es":[],"en":[]}},
                "other":{"lexemas":{"es":"Otro","en":english_lexeme},"alias":{"es":[],"en":[]}}
            }}}
        ]),
    )
}

#[test]
fn accepts_disjoint_openers_and_folds_case_and_accents() -> Result<(), String> {
    assert!(
        see_validation::openers::check(&corpus("other")?, &json!({"aperturas":["algorithm"]}))
            .is_empty()
    );
    assert_eq!(
        see_validation::openers::folded("ÁLGORÍTMO Ñandú"),
        "algoritmo nandu"
    );
    assert_eq!(see_validation::openers::folded(""), "");
    Ok(())
}

#[test]
fn rejects_openers_shared_with_the_other_profile_and_unknown_identities() -> Result<(), String> {
    for colliding in ["proceso", "ALGORITMO", "Cláse"] {
        let corpus = corpus(colliding)?;
        let errors = see_validation::cli::check(&corpus);
        assert!(
            errors
                .iter()
                .any(|error| error.starts_with("SEE-PROFILE-OPENERS")),
            "{colliding}"
        );
    }
    let errors =
        see_validation::openers::check(&corpus("other")?, &json!({"aperturas":["missing"]}));
    assert!(errors.iter().any(|error| error.contains("unknown opener")));
    Ok(())
}
