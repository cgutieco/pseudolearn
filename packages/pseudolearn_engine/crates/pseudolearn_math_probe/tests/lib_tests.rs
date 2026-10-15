use pseudolearn_math_probe::{evaluate_line, probe_directory};

fn word(value: f64) -> String {
    format!("{:016x}", value.to_bits())
}

#[test]
fn evaluates_unary_and_binary_functions() {
    assert_eq!(evaluate_line("exp", &word(0.0)), Ok(word(1.0)));
    assert_eq!(
        evaluate_line("pow", &format!("{} {}", word(2.0), word(10.0))),
        Ok(word(1024.0))
    );
}

#[test]
fn reports_non_finite_results_by_their_trap() {
    assert_eq!(
        evaluate_line("ln", &word(0.0)),
        Ok("nonFiniteRealResult".to_owned())
    );
}

#[test]
fn rejects_malformed_lines() {
    assert!(evaluate_line("exp", "zz").is_err());
    assert!(evaluate_line("pow", &word(2.0)).is_err());
    assert!(evaluate_line("tan", &word(1.0)).is_err());
}

#[test]
fn probes_every_function_file_in_a_directory() {
    let directory = std::env::temp_dir().join("pseudolearn_math_probe_tests");
    let created = std::fs::create_dir_all(&directory);
    assert!(created.is_ok());
    for name in ["exp", "ln", "sin", "cos", "atan"] {
        assert!(std::fs::write(directory.join(format!("{name}.arguments")), word(1.0)).is_ok());
    }
    let pair = format!("{} {}", word(4.0), word(0.5));
    assert!(std::fs::write(directory.join("pow.arguments"), pair).is_ok());
    assert_eq!(probe_directory(&directory), Ok(6));
    let power = std::fs::read_to_string(directory.join("pow.results")).unwrap_or_default();
    assert_eq!(power.trim(), word(2.0));
    assert!(probe_directory(&directory.join("missing")).is_err());
}
