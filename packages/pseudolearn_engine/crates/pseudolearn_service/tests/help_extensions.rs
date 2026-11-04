use pseudolearn_lexicon::Profile;
use pseudolearn_service::marked_text::split_cursor;
use pseudolearn_service::{DocumentSession, HelpLocale, help_content, resolve_help_at_position};

fn assert_card(source: &str, profile: Profile, expected: &str) -> Result<(), String> {
    let (source, position) = split_cursor(source);
    let document = DocumentSession::new(source, profile);
    let outcome = resolve_help_at_position(&document, position).ok_or("missing resolution")?;
    assert!(outcome.hover.is_some());
    for locale in [HelpLocale::Spanish, HelpLocale::English] {
        let content = help_content(&outcome, locale).ok_or("missing content")?;
        assert_eq!(content.card_id, expected);
    }
    Ok(())
}

fn marked(name: &str) -> String {
    let (left, right) = name.split_at(1);
    format!("{left}|{right}")
}

#[test]
fn text_and_vector_contains_resolve_different_cards() -> Result<(), String> {
    for (source, profile, expected) in [
        (
            "algorithm P\nwrite con|tains(\"abcd\",\"bc\");\nendAlgorithm\n",
            Profile::English,
            "help.pg501.contains",
        ),
        (
            "Algoritmo P\nEscribir Con|tiene(\"abcd\",\"bc\");\nFinAlgoritmo\n",
            Profile::Spanish,
            "help.pg501.contains",
        ),
        (
            "algorithm P\ndefine values as vector<integer> <- vector();\nwrite values.con|tains(1);\nendAlgorithm\n",
            Profile::English,
            "help.pgs02.vector_contains",
        ),
        (
            "Algoritmo P\nDefinir values Como Vector<Entero> <- Vector();\nEscribir values.Con|tiene(1);\nFinAlgoritmo\n",
            Profile::Spanish,
            "help.pgs02.vector_contains",
        ),
    ] {
        assert_card(source, profile, expected)?;
    }
    Ok(())
}

#[test]
fn numeric_cards_resolve_exact_identities_in_both_profiles() -> Result<(), String> {
    for (spanish, english, identity, arguments) in [
        ("min", "min", "minimum", "1,2"),
        ("max", "max", "maximum", "1,2"),
        ("piso", "floor", "floor", "1.5"),
        ("techo", "ceil", "ceiling", "1.5"),
        ("tan", "tan", "tangent", "0.5"),
        ("asen", "asin", "arc_sine", "0.5"),
        ("acos", "acos", "arc_cosine", "0.5"),
        ("atan2", "atan2", "arc_tangent2", "1,2"),
        ("log10", "log10", "logarithm10", "2"),
        ("log2", "log2", "logarithm2", "2"),
    ] {
        for (profile, name, opening, write, closing) in [
            (
                Profile::Spanish,
                spanish,
                "Algoritmo",
                "Escribir",
                "FinAlgoritmo",
            ),
            (
                Profile::English,
                english,
                "algorithm",
                "write",
                "endAlgorithm",
            ),
        ] {
            let source = format!(
                "{opening} P\n{write} {}({arguments});\n{closing}\n",
                marked(name)
            );
            assert_card(&source, profile, &format!("help.pgs03.{identity}"))?;
        }
    }
    Ok(())
}

#[test]
fn collection_cards_resolve_exact_identities_in_both_profiles() -> Result<(), String> {
    for (spanish, english, identity, arguments, dictionary) in [
        ("Ordenar", "sort", "vector_sort", "", false),
        ("Invertir", "reverse", "vector_reverse", "", false),
        ("PosicionDe", "indexOf", "vector_index_of", "1", false),
        ("Contiene", "contains", "vector_contains", "1", false),
        ("Claves", "keys", "dictionary_keys", "", true),
    ] {
        let kind = if dictionary {
            "dictionary<integer,integer> <- dictionary()"
        } else {
            "vector<integer> <- vector()"
        };
        let english_source = format!(
            "algorithm P\ndefine values as {kind};\nvalues.{}({arguments});\nendAlgorithm\n",
            marked(english)
        );
        assert_card(
            &english_source,
            Profile::English,
            &format!("help.pgs02.{identity}"),
        )?;
        let kind = if dictionary {
            "Diccionario<Entero,Entero> <- Diccionario()"
        } else {
            "Vector<Entero> <- Vector()"
        };
        let spanish_source = format!(
            "Algoritmo P\nDefinir values Como {kind};\nvalues.{}({arguments});\nFinAlgoritmo\n",
            marked(spanish)
        );
        assert_card(
            &spanish_source,
            Profile::Spanish,
            &format!("help.pgs02.{identity}"),
        )?;
    }
    Ok(())
}
