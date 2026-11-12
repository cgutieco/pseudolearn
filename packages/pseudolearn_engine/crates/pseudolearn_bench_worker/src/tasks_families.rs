use crate::tasks_agendas::{Agenda, Expected, SplitMix64};
use crate::tasks_templates;
use serde_json::json;

const CAPACITIES: [u64; 4] = [1, 2, 8, 64];

fn agenda(seed: u64, family: u64, inputs: &[u64], expected: Expected) -> Agenda {
    Agenda {
        seed,
        family,
        program: template(family).to_owned(),
        inputs: inputs.iter().map(u64::to_string).collect(),
        host: None,
        gc_stress: false,
        expected,
    }
}

pub fn template(family: u64) -> &'static str {
    match family {
        0 => tasks_templates::FAN_OUT,
        1 => tasks_templates::PRODUCER_CONSUMER,
        2 => tasks_templates::SIBLING_FAILURE,
        3 => tasks_templates::STARVATION,
        4 => tasks_templates::READY_SELECTION,
        5 => tasks_templates::INJECTED_DEADLOCK,
        6 => tasks_templates::CONCURRENT_EFFECTS,
        _ => tasks_templates::SNAPSHOT_UNDER_COLLECTION,
    }
}

fn completed(output: String) -> Expected {
    Expected {
        output,
        termination: "completed",
    }
}

pub fn build(seed: u64, family: u64, random: &mut SplitMix64) -> Agenda {
    match family {
        0 => fan_out(seed, random),
        1 => producer_consumer(seed, random),
        2 => sibling_failure(seed, random),
        3 => starvation(seed, random),
        4 => ready_selection(seed, random),
        5 => injected_deadlock(seed, random),
        6 => concurrent_effects(seed, random),
        _ => snapshot_under_collection(seed, random),
    }
}

fn fan_out(seed: u64, random: &mut SplitMix64) -> Agenda {
    let tasks = random.between(1, 1000);
    let output = format!("{}end\n", "w\n".repeat(usize::try_from(tasks).unwrap_or(0)));
    agenda(seed, 0, &[tasks], completed(output))
}

fn producer_consumer(seed: u64, random: &mut SplitMix64) -> Agenda {
    let capacity = CAPACITIES
        .get(usize::try_from(random.below(4)).unwrap_or(0))
        .copied()
        .unwrap_or(1);
    let items = random.between(1, 200);
    let total: u64 = (1..=items).sum();
    agenda(seed, 1, &[capacity, items], completed(format!("{total}\n")))
}

fn sibling_failure(seed: u64, random: &mut SplitMix64) -> Agenda {
    let tasks = random.between(2, 20);
    let failing = random.between(1, tasks);
    let cancelled = tasks.saturating_sub(1);
    agenda(
        seed,
        2,
        &[tasks, failing],
        completed(format!("e{failing}\n{cancelled}\n")),
    )
}

fn starvation(seed: u64, random: &mut SplitMix64) -> Agenda {
    let rounds = random.between(1500, 4500);
    agenda(seed, 3, &[rounds], completed("alpha\nbeta\n".to_owned()))
}

fn ready_selection(seed: u64, random: &mut SplitMix64) -> Agenda {
    let branches = random.between(2, 4);
    let first_ready = random.below(branches);
    let winner = first_ready.saturating_add(1);
    agenda(
        seed,
        4,
        &[first_ready, branches],
        completed(format!("{winner}\n")),
    )
}

fn injected_deadlock(seed: u64, random: &mut SplitMix64) -> Agenda {
    let tasks = random.between(1, 5);
    agenda(
        seed,
        5,
        &[tasks],
        Expected {
            output: String::new(),
            termination: "taskDeadlock",
        },
    )
}

fn concurrent_effects(seed: u64, random: &mut SplitMix64) -> Agenda {
    let tasks = random.between(2, 6);
    let order = random.shuffled(tasks);
    let output: String = order.iter().map(|label| format!("{label}\n")).collect();
    let host = json!({"orden_entrega": order});
    Agenda {
        host: Some(host),
        ..agenda(seed, 6, &[tasks], completed(output))
    }
}

fn snapshot_under_collection(seed: u64, random: &mut SplitMix64) -> Agenda {
    let base = random.between(1, 100);
    let doubled = base.saturating_mul(2);
    Agenda {
        gc_stress: true,
        ..agenda(seed, 7, &[base], completed(format!("{doubled}\n")))
    }
}
