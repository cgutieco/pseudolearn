mod support;

#[test]
fn keys_read_from_immutable_dictionaries_preserve_the_readonly_type() {
    let prefix = "algorithm P\ndefine values as dictionary<integer,integer> <- dictionary();\ndefine frozen as immutable<dictionary<integer,integer>> <- snapshot(values);\n";
    let (_, diagnostics) = support::analyze(&format!(
        "{prefix}define names as immutable<vector<integer>> <- frozen.keys();\nwrite names.length();\nendAlgorithm\n"
    ));
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    let (_, diagnostics) =
        support::analyze(&format!("{prefix}frozen.keys().reverse();\nendAlgorithm\n"));
    assert!(
        diagnostics
            .iter()
            .any(|diagnostic| diagnostic.code.as_str() == "immutableValueWrite"),
        "{diagnostics:?}"
    );
}

#[test]
fn immutable_vectors_allow_queries_and_reject_reordering() {
    let prefix = "algorithm P\ndefine values as vector<integer> <- vector();\ndefine frozen as immutable<vector<integer>> <- snapshot(values);\n";
    let (_, diagnostics) = support::analyze(&format!(
        "{prefix}write frozen.contains(1);\nendAlgorithm\n"
    ));
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    for operation in ["sort", "reverse"] {
        let (_, diagnostics) =
            support::analyze(&format!("{prefix}frozen.{operation}();\nendAlgorithm\n"));
        assert!(
            diagnostics
                .iter()
                .any(|diagnostic| diagnostic.code.as_str() == "immutableValueWrite"),
            "{diagnostics:?}"
        );
    }
}

#[test]
fn collection_extensions_accept_typed_values_and_reject_invalid_result_uses() {
    let valid = "define values as vector<integer> <- vector();\nvalues.sort(); values.reverse();\nwrite values.contains(1);\n";
    let (_, diagnostics) = support::analyze(&format!("algorithm P\n{valid}endAlgorithm\n"));
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    for (body, code) in [
        ("write values.sort();", "callAsExpressionWithoutReturnType"),
        ("values.contains(1);", "discardedReturnValue"),
    ] {
        let (_, diagnostics) = support::analyze(&format!(
            "algorithm P\ndefine values as vector<integer> <- vector();\n{body}\nendAlgorithm\n"
        ));
        assert!(
            diagnostics
                .iter()
                .any(|diagnostic| diagnostic.code.as_str() == code),
            "{diagnostics:?}"
        );
    }
}

#[test]
fn collection_extensions_reject_wrong_element_types_and_signatures() {
    for (body, code) in [
        (
            "define values as vector<vector<integer>> <- vector();\nvalues.sort();",
            "elementTypeNotOrderable",
        ),
        (
            "define values as vector<vector<integer>> <- vector();\nwrite values.contains(vector());",
            "elementTypeNotComparable",
        ),
        (
            "define values as vector<integer> <- vector();\nvalues.sort(subroutine(left as real, right as real) as integer\nreturn 0;\nendSubroutine);",
            "incompatibleArgumentType",
        ),
        (
            "define values as vector<integer> <- vector();\nvalues.reverse(1);",
            "argumentCountMismatch",
        ),
    ] {
        let (_, diagnostics) = support::analyze(&format!("algorithm P\n{body}\nendAlgorithm\n"));
        assert!(
            diagnostics
                .iter()
                .any(|diagnostic| diagnostic.code.as_str() == code),
            "{code}: {diagnostics:?}"
        );
    }
}
