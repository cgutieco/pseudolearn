mod support;
use see_conformance::properties::{PropertyContext, PropertySubject, run};
use see_model::properties::{PropertyBinding, PropertyExecutor};
use serde_json::{Value, json};

struct Subject {
    hello: Value,
    responses: std::collections::VecDeque<Value>,
    requests: Vec<Value>,
}

impl PropertySubject for Subject {
    fn declaration(&self) -> &Value {
        &self.hello
    }
    fn exchange(&mut self, request: &Value) -> Result<Value, String> {
        self.requests.push(request.clone());
        self.responses
            .pop_front()
            .ok_or("SEE-TEST: exhausted responses".to_owned())
    }
}

fn binding(executor: PropertyExecutor) -> PropertyBinding {
    PropertyBinding {
        reference: "TEST.MODEL@0.1.0#P1".to_owned(),
        executor,
        seed: 42,
        samples: 1,
    }
}

fn measured(
    executor: PropertyExecutor,
    responses: Vec<Value>,
) -> Result<(see_model::properties::PropertyRun, Subject), String> {
    let corpus = vec![support::specification()?];
    let vocabulary = Default::default();
    let context = PropertyContext {
        corpus: &corpus,
        vocabulary: &vocabulary,
        subject: "engine",
        first_sample: 0,
        exhaustive: false,
    };
    let mut subject = Subject {
        hello: json!({"capabilities":["execute", "observe", "gc_stress", "api"]}),
        responses: responses.into(),
        requests: Vec::new(),
    };
    let report = run(&binding(executor), &context, &mut subject)?;
    Ok((report, subject))
}

#[test]
fn deterministic_repetition_reports_first_counterexample_and_replay() -> Result<(), String> {
    let good = json!({"output":"3\n", "termination":{"kind":"completed"}, "diagnostics":[]});
    let (report, _) = measured(
        PropertyExecutor::Determinism,
        vec![good.clone(), good.clone()],
    )?;
    assert_eq!(report.verdict, "cumple");
    assert_eq!(report.completed, 1);
    let (report, _) = measured(
        PropertyExecutor::Determinism,
        vec![good, json!({"output":"4\n"})],
    )?;
    assert_eq!(report.verdict, "incumple");
    let failure = report.counterexample.ok_or("Missing counterexample")?;
    assert_eq!(failure.sample, 0);
    assert!(failure.reproduction.contains(&"--sample".to_owned()));
    assert!(
        failure
            .reproduction
            .contains(&"TEST.MODEL@0.1.0#P1".to_owned())
    );
    Ok(())
}

#[test]
fn observed_and_gc_variants_are_requested_and_compared() -> Result<(), String> {
    let plain = json!({"output":"3\n"});
    let observed = json!({"output":"3\n", "events":[{"class":"output"}]});
    let (report, subject) = measured(
        PropertyExecutor::ObservationCorrespondence,
        vec![plain.clone(), observed],
    )?;
    assert_eq!(report.verdict, "cumple");
    assert_eq!(
        subject
            .requests
            .first()
            .and_then(|request| request.get("observe")),
        Some(&json!("none"))
    );
    let (report, subject) = measured(PropertyExecutor::GcTransparency, vec![plain.clone(), plain])?;
    assert_eq!(report.verdict, "cumple");
    assert_eq!(
        subject
            .requests
            .last()
            .and_then(|request| request.get("gc_stress")),
        Some(&json!(true))
    );
    Ok(())
}

#[test]
fn missing_capability_and_zero_samples_never_pass() -> Result<(), String> {
    let corpus = vec![];
    let vocabulary = Default::default();
    let context = PropertyContext {
        corpus: &corpus,
        vocabulary: &vocabulary,
        subject: "engine",
        first_sample: 0,
        exhaustive: false,
    };
    let mut subject = Subject {
        hello: json!({"capabilities":[]}),
        responses: Default::default(),
        requests: vec![],
    };
    let mut selected = binding(PropertyExecutor::GcTransparency);
    let report = run(&selected, &context, &mut subject)?;
    assert_eq!(report.verdict, "pendiente");
    assert_eq!(report.completed, 0);
    selected.samples = 0;
    assert!(run(&selected, &context, &mut subject).is_err());
    assert!(subject.requests.is_empty());
    Ok(())
}

#[test]
fn operational_failure_is_not_converted_into_a_pass() {
    assert!(measured(PropertyExecutor::Determinism, vec![]).is_err());
}

fn result(value: Value) -> Value {
    json!({"kind":"api","result":{"value":value}})
}
fn failure(family: &str) -> Value {
    json!({"kind":"api","result":{"failure":{"family":family}}})
}

