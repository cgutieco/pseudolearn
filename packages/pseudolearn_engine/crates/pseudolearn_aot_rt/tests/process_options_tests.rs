use pseudolearn_aot_rt::{ProcessOptions, ProcessOptionsError};

fn parse(arguments: &[&str]) -> Result<ProcessOptions, ProcessOptionsError> {
    let owned: Vec<String> = arguments.iter().map(|text| (*text).to_owned()).collect();
    ProcessOptions::parse(&owned)
}

#[test]
fn runtime_options_precede_the_program_arguments() {
    let options = parse(&[
        "--semilla",
        "-7",
        "--effects-out",
        "out.json",
        "uno",
        "--semilla",
    ]);
    assert_eq!(
        options,
        Ok(ProcessOptions {
            effects_in: None,
            effects_out: Some("out.json".to_owned()),
            seed: Some(-7),
            program_arguments: vec!["uno".to_owned(), "--semilla".to_owned()],
        })
    );
}

#[test]
fn the_english_seed_spelling_and_the_separator_are_accepted() {
    let options = parse(&["--seed", "9223372036854775807", "--", "--effects-in", "x"]);
    assert_eq!(
        options.map(|options| (options.seed, options.program_arguments)),
        Ok((
            Some(i64::MAX),
            vec!["--effects-in".to_owned(), "x".to_owned()]
        ))
    );
}

#[test]
fn no_arguments_leave_entropy_and_an_empty_argument_list() {
    assert_eq!(parse(&[]), Ok(ProcessOptions::default()));
    assert_eq!(parse(&["--"]), Ok(ProcessOptions::default()));
}

#[test]
fn a_seed_without_a_number_is_rejected() {
    assert_eq!(
        parse(&["--semilla"]),
        Err(ProcessOptionsError::MissingValue("--semilla".to_owned()))
    );
    assert_eq!(
        parse(&["--semilla", "doce"]),
        Err(ProcessOptionsError::InvalidSeed("doce".to_owned()))
    );
    assert_eq!(
        parse(&["--seed", "9223372036854775808"]),
        Err(ProcessOptionsError::InvalidSeed(
            "9223372036854775808".to_owned()
        ))
    );
}

#[test]
fn an_unknown_option_starts_the_program_arguments() {
    assert_eq!(
        parse(&["--verbose", "--semilla", "1"]).map(|options| options.program_arguments),
        Ok(vec![
            "--verbose".to_owned(),
            "--semilla".to_owned(),
            "1".to_owned()
        ])
    );
}
