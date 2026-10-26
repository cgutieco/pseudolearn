use pseudolearn_lexicon::Profile;
use pseudolearn_service::{FormatOptions, format_checked, format_source};

#[test]
fn formats_canonical_strict_spanish() {
    let unformatted =
        "algoritmo Principal\ndefinir mutable x como entero<-0\nx<-1+2\nescribir x\nfinalgoritmo";
    let options = FormatOptions {
        profile: Profile::Spanish,
        strict: true,
        indent_size: 2,
    };
    let formatted = format_source(unformatted, options);
    assert_eq!(
        formatted,
        "Algoritmo Principal\n  Definir Mutable x Como Entero <- 0;\n  x <- 1 + 2;\n  Escribir x;\nFinAlgoritmo\n"
    );
}

#[test]
fn formats_flexible_spanish_without_semicolons() {
    let unformatted = "Algoritmo Flexible\n  x := 1;\n  w <- 2;\nFinAlgoritmo\n";
    let options = FormatOptions {
        profile: Profile::Spanish,
        strict: false,
        indent_size: 2,
    };
    let formatted = format_source(unformatted, options);
    assert_eq!(
        formatted,
        "Algoritmo Flexible\n  x <- 1\n  w <- 2\nFinAlgoritmo\n"
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
    let unformatted = "algorithm Main\ndefine x as integer <- 0;\nwrite x;\nendalgorithm";
    let options = FormatOptions {
        profile: Profile::English,
        strict: true,
        indent_size: 2,
    };
    let formatted = format_source(unformatted, options);
    assert_eq!(
        formatted,
        "Algorithm Main\n  Define x As Integer <- 0;\n  Write x;\nEndAlgorithm\n"
    );
}

#[test]
fn is_idempotent_on_formatted_source() {
    let source = "Algoritmo Idempotente\n  Definir Mutable valor Como Entero <- 0;\n  valor <- 10;\n  Escribir valor;\nFinAlgoritmo\n";
    let options = FormatOptions {
        profile: Profile::Spanish,
        strict: true,
        indent_size: 2,
    };
    let first = format_source(source, options);
    let second = format_source(&first, options);
    assert_eq!(first, second);
}

fn spanish(strict: bool) -> FormatOptions {
    FormatOptions {
        profile: Profile::Spanish,
        strict,
        indent_size: 2,
    }
}

fn english(strict: bool) -> FormatOptions {
    FormatOptions {
        profile: Profile::English,
        strict,
        indent_size: 2,
    }
}

#[test]
fn indents_conditionals_loops_and_switch_cases() {
    let source = "Algoritmo Estructuras
Definir Mutable n Como Entero<-0
n<-3
Si n>2 Entonces
Escribir n
Sino
Escribir 0
FinSi
Mientras n>0 Hacer
n<-n-1
FinMientras
Segun n Hacer
1: Escribir 1
De Otro Modo:
Escribir 2
FinSegun
FinAlgoritmo
";
    let expected = "Algoritmo Estructuras\n  Definir Mutable n Como Entero <- 0;\n  n <- 3;\n  Si n > 2 Entonces\n    Escribir n;\n  Sino\n    Escribir 0;\n  FinSi\n  Mientras n > 0 Hacer\n    n <- n - 1;\n  FinMientras\n  Segun n Hacer\n    1: Escribir 1\n    De Otro Modo:\n      Escribir 2;\n  FinSegun\nFinAlgoritmo\n";
    assert_eq!(format_source(source, spanish(true)), expected);
}

#[test]
fn separates_top_level_units_with_one_blank_line() {
    let source = "SubProceso Uno()\nFinSubProceso\n\n\n\nAlgoritmo Dos\nFinAlgoritmo\n";
    assert_eq!(
        format_source(source, spanish(true)),
        "SubProceso Uno()\nFinSubProceso\n\nAlgoritmo Dos\nFinAlgoritmo\n"
    );
    let glued = "SubProceso Uno()\nFinSubProceso\nAlgoritmo Dos\nFinAlgoritmo\n";
    assert_eq!(
        format_source(glued, spanish(true)),
        "SubProceso Uno()\nFinSubProceso\n\nAlgoritmo Dos\nFinAlgoritmo\n"
    );
}

#[test]
fn spaces_unary_minus_calls_and_indexing_consistently() {
    let source = "Algoritmo Operadores\nDefinir Mutable a Como Entero<-0\na<- -3 +  2*( 4-1 )\nEscribir  Longitud ( \"hola\" ) ,a\nFinAlgoritmo\n";
    assert_eq!(
        format_source(source, spanish(true)),
        "Algoritmo Operadores\n  Definir Mutable a Como Entero <- 0;\n  a <- -3 + 2 * (4 - 1);\n  Escribir Longitud(\"hola\"), a;\nFinAlgoritmo\n"
    );
}

#[test]
fn keeps_block_comments_and_multiline_block_comment_bodies() {
    let source = "/* cabecera\n   larga */\nAlgoritmo A\n/* nota */ Escribir 1\nFinAlgoritmo\n";
    assert_eq!(
        format_source(source, spanish(true)),
        "/* cabecera\n   larga */\nAlgoritmo A\n  /* nota */ Escribir 1;\nFinAlgoritmo\n"
    );
}

#[test]
fn canonicalizes_unshadowed_builtins_but_keeps_shadowed_names() {
    let source = "Algoritmo A\nDefinir Mutable r Como Real<-0.0\nr <- RAIZ(4.0)\nFinAlgoritmo\n";
    assert_eq!(
        format_source(source, spanish(true)),
        "Algoritmo A\n  Definir Mutable r Como Real <- 0.0;\n  r <- rc(4.0);\nFinAlgoritmo\n"
    );
    let shadowed = "Algoritmo A\nDefinir Mutable rc Como Real<-0.0\nrc <- 1.0\nFinAlgoritmo\n";
    assert_eq!(
        format_source(shadowed, spanish(true)),
        "Algoritmo A\n  Definir Mutable rc Como Real <- 0.0;\n  rc <- 1.0;\nFinAlgoritmo\n"
    );
}

#[test]
fn formats_classes_with_members() {
    let source = "Clase Punto\nDefinir x Como Entero\nMetodo Mover()\nx<-x+1\nFinMetodo\nFinClase\nAlgoritmo A\nFinAlgoritmo\n";
    assert_eq!(
        format_source(source, spanish(true)),
        "Clase Punto\n  Definir x Como Entero;\n  Metodo Mover()\n    x <- x + 1;\n  FinMetodo\nFinClase\n\nAlgoritmo A\nFinAlgoritmo\n"
    );
}

#[test]
fn returns_the_original_text_when_syntax_errors_exist() {
    let broken = "Algoritmo A\n  Si x >\nFinAlgoritmo\n";
    assert_eq!(format_checked(broken, spanish(true)), None);
    assert_eq!(format_source(broken, spanish(true)), broken);
}

#[test]
fn handles_empty_and_whitespace_only_input() {
    assert_eq!(format_source("", spanish(true)), "");
    assert_eq!(format_source("   \n\n  \n", spanish(true)), "");
}

#[test]
fn normalizes_crlf_and_trailing_blank_lines() {
    let source = "Algoritmo A\r\n  Escribir 1;\r\nFinAlgoritmo\r\n\r\n\r\n";
    assert_eq!(
        format_source(source, spanish(true)),
        "Algoritmo A\n  Escribir 1;\nFinAlgoritmo\n"
    );
}

#[test]
fn removes_trailing_semicolons_only_in_flexible_mode() {
    let source = "Algoritmo A\n  Escribir 1;\nFinAlgoritmo\n";
    assert_eq!(
        format_source(source, spanish(false)),
        "Algoritmo A\n  Escribir 1\nFinAlgoritmo\n"
    );
    assert_eq!(format_source(source, spanish(true)), source);
}

#[test]
fn formats_english_control_flow() {
    let source = "algorithm A\nif 1<2 then\nprint 1\nelse\nwrite 2\nendif\nendalgorithm\n";
    assert_eq!(
        format_source(source, english(true)),
        "Algorithm A\n  If 1 < 2 Then\n    Write 1;\n  Else\n    Write 2;\n  EndIf\nEndAlgorithm\n"
    );
}
