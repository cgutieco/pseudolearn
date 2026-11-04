mod support;

#[test]
fn numeric_extrema_keep_integer_precision_and_accept_mixed_arguments() {
    let (module, diagnostics) = support::analyze(
        "algorithm P\ndefine lower as integer <- min(9007199254740993,9007199254740994);\ndefine upper as real <- max(3,2.5);\nwrite lower, upper;\nendAlgorithm\n",
    );
    assert!(module.is_some(), "{diagnostics:?}");
    assert!(diagnostics.is_empty());
}