#[test]
fn resource_lifecycle_requires_usage_error_after_release() -> Result<(), String> {
    for (last, verdict) in [
        (failure("usage"), "cumple"),
        (result(json!({})), "incumple"),
    ] {
        let responses = vec![
            result(json!({"resource":7})),
            result(json!({"tree":true})),
            result(json!({})),
            last,
        ];
        let (report, subject) = measured(PropertyExecutor::ResourceLifecycle, responses)?;
        assert_eq!(report.verdict, verdict);
        assert_eq!(
            subject
                .requests
                .last()
                .and_then(|request| request.pointer("/arguments/resource")),
            Some(&json!(7))
        );
    }
    Ok(())
}

#[test]
fn version_schema_rejects_missing_declarations() -> Result<(), String> {
    let declaration = json!({"version":"1", "editions":["1"], "capabilities":["analyze"]});
    let (report, _) = measured(
        PropertyExecutor::VersionNegotiation,
        vec![result(declaration)],
    )?;
    assert_eq!(report.verdict, "cumple");
    let (report, _) = measured(
        PropertyExecutor::VersionNegotiation,
        vec![result(json!({"version":"1"}))],
    )?;
    assert_eq!(report.verdict, "incumple");
    Ok(())
}

#[test]
fn injected_faults_require_internal_failure_and_surviving_host() -> Result<(), String> {
    let responses = vec![
        result(json!(["syntax", "semantic"])),
        failure("internal"),
        result(json!({})),
        failure("internal"),
        result(json!({})),
    ];
    let (report, subject) = measured(PropertyExecutor::InternalFaultContainment, responses)?;
    assert_eq!(report.verdict, "cumple");
    assert_eq!(subject.requests.len(), 5);
    let responses = vec![result(json!(["syntax"])), failure("usage")];
    let (report, _) = measured(PropertyExecutor::InternalFaultContainment, responses)?;
    assert_eq!(report.verdict, "incumple");
    Ok(())
}

#[test]
fn interface_language_only_changes_diagnostic_prose() -> Result<(), String> {
    let analysis = |message: &str, code: &str| {
        result(json!({"tree":true,"diagnostics":[{"message":message,"code":code}]}))
    };
    for (code, verdict) in [("test", "cumple"), ("changed", "incumple")] {
        let mut responses = vec![
            result(json!({"resource":7})),
            analysis("", "test"),
            analysis("es", code),
        ];
        if verdict == "cumple" {
            responses.push(analysis("en", "test"));
        }
        responses.push(result(json!({})));
        let (report, _) = measured(PropertyExecutor::InterfaceLanguage, responses)?;
        assert_eq!(report.verdict, verdict);
    }
    Ok(())
}

#[test]
fn step_depth_verifies_step_conditions() -> Result<(), String> {
    let base = json!({
        "events": [
            {"clase": "statement_entered", "profundidad": 0, "linea": 1},
            {"clase": "statement_entered", "profundidad": 1, "linea": 2},
            {"clase": "output", "profundidad": 1, "linea": 2},
            {"clase": "statement_exited", "profundidad": 1, "linea": 2}
        ]
    });
    let mut responses = vec![result(base)];
    for target in [1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4] {
        responses.push(result(json!({"target": target})));
    }
    let (report, _) = measured(PropertyExecutor::StepDepth, responses)?;
    assert_eq!(report.verdict, "cumple");
    Ok(())
}

#[test]
fn scenarios_that_need_observation_are_skipped_for_subjects_without_it() -> Result<(), String> {
    let mut specification = support::specification()?;
    let mut cancelled = specification
        .blocks
        .iter()
        .find(|block| block.kind == "caso")
        .cloned()
        .ok_or("Missing case")?;
    cancelled.fields.insert("cancelacion".to_owned(), json!(1));
    specification.blocks.insert(0, cancelled);
    let corpus = vec![specification];
    let vocabulary = Default::default();
    let context = PropertyContext {
        corpus: &corpus,
        vocabulary: &vocabulary,
        subject: "aot",
        first_sample: 0,
        exhaustive: false,
    };
    let good = json!({"output":"1\n", "termination":{"kind":"completed"}, "diagnostics":[]});
    let mut subject = Subject {
        hello: json!({"capabilities":["execute"]}),
        responses: vec![good.clone(); 2].into(),
        requests: Vec::new(),
    };
    let report = run(
        &binding(PropertyExecutor::Determinism),
        &context,
        &mut subject,
    )?;
    assert_eq!(report.verdict, "cumple");
    assert_eq!(subject.requests.len(), 2);
    assert!(
        subject
            .requests
            .iter()
            .all(|request| request.get("cancel_at_statement").is_none())
    );
    Ok(())
}
