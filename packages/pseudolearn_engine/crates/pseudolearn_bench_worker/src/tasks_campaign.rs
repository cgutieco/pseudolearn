use crate::tasks_agendas::{Agenda, generate};
use crate::tasks_compare::{Observation, against_expected, differences, observe};
use crate::tasks_subject::{TaskSubject, subject_from};
use crate::tasks_summary::Summary;
use pseudolearn_api::ExecuteRequest;
use serde_json::{Value, json};
use std::path::Path;

pub fn request(agenda: &Agenda) -> ExecuteRequest {
    ExecuteRequest {
        program: agenda.program.clone(),
        inputs: agenda.inputs.clone(),
        host: agenda.host.clone(),
        gc_stress: agenda.gc_stress,
        ..Default::default()
    }
}

pub fn live(subject: &mut dyn TaskSubject, agenda: &Agenda) -> Result<Observation, String> {
    subject
        .execute(&request(agenda))
        .map(|response| observe(&response))
}

pub fn replayed(
    subject: &mut dyn TaskSubject,
    agenda: &Agenda,
    tape: &Value,
) -> Result<Observation, String> {
    let mut replay = request(agenda);
    replay.execution_mode = Some("replay_from_tape".to_owned());
    replay.effect_tape = Some(tape.clone());
    subject.execute(&replay).map(|response| observe(&response))
}

pub fn check_seed(subject: &mut dyn TaskSubject, seed: u64) -> Result<Vec<String>, String> {
    let agenda = generate(seed);
    let first = live(subject, &agenda)?;
    let mut found = against_expected(&agenda, &first);
    found.extend(differences(
        "repeated live",
        &first,
        &live(subject, &agenda)?,
    ));
    if first.kind == "completed"
        && let Some(tape) = &first.tape
    {
        let second = replayed(subject, &agenda, tape)?;
        found.extend(differences(
            "replay",
            &Observation {
                tape: None,
                ..first.clone()
            },
            &Observation {
                tape: None,
                ..second
            },
        ));
    }
    Ok(found)
}

pub fn collect(arguments: &[String]) -> Result<(), String> {
    let usage =
        || "Usage: pg-tasks <directory> <first-seed> <last-seed> [vm | aot <pseudo>]".to_owned();
    let [directory, first, last, subject_arguments @ ..] = arguments else {
        return Err(usage());
    };
    let first: u64 = first.parse().map_err(|_| "Invalid first seed".to_owned())?;
    let last: u64 = last.parse().map_err(|_| "Invalid last seed".to_owned())?;
    let mut subject = subject_from(subject_arguments)?;
    let path = Path::new(directory).join(format!("tasks-{}-{first}-{last}.json", subject.name()));
    if path.exists() {
        return Err(format!("Refusing to overwrite {}", path.display()));
    }
    let mut summary = Summary::default();
    for seed in first..last {
        let agenda = generate(seed);
        summary.record(&agenda, check_seed(subject.as_mut(), seed)?);
    }
    let mut document = summary.document();
    if let Some(fields) = document.as_object_mut() {
        fields.insert("subject".to_owned(), json!(subject.name()));
    }
    std::fs::create_dir_all(directory).map_err(|error| error.to_string())?;
    std::fs::write(&path, document.to_string()).map_err(|error| error.to_string())?;
    if summary.divergent_seeds().is_empty() {
        Ok(())
    } else {
        Err(format!("Divergent seeds: {:?}", summary.divergent_seeds()))
    }
}
