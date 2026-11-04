use pseudolearn_api::{ExecuteRequest, ExecutionLimits, compile_source_to_module, execute_program};

#[test]
fn synthesized_sort_growth_is_linear_and_reuses_each_instance() -> Result<(), String> {
    let mut sizes = Vec::new();
    for count in [1, 10, 100] {
        let declarations = (0..count)
            .map(|index| format!("record Entry{index}\ndefine value as integer;\nendRecord\n"))
            .collect::<String>();
        let body = (0..count).map(|index| format!("define values{index} as vector<Entry{index}> <- vector();\nvalues{index}.sort(subroutine(left as Entry{index}, right as Entry{index}) as integer\nreturn left.value - right.value;\nendSubroutine);\nvalues{index}.sort(subroutine(left as Entry{index}, right as Entry{index}) as integer\nreturn left.value - right.value;\nendSubroutine);\n")).collect::<String>();
        let program = format!("{declarations}algorithm P\n{body}endAlgorithm\n");
        let module = compile_source_to_module(&program, "en")
            .map_err(|diagnostics| format!("{diagnostics:?}"))?;
        let helpers = module
            .functions
            .iter()
            .filter(|function| function.name.starts_with("@__collection."))
            .collect::<Vec<_>>();
        assert_eq!(helpers.len(), count);
        let instructions = helpers
            .iter()
            .map(|function| {
                function
                    .blocks
                    .iter()
                    .map(|block| block.instructions.len())
                    .sum::<usize>()
            })
            .sum::<usize>();
        sizes.push(instructions);
        eprintln!("instances={count} helper_instructions={instructions}");
    }
    assert_eq!(
        sizes.get(1),
        sizes
            .first()
            .map(|size| size.checked_mul(10).unwrap_or(usize::MAX))
            .as_ref()
    );
    assert_eq!(
        sizes.get(2),
        sizes
            .first()
            .map(|size| size.checked_mul(100).unwrap_or(usize::MAX))
            .as_ref()
    );
    Ok(())
}

#[test]
fn sorting_one_hundred_thousand_elements_preserves_the_permutation() {
    let request = ExecuteRequest {
        program: "algorithm P\ndefine values as vector<integer> <- vector();\nfor index <- 1 to 100000 step 1 do\nvalues.append(100001 - index);\nendFor\nvalues.sort();\nfor index <- 0 to 99999 step 1 do\nif values[index] <> index + 1 then\nwrite -1;\nendIf\nendFor\nwrite values[0], \":\", values[99999];\nendAlgorithm\n".to_owned(),
        profile: "en".to_owned(),
        limits: ExecutionLimits { cells: Some(1_000_000), statements: Some(2_000_000), micro_steps: Some(500_000_000), ..Default::default() },
        ..Default::default()
    };
    assert!(compile_source_to_module(&request.program, "en").is_ok());
    let result = execute_program(&request);
    assert_eq!(
        result.output, "1:100000\n",
        "{:?} {:?}",
        result.diagnostics, result.termination
    );
    assert_eq!(
        result
            .termination
            .get("kind")
            .and_then(serde_json::Value::as_str),
        Some("completed")
    );
}

#[test]
fn sorting_is_one_visible_statement_and_keeps_the_caller_span() {
    let result = execute_program(&ExecuteRequest {
        program: "algorithm P\ndefine values as vector<integer> <- vector();\nvalues.append(2);\nvalues.append(1);\nvalues.sort();\nwrite values[0];\nendAlgorithm\n".to_owned(),
        profile: "en".to_owned(), observe: "events".to_owned(), ..Default::default()
    });
    assert_eq!(
        result.output, "1\n",
        "{:?} {:?}",
        result.diagnostics, result.termination
    );
    let serialized = serde_json::to_value(&result.events).unwrap_or(serde_json::Value::Null);
    assert!(!serialized.to_string().contains("__collection"));
}

#[cfg(feature = "native")]
#[test]
fn native_build_rejects_the_new_collection_instruction() {
    let request = pseudolearn_api::conformance_build_request(&ExecuteRequest {
        program: "algorithm P\ndefine values as vector<integer> <- vector();\nvalues.sort();\nendAlgorithm\n".to_owned(), profile: "en".to_owned(), ..Default::default()
    });
    let result = pseudolearn_api::build_native_object(&request);
    assert!(
        matches!(&result, Err(pseudolearn_api::NativeBuildFailure::Backend(message)) if message.contains("collection.begin_sort")),
        "{result:?}"
    );
}

#[test]
fn comparator_budget_exhaustion_remains_a_user_failure() {
    let request = ExecuteRequest {
        program: "algorithm P\ndefine values as vector<integer> <- vector();\nvalues.append(2); values.append(1);\nvalues.sort(subroutine(left as integer, right as integer) as integer\ndefine mutable total as integer <- 0;\nfor cursor <- 1 to 100 step 1 do\ntotal <- total + cursor;\nendFor\nreturn left - right;\nendSubroutine);\nendAlgorithm\n".to_owned(),
        profile: "en".to_owned(),
        limits: ExecutionLimits { statements: Some(15), ..Default::default() },
        ..Default::default()
    };
    let result = execute_program(&request);
    assert!(
        result
            .diagnostics
            .iter()
            .any(|diagnostic| diagnostic.code == "statementBudgetExhausted"),
        "{:?}",
        result.diagnostics
    );
}

#[test]
fn failed_sort_allocation_is_attributed_to_the_call() {
    let result = execute_program(&ExecuteRequest {
        program: "algorithm P\ndefine values as vector<integer> <- vector();\nvalues.append(2);\nvalues.append(1);\nvalues.sort();\nendAlgorithm\n".to_owned(), profile: "en".to_owned(), limits: ExecutionLimits { cells: Some(6), ..Default::default() }, ..Default::default()
    });
    let diagnostic = result
        .diagnostics
        .iter()
        .find(|diagnostic| diagnostic.code == "cellLimitExceeded");
    assert!(diagnostic.is_some(), "{:?}", result.diagnostics);
    assert_eq!(
        diagnostic.map(|diagnostic| diagnostic.span.start.line),
        Some(5)
    );
}
