mod support;

use pseudolearn_diagnostics::DiagnosticCode;

fn unassigned(body: &str) -> usize {
    let (_, diagnostics) = support::analyze(&format!(
        "record Point\ndefine x, z as integer;\nendRecord\nalgorithm Main\ndefine p as Point;\n{body}\nendAlgorithm\n"
    ));
    diagnostics
        .iter()
        .filter(|diagnostic| diagnostic.code == DiagnosticCode::VariableUsedUninitialized)
        .count()
}

#[test]
fn fields_are_tracked_one_by_one() {
    assert_eq!(unassigned("p.x <- 1;\nwrite p.x;"), 0);
    assert_eq!(unassigned("p.x <- 1;\nwrite p.z;"), 1);
}

#[test]
fn the_whole_record_has_a_value_once_every_field_does() {
    assert_eq!(
        unassigned("p.x <- 1;\np.z <- 2;\ndefine q as Point <- p;\nwrite q.z;"),
        0
    );
    assert_eq!(
        unassigned("p.x <- 1;\ndefine q as Point <- p;\nwrite q.x;"),
        1
    );
}

#[test]
fn assigning_the_whole_record_gives_every_field_a_value() {
    assert_eq!(unassigned("p <- Point(1, 2);\nwrite p.z;"), 0);
}
