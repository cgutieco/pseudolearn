use pseudolearn_api::{ExecuteRequest, execute_program};

#[cfg(feature = "native")]
#[path = "native_access/support.rs"]
mod native_support;

const CLASSES: &str = "class Base\n  public method Value() as integer\n    return 1;\n  endMethod\nendClass\nclass Derived inherits from Base\n  public method Value() as integer\n    return 2;\n  endMethod\nendClass\nclass Sibling inherits from Base\n  public method Value() as integer\n    return 3;\n  endMethod\nendClass\nclass Other\nendClass\n";

fn run(body: &str, observe: &str) -> pseudolearn_api::ExecuteResponse {
    run_with(body, observe, Vec::new())
}

fn run_with(body: &str, observe: &str, inputs: Vec<String>) -> pseudolearn_api::ExecuteResponse {
    let request = ExecuteRequest {
        inputs,
        program: format!("{CLASSES}algorithm P\n{body}endAlgorithm\n"),
        profile: "en".to_owned(),
        observe: observe.to_owned(),
        gc_stress: true,
        ..Default::default()
    };
    execute_program(&request)
}

#[test]
fn a_base_typed_variable_accepts_a_derived_instance_in_both_twins() {
    let body = "define mutable item as Base <- new Base();\nwrite item.Value();\nitem <- new Derived();\nwrite item.Value();\n";
    for observe in ["none", "events"] {
        let response = run(body, observe);
        assert_eq!(
            response.output, "1\n2\n",
            "{observe}: {:?}",
            response.diagnostics
        );
    }
}

#[test]
fn a_base_typed_variable_accepts_a_copy_of_a_derived_instance() {
    let body = "define source as Derived <- new Derived();\ndefine mutable item as Base <- new Base();\nitem <- copy(source);\nwrite item.Value();\n";
    let response = run(body, "none");
    assert_eq!(response.output, "2\n", "{:?}", response.diagnostics);
}

#[test]
fn an_unrelated_class_is_still_rejected_before_execution() {
    let body =
        "define mutable item as Base <- new Base();\nitem <- new Other();\nwrite item.Value();\n";
    let response = run(body, "none");
    assert_eq!(response.output, "");
    assert!(
        response
            .diagnostics
            .iter()
            .any(|diagnostic| diagnostic.code == "incompatibleTypesInAssignment"),
        "{:?}",
        response.diagnostics
    );
}

#[test]
fn a_base_instance_cannot_be_stored_where_a_derived_one_is_declared() {
    let body = "define mutable item as Derived <- new Derived();\nitem <- new Base();\nwrite item.Value();\n";
    let response = run(body, "none");
    assert!(
        response
            .diagnostics
            .iter()
            .any(|diagnostic| diagnostic.code == "incompatibleTypesInAssignment"),
        "{:?}",
        response.diagnostics
    );
}

#[test]
fn sibling_classes_join_at_their_common_base_after_a_branch() {
    let body = "define mutable flag as integer <- 0;\nread flag;\ndefine mutable item as Base <- new Derived();\nif flag = 1 then\nitem <- new Sibling();\nendIf\nwrite item.Value();\n";
    for (input, expected) in [("1", "3\n"), ("0", "2\n")] {
        let response = run_with(body, "none", vec![input.to_owned()]);
        assert_eq!(
            response.output, expected,
            "{input}: {:?}",
            response.diagnostics
        );
    }
}

#[cfg(feature = "native")]
#[test]
fn native_code_matches_the_vm_for_polymorphic_reassignment() -> Result<(), String> {
    let program = "Clase Base\n  Publico Metodo Valor() Como Entero\n    Retornar 1;\n  FinMetodo\nFinClase\nClase Derivada Hereda De Base\n  Publico Metodo Valor() Como Entero\n    Retornar 2;\n  FinMetodo\nFinClase\nClase Hermana Hereda De Base\n  Publico Metodo Valor() Como Entero\n    Retornar 3;\n  FinMetodo\nFinClase\nAlgoritmo P\n  Definir Mutable item Como Base <- Nuevo Derivada();\n  Escribir item.Valor();\n  Si 1 = 1 Entonces\n    item <- Nuevo Hermana();\n  FinSi\n  Escribir item.Valor();\nFinAlgoritmo\n";
    native_support::compare(program)
}
