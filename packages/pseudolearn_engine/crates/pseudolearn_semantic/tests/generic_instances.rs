mod support;

use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_semantic::HirModule;

const IDENTITY: &str = "subroutine identity<T>(value as T) as T\nreturn value;\nendSubroutine\n";
const BOX: &str = "record Box<T>\ndefine v as T;\nendRecord\n";

fn program(declarations: &str, body: &str) -> String {
    format!("{declarations}algorithm P\n{body}endAlgorithm\n")
}

fn analyze(text: &str) -> Result<HirModule, String> {
    let (module, diagnostics) = support::analyze(text, true);
    module.ok_or_else(|| format!("{diagnostics:?}"))
}

fn codes(text: &str) -> Vec<DiagnosticCode> {
    let (_, diagnostics) = support::analyze(text, true);
    diagnostics
        .iter()
        .map(|diagnostic| diagnostic.code)
        .collect()
}

fn instance_names(module: &HirModule) -> Vec<String> {
    let mut names: Vec<String> = module
        .functions
        .iter()
        .map(|function| function.name.clone())
        .filter(|name| name.contains('<'))
        .collect();
    names.sort();
    names
}

fn distinct_records(count: usize) -> String {
    (1..=count)
        .map(|index| format!("record R{index}\ndefine v as integer;\nendRecord\n"))
        .collect()
}

fn consume_calls(count: usize) -> (String, String) {
    let declarations = format!(
        "{}subroutine consume<T>(x as T)\nendSubroutine\n",
        distinct_records(count)
    );
    let body = (1..=count)
        .map(|index| format!("consume(R{index}(1));\n"))
        .collect();
    (declarations, body)
}

#[test]
fn single_instance_is_named_by_its_canonical_arguments() -> Result<(), String> {
    let module = analyze(&program(IDENTITY, "write identity(4);\n"))?;
    assert_eq!(instance_names(&module), vec!["identity<integer>"]);
    Ok(())
}

#[test]
fn repeated_calls_share_one_instance_and_new_arguments_add_one() -> Result<(), String> {
    let body = "write identity(1);\nwrite identity(2);\nwrite identity(2.5);\n";
    let module = analyze(&program(IDENTITY, body))?;
    assert_eq!(
        instance_names(&module),
        vec!["identity<integer>", "identity<real>"]
    );
    Ok(())
}

#[test]
fn discovery_order_does_not_change_the_instance_set() -> Result<(), String> {
    let forward = analyze(&program(
        IDENTITY,
        "write identity(1);\nwrite identity(2.5);\n",
    ))?;
    let backward = analyze(&program(
        IDENTITY,
        "write identity(2.5);\nwrite identity(1);\n",
    ))?;
    assert_eq!(instance_names(&forward), instance_names(&backward));
    Ok(())
}

#[test]
fn uninstantiated_generics_add_no_functions_or_records() -> Result<(), String> {
    let with_generics = analyze(&program(&format!("{IDENTITY}{BOX}"), "write 1;\n"))?;
    let without = analyze(&program("", "write 1;\n"))?;
    assert_eq!(with_generics.functions.len(), without.functions.len());
    assert_eq!(instance_names(&with_generics), Vec::<String>::new());
    Ok(())
}

#[test]
fn record_instances_are_canonical_per_argument_list() -> Result<(), String> {
    let body = "define a as Box<integer> <- Box(1);\ndefine b as Box<integer> <- Box(2);\ndefine c as Box<real> <- Box(2.5);\n";
    let module = analyze(&program(BOX, body))?;
    let names: Vec<_> = module
        .records
        .iter()
        .map(|record| record.name.clone())
        .filter(|name| name.contains('<') && name != "T")
        .collect();
    assert!(names.contains(&"Box<integer>".to_owned()));
    assert!(names.contains(&"Box<real>".to_owned()));
    assert_eq!(
        names.iter().filter(|name| *name == "Box<integer>").count(),
        1
    );
    Ok(())
}

#[test]
fn limit_is_inclusive_at_sixty_four_instances() -> Result<(), String> {
    let (declarations, body) = consume_calls(64);
    let module = analyze(&program(&declarations, &body))?;
    assert_eq!(instance_names(&module).len(), 64);
    Ok(())
}

#[test]
fn sixty_fifth_instance_reports_the_limit_once() {
    let (declarations, body) = consume_calls(65);
    assert_eq!(
        codes(&program(&declarations, &body)),
        vec![DiagnosticCode::GenericInstanceLimitExceeded]
    );
}

#[test]
fn expansive_polymorphic_recursion_exhausts_the_limit() {
    let declarations =
        format!("{BOX}subroutine grow<T>(value as T)\ngrow(Box(value));\nendSubroutine\n");
    assert_eq!(
        codes(&program(&declarations, "grow(1);\n")),
        vec![DiagnosticCode::GenericInstanceLimitExceeded]
    );
}

#[test]
fn same_argument_recursion_reuses_its_instance() -> Result<(), String> {
    let declarations = "subroutine count<T>(x as T, n as integer)\nif n > 0 then\ncount(x, n - 1);\nendIf\nendSubroutine\n";
    let module = analyze(&program(declarations, "count(\"ab\", 3);\n"))?;
    assert_eq!(instance_names(&module), vec!["count<string>"]);
    Ok(())
}

#[test]
fn conflicting_and_missing_inference_are_reported() {
    let pair = "subroutine pick<T>(a as T, b as T) as T\nreturn a;\nendSubroutine\n";
    assert_eq!(
        codes(&program(pair, "write pick(1, 2.5);\n")),
        vec![DiagnosticCode::CannotInferTypeArgument]
    );
    let unused = "subroutine mark<T>(n as integer)\nendSubroutine\n";
    assert_eq!(
        codes(&program(unused, "mark(1);\n")),
        vec![DiagnosticCode::CannotInferTypeArgument]
    );
}

#[test]
fn type_argument_counts_must_match_the_parameters() {
    for body in [
        "define c as Box<integer, real> <- Box(1);\n",
        "define c as Box <- Box(1);\n",
    ] {
        assert_eq!(
            codes(&program(BOX, body)),
            vec![DiagnosticCode::TypeArgumentCountMismatch]
        );
    }
}

#[test]
fn definitions_are_checked_once_even_without_instances() {
    let declarations = "subroutine add<T>(a as T, b as T) as T\nreturn a + b;\nendSubroutine\n";
    assert_eq!(
        codes(&program(declarations, "write 1;\n")),
        vec![DiagnosticCode::IncompatibleOperandTypes]
    );
}

#[test]
fn recursive_generic_record_is_rejected_on_definition() {
    let declarations = "record Node<T>\ndefine next as Node<T>;\nendRecord\n";
    assert_eq!(
        codes(&program(declarations, "write 1;\n")),
        vec![DiagnosticCode::RecursiveRecordContainment]
    );
}

#[test]
fn zero_and_one_character_names_are_valid_parameters() -> Result<(), String> {
    let declarations = "subroutine id<T>(x as T) as T\nreturn x;\nendSubroutine\n";
    let module = analyze(&program(declarations, "write id(1);\n"))?;
    assert_eq!(instance_names(&module), vec!["id<integer>"]);
    Ok(())
}
