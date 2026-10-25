mod support;

use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_semantic::Type;
use support::analyze;

fn codes(text: &str) -> Vec<DiagnosticCode> {
    analyze(text, false)
        .1
        .iter()
        .map(|diagnostic| diagnostic.code)
        .collect()
}

const POINT: &str = "record Point\ndefine x, z as integer;\nendRecord\n";

#[test]
fn registers_enum_members_in_declaration_order() {
    let (module, diagnostics) = analyze(
        "enum Color\nRojo, Verde, Azul\nendEnum\nalgorithm P\nwrite Color.Azul;\nendAlgorithm\n",
        true,
    );
    assert!(diagnostics.is_empty());
    let enumeration = module.as_ref().and_then(|module| module.enums.first());
    assert_eq!(
        enumeration.map(|model| model.members.clone()),
        Some(vec![
            "Rojo".to_owned(),
            "Verde".to_owned(),
            "Azul".to_owned()
        ])
    );
}

#[test]
fn accepts_empty_and_single_member_enumerations() {
    let (module, diagnostics) = analyze(
        "enum Empty\nendEnum\nenum One\nOnly\nendEnum\nalgorithm P\nwrite One.Only;\nendAlgorithm\n",
        true,
    );
    assert!(diagnostics.is_empty());
    let sizes: Vec<usize> = module
        .map(|module| {
            module
                .enums
                .iter()
                .map(|model| model.members.len())
                .collect()
        })
        .unwrap_or_default();
    assert_eq!(sizes, vec![0, 1]);
}

#[test]
fn rejects_duplicate_members_and_duplicate_type_names() {
    assert!(
        codes("enum C\nA, A\nendEnum\nalgorithm P\nendAlgorithm\n")
            .contains(&DiagnosticCode::DuplicateEnumMember)
    );
    assert!(
        codes("enum C\nA\nendEnum\nenum C\nB\nendEnum\nalgorithm P\nendAlgorithm\n")
            .contains(&DiagnosticCode::DuplicateTypeDeclaration)
    );
    assert!(
        codes(&format!(
            "{POINT}enum Point\nA\nendEnum\nalgorithm P\nendAlgorithm\n"
        ))
        .contains(&DiagnosticCode::DuplicateTypeDeclaration)
    );
}

#[test]
fn allows_equal_member_names_in_different_enumerations() {
    let (module, diagnostics) = analyze(
        "enum A\nx\nendEnum\nenum B\nx\nendEnum\nalgorithm P\nwrite A.x, B.x;\nendAlgorithm\n",
        true,
    );
    assert!(diagnostics.is_empty());
    assert!(module.is_some());
}

#[test]
fn flattens_nested_records_into_leaves_with_offsets() {
    let source = format!(
        "{POINT}record Line\ndefine a, b as Point;\nendRecord\nalgorithm P\ndefine l as Line;\nl <- Line(Point(1, 2), Point(3, 4));\nwrite l.b.z;\nendAlgorithm\n"
    );
    let (module, diagnostics) = analyze(&source, true);
    assert!(diagnostics.is_empty());
    let line = module.as_ref().and_then(|module| module.records.get(1));
    assert_eq!(
        line.map(|model| model.leaf_names.clone()),
        Some(vec![
            "a.x".to_owned(),
            "a.z".to_owned(),
            "b.x".to_owned(),
            "b.z".to_owned()
        ])
    );
    assert_eq!(
        line.map(|model| model
            .fields
            .iter()
            .map(|field| (field.offset, field.width))
            .collect::<Vec<_>>()),
        Some(vec![(0, 2), (2, 2)])
    );
    let components = module.as_ref().and_then(|module| {
        let slot = module.locals.iter().position(|local| local.name == "l")?;
        let identifier = u32::try_from(slot).ok()?;
        module
            .record_locals
            .get(&pseudolearn_semantic::LocalId(identifier))
            .map(Vec::len)
    });
    assert_eq!(components, Some(4));
}

