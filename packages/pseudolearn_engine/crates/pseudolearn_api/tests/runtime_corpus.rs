mod runtime_support;

#[test]
fn runtime_executes_exported_cases_under_each_collection_policy() -> Result<(), String> {
    runtime_support::verify()
}
