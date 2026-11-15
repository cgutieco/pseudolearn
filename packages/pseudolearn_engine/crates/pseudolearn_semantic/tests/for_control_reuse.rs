mod support;

use pseudolearn_diagnostics::DiagnosticCode;

fn codes(body: &str) -> Vec<DiagnosticCode> {
    let (_, diagnostics) = support::analyze(&format!("algorithm Main\n{body}\nendAlgorithm\n"));
    diagnostics
        .iter()
        .map(|diagnostic| diagnostic.code)
        .collect()
}

const LOOP: &str = "for i <- 1 to 3 do\nwrite i;\nendFor";

#[test]
fn reuses_an_untouched_integer_declaration_of_the_same_block() {
    assert!(codes(&format!("define i as integer;\n{LOOP}")).is_empty());
    assert!(
        codes(&format!(
            "define i, n as integer;\nn <- 1;\n{LOOP}\nwrite n;"
        ))
        .is_empty()
    );
}

#[test]
fn reuses_the_same_declaration_in_consecutive_loops() {
    assert!(codes(&format!("define i as integer;\n{LOOP}\n{LOOP}")).is_empty());
}

#[test]
fn keeps_shadowing_when_the_declaration_does_not_qualify() {
    for body in [
        format!("define i as real;\n{LOOP}"),
        format!("define i as integer <- 0;\n{LOOP}"),
        format!("define i as integer;\nif true then\n{LOOP}\nendIf"),
        format!("define i as integer;\ni <- 2;\nwrite i;\n{LOOP}"),
    ] {
        assert!(
            codes(&body).contains(&DiagnosticCode::BindingShadowsOuter),
            "{body}"
        );
    }
}

#[test]
fn keeps_shadowing_for_a_parameter() {
    let (_, diagnostics) = support::analyze(
        "subroutine Show(i as integer)\nfor i <- 1 to 2 do\nwrite i;\nendFor\nendSubroutine\nalgorithm Main\nShow(1);\nendAlgorithm\n",
    );
    assert!(
        diagnostics
            .iter()
            .any(|diagnostic| diagnostic.code == DiagnosticCode::BindingShadowsOuter),
        "{diagnostics:?}"
    );
}

#[test]
fn leaves_the_reused_declaration_without_a_value_after_the_loop() {
    assert_eq!(
        codes(&format!("define i as integer;\n{LOOP}\nwrite i;")),
        vec![DiagnosticCode::VariableUsedUninitialized]
    );
}

#[test]
fn reports_a_reused_declaration_assigned_later_and_never_read() {
    assert_eq!(
        codes(&format!("define i as integer;\n{LOOP}\ni <- 4;")),
        vec![DiagnosticCode::VariableAssignedNeverRead]
    );
}
