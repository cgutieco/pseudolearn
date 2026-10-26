use pseudolearn_lexicon::Profile;
use pseudolearn_service::marked_text::split_cursor;
use pseudolearn_service::{CompletionEntry, DocumentSession};

fn complete_marked(marked: &str, profile: Profile) -> Vec<CompletionEntry> {
    let (clean, position) = split_cursor(marked);
    DocumentSession::new(clean, profile, true)
        .queries()
        .complete_with_edit(position)
        .entries
}

fn labels(entries: &[CompletionEntry]) -> Vec<&str> {
    entries.iter().map(|entry| entry.label.as_str()).collect()
}

fn index_of(entries: &[CompletionEntry], label: &str) -> Result<usize, String> {
    labels(entries)
        .iter()
        .position(|found| *found == label)
        .ok_or_else(|| format!("{label} missing from {:?}", labels(entries)))
}

#[test]
fn conditions_rank_boolean_variables_before_incompatible_ones() -> Result<(), String> {
    let code = "Algoritmo P\n  Definir Mutable cantidad Como Entero <- 0;\n  Definir Mutable valido Como Logico <- Falso;\n  Mientras |\nFinAlgoritmo\n";
    let entries = complete_marked(code, Profile::Spanish);
    assert_eq!(labels(&entries).first(), Some(&"valido"));
    assert!(index_of(&entries, "valido")? < index_of(&entries, "cantidad")?);
    Ok(())
}

#[test]
fn incompatible_candidates_are_kept_after_compatible_ones() -> Result<(), String> {
    let code = "Algoritmo P\n  Definir Mutable cantidad Como Entero <- 0;\n  Si |\nFinAlgoritmo\n";
    let entries = complete_marked(code, Profile::Spanish);
    assert!(index_of(&entries, "Verdadero")? < index_of(&entries, "Hacer").unwrap_or(usize::MAX));
    assert!(labels(&entries).contains(&"cantidad"));
    Ok(())
}

#[test]
fn assignments_rank_the_target_type_then_widenable_then_the_rest() -> Result<(), String> {
    let code = "Algoritmo P\n  Definir Mutable total Como Real <- 0.0;\n  Definir Mutable cuenta Como Entero <- 0;\n  Definir Mutable texto Como Cadena <- \"\";\n  Definir Mutable otro Como Real <- 0.0;\n  total <- |\nFinAlgoritmo\n";
    let entries = complete_marked(code, Profile::Spanish);
    let other = index_of(&entries, "otro")?;
    let widened = index_of(&entries, "cuenta")?;
    let rest = index_of(&entries, "texto")?;
    assert!(other < widened && widened < rest, "{:?}", labels(&entries));
    Ok(())
}

#[test]
fn arguments_follow_the_parameter_type_of_user_callables() -> Result<(), String> {
    let code = "SubProceso Mostrar(texto Como Cadena)\nFinSubProceso\nAlgoritmo P\n  Definir Mutable cuenta Como Entero <- 0;\n  Definir Mutable nombre Como Cadena <- \"\";\n  Mostrar(|\nFinAlgoritmo\n";
    let entries = complete_marked(code, Profile::Spanish);
    assert!(index_of(&entries, "nombre")? < index_of(&entries, "cuenta")?);
    Ok(())
}

#[test]
fn unconstrained_slots_do_not_reorder_by_type() -> Result<(), String> {
    let code = "Algoritmo P\n  Definir Mutable cantidad Como Entero <- 0;\n  Definir Mutable valido Como Logico <- Falso;\n  Escribir |\nFinAlgoritmo\n";
    let entries = complete_marked(code, Profile::Spanish);
    assert!(index_of(&entries, "valido")? < index_of(&entries, "cantidad")?);
    Ok(())
}

#[test]
fn initials_match_after_direct_prefix_matches() -> Result<(), String> {
    let code = "Algoritmo P\n  Mientras 1 = 1 Hacer\n    fm|\nFinAlgoritmo\n";
    let entries = complete_marked(code, Profile::Spanish);
    assert_eq!(labels(&entries).first(), Some(&"FinMientras"));
    let single = complete_marked(
        "Algoritmo P\n  Mientras 1 = 1 Hacer\n    f|\nFinAlgoritmo\n",
        Profile::Spanish,
    );
    assert!(labels(&single).contains(&"FinMientras"));
    let none = complete_marked("Algoritmo P\n  zz|\nFinAlgoritmo\n", Profile::Spanish);
    assert!(none.iter().all(|entry| entry.bilingual_origin.is_some()) || none.is_empty());
    Ok(())
}

#[test]
fn initials_require_two_characters_and_segments() {
    let entries = complete_marked(
        "Algoritmo P\n  Segun 1 Hacer\n    d|\nFinAlgoritmo\n",
        Profile::Spanish,
    );
    let direct = labels(&entries)
        .iter()
        .filter(|label| label.starts_with('D'))
        .count();
    assert!(direct >= 1);
    let initials = complete_marked(
        "Algoritmo P\n  Segun 1 Hacer\n    dom|\nFinAlgoritmo\n",
        Profile::Spanish,
    );
    assert_eq!(labels(&initials).first(), Some(&"De Otro Modo"));
}

#[test]
fn detail_keys_are_stable_and_carry_arguments() -> Result<(), String> {
    let code =
        "Algoritmo P\n  Definir Mutable total Como Entero <- 0;\n  Mientras 1 = 1 Hacer\n    |\nFinAlgoritmo\n";
    let entries = complete_marked(code, Profile::Spanish);
    let closer = entries.first().ok_or("no candidates")?;
    assert_eq!(closer.detail_key.as_deref(), Some("close_block"));
    let total = entries
        .iter()
        .find(|entry| entry.label == "total")
        .ok_or("total missing")?;
    assert_eq!(total.detail_key.as_deref(), Some("type_name"));
    assert_eq!(total.detail_arguments, vec!["Entero".to_owned()]);
    Ok(())
}

#[test]
fn inline_marks_only_unambiguous_candidates() -> Result<(), String> {
    let closer = complete_marked(
        "Algoritmo P\n  Mientras 1 = 1 Hacer\n    |\nFinAlgoritmo\n",
        Profile::Spanish,
    );
    assert!(closer.iter().all(|entry| !entry.inline));
    let ambiguous = complete_marked("Algoritmo P\n  A|\nFinAlgoritmo\n", Profile::Spanish);
    assert!(ambiguous.iter().all(|entry| !entry.inline));
    let sole = complete_marked("Algoritmo P\n  Esc|\nFinAlgoritmo\n", Profile::Spanish);
    assert_eq!(sole.iter().filter(|entry| entry.inline).count(), 1);
    let exact = complete_marked("Algoritmo P\n  Escribir|\nFinAlgoritmo\n", Profile::Spanish);
    assert!(exact.iter().all(|entry| !entry.inline));
    let initials = complete_marked(
        "Algoritmo P\n  Mientras Verdadero Hacer\n    fm|\nFinAlgoritmo\n",
        Profile::Spanish,
    );
    assert!(initials.iter().all(|entry| !entry.inline));
    Ok(())
}

#[test]
fn comments_and_literals_stay_inert_for_every_new_field() {
    let entries = complete_marked("Algoritmo P\n  // Esc|\nFinAlgoritmo\n", Profile::Spanish);
    assert!(entries.is_empty());
}
