mod support;

use pseudolearn_transpiler::{TargetLanguage, TranspileOutcome};
use support::{HIERARCHY, NETWORK, TASKS, code, translate};

#[test]
fn empty_algorithm_becomes_an_empty_main() -> Result<(), String> {
    let text = code("Algoritmo P\nFinAlgoritmo\n", TargetLanguage::Python)?;
    assert_eq!(text, "def main():\n    pass\n\nmain()\n");
    Ok(())
}

#[test]
fn tasks_and_channels_use_asyncio() -> Result<(), String> {
    let text = code(TASKS, TargetLanguage::Python)?;
    assert!(text.contains("async def produce(stream):"));
    assert!(text.contains("task_scope.spawn(produce(stream))"));
    assert!(text.contains("case Some(received):"));
    assert!(text.contains("asyncio.run(main())"));
    Ok(())
}

#[test]
fn class_hierarchies_use_python_inheritance() -> Result<(), String> {
    let text = code(HIERARCHY, TargetLanguage::Python)?;
    assert!(text.contains("class Perro(Animal):"));
    assert!(text.contains("super().__init__(n)"));
    assert!(text.contains("return super().hablar() + \" y ladra\""));
    Ok(())
}

#[test]
fn by_reference_parameters_are_returned_to_the_caller() -> Result<(), String> {
    let program = "SubProceso Doblar(n Como Entero Por Referencia)\nn <- n * 2;\nFinSubProceso\nAlgoritmo P\nDefinir x Como Entero <- 3;\nDoblar(x);\nEscribir x;\nFinAlgoritmo\n";
    let text = code(program, TargetLanguage::Python)?;
    assert!(text.contains("    return n\n"));
    assert!(text.contains("    x = doblar(x)\n"));
    Ok(())
}

#[test]
fn integer_division_truncates_like_the_engine() -> Result<(), String> {
    let program = "Algoritmo P\nEscribir -7 div 2, -7 mod 2;\nFinAlgoritmo\n";
    let text = code(program, TargetLanguage::Python)?;
    assert!(text.contains("int_divide(-7, 2)"));
    assert!(text.contains("int_modulo(-7, 2)"));
    Ok(())
}

#[test]
fn constructs_without_equivalent_are_named() -> Result<(), String> {
    match translate(NETWORK, TargetLanguage::Python)? {
        TranspileOutcome::Unavailable(blockers) => {
            assert!(!blockers.is_empty());
            Ok(())
        }
        TranspileOutcome::Code(_) => Err("network translated without an equivalent".to_owned()),
    }
}

#[test]
fn failing_tasks_report_through_the_scope() -> Result<(), String> {
    let text = code(support::FAILING_SCOPE, TargetLanguage::Python)?;
    assert!(text.contains("task_scope.spawn_fallible(work())"));
    assert!(text.contains("except asyncio.CancelledError:"));
    assert!(text.contains("failure_report = task_scope.report("));
    Ok(())
}

#[test]
fn selection_waits_on_every_channel() -> Result<(), String> {
    let text = code(support::SELECTION, TargetLanguage::Python)?;
    assert!(text.contains("selected, selected_value = await select_receive([stream, other])"));
    Ok(())
}

#[test]
fn nul_is_written_as_a_hex_escape_so_digits_stay_literal() -> Result<(), String> {
    let program = "Algoritmo P\nEscribir \"\u{0}1\";\nFinAlgoritmo\n";
    let text = code(program, TargetLanguage::Python)?;
    assert!(text.contains("\"\\x001\""));
    Ok(())
}

#[test]
fn bidirectional_and_separator_characters_are_escaped() -> Result<(), String> {
    let program = "Algoritmo P\nEscribir \"a\u{202E}b\u{2028}c\u{FEFF}\u{E0001}\";\nFinAlgoritmo\n";
    let text = code(program, TargetLanguage::Python)?;
    assert!(text.contains("\"a\\u202eb\\u2028c\\ufeff\\U000e0001\""));
    Ok(())
}

#[test]
fn printable_text_is_kept_verbatim() -> Result<(), String> {
    let program = "Algoritmo P\nEscribir \"ñ café\";\nFinAlgoritmo\n";
    let text = code(program, TargetLanguage::Python)?;
    assert!(text.contains("\"ñ café\""));
    Ok(())
}

#[test]
fn boolean_text_literals_use_python_escapes() -> Result<(), String> {
    let program = "Algoritmo P\nEscribir 1 = 1;\nFinAlgoritmo\n";
    let text = code(program, TargetLanguage::Python)?;
    assert!(text.contains("return \"Verdadero\" if value else \"Falso\""));
    Ok(())
}
