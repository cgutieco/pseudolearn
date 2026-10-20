use pseudolearn_lexicon::Profile;
use pseudolearn_service::{DocumentSession, apply_changes, on_type};

fn assist(marked: &str, typed: char, profile: Profile, strict: bool) -> (String, usize) {
    let cursor = marked.find('|').unwrap_or(marked.len());
    let clean = marked.replacen('|', "", 1);
    let session = DocumentSession::new(clean.clone(), profile, strict);
    let outcome = on_type(&session, cursor, typed);
    (apply_changes(&clean, &outcome.edits), outcome.cursor)
}

fn enter(marked: &str) -> (String, usize) {
    assist(marked, '\n', Profile::Spanish, true)
}

#[test]
fn enter_closes_every_unclosed_block_kind() {
    let cases = [
        (
            "Algoritmo P\n  Si 1 = 1 Entonces\n|\nFinAlgoritmo\n",
            "FinSi",
        ),
        (
            "Algoritmo P\n  Para i <- 1 Hasta 3 Hacer\n|\nFinAlgoritmo\n",
            "FinPara",
        ),
        (
            "Algoritmo P\n  Segun 1 Hacer\n|\nFinAlgoritmo\n",
            "FinSegun",
        ),
        (
            "Algoritmo P\n  Mientras 1 = 1 Hacer\n|\nFinAlgoritmo\n",
            "FinMientras",
        ),
    ];
    for (marked, closer) in cases {
        let (text, _) = enter(marked);
        assert!(text.contains(&format!("\n  {closer}\n")), "{text}");
    }
}

#[test]
fn enter_closes_units_at_column_zero() {
    let (text, cursor) = enter("Algoritmo P\n|\n");
    assert_eq!(text, "Algoritmo P\n  \nFinAlgoritmo\n");
    assert_eq!(cursor, 14);
    let (class_text, _) = enter("Clase C\n|\n");
    assert!(class_text.ends_with("\nFinClase\n"));
}

#[test]
fn enter_indents_repeat_without_inserting_a_closer() {
    let (text, _) = enter("Algoritmo P\n  Repetir\n|\nFinAlgoritmo\n");
    assert_eq!(text, "Algoritmo P\n  Repetir\n    \nFinAlgoritmo\n");
}

#[test]
fn enter_in_english_uses_the_english_closer() {
    let (text, _) = assist(
        "Algorithm P\n  While 1 = 1 Do\n|\nEndAlgorithm\n",
        '\n',
        Profile::English,
        true,
    );
    assert!(text.contains("\n  EndWhile\n"));
}

#[test]
fn enter_does_not_close_an_already_closed_block() {
    let (text, cursor) = enter("Algoritmo P\n  Si 1 = 1 Entonces\n|\n  FinSi\nFinAlgoritmo\n");
    assert_eq!(
        text,
        "Algoritmo P\n  Si 1 = 1 Entonces\n    \n  FinSi\nFinAlgoritmo\n"
    );
    assert_eq!(cursor, 36);
}

#[test]
fn enter_with_trailing_text_only_indents() {
    let (text, _) = enter("Algoritmo P\n  Mientras 1 = 1 Hacer\n|Escribir 1;\nFinAlgoritmo\n");
    assert!(!text.contains("FinMientras"));
    assert!(text.contains("\n    Escribir 1;\n"));
}

#[test]
fn enter_keeps_the_indentation_of_plain_and_blank_lines() {
    let (plain, _) = enter("Algoritmo P\n    Escribir 1;\n|\nFinAlgoritmo\n");
    assert!(plain.contains("Escribir 1;\n    \n"));
    let (blank, _) = enter("Algoritmo P\n      \n|\nFinAlgoritmo\n");
    assert!(blank.contains("      \n      \n"));
}

#[test]
fn enter_after_else_indents_one_more_unit() {
    let code =
        "Algoritmo P\n  Si 1 = 1 Entonces\n    Escribir 1;\n  Sino\n|\n  FinSi\nFinAlgoritmo\n";
    let (text, _) = enter(code);
    assert!(text.contains("  Sino\n    \n  FinSi"));
}

#[test]
fn enter_terminates_simple_statements_only_in_strict_mode() {
    let code = "Algoritmo P\n  Escribir 1\n|\nFinAlgoritmo\n";
    let (strict, _) = enter(code);
    assert!(strict.contains("Escribir 1;\n"));
    let (flexible, _) = assist(code, '\n', Profile::Spanish, false);
    assert!(flexible.contains("Escribir 1\n"));
    assert!(!flexible.contains(';'));
}

#[test]
fn enter_never_terminates_headers_labels_or_unfinished_expressions() {
    let (header, _) = enter("Algoritmo P\n  Si 1 = 1 Entonces\n|\n  FinSi\nFinAlgoritmo\n");
    assert!(!header.contains("Entonces;"));
    let (open, _) = enter("Algoritmo P\n  x <- 1 +\n|\nFinAlgoritmo\n");
    assert!(!open.contains("+;"));
    assert!(open.contains("+\n  \n"));
}

