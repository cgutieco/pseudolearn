use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{parse_source, reprint_lossless};

struct NestedForm {
    opening: &'static str,
    inner: &'static str,
    closing: &'static str,
    levels_per_repeat: usize,
}

const NESTED_FORMS: [NestedForm; 4] = [
    NestedForm {
        opening: "F(",
        inner: "1",
        closing: ")",
        levels_per_repeat: 1,
    },
    NestedForm {
        opening: "a[",
        inner: "0",
        closing: "]",
        levels_per_repeat: 1,
    },
    NestedForm {
        opening: "new C(",
        inner: "1",
        closing: ")",
        levels_per_repeat: 1,
    },
    NestedForm {
        opening: "F(spawn G(",
        inner: "1",
        closing: "))",
        levels_per_repeat: 2,
    },
];

fn nesting_diagnostics(form: &NestedForm, depth: usize) -> Vec<Diagnostic> {
    let program = format!(
        "algorithm Main\nwrite {}{}{};\nendAlgorithm\n",
        form.opening.repeat(depth),
        form.inner,
        form.closing.repeat(depth)
    );
    let source = SourceText::new(program);
    let (tree, diagnostics) = parse_source(&source, Profile::English);
    assert_eq!(reprint_lossless(&source, &tree.tokens), source.as_str());
    diagnostics
        .into_iter()
        .filter(|diagnostic| diagnostic.code == DiagnosticCode::AnalysisNestingLimitExceeded)
        .collect()
}

#[test]
fn nested_argument_and_index_lists_within_the_limit_are_accepted() {
    for form in &NESTED_FORMS {
        let depth = 256_usize.div_ceil(form.levels_per_repeat);
        assert!(
            nesting_diagnostics(form, depth).is_empty(),
            "{}",
            form.opening
        );
    }
}

#[test]
fn nested_argument_and_index_lists_beyond_the_limit_report_once() {
    for form in &NESTED_FORMS {
        for depth in [257_usize.div_ceil(form.levels_per_repeat), 100_000] {
            let diagnostics = nesting_diagnostics(form, depth);
            assert_eq!(diagnostics.len(), 1, "{} at {depth}", form.opening);
        }
    }
}

#[test]
fn sibling_arguments_do_not_add_a_nesting_level() {
    let arguments = vec!["F(1)"; 10_000].join(", ");
    let program = format!("algorithm Main\nwrite G({arguments});\nendAlgorithm\n");
    let source = SourceText::new(program);
    let (_, diagnostics) = parse_source(&source, Profile::English);
    assert!(
        diagnostics
            .iter()
            .all(|diagnostic| diagnostic.code != DiagnosticCode::AnalysisNestingLimitExceeded)
    );
}
