use crate::service::help_campaign::oracle::Oracle;
use crate::service::help_campaign::scanner::scan;

fn words(program: &str) -> Result<Vec<(u32, u32, String, String)>, String> {
    let oracle = Oracle::load()?;
    Ok(scan(&oracle, "es", program)
        .occurrences
        .into_iter()
        .map(|found| (found.line, found.column, found.word, found.identity))
        .collect())
}

#[test]
fn reports_reserved_words_with_scalar_columns() -> Result<(), String> {
    let found = words("Algoritmo P\n  Mientras x Hacer\n")?;
    assert!(
        found
            .iter()
            .any(|entry| entry.2 == "Algoritmo" && entry.0 == 1 && entry.1 == 1)
    );
    assert!(
        found
            .iter()
            .any(|entry| entry.2 == "Mientras" && entry.0 == 2 && entry.1 == 3)
    );
    Ok(())
}

#[test]
fn ignores_words_inside_strings_and_comments() -> Result<(), String> {
    let found = words("Escribir \"Mientras\"; // Hacer\n/* Para\nSi */ Leer x;\n")?;
    let listed: Vec<&str> = found.iter().map(|entry| entry.2.as_str()).collect();
    assert!(listed.contains(&"Escribir"));
    assert!(listed.contains(&"Leer"));
    for hidden in ["Mientras", "Hacer", "Para", "Si"] {
        assert!(!listed.contains(&hidden), "{hidden} was scanned");
    }
    Ok(())
}

#[test]
fn compound_words_are_left_out_instead_of_being_split() -> Result<(), String> {
    let found = words("Repetir\n  x <- 1;\nHasta Que x = 1\n")?;
    let listed: Vec<&str> = found.iter().map(|entry| entry.2.as_str()).collect();
    assert!(!listed.contains(&"Hasta"));
    assert!(!listed.contains(&"Que"));
    Ok(())
}

#[test]
fn a_supplementary_scalar_counts_as_one_column() -> Result<(), String> {
    let found = words("Escribir \"🧩\"; Leer x;\n")?;
    let read = found
        .iter()
        .find(|entry| entry.2 == "Leer")
        .ok_or("Leer missing")?;
    assert_eq!(read.1, 15);
    Ok(())
}

#[test]
fn empty_and_wordless_programs_yield_nothing() -> Result<(), String> {
    assert!(words("")?.is_empty());
    assert!(words("\n\n  \n")?.is_empty());
    Ok(())
}

#[test]
fn inert_positions_mark_strings_and_comments() -> Result<(), String> {
    let oracle = Oracle::load()?;
    let scanned = scan(&oracle, "es", "Escribir \"hola\";\n// nota\n");
    assert!(scanned.inert_positions.iter().any(|blank| blank.line == 1));
    assert!(scanned.inert_positions.iter().any(|blank| blank.line == 2));
    Ok(())
}
