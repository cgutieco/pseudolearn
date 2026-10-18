use pseudolearn_aot_rt::{
    AotLimits, AotRuntimeContext, BooleanWords, ExecutableMetadata, ExecutableSettings,
    encode_metadata,
};
use pseudolearn_native_probe::{Configuration, measure, native_first, pseudolearn_native_pair};

extern "C" fn empty(_context: *mut AotRuntimeContext) {}

fn configuration() -> Configuration {
    let settings = ExecutableSettings {
        source_name: String::new(),
        locale: "en".to_owned(),
        seed: 42,
        forced_collection: false,
        limits: AotLimits::default(),
        boolean_words: BooleanWords {
            truth: "true".to_owned(),
            falsity: "false".to_owned(),
        },
        error_template: String::new(),
        warning_template: String::new(),
        information_template: String::new(),
        exhausted_template: String::new(),
    };
    Configuration {
        workload: "unknown".to_owned(),
        source: "Algoritmo P\nFinAlgoritmo\n".to_owned(),
        size: 1,
        input: String::new(),
        expected: String::new(),
        metadata: encode_metadata(&ExecutableMetadata {
            settings,
            sites: Vec::new(),
            classes: Vec::new(),
        }),
        process: 0,
        iterations: 1,
    }
}

#[test]
fn order_alternates_across_processes_and_iterations() {
    assert!(native_first(0, 0));
    assert!(!native_first(0, 1));
    assert!(!native_first(1, 0));
    assert!(native_first(1, 1));
}

#[test]
fn invalid_configuration_and_missing_metadata_are_rejected() {
    assert_eq!(pseudolearn_native_pair(empty, std::ptr::null(), 0), 1);
    let mut configuration = configuration();
    configuration.iterations = 0;
    assert!(measure(empty, &configuration).is_err());
    configuration.iterations = 1;
    configuration.metadata.clear();
    assert!(measure(empty, &configuration).is_err());
}

#[test]
fn unknown_workloads_and_wrong_native_output_are_rejected() {
    let mut configuration = configuration();
    assert!(measure(empty, &configuration).is_err());
    configuration.expected = "incorrect".to_owned();
    assert!(measure(empty, &configuration).is_err());
}

extern "C" fn zero(context: *mut AotRuntimeContext) {
    let _status = pseudolearn_aot_rt::rt_aot_write(
        context,
        0,
        0,
        pseudolearn_aot_rt::KIND_INTEGER | pseudolearn_aot_rt::NEWLINE_FLAG,
    );
}

#[test]
fn a_valid_pair_verifies_both_results_outside_the_interval() -> Result<(), String> {
    let mut configuration = configuration();
    configuration.workload = "sieve".to_owned();
    configuration.size = 0;
    configuration.expected = "0\n".to_owned();
    configuration.source = "Algoritmo P\nEscribir 0;\nFinAlgoritmo\n".to_owned();
    let pairs = measure(zero, &configuration)?;
    assert_eq!(pairs.len(), 1);
    assert!(
        pairs
            .iter()
            .all(|pair| pair.native_nanoseconds > 0 && pair.ceiling_nanoseconds > 0)
    );
    Ok(())
}
