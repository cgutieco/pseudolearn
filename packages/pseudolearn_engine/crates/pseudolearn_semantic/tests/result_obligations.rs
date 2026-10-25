mod support;
use pseudolearn_diagnostics::DiagnosticCode;

const PRODUCE: &str =
    "subroutine Produce() as result<integer, string>\nreturn success(1);\nendSubroutine\n";

#[test]
fn overwriting_a_pending_result_reports_the_discard_site() {
    let source = format!(
        "{PRODUCE}algorithm Main\ndefine mutable outcome as result<integer, string> <- Produce();\noutcome <- Produce();\ndiscard outcome;\nendAlgorithm\n"
    );
    let (module, diagnostics) = support::analyze(&source, true);
    assert!(module.is_none());
    assert_eq!(diagnostics.len(), 1, "{diagnostics:?}");
    assert_eq!(
        diagnostics.first().map(|diagnostic| diagnostic.code),
        Some(DiagnosticCode::ResultNotHandled)
    );
}

#[test]
fn requires_handling_on_both_conditional_paths() {
    for otherwise in ["", "else\ndiscard outcome;\n"] {
        let source = format!(
            "{PRODUCE}subroutine Consume(flag as boolean)\ndefine outcome as result<integer, string> <- Produce();\nif flag then\ndiscard outcome;\n{otherwise}endIf\nendSubroutine\nalgorithm Main\nConsume(true);\nendAlgorithm\n"
        );
        let (module, diagnostics) = support::analyze(&source, true);
        assert_eq!(module.is_some(), !otherwise.is_empty(), "{diagnostics:?}");
        assert_eq!(
            diagnostics
                .iter()
                .filter(|diagnostic| diagnostic.code == DiagnosticCode::ResultNotHandled)
                .count(),
            usize::from(otherwise.is_empty())
        );
    }
}

#[test]
fn an_early_return_cannot_hide_an_unhandled_result() {
    let source = format!(
        "{PRODUCE}subroutine Consume(flag as boolean)\ndefine outcome as result<integer, string> <- Produce();\nif flag then\nreturn;\nendIf\ndiscard outcome;\nendSubroutine\nalgorithm Main\nConsume(true);\nendAlgorithm\n"
    );
    let (module, diagnostics) = support::analyze(&source, true);
    assert!(module.is_none());
    assert_eq!(
        diagnostics.first().map(|diagnostic| diagnostic.code),
        Some(DiagnosticCode::ResultNotHandled)
    );
}
