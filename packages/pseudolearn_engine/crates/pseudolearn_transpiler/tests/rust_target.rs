mod support;

use pseudolearn_transpiler::{TargetLanguage, TranspileOutcome};
use support::{HIERARCHY, NETWORK, TASKS, code, translate};

#[test]
fn empty_algorithm_becomes_an_empty_main() -> Result<(), String> {
    let text = code("Algoritmo P\nFinAlgoritmo\n", TargetLanguage::Rust)?;
    assert_eq!(text, "fn main() {\n}\n");
    Ok(())
}

#[test]
fn tasks_and_channels_use_the_cooperative_executor() -> Result<(), String> {
    let text = code(TASKS, TargetLanguage::Rust)?;
    assert!(text.contains("async fn produce(stream: Channel<i64>) {"));
    assert!(text.contains("task_scope.spawn(produce(stream.clone()));"));
    assert!(text.contains("Some(received) => {"));
    assert!(text.contains("fn run_tasks(algorithm: impl Future<Output = ()> + 'static) {"));
    Ok(())
}

#[test]
fn class_hierarchies_dispatch_through_kind_traits() -> Result<(), String> {
    let text = code(HIERARCHY, TargetLanguage::Rust)?;
    assert!(text.contains("trait PerroKind: AnimalKind {"));
    assert!(text.contains("fn perro_hablar<T: PerroKind + ?Sized>(this: &mut T) -> String {"));
    assert!(text.contains("format!(\"{} y ladra\", animal_hablar(this))"));
    assert!(text.contains("let a: Rc<RefCell<dyn AnimalKind>> = Perro::new("));
    Ok(())
}

#[test]
fn extreme_integer_literals_keep_their_type() -> Result<(), String> {
    let program =
        "Algoritmo P\nEscribir 9223372036854775807;\nEscribir 3000000000 + 1;\nFinAlgoritmo\n";
    let text = code(program, TargetLanguage::Rust)?;
    assert!(text.contains("println!(\"9223372036854775807\");"));
    assert!(text.contains("3000000000_i64 + 1"));
    Ok(())
}

#[test]
fn reserved_names_of_the_target_are_renamed() -> Result<(), String> {
    let program = "Algoritmo P\nDefinir loop Como Entero <- 1;\nEscribir loop;\nFinAlgoritmo\n";
    let text = code(program, TargetLanguage::Rust)?;
    assert!(text.contains("let loop_value: i64 = 1;"));
    assert!(!text.contains("let mut"));
    Ok(())
}

#[test]
fn constructs_without_equivalent_are_named_with_their_span() -> Result<(), String> {
    match translate(NETWORK, TargetLanguage::Rust)? {
        TranspileOutcome::Unavailable(blockers) => {
            assert!(
                blockers
                    .iter()
                    .all(|blocker| blocker.construct == "capability")
            );
            assert!(
                blockers
                    .iter()
                    .all(|blocker| blocker.span.start < blocker.span.ending)
            );
            Ok(())
        }
        TranspileOutcome::Code(_) => Err("network translated without an equivalent".to_owned()),
    }
}

#[test]
fn failing_tasks_report_through_the_scope() -> Result<(), String> {
    let text = code(support::FAILING_SCOPE, TargetLanguage::Rust)?;
    assert!(text.contains("let task_scope = TaskScope::<String>::new();"));
    assert!(text.contains("task_scope.spawn_fallible(work());"));
    assert!(text.contains("task_scope.report().map("));
    Ok(())
}

#[test]
fn selection_waits_on_every_channel() -> Result<(), String> {
    let text = code(support::SELECTION, TargetLanguage::Rust)?;
    assert!(text.contains("select_receive(&[stream.clone(), other.clone()]).await;"));
    assert!(text.contains("match selected {"));
    Ok(())
}
