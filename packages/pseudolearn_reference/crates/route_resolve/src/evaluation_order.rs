use crate::RouteContext;
use crate::evaluation::{edition_code, reference_cases};
use crate::exercise::ExerciseParts;
use crate::ordering::shuffled_order;
use reference_model::{Evaluation, ExerciseDocument, RouteFence};
use reference_resolve::resolve_runs;
use std::collections::BTreeMap;

pub fn order(
    context: &RouteContext<'_>,
    document: &ExerciseDocument,
    parts: &ExerciseParts,
) -> Evaluation {
    if let Some(RouteFence::Steps(steps)) = parts.fence("pasos") {
        let order = shuffled_order(&document.header.id, steps.len());
        let shuffled = order
            .iter()
            .filter_map(|position| steps.get(*position))
            .map(|step| resolve_runs(context.resolution, step))
            .collect();
        let solution = restoring_order(&order);
        return Evaluation::OrderSteps {
            steps: shuffled,
            solution,
        };
    }
    let code = parts
        .program("referencia")
        .map(|program| edition_code(context, program))
        .unwrap_or_default();
    let (head, blocks, tail) = program_blocks(&code);
    let order = shuffled_order(&document.header.id, blocks.len());
    Evaluation::OrderProgram {
        head,
        tail,
        blocks: order
            .iter()
            .filter_map(|position| blocks.get(*position).cloned())
            .collect(),
        solution: restoring_order(&order),
        cases: reference_cases(context, parts, "casos"),
    }
}

fn restoring_order(order: &[usize]) -> Vec<usize> {
    (0..order.len())
        .filter_map(|wanted| order.iter().position(|position| *position == wanted))
        .collect()
}

pub fn program_blocks(code: &str) -> (String, Vec<String>, String) {
    let lines: Vec<String> = code
        .lines()
        .map(str::trim)
        .filter(|line| !line.is_empty())
        .map(str::to_owned)
        .collect();
    match lines.split_first() {
        Some((head, rest)) => match rest.split_last() {
            Some((tail, middle)) => (head.clone(), middle.to_vec(), tail.clone()),
            None => (head.clone(), Vec::new(), String::new()),
        },
        None => (String::new(), Vec::new(), String::new()),
    }
}

pub fn assertions(parts: &ExerciseParts) -> Vec<BTreeMap<String, String>> {
    let Some(RouteFence::Assertions(assertions)) = parts.fence("aserciones") else {
        return Vec::new();
    };
    assertions
        .iter()
        .map(|assertion| {
            let keys = assertion_keys(&assertion.kind);
            let mut published: BTreeMap<String, String> = keys
                .iter()
                .zip(assertion.fields.iter())
                .map(|(key, value)| ((*key).to_owned(), value.clone()))
                .collect();
            published.insert("kind".to_owned(), assertion.kind.clone());
            published.insert("requirement".to_owned(), assertion.requirement.clone());
            published
        })
        .collect()
}

pub fn assertion_keys(kind: &str) -> &'static [&'static str] {
    match kind {
        "contiene" | "no-contiene" => &["construct"],
        "declara-subprograma" => &["name", "arity"],
        "declara-miembro" => &["class", "member", "visibility"],
        "repite-como-mucho" => &["construct", "max"],
        _ => &[],
    }
}
