use pseudolearn_api::{ExecuteRequest, execute_program};

#[test]
fn record_comparators_preserve_value_fields_and_live_text_references() {
    let result = execute_program(&ExecuteRequest {
        program: "record Entry\ndefine key as integer;\ndefine marker as string;\nendRecord\nalgorithm P\ndefine values as vector<Entry> <- vector();\nvalues.append(Entry(2,\"B1\"));\nvalues.append(Entry(1,\"A1\"));\nvalues.append(Entry(1,\"A2\"));\nvalues.sort(subroutine(left as Entry, right as Entry) as integer\nreturn left.key - right.key;\nendSubroutine);\nwrite values[0].marker, \":\", values[1].marker, \":\", values[2].marker;\nendAlgorithm\n".to_owned(),
        profile: "en".to_owned(),
        gc_stress: true,
        ..Default::default()
    });
    assert_eq!(result.output, "A1:A2:B1\n", "{:?}", result.diagnostics);
    assert!(result.diagnostics.is_empty());
}

#[test]
fn seeded_sort_preserves_stability_and_the_multiset() {
    let mut state = 20_261_104_u64;
    for length in [0, 1, 2, 7, 31, 96] {
        let values = (0..length)
            .map(|_| {
                state = state
                    .wrapping_mul(6_364_136_223_846_793_005)
                    .wrapping_add(1);
                i64::try_from(state % 997).unwrap_or_default()
            })
            .collect::<Vec<_>>();
        let mut expected = values.clone();
        expected.sort_by_key(|value| value % 7);
        let declarations = values
            .iter()
            .map(|value| format!("values.append({value});\n"))
            .collect::<String>();
        let result = execute_program(&ExecuteRequest {
            program: format!(
                "algorithm P\ndefine values as vector<integer> <- vector();\n{declarations}values.sort(subroutine(left as integer, right as integer) as integer\nreturn left mod 7 - right mod 7;\nendSubroutine);\nfor each element in values do\nwrite element;\nendFor\nendAlgorithm\n"
            ),
            profile: "en".to_owned(),
            ..Default::default()
        });
        let output = expected
            .iter()
            .map(|value| format!("{value}\n"))
            .collect::<String>();
        assert_eq!(result.output, output, "{:?}", result.diagnostics);
        assert!(result.diagnostics.is_empty(), "{:?}", result.diagnostics);
    }
}
