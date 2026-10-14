#[path = "../src/corpus.rs"]
mod corpus;

#[test]
fn all_variants_match_both_normative_sizes() -> Result<(), String> {
    for purpose in ["verificacion", "medicion"] {
        for workload in corpus::load(purpose)? {
            for variant in 0..4 {
                let actual = ceiling_kernels::variant::run(&workload.name, variant, workload.size)
                    .map_err(|error| format!("{} V{variant}: {error:?}", workload.name))?;
                assert_eq!(actual, workload.expected, "{} V{variant}", workload.name);
                assert!(!workload.family.is_empty());
            }
        }
    }
    Ok(())
}

#[test]
fn rejects_invalid_or_missing_corpus() {
    assert!(corpus::parse("{", "medicion").is_err());
    assert!(corpus::parse("{\"specifications\":[]}", "medicion").is_err());
}