#[test]
fn enter_without_a_preceding_newline_does_nothing() {
    let (text, cursor) = enter("Algoritmo P|\n");
    assert_eq!(text, "Algoritmo P\n");
    assert_eq!(cursor, 11);
    let (first, _) = enter("|Algoritmo P\n");
    assert_eq!(first, "Algoritmo P\n");
}

#[test]
fn boundary_realigns_closers_else_and_default_case() {
    let (closer, cursor) = assist(
        "Algoritmo P\n  Si 1 = 1 Entonces\n      FinSi |\nFinAlgoritmo\n",
        ' ',
        Profile::Spanish,
        true,
    );
    assert!(closer.contains("\n  FinSi \n"));
    assert_eq!(cursor, closer.find("FinSi ").unwrap_or(0) + 6);
    let (otherwise, _) = assist(
        "Algoritmo P\n  Si 1 = 1 Entonces\n  Escribir 1;\n      Sino |\n  FinSi\nFinAlgoritmo\n",
        ' ',
        Profile::Spanish,
        true,
    );
    assert!(otherwise.contains("\n  Sino \n"));
    let (default, _) = assist(
        "Algoritmo P\n  Segun 1 Hacer\n      De Otro Modo: |\n  FinSegun\nFinAlgoritmo\n",
        ' ',
        Profile::Spanish,
        true,
    );
    assert!(default.contains("\n    De Otro Modo:"), "{default}");
}

#[test]
fn boundary_ignores_words_that_are_not_complete_closers() {
    let code = "Algoritmo P\n  Si 1 = 1 Entonces\n      Escribir |\n  FinSi\nFinAlgoritmo\n";
    let (text, _) = assist(code, ' ', Profile::Spanish, true);
    assert_eq!(text, code.replace('|', ""));
}

#[test]
fn pairs_are_inserted_outside_comments_and_literals() {
    let (paren, cursor) = assist(
        "Algoritmo P\n  Escribir (|\nFinAlgoritmo\n",
        '(',
        Profile::Spanish,
        true,
    );
    assert!(paren.contains("Escribir ()\n"));
    assert_eq!(cursor, paren.find('(').unwrap_or(0) + 1);
    let (bracket, _) = assist(
        "Algoritmo P\n  x[|\nFinAlgoritmo\n",
        '[',
        Profile::Spanish,
        true,
    );
    assert!(bracket.contains("x[]"));
    let (quote, _) = assist(
        "Algoritmo P\n  Escribir \"|\nFinAlgoritmo\n",
        '"',
        Profile::Spanish,
        true,
    );
    assert!(quote.contains("\"\"\n"));
    let (character, _) = assist(
        "Algoritmo P\n  c <- '|\nFinAlgoritmo\n",
        '\'',
        Profile::Spanish,
        true,
    );
    assert!(character.contains("''"));
}

#[test]
fn pairs_are_skipped_in_comments_literals_and_before_identifiers() {
    let (comment, _) = assist(
        "Algoritmo P\n  // nota (|\nFinAlgoritmo\n",
        '(',
        Profile::Spanish,
        true,
    );
    assert!(!comment.contains("()"));
    let (literal, _) = assist(
        "Algoritmo P\n  Escribir \"a (|\"\nFinAlgoritmo\n",
        '(',
        Profile::Spanish,
        true,
    );
    assert!(literal.contains("\"a (\""));
    let (glued, _) = assist(
        "Algoritmo P\n  f(|x\nFinAlgoritmo\n",
        '(',
        Profile::Spanish,
        true,
    );
    assert!(glued.contains("f(x"));
}

#[test]
fn closers_overtype_the_character_that_follows_them() {
    let (paren, _) = assist(
        "Algoritmo P\n  f(1)|)\nFinAlgoritmo\n",
        ')',
        Profile::Spanish,
        true,
    );
    assert!(paren.contains("f(1)\n"));
    let (quote, _) = assist(
        "Algoritmo P\n  Escribir \"ab\"|\"\nFinAlgoritmo\n",
        '"',
        Profile::Spanish,
        true,
    );
    assert!(quote.contains("\"ab\"\n"));
    let (lonely, _) = assist(
        "Algoritmo P\n  f(1)|\nFinAlgoritmo\n",
        ')',
        Profile::Spanish,
        true,
    );
    assert!(lonely.contains("f(1)\n"));
}

#[test]
fn unrelated_characters_produce_no_edits() {
    let (text, cursor) = assist(
        "Algoritmo P\n  xa|\nFinAlgoritmo\n",
        'a',
        Profile::Spanish,
        true,
    );
    assert_eq!(text, "Algoritmo P\n  xa\nFinAlgoritmo\n");
    assert_eq!(cursor, 16);
}
