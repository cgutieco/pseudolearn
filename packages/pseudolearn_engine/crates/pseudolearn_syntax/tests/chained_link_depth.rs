use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{parse_source, reprint_lossless};

const LIMIT: usize = 256;

struct ChainForm {
    name: &'static str,
    program: fn(usize) -> String,
}

fn binary_chain(links: usize) -> String {
    format!(
        "algorithm Main\nwrite 1{};\nendAlgorithm\n",
        "+1".repeat(links)
    )
}

fn logical_chain(links: usize) -> String {
    format!(
        "algorithm Main\nwrite true{};\nendAlgorithm\n",
        " and true".repeat(links)
    )
}

fn comparison_chain(links: usize) -> String {
    format!(
        "algorithm Main\nwrite 1{};\nendAlgorithm\n",
        "<1".repeat(links)
    )
}

fn member_chain(links: usize) -> String {
    format!(
        "algorithm Main\nwrite a{};\nendAlgorithm\n",
        ".b".repeat(links)
    )
}

fn call_chain(links: usize) -> String {
    format!(
        "algorithm Main\nwrite f{};\nendAlgorithm\n",
        "()".repeat(links)
    )
}

fn mixed_member_index_chain(links: usize) -> String {
    format!(
        "algorithm Main\nwrite a[0]{};\nendAlgorithm\n",
        ".b".repeat(links.saturating_sub(1))
    )
}

fn function_type_chain(links: usize) -> String {
    format!(
        "algorithm Main\ndeclare f as {}integer;\nendAlgorithm\n",
        "function() as ".repeat(links)
    )
}

const FORMS: [ChainForm; 7] = [
    ChainForm {
        name: "binary",
        program: binary_chain,
    },
    ChainForm {
        name: "logical",
        program: logical_chain,
    },
    ChainForm {
        name: "comparison",
        program: comparison_chain,
    },
    ChainForm {
        name: "member",
        program: member_chain,
    },
    ChainForm {
        name: "call",
        program: call_chain,
    },
    ChainForm {
        name: "member after index",
        program: mixed_member_index_chain,
    },
    ChainForm {
        name: "function type",
        program: function_type_chain,
    },
];

fn limit_diagnostics(program: String) -> usize {
    let source = SourceText::new(program);
    let (tree, diagnostics) = parse_source(&source, Profile::English);
    assert_eq!(reprint_lossless(&source, &tree.tokens), source.as_str());
    diagnostics
        .iter()
        .filter(|diagnostic| diagnostic.code == DiagnosticCode::AnalysisNestingLimitExceeded)
        .count()
}

#[test]
fn chains_at_the_limit_are_accepted() {
    for form in &FORMS {
        assert_eq!(limit_diagnostics((form.program)(LIMIT)), 0, "{}", form.name);
    }
}

#[test]
fn chains_beyond_the_limit_report_once() {
    for form in &FORMS {
        for links in [LIMIT + 1, 100_000] {
            assert_eq!(
                limit_diagnostics((form.program)(links)),
                1,
                "{} at {links}",
                form.name
            );
        }
    }
}

#[test]
fn short_chains_are_accepted() {
    for form in &FORMS {
        for links in [1, 2] {
            assert_eq!(limit_diagnostics((form.program)(links)), 0, "{}", form.name);
        }
    }
}

#[test]
fn chain_levels_are_released_between_statements() {
    let statement = format!("write 1{};\n", "+1".repeat(LIMIT));
    let program = format!("algorithm Main\n{}endAlgorithm\n", statement.repeat(5));
    assert_eq!(limit_diagnostics(program), 0);
}
