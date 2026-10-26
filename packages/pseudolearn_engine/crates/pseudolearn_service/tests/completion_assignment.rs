use pseudolearn_service::marked_text::split_cursor;
use pseudolearn_service::{DocumentSession, Profile, apply_change, build_insertion};

fn insertion_for(marked: &str, profile: Profile) -> Option<(String, usize)> {
    let (clean, position) = split_cursor(marked);
    let session = DocumentSession::new(clean, profile, false);
    let result = session.queries().complete_with_edit(position);
    let entry = result.entries.iter().find(|entry| entry.inline)?;
    let insertion = build_insertion(entry, &result.text_edit, session.text(), profile);
    Some((
        apply_change(session.text(), &insertion.edit),
        insertion.final_offset,
    ))
}

#[test]
fn trailing_whitespace_and_unicode_preserve_the_identifier_and_caret() {
    let code = "Algoritmo Medida\n\tDefinir Mutable duración Como Real <- 0.0;\n\tduración \t |\nFinAlgoritmo\n";
    let expected =
        "Algoritmo Medida\n\tDefinir Mutable duración Como Real <- 0.0;\n\tduración <- \nFinAlgoritmo\n";
    assert_eq!(
        insertion_for(code, Profile::Spanish),
        Some((
            expected.to_owned(),
            expected.find("\nFinAlgoritmo").unwrap_or(0)
        ))
    );
}

#[test]
fn exact_targets_do_not_require_unique_name_prefixes() {
    let code = "algorithm Main\n  define mutable value as integer <- 0;\n  define mutable values as integer <- 0;\n  value|\nendAlgorithm\n";
    assert!(insertion_for(code, Profile::English).is_some());
}

#[test]
fn unrelated_errors_do_not_hide_a_confirmed_target() {
    let code = "Algoritmo Medida\n  Definir Mutable total Como Real <- 0.0;\n  Escribir inexistente;\n  total|\nFinAlgoritmo\n";
    assert!(insertion_for(code, Profile::Spanish).is_some());
}

#[test]
fn invalid_targets_and_non_statement_positions_stay_silent() {
    let statements = [
        "Definir Mutable total Como Entero <- 0;\n  Definir Mutable total Como Real <- 0.0;\n  total|",
        "total|\n  Definir Mutable total Como Entero <- 0;",
        "Definir Mutable total Como Entero <- 0;\n  total| <- 1;",
        "Definir Mutable total Como Entero <- 0;\n  total| // existing explanation",
        "Definir Mutable total Como Entero <- 0;\n  total|[1]",
        "Definir Mutable total Como Entero <- 0;\n  total|()",
        "Definir Mutable total Como Entero <- 0;\n  Escribir total|",
        "Definir Mutable total Como Entero <- 0;\n  Leer total|",
        "Definir Mutable total Como Entero <- 0;\n  Si total|",
        "Definir Mutable total Como Entero <- 0;\n  total <- total|",
        "Definir Mutable total Como Entero <- 0;\n  tot|al",
        "Definir Mutable total Como Entero <- 0;\n  /* before */ total|",
        "Definir Mutable total Como Entero <- 0;\n  Leer\n  total|",
        "Definir Mutable total Como Entero <- 0;\n  total <-\n  total|",
        "total <- 1;\n  total|",
        "Definir Mutable total Como Entero <- 0;\n  total|   ",
        "Definir Mutable total Como Entero <- 0;\n  Mostrar(\n    1\n    total|",
        "Definir Mutable total Como Entero <- 0;\n  total <- (\n    1\n    total|",
    ];
    for statement in statements {
        let code = format!("Algoritmo Medida\n  {statement}\nFinAlgoritmo\n");
        assert_eq!(insertion_for(&code, Profile::Spanish), None, "{statement}");
    }
}

#[test]
fn parameters_and_object_references_are_assignable() {
    let codes = [
        "SubProceso Medir(total Como Entero)\n  total|\nFinSubProceso\nAlgoritmo P\nFinAlgoritmo\n",
        "Clase Caja\nFinClase\nAlgoritmo Medida\n  Definir Mutable caja Como Caja <- Nuevo Caja();\n  caja|\nFinAlgoritmo\n",
    ];
    for code in codes {
        assert!(insertion_for(code, Profile::Spanish).is_some(), "{code}");
    }
}

#[test]
fn names_from_other_units_and_unknown_parameter_types_stay_silent() {
    let codes = [
        "SubProceso Medir()\n  Definir Mutable total Como Entero <- 0;\nFinSubProceso\nAlgoritmo P\n  total|\nFinAlgoritmo\n",
        "SubProceso Medir(total)\n  total|\nFinSubProceso\nAlgoritmo P\nFinAlgoritmo\n",
    ];
    for code in codes {
        assert_eq!(insertion_for(code, Profile::Spanish), None);
    }
}
