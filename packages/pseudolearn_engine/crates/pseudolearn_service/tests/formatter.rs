use pseudolearn_lexicon::Profile;
use pseudolearn_service::{FormatOptions, format_source};

#[test]
fn formats_canonical_strict_spanish() {
    let unformatted =
        "algoritmo Principal\ndefinir x como entero\nx<-1+2\nescribir x\nfinalgoritmo";
    let options = FormatOptions {
        profile: Profile::Spanish,
        strict: true,
        indent_size: 2,
    };
    let formatted = format_source(unformatted, options);
    assert_eq!(
        formatted,
        "Algoritmo Principal\n  Definir x Como Entero;\n  x <- 1 + 2;\n  Escribir x;\nFinAlgoritmo\n"
    );
}

#[test]
fn formats_flexible_spanish_without_semicolons() {
    let unformatted = "Algoritmo Flexible\n  x := 1;\n  y <- 2;\nFinAlgoritmo\n";
    let options = FormatOptions {
        profile: Profile::Spanish,
        strict: false,
        indent_size: 2,
    };
    let formatted = format_source(unformatted, options);
    assert_eq!(
        formatted,
        "Algoritmo Flexible\n  x <- 1\n  y <- 2\nFinAlgoritmo\n"
    );
}

#[test]
fn preserves_comments_and_normalizes_empty_lines() {
    let unformatted = "// cabecera\n\n\nAlgoritmo Comentarios\n// comentario interior\n\n\nx <- 1; // fin de linea\nFinAlgoritmo\n";
    let options = FormatOptions {
        profile: Profile::Spanish,
        strict: true,
        indent_size: 2,
    };
    let formatted = format_source(unformatted, options);
    assert_eq!(
        formatted,
        "// cabecera\nAlgoritmo Comentarios\n  // comentario interior\n  x <- 1;  // fin de linea\nFinAlgoritmo\n"
    );
}

#[test]
fn formats_strict_english() {
    let unformatted = "algorithm Main\ndefine x as integer;\nwrite x;\nendalgorithm";
    let options = FormatOptions {
        profile: Profile::English,
        strict: true,
        indent_size: 2,
    };
    let formatted = format_source(unformatted, options);
    assert_eq!(
        formatted,
        "Algorithm Main\n  Define x As Integer;\n  Write x;\nEndAlgorithm\n"
    );
}

#[test]
fn is_idempotent_on_formatted_source() {
    let source = "Algoritmo Idempotente\n  Definir valor Como Entero;\n  valor <- 10;\n  Escribir valor;\nFinAlgoritmo\n";
    let options = FormatOptions {
        profile: Profile::Spanish,
        strict: true,
        indent_size: 2,
    };
    let first = format_source(source, options);
    let second = format_source(&first, options);
    assert_eq!(first, second);
}
