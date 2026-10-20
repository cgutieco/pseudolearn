use pseudolearn_service::marked_text::split_cursor;
use pseudolearn_service::{DocumentSession, Profile, apply_change, build_insertion};

fn accepted(marked: &str, label: &str) -> Result<String, String> {
    let (clean, position) = split_cursor(marked);
    let session = DocumentSession::new(clean, Profile::Spanish, false);
    let result = session.queries().complete_with_edit(position);
    let entry = result
        .entries
        .iter()
        .find(|entry| entry.label == label)
        .ok_or("missing candidate")?;
    let insertion = build_insertion(entry, &result.text_edit, session.text(), session.profile);
    Ok(apply_change(session.text(), &insertion.edit))
}

#[test]
fn a_nested_template_preserves_the_closer_of_its_outer_block() -> Result<(), String> {
    let result = accepted(
        "Algoritmo P\n  Mientras Verdadero Hacer\n    Mie|\n  FinMientras\nFinAlgoritmo\n",
        "Mientras",
    )?;
    assert_eq!(result.matches("FinMientras").count(), 2);
    assert!(result.contains("Mientras condicion Hacer\n      \n    FinMientras"));
    Ok(())
}

#[test]
fn a_reused_closer_preserves_existing_branches_and_body() -> Result<(), String> {
    let result = accepted(
        "Algoritmo P\n  Si|\n    Escribir 1;\n  Sino\n    Escribir 2;\n  FinSi\nFinAlgoritmo\n",
        "Si",
    )?;
    assert_eq!(result.matches("FinSi").count(), 1);
    assert_eq!(result.matches("Sino").count(), 1);
    assert!(result.contains("Escribir 1;"));
    Ok(())
}

#[test]
fn a_different_closing_keyword_does_not_replace_the_template_closer() -> Result<(), String> {
    let result = accepted("Algoritmo P\n  Mie|\nFinAlgoritmo\n", "Mientras")?;
    assert_eq!(result.matches("FinMientras").count(), 1);
    assert_eq!(result.matches("FinAlgoritmo").count(), 1);
    Ok(())
}

#[test]
fn a_same_line_outer_opener_keeps_its_own_closer() -> Result<(), String> {
    let result = accepted(
        "Algoritmo P\n  Mientras Verdadero Hacer Mie|\n  FinMientras\nFinAlgoritmo\n",
        "Mientras",
    )?;
    assert_eq!(result.matches("FinMientras").count(), 2);
    Ok(())
}

#[test]
fn repeating_preserves_an_existing_termination_condition() -> Result<(), String> {
    let result = accepted(
        "Algoritmo P\n  Rep|\n  Hasta Que Verdadero\nFinAlgoritmo\n",
        "Repetir",
    )?;
    assert_eq!(result.matches("Hasta Que").count(), 1);
    assert!(result.contains("Hasta Que Verdadero"));
    Ok(())
}

#[test]
fn inline_closers_use_the_innermost_matching_opener() {
    let programs = [
        (
            "Algoritmo P\n  Mientras Verdadero Hacer\n    Mientras Verdadero Hacer\n      FinM|\n    FinMientras\n  FinMientras\nFinAlgoritmo\n",
            false,
        ),
        (
            "Algoritmo P\n  Mientras Verdadero Hacer\n    Mientras Verdadero Hacer\n      FinM|\n  FinMientras\nFinAlgoritmo\n",
            false,
        ),
        (
            "Algoritmo P\n  Mientras Verdadero Hacer\n    FinM|\nFinAlgoritmo\n",
            true,
        ),
    ];
    for (program, expected) in programs {
        let (clean, position) = split_cursor(program);
        let session = DocumentSession::new(clean, Profile::Spanish, false);
        let result = session.queries().complete_with_edit(position);
        assert_eq!(
            result.entries.iter().any(|entry| entry.inline),
            expected,
            "{program}"
        );
    }
}