#[test]
fn rejects_recursive_containment_directly_and_indirectly() {
    let direct = codes("record R\ndefine r as R;\nendRecord\nalgorithm P\nendAlgorithm\n");
    assert_eq!(
        direct
            .iter()
            .filter(|code| **code == DiagnosticCode::RecursiveRecordContainment)
            .count(),
        1
    );
    let indirect = codes(
        "record A\ndefine b as B;\nendRecord\nrecord B\ndefine a as A;\nendRecord\nalgorithm P\nendAlgorithm\n",
    );
    assert_eq!(
        indirect
            .iter()
            .filter(|code| **code == DiagnosticCode::RecursiveRecordContainment)
            .count(),
        1
    );
}

#[test]
fn accepts_records_that_reference_classes_without_recursion() {
    let source = "class Box\ndefine v as integer;\nendClass\nrecord Pair\ndefine c as Box;\nendRecord\nalgorithm P\nendAlgorithm\n";
    let (module, diagnostics) = analyze(source, true);
    assert!(diagnostics.is_empty());
    let leaf = module.as_ref().and_then(|module| {
        module
            .records
            .first()
            .and_then(|model| model.leaf_types.first().map(|id| module.types.get(*id)))
    });
    assert!(matches!(leaf, Some(Type::Object(_))));
}

#[test]
fn rejects_empty_records_and_unsupported_placements() {
    assert!(
        codes("record E\nendRecord\nalgorithm P\nendAlgorithm\n")
            .contains(&DiagnosticCode::RecordWithoutFields)
    );
    assert!(
        codes(&format!(
            "{POINT}class K\ndefine p as Point;\nendClass\nalgorithm P\nendAlgorithm\n"
        ))
        .contains(&DiagnosticCode::RecordClassFieldNotSupported)
    );
    assert!(
        codes(&format!(
            "{POINT}algorithm P\ndimension a[2] as Point;\nendAlgorithm\n"
        ))
        .contains(&DiagnosticCode::RecordArrayElementNotSupported)
    );
}

#[test]
fn rejects_by_reference_record_parameters_and_record_members() {
    assert!(codes(&format!(
        "{POINT}subroutine f(p as Point by reference)\nwrite p.x;\nendSubroutine\nalgorithm P\ndefine q as Point;\nq <- Point(1, 2);\nf(q);\nendAlgorithm\n"
    ))
    .contains(&DiagnosticCode::RecordPassedByReference));
    assert!(codes(&format!(
        "{POINT}class K\nmethod m(p as Point)\nwrite p.x;\nendMethod\nendClass\nalgorithm P\nendAlgorithm\n"
    ))
    .contains(&DiagnosticCode::RecordMemberSignatureNotSupported));
}

#[test]
fn rejects_records_in_ordering_output_and_inference() {
    assert!(
        codes(&format!(
            "{POINT}algorithm P\nwrite Point(1, 2) < Point(1, 3);\nendAlgorithm\n"
        ))
        .contains(&DiagnosticCode::IncompatibleOperandTypes)
    );
    assert!(
        codes(&format!(
            "{POINT}algorithm P\nwrite Point(1, 2);\nendAlgorithm\n"
        ))
        .contains(&DiagnosticCode::RecordCannotBeWritten)
    );
    assert!(
        codes(&format!(
            "{POINT}algorithm P\nq <- Point(1, 2);\nendAlgorithm\n"
        ))
        .contains(&DiagnosticCode::RecordNotInferable)
    );
}

#[test]
fn rejects_wrong_construction_arity_and_unknown_field() {
    assert!(
        codes(&format!(
            "{POINT}algorithm P\nwrite Point(1).x;\nendAlgorithm\n"
        ))
        .contains(&DiagnosticCode::ArgumentCountMismatch)
    );
    assert!(
        codes(&format!(
            "{POINT}algorithm P\nwrite Point(1, 2).w;\nendAlgorithm\n"
        ))
        .contains(&DiagnosticCode::UndefinedMember)
    );
}
