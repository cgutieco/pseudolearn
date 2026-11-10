#[path = "support/translation.rs"]
mod support;

use pseudolearn_transpiler::TargetLanguage;
use support::code;

fn declare(names: &[&str]) -> String {
    let mut program = String::from("Algoritmo P\n");
    for name in names {
        program.push_str(&format!("Definir {name} Como Entero <- 1;\n"));
    }
    for name in names {
        program.push_str(&format!("Escribir {name};\n"));
    }
    program.push_str("FinAlgoritmo\n");
    program
}

#[test]
fn python_builtins_used_by_the_emitter_are_renamed() -> Result<(), String> {
    let names = [
        "range",
        "map",
        "iter",
        "filter",
        "enumerate",
        "zip",
        "abs",
        "min",
        "max",
        "any",
        "isinstance",
        "chr",
        "ord",
        "repr",
        "format",
    ];
    let text = code(&declare(&names), TargetLanguage::Python)?;
    for name in names {
        assert!(text.contains(&format!("{name}_value = 1")), "{name}");
    }
    Ok(())
}

#[test]
fn ordinary_python_names_stay_unchanged() -> Result<(), String> {
    let text = code(&declare(&["total"]), TargetLanguage::Python)?;
    assert!(text.contains("    total = 1\n"));
    Ok(())
}

#[test]
fn self_is_renamed_in_rust() -> Result<(), String> {
    let text = code(&declare(&["self"]), TargetLanguage::Rust)?;
    assert!(text.contains("let self_value: i64 = 1;"));
    Ok(())
}

#[test]
fn distinct_names_with_the_same_spelling_stay_distinct() -> Result<(), String> {
    let names = ["fooBar", "foo_bar", "FOO_BAR"];
    let python = code(&declare(&names), TargetLanguage::Python)?;
    assert!(python.contains("    foo_bar = 1\n"));
    assert!(python.contains("    foo_bar_2 = 1\n"));
    assert!(python.contains("    foo_bar_3 = 1\n"));
    let rust = code(&declare(&names), TargetLanguage::Rust)?;
    assert!(rust.contains("let foo_bar: i64 = 1;"));
    assert!(rust.contains("let foo_bar_2: i64 = 1;"));
    assert!(rust.contains("let foo_bar_3: i64 = 1;"));
    Ok(())
}

#[test]
fn suffixed_spelling_skips_names_already_taken() -> Result<(), String> {
    let text = code(
        &declare(&["fooBar", "foo_bar", "foo_bar_2"]),
        TargetLanguage::Python,
    )?;
    assert!(text.contains("    foo_bar_2 = 1\n"));
    assert!(text.contains("    foo_bar_2_2 = 1\n"));
    Ok(())
}

#[test]
fn single_character_and_underscore_names_translate() -> Result<(), String> {
    let text = code(&declare(&["x", "_"]), TargetLanguage::Python)?;
    assert!(text.contains("    x = 1\n"));
    assert!(text.contains("    value = 1\n"));
    Ok(())
}

#[test]
fn underscore_does_not_collide_with_a_real_value_name() -> Result<(), String> {
    let text = code(&declare(&["value", "_"]), TargetLanguage::Python)?;
    assert!(text.contains("    value = 1\n"));
    assert!(text.contains("    value_2 = 1\n"));
    Ok(())
}

#[test]
fn classes_named_like_prelude_imports_are_renamed() -> Result<(), String> {
    let program = "Clase Poll\nDefinir n Como Entero;\nFinClase\nClase Enum\nDefinir n Como Entero;\nFinClase\nAlgoritmo P\nDefinir a Como Poll <- Nuevo Poll();\nDefinir b Como Enum <- Nuevo Enum();\nFinAlgoritmo\n";
    let rust = code(program, TargetLanguage::Rust)?;
    assert!(rust.contains("PollType"));
    assert!(!rust.contains("struct Poll "));
    let python = code(program, TargetLanguage::Python)?;
    assert!(python.contains("class EnumType"));
    assert!(!python.contains("class Enum:"));
    Ok(())
}

#[test]
fn enum_members_with_the_same_spelling_stay_distinct() -> Result<(), String> {
    let program = "Enumerado Modo\nfooBar, foo_bar\nFinEnumerado\nAlgoritmo P\nDefinir m Como Modo <- Modo.foo_bar;\nEscribir m;\nFinAlgoritmo\n";
    let python = code(program, TargetLanguage::Python)?;
    assert!(python.contains("FooBar = \"fooBar\""));
    assert!(python.contains("FooBar_2 = \"foo_bar\""));
    let rust = code(program, TargetLanguage::Rust)?;
    assert!(rust.contains("FooBar_2,"));
    Ok(())
}
