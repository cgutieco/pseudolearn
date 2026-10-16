use crate::properties::PropertySubject;
use crate::property_scenarios::Scenario;
use see_model::properties::PropertyExecutor;
use serde_json::{Value, json};

pub(crate) fn available(executor: PropertyExecutor, declaration: &Value) -> bool {
    let capability = match executor {
        PropertyExecutor::Determinism
        | PropertyExecutor::LoweringExecution
        | PropertyExecutor::FirstTrap
        | PropertyExecutor::FusedFirstTrap => "execute",
        PropertyExecutor::ObservationCorrespondence => "observe",
        PropertyExecutor::GcTransparency | PropertyExecutor::IdentityStability => "gc_stress",
        _ => "api",
    };
    declaration
        .get("capabilities")
        .and_then(Value::as_array)
        .is_some_and(|values| values.contains(&json!(capability)))
}

pub(crate) fn check(
    executor: PropertyExecutor,
    scenario: &Scenario,
    subject: &mut impl PropertySubject,
) -> Result<Option<(Value, Value)>, String> {
    match executor {
        PropertyExecutor::Determinism => paired(scenario, subject, None),
        PropertyExecutor::GcTransparency | PropertyExecutor::IdentityStability => {
            paired(scenario, subject, Some(("gc_stress", json!(true))))
        }
        PropertyExecutor::ObservationCorrespondence => observed(scenario, subject),
        PropertyExecutor::LoweringExecution => normative(scenario, subject),
        PropertyExecutor::ResourceLifecycle
        | PropertyExecutor::UsageErrors
        | PropertyExecutor::VersionNegotiation
        | PropertyExecutor::CapabilityNegotiation
        | PropertyExecutor::InternalFaultContainment
        | PropertyExecutor::InterfaceLanguage => {
            crate::property_resources::check(executor, scenario, subject)
        }
        _ => check_extended(executor, scenario, subject),
    }
}

fn check_extended(
    executor: PropertyExecutor,
    scenario: &Scenario,
    subject: &mut impl PropertySubject,
) -> Result<Option<(Value, Value)>, String> {
    match executor {
        PropertyExecutor::SnapshotIsolation
        | PropertyExecutor::PastStateIsolation
        | PropertyExecutor::DeltaMinimality
        | PropertyExecutor::DeltaReconstruction => {
            if !scenario.traced {
                return Ok(None);
            }
            crate::property_states::check(executor, scenario, subject)
        }
        PropertyExecutor::StepPartition
        | PropertyExecutor::StepDepth
        | PropertyExecutor::InputBatching
        | PropertyExecutor::ExecutionControls
        | PropertyExecutor::HostRecording
        | PropertyExecutor::StateQuery
        | PropertyExecutor::WireRoundtrip => {
            if !recorded(executor, scenario) {
                return Ok(None);
            }
            crate::property_recording::check(executor, scenario, subject)
        }
        PropertyExecutor::LosslessReprint
        | PropertyExecutor::LosslessRecovery
        | PropertyExecutor::LoweringValidity
        | PropertyExecutor::StatementMass
        | PropertyExecutor::AnalysisSchema => {
            crate::property_syntax::check(executor, scenario, subject)
        }
        PropertyExecutor::FirstTrap | PropertyExecutor::FusedFirstTrap => {
            crate::property_traps::check(executor, scenario, subject)
        }
        _ => Err("SEE-PROPERTY: executor unavailable".to_owned()),
    }
}

fn paired(
    scenario: &Scenario,
    subject: &mut impl PropertySubject,
    variation: Option<(&str, Value)>,
) -> Result<Option<(Value, Value)>, String> {
    let expected = subject.exchange(&scenario.request)?;
    let mut request = scenario.request.clone();
    if let Some((name, value)) = variation {
        request
            .as_object_mut()
            .ok_or("SEE-PROPERTY: request object")?
            .insert(name.to_owned(), value);
    }
    let actual = subject.exchange(&request)?;
    Ok((expected != actual).then_some((expected, actual)))
}

fn observed(
    scenario: &Scenario,
    subject: &mut impl PropertySubject,
) -> Result<Option<(Value, Value)>, String> {
    let mut request = scenario.request.clone();
    request
        .as_object_mut()
        .ok_or("SEE-PROPERTY: request object")?
        .insert("observe".to_owned(), json!("none"));
    let expected = observable(subject.exchange(&request)?);
    request
        .as_object_mut()
        .ok_or("SEE-PROPERTY: request object")?
        .insert("observe".to_owned(), json!("events"));
    let resource_execution = subject
        .declaration()
        .get("capabilities")
        .and_then(Value::as_array)
        .is_some_and(|capabilities| capabilities.contains(&json!("seek")));
    let actual = if !resource_execution
        || expected
            .pointer("/termination/code")
            .and_then(Value::as_str)
            == Some("analysisFailed")
    {
        observable(subject.exchange(&request)?)
    } else {
        observable(crate::property_observation::execute(subject, &request)?)
    };
    Ok((expected != actual).then_some((expected, actual)))
}

fn observable(response: Value) -> Value {
    let mut fields = serde_json::Map::new();
    for name in ["output", "termination", "diagnostics", "inputs_consumed"] {
        if let Some(value) = response.get(name) {
            fields.insert(name.to_owned(), value.clone());
        }
    }
    Value::Object(fields)
}

fn normative(
    scenario: &Scenario,
    subject: &mut impl PropertySubject,
) -> Result<Option<(Value, Value)>, String> {
    let actual = subject.exchange(&scenario.request)?;
    let Some(expected) = &scenario.expected else {
        return Ok(None);
    };
    Ok((!crate::comparison::compare(expected, &actual).is_empty())
        .then(|| (expected.clone(), actual)))
}

fn recorded(executor: PropertyExecutor, scenario: &Scenario) -> bool {
    let has_inputs = scenario
        .request
        .get("inputs")
        .and_then(Value::as_array)
        .is_some_and(|inputs| !inputs.is_empty());
    match executor {
        PropertyExecutor::InputBatching | PropertyExecutor::HostRecording => {
            scenario.traced || has_inputs
        }
        _ => scenario.traced,
    }
}
