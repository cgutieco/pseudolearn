mod support;

use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_semantic::HirModule;
use pseudolearn_semantic::variant_model::VariantFamily;

const SHAPE: &str = "variant Shape\ncase Circle(radius as integer)\ncase Rectangle(width as integer, height as integer)\ncase Dot\nendVariant\n";
const TREE: &str = "variant Tree<T>\ncase Leaf(content as T)\ncase Empty\nendVariant\n";

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

fn messages(text: &str) -> Vec<String> {
    let (_, diagnostics) = support::analyze(text);
    diagnostics
        .iter()
        .filter_map(|diagnostic| match diagnostic.arguments.get("lexeme") {
            Some(pseudolearn_diagnostics::DiagnosticArgument::Lexeme(lexeme)) => {
                Some(lexeme.clone())
            }
            _ => None,
        })
        .collect()
}

#[test]
fn a_declared_variant_shares_the_builtin_layout_with_a_payload_per_case() -> Result<(), String> {
    let module = analyze(&program(
        SHAPE,
        "define s as Shape <- Shape.Rectangle(2, 3);\nswitch s do\nShape.Circle(r): write r;\nShape.Rectangle(w, h): write w * h;\nShape.Dot: write 0;\nendSwitch\n",
    ))?;
    let (record, model) = module
        .user_variants
        .iter()
        .next()
        .ok_or("missing variant")?;
    assert_eq!(model.alternatives.len(), 3);
    assert!(
        model
            .alternatives
            .get(2)
            .is_some_and(|dot| dot.payload.is_none())
    );
    let variant = module.variants.get(record).ok_or("missing layout")?;
    assert_eq!(variant.family, VariantFamily::User);
    assert_eq!(variant.offsets.get(1).map(Vec::len), Some(2));
    Ok(())
}

#[test]
fn missing_cases_are_listed_in_declaration_order() {
    let text = program(
        SHAPE,
        "define s as Shape <- Shape.Dot;\nswitch s do\nShape.Circle(r): write r;\nendSwitch\n",
    );
    assert_eq!(codes(&text), vec![DiagnosticCode::NonExhaustiveSwitch]);
    assert_eq!(messages(&text), vec!["Rectangle, Dot".to_owned()]);
}

#[test]
fn construction_checks_the_case_name_arity_and_field_types() {
    for (body, code) in [
        (
            "define s as Shape <- Shape.Triangle(1);\n",
            DiagnosticCode::UndefinedMember,
        ),
        (
            "define s as Shape <- Shape.Rectangle(1);\n",
            DiagnosticCode::ArgumentCountMismatch,
        ),
        (
            "define s as Shape <- Shape.Circle;\n",
            DiagnosticCode::ArgumentCountMismatch,
        ),
        (
            "define s as Shape <- Shape.Circle(\"xy\");\n",
            DiagnosticCode::IncompatibleArgumentType,
        ),
        (
            "define s as Shape <- Shape.Dot;\nwrite s;\n",
            DiagnosticCode::VariantRequiresPattern,
        ),
    ] {
        assert_eq!(codes(&program(SHAPE, body)), vec![code], "{body}");
    }
}

#[test]
fn an_empty_variant_and_a_repeated_case_are_rejected() {
    assert_eq!(
        codes(&program("variant Empty\nendVariant\n", "")),
        vec![DiagnosticCode::VariantWithoutAlternatives]
    );
    assert_eq!(
        codes(&program(
            "variant Tint\ncase Red\ncase Red\nendVariant\n",
            ""
        )),
        vec![DiagnosticCode::DuplicateMember]
    );
}

#[test]
fn a_variant_that_contains_itself_by_value_is_recursive() {
    assert_eq!(
        codes(&program(
            "variant List\ncase Node(next as List)\ncase End\nendVariant\n",
            ""
        )),
        vec![DiagnosticCode::RecursiveRecordContainment]
    );
}

#[test]
fn generic_instances_come_from_context_or_from_direct_fields() -> Result<(), String> {
    let module = analyze(&program(
        TREE,
        "define x as Tree<integer> <- Tree.Empty;\ndefine y as Tree<string> <- Tree.Leaf(\"ab\");\nswitch x do\nTree.Leaf(v): write v;\nTree.Empty: write y;\nendSwitch\n",
    ));
    assert!(module.is_err());
    let module = analyze(&program(
        &format!("{TREE}subroutine take<T>(t as Tree<T>)\nendSubroutine\n"),
        "take(Tree.Leaf(3));\ndefine x as Tree<integer> <- Tree.Empty;\ntake(x);\n",
    ))?;
    let instances: Vec<&str> = module
        .records
        .iter()
        .map(|record| record.name.as_str())
        .filter(|name| name.starts_with("Tree<"))
        .collect();
    assert!(instances.contains(&"Tree<integer>"), "{instances:?}");
    Ok(())
}

#[test]
fn a_generic_case_without_context_or_fields_is_ambiguous() {
    assert_eq!(
        codes(&program(
            &format!("{TREE}subroutine take<T>(t as T)\nendSubroutine\n"),
            "take(Tree.Empty);\n"
        )),
        vec![DiagnosticCode::AmbiguousVariantType]
    );
}

#[test]
fn a_pattern_must_name_the_selector_variant() {
    assert_eq!(
        codes(&program(
            &format!("{SHAPE}variant Other\ncase Dot\nendVariant\n"),
            "define s as Shape <- Shape.Dot;\nswitch s do\nOther.Dot: write 1;\notherwise: write 0;\nendSwitch\n"
        )),
        vec![DiagnosticCode::IncompatibleSwitchCaseType]
    );
}
