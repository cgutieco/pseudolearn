mod support;

use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_semantic::HirModule;

const BOX: &str = "class Box<T>\ndefine content as T;\nmethod constructor(initial as T)\nthis.content <- initial;\nendMethod\nmethod current() as T\nreturn this.content;\nendMethod\nendClass\n";

fn program(declarations: &str, body: &str) -> String {
    format!("{declarations}algorithm P\n{body}endAlgorithm\n")
}

fn analyze(text: &str) -> Result<HirModule, String> {
    let (module, diagnostics) = support::analyze(text);
    module.ok_or_else(|| format!("{diagnostics:?}"))
}

fn codes(text: &str) -> Vec<DiagnosticCode> {
    let (_, diagnostics) = support::analyze(text);
    diagnostics
        .iter()
        .map(|diagnostic| diagnostic.code)
        .collect()
}

fn class_names(module: &HirModule) -> Vec<String> {
    let mut names: Vec<String> = module
        .classes
        .iter()
        .map(|class| class.name.clone())
        .collect();
    names.sort();
    names
}

#[test]
fn each_argument_combination_is_one_concrete_class() -> Result<(), String> {
    let module = analyze(&program(
        BOX,
        "define a as Box<integer> <- new Box<integer>(1);\ndefine b as Box<string> <- new Box<string>(\"xy\");\ndefine c as Box<integer> <- new Box(2);\nwrite a.current(), b.current(), c.current();\n",
    ))?;
    assert_eq!(class_names(&module), vec!["Box<integer>", "Box<string>"]);
    let owners = module
        .functions
        .iter()
        .filter(|function| function.owner.is_some())
        .count();
    assert_eq!(owners, 4);
    Ok(())
}

#[test]
fn an_unused_template_produces_no_class() -> Result<(), String> {
    let module = analyze(&program(BOX, "write 1;\n"))?;
    assert!(module.classes.is_empty());
    Ok(())
}

#[test]
fn a_base_instance_gives_its_slots_to_concrete_and_generic_subclasses() -> Result<(), String> {
    let declarations = "class Base<T>\nmethod name() as string\nreturn \"base\";\nendMethod\nendClass\nclass Child<T> inherits from Base<T>\nmethod name() as string\nreturn \"child\";\nendMethod\nendClass\nclass Fixed inherits from Base<integer>\nendClass\n";
    let module = analyze(&program(
        declarations,
        "define x as Base<integer> <- new Child<integer>();\ndefine y as Base<integer> <- new Fixed();\nwrite x.name(), y.name();\n",
    ))?;
    let base = module
        .classes
        .iter()
        .position(|class| class.name == "Base<integer>")
        .ok_or("missing base instance")?;
    for name in ["Child<integer>", "Fixed"] {
        let class = module
            .classes
            .iter()
            .find(|class| class.name == name)
            .ok_or(name)?;
        assert_eq!(
            class.superclass.map(|parent| parent.0),
            u32::try_from(base).ok()
        );
        assert_eq!(class.virtual_slots.len(), 1);
    }
    Ok(())
}

#[test]
fn instances_with_different_arguments_are_not_assignable() {
    assert_eq!(
        codes(&program(
            BOX,
            "define a as Box<integer> <- new Box<string>(\"xy\");\nwrite a.current();\n"
        )),
        vec![DiagnosticCode::IncompatibleTypesInAssignment]
    );
}

#[test]
fn missing_or_extra_type_arguments_are_counted() {
    assert_eq!(
        codes(&program(BOX, "write new Box(1).current();\n")),
        vec![DiagnosticCode::TypeArgumentCountMismatch]
    );
    assert_eq!(
        codes(&program(
            BOX,
            "define a as Box<integer, string> <- new Box<integer>(1);\n"
        )),
        vec![DiagnosticCode::TypeArgumentCountMismatch]
    );
    assert_eq!(
        codes(&program(
            "class Plain\nendClass\n",
            "define a as Plain <- new Plain<integer>();\n"
        )),
        vec![DiagnosticCode::TypeArgumentCountMismatch]
    );
}

#[test]
fn an_opaque_operation_fails_in_the_definition_without_instances() {
    assert_eq!(
        codes(&program(
            "class Sum<T>\ndefine a as T;\nmethod twice() as T\nreturn this.a + this.a;\nendMethod\nendClass\n",
            "write 1;\n"
        )),
        vec![DiagnosticCode::IncompatibleOperandTypes]
    );
}

#[test]
fn a_template_cycle_is_reported_once() {
    assert_eq!(
        codes(&program(
            "class A<T> inherits from B<T>\nendClass\nclass B<T> inherits from A<T>\nendClass\n",
            "define x as A<integer> <- new A<integer>();\n"
        )),
        vec![DiagnosticCode::CircularInheritance]
    );
}

#[test]
fn expansive_recursion_stops_at_the_instance_limit() {
    assert_eq!(
        codes(&program(
            "class Node<T>\nmethod grow(n as Node<Node<T>>)\nendMethod\nendClass\n",
            "define r as Node<integer> <- new Node<integer>();\n"
        )),
        vec![DiagnosticCode::GenericInstanceLimitExceeded]
    );
}

#[test]
fn a_generic_interface_is_realized_and_required_with_its_arguments() -> Result<(), String> {
    let declarations = "interface Measure<T>\nmethod measure() as T;\nendInterface\nclass Fixed<T> implements Measure<T>\ndefine datum as T;\nmethod constructor(initial as T)\nthis.datum <- initial;\nendMethod\nmethod measure() as T\nreturn this.datum;\nendMethod\nendClass\nsubroutine sample<M: Measure<string>>(m as M) as string\nreturn m.measure();\nendSubroutine\n";
    let module = analyze(&program(
        declarations,
        "write sample(new Fixed<string>(\"ok\"));\n",
    ))?;
    let names: Vec<&str> = module
        .interfaces
        .iter()
        .map(|interface| interface.name.as_str())
        .collect();
    assert!(names.contains(&"Measure<string>"), "{names:?}");
    assert_eq!(
        codes(&program(
            declarations,
            "write sample(new Fixed<integer>(4));\n"
        )),
        vec![DiagnosticCode::GenericConstraintNotSatisfied]
    );
    Ok(())
}

#[test]
fn a_constraint_may_name_its_own_parameter() -> Result<(), String> {
    let declarations = "interface Comparable<T>\nmethod compare(other as T) as integer;\nendInterface\nclass Number implements Comparable<Number>\ndefine v as integer;\nmethod compare(other as Number) as integer\nreturn this.v - other.v;\nendMethod\nendClass\nsubroutine larger<T: Comparable<T>>(a as T, b as T) as T\nif a.compare(b) > 0 then\nreturn a;\nendIf\nreturn b;\nendSubroutine\n";
    analyze(&program(
        declarations,
        "define n as Number <- larger(new Number(), new Number());\nwrite n.v;\n",
    ))?;
    assert_eq!(
        codes(&program(declarations, "write larger(1, 2);\n")),
        vec![DiagnosticCode::GenericConstraintNotSatisfied]
    );
    Ok(())
}
