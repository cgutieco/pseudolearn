use crate::pg_tasks_agendas::{Agenda, generate};
use crate::pg_tasks_compare::{Observation, against_expected, differences, observe};
use crate::pg_tasks_summary::Summary;
use pseudolearn_api::{ExecuteRequest, execute_program};
use serde_json::Value;
use std::path::Path;

fn request(agenda: &Agenda) -> ExecuteRequest {
    ExecuteRequest {
        program: agenda.program.clone(),
        host: agenda.host.clone(),
        gc_stress: agenda.gc_stress,
        ..Default::default()
    }
}

pub fn live(agenda: &Agenda) -> Observation {
    observe(&execute_program(&request(agenda)))
}

pub fn replayed(agenda: &Agenda, tape: &Value) -> Observation {
    let mut replay = request(agenda);
    replay.execution_mode = Some("replay_from_tape".to_owned());
    replay.effect_tape = Some(tape.clone());
    observe(&execute_program(&replay))
}

pub fn check_seed(seed: u64) -> Vec<String> {
    let agenda = generate(seed);
    let first = live(&agenda);
    let mut found = against_expected(&agenda, &first);
    found.extend(differences("repeated live", &first, &live(&agenda)));
    if first.kind == "completed"
        && let Some(tape) = &first.tape
    {
        let second = replayed(&agenda, tape);
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
    found
}

pub fn collect(arguments: &[String]) -> Result<(), String> {
    let [directory, first, last] = arguments else {
        return Err("Usage: pg-tasks <directory> <first-seed> <last-seed>".to_owned());
    };
    let first: u64 = first.parse().map_err(|_| "Invalid first seed".to_owned())?;
    let last: u64 = last.parse().map_err(|_| "Invalid last seed".to_owned())?;
    let mut summary = Summary::default();
    for seed in first..last {
        let agenda = generate(seed);
        summary.record(&agenda, check_seed(seed));
    }
    let path = Path::new(directory).join(format!("tasks-{first}-{last}.json"));
    if path.exists() {
        return Err(format!("Refusing to overwrite {}", path.display()));
    }
    std::fs::create_dir_all(directory).map_err(|error| error.to_string())?;
    std::fs::write(&path, summary.document().to_string()).map_err(|error| error.to_string())?;
    if summary.divergent_seeds().is_empty() {
        Ok(())
    } else {
        Err(format!("Divergent seeds: {:?}", summary.divergent_seeds()))
    }
}
