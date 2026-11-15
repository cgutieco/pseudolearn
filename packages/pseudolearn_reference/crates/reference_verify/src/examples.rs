use reference_model::{ExampleCheck, ExecutionReport, RuleId, Violation};

pub fn check_examples(examples: &[ExampleCheck]) -> Vec<Violation> {
    examples.iter().flat_map(check_example).collect()
}

fn check_example(example: &ExampleCheck) -> Vec<Violation> {
    let report = &example.source_report;
    let promised_codes = example.promise.diagnostics.clone().unwrap_or_default();
    let problems = [
        output_problem(example),
        (promised_codes != codes(report)).then(|| {
            format!(
                "promised diagnostics {promised_codes:?} but the engine reported {:?}",
                codes(report)
            )
        }),
        termination_problem(example, &promised_codes),
        (codes(&example.target_report) != codes(report)
            || example.target_report.termination != report.termination)
            .then(|| "the translated program behaves differently".to_owned()),
    ];
    problems
        .into_iter()
        .flatten()
        .map(|detail| Violation::new(RuleId::ExampleVerified, example.location.clone(), detail))
        .collect()
}

fn output_problem(example: &ExampleCheck) -> Option<String> {
    let promised = normalize(example.promise.output.as_deref().unwrap_or(""));
    let written = normalize(&example.source_report.output);
    (promised != written)
        .then(|| format!("promised output {promised:?} but the engine wrote {written:?}"))
}

fn termination_problem(example: &ExampleCheck, promised_codes: &[String]) -> Option<String> {
    let actual = example.source_report.termination.as_str();
    let fallback = if promised_codes.is_empty() {
        "completed"
    } else {
        actual
    };
    let expected = example.promise.termination.as_deref().unwrap_or(fallback);
    (expected != actual)
        .then(|| format!("promised termination {expected} but the engine ended {actual}"))
}

fn codes(report: &ExecutionReport) -> Vec<String> {
    report
        .diagnostics
        .iter()
        .map(|diagnostic| diagnostic.code.clone())
        .collect()
}

fn normalize(text: &str) -> &str {
    text.trim_end_matches('\n')
}
