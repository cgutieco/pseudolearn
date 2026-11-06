mod support;

use pseudolearn_diagnostics::DiagnosticCode;

fn codes(body: &str) -> Vec<DiagnosticCode> {
    let (_, diagnostics) = support::analyze(&format!("algorithm Main\n{body}\nendAlgorithm\n"));
    diagnostics
        .iter()
        .map(|diagnostic| diagnostic.code)
        .collect()
}

#[test]
fn adopts_an_untouched_declaration_of_the_same_scope() {
    assert!(codes("define v as real;\ndimension v[3];\nv[0] <- 1;\nwrite v[0];").is_empty());
    assert!(
        codes("define m as integer;\ndimension m[2, 2];\nm[1, 1] <- 1;\nwrite m[1, 1];").is_empty()
    );
    assert!(
        !codes("define v as integer;\ndimension v[0];\nwrite 1;")
            .contains(&DiagnosticCode::DimensionWithoutType)
    );
}

#[test]
fn rejects_unknown_initialized_used_or_outer_names() {
    for body in [
        "dimension w[3];\nwrite 1;",
        "define v as integer <- 1;\ndimension v[3];\nwrite 1;",
        "define v as integer;\nv <- 2;\ndimension v[3];\nwrite 1;",
        "define v as integer;\nif true then\ndimension v[3];\nendIf\nwrite 1;",
    ] {
        assert!(
            codes(body).contains(&DiagnosticCode::DimensionWithoutType),
            "{body}"
        );
    }
}
