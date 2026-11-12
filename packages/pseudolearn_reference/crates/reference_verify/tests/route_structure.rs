use reference_model::{
    AssertionSource, ExerciseCheck, ExerciseKind, MemberView, ProgramView, RuleId, StructureCheck,
    SubprogramView,
};
use reference_verify::check_exercise_runs;

fn view() -> ProgramView {
    let mut view = ProgramView::default();
    view.constructs.insert("condicional".to_owned(), 2);
    view.subprograms.push(SubprogramView {
        name: "Cocinar".to_owned(),
        arity: 2,
    });
    view.members.push(MemberView {
        class: "Caja".to_owned(),
        name: "peso".to_owned(),
        visibility: "private".to_owned(),
    });
    view
}

fn assertion(kind: &str, fields: &[&str]) -> AssertionSource {
    AssertionSource {
        kind: kind.to_owned(),
        fields: fields.iter().map(|field| (*field).to_owned()).collect(),
        requirement: "Requirement shown to the student.".to_owned(),
    }
}

fn check(assertions: Vec<AssertionSource>, view: Result<ProgramView, String>) -> ExerciseCheck {
    ExerciseCheck {
        location: "estructura.md".to_owned(),
        kind: ExerciseKind::Explain,
        roles: Vec::new(),
        laps: None,
        structural: true,
        structure: Some(StructureCheck { assertions, view }),
    }
}

fn violations(assertions: Vec<AssertionSource>) -> usize {
    let found = check_exercise_runs(&check(assertions, Ok(view())));
    assert!(
        found
            .iter()
            .all(|violation| violation.rule == RuleId::RouteExerciseVerified)
    );
    found.len()
}

#[test]
fn the_reference_satisfying_every_assertion_raises_nothing() {
    let assertions = vec![
        assertion("contiene", &["condicional"]),
        assertion("no-contiene", &["bucle-contado"]),
        assertion("repite-como-mucho", &["condicional", "2"]),
        assertion("declara-subprograma", &["Cocinar", "2"]),
        assertion("declara-miembro", &["Caja", "peso", "privado"]),
    ];
    assert_eq!(violations(assertions), 0);
}

#[test]
fn an_assertion_the_reference_does_not_meet_fails() {
    for unmet in [
        assertion("contiene", &["bucle-contado"]),
        assertion("no-contiene", &["condicional"]),
        assertion("repite-como-mucho", &["condicional", "1"]),
        assertion("declara-subprograma", &["Cocinar", "3"]),
        assertion("declara-subprograma", &["Hornear", "2"]),
        assertion("declara-miembro", &["Caja", "peso", "publico"]),
        assertion("declara-miembro", &["Caja", "color", "privado"]),
    ] {
        assert_eq!(violations(vec![unmet.clone()]), 1, "{unmet:?}");
    }
}

#[test]
fn a_reference_without_a_view_fails_instead_of_passing_silently() {
    let broken = check(
        vec![assertion("contiene", &["condicional"])],
        Err("syntax error".to_owned()),
    );
    assert_eq!(check_exercise_runs(&broken).len(), 1);
}

#[test]
fn a_malformed_assertion_never_holds() {
    assert_eq!(
        violations(vec![assertion("repite-como-mucho", &["condicional", "x"])]),
        1
    );
    assert_eq!(violations(vec![assertion("inventada", &[])]), 1);
}
