use pseudolearn_api::{AnalyzeRequest, execute_analyze, render_diagnostic};

#[test]
fn keeps_named_types_distinct_from_generated_keyword_identities() -> Result<(), String> {
    let response = execute_analyze(&AnalyzeRequest {program: "class integerType\nendClass\nalgorithm Main\ndefine instance as integerType;\ninstance <- 1;\nendAlgorithm\n".to_owned(), profile: "en".to_owned(), strictness: "strict".to_owned()});
    let diagnostic = response
        .diagnostics
        .iter()
        .find(|diagnostic| diagnostic.code == "incompatibleTypesInAssignment")
        .ok_or(format!(
            "Missing typed assignment diagnostic: {:?}",
            response.diagnostics
        ))?;
    assert_eq!(
        diagnostic.arguments.get("expected"),
        Some(&serde_json::json!("integerType"))
    );
    assert_eq!(
        diagnostic.arguments.get("found"),
        Some(&serde_json::json!("integer"))
    );
    assert!(render_diagnostic(diagnostic, "es").contains("integerType"));
    assert!(
        response
            .diagnostics
            .iter()
            .all(|diagnostic| diagnostic.code != "internalFault")
    );
    Ok(())
}

#[test]
fn serializes_nesting_limits_as_numbers_instead_of_strings() -> Result<(), String> {
    let program = format!(
        "algorithm Main\nwrite {}1{};\nendAlgorithm\n",
        "(".repeat(257),
        ")".repeat(257)
    );
    let response = execute_analyze(&AnalyzeRequest {
        program,
        profile: "en".to_owned(),
        strictness: "strict".to_owned(),
    });
    let diagnostic = response
        .diagnostics
        .iter()
        .find(|diagnostic| diagnostic.code == "analysisNestingLimitExceeded")
        .ok_or("Missing nesting diagnostic")?;
    assert_eq!(
        diagnostic.arguments.get("limit"),
        Some(&serde_json::json!(256))
    );
    assert!(render_diagnostic(diagnostic, "es").contains("256"));
    Ok(())
}
