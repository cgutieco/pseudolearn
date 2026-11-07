use crate::route_mix::fence;
use crate::route_normalize::{outputs_match, values_match};
use reference_model::{
    ExerciseCheck, ExerciseDocument, ExerciseKind, LapCheck, RoleRuns, RouteFence, RuleId,
    RunRecord, SourceBlock, Violation,
};

pub fn passes(record: &RunRecord) -> bool {
    record.completed()
        && record
            .expected
            .as_deref()
            .is_some_and(|expected| outputs_match(expected, &record.output))
}

pub fn check_exercise_runs(check: &ExerciseCheck) -> Vec<Violation> {
    let problems = match check.kind {
        ExerciseKind::Solve | ExerciseKind::Order => reference_passes(check),
        ExerciseKind::FindError => with_reference(check, |check| initial_fails(check, false)),
        ExerciseKind::Modify => with_reference(check, |check| initial_fails(check, true)),
        ExerciseKind::Break => with_reference(check, breaks),
        ExerciseKind::DesignTests => designed(check),
        ExerciseKind::Trace => check.laps.as_ref().map(laps).unwrap_or_else(|| {
            vec!["a trace exercise needs an object program and a `vueltas` block".to_owned()]
        }),
        _ => Vec::new(),
    };
    problems
        .into_iter()
        .map(|detail| {
            Violation::new(
                RuleId::RouteExerciseVerified,
                check.location.clone(),
                detail,
            )
        })
        .collect()
}

fn with_reference(check: &ExerciseCheck, rest: fn(&ExerciseCheck) -> Vec<String>) -> Vec<String> {
    let mut problems = reference_passes(check);
    problems.extend(rest(check));
    problems
}

fn reference_passes(check: &ExerciseCheck) -> Vec<String> {
    let Some(reference) = check.role("referencia") else {
        if check.kind == ExerciseKind::Order {
            return Vec::new();
        }
        return vec!["the exercise has no reference program".to_owned()];
    };
    reference
        .cases
        .iter()
        .chain(reference.solution.iter())
        .filter(|record| !passes(record))
        .map(|record| {
            format!(
                "the reference fails the case {:?}: wrote {:?} ({})",
                record.inputs, record.output, record.termination
            )
        })
        .collect()
}

fn initial_fails(check: &ExerciseCheck, hidden_only: bool) -> Vec<String> {
    let Some(initial) = check.role("inicial") else {
        return vec!["the exercise has no initial program".to_owned()];
    };
    let fails = initial
        .cases
        .iter()
        .filter(|record| !hidden_only || record.hidden)
        .any(|record| !passes(record));
    if fails {
        return Vec::new();
    }
    vec!["the initial program already passes every case: there is nothing to fix".to_owned()]
}

fn breaks(check: &ExerciseCheck) -> Vec<String> {
    let (Some(defective), Some(reference)) = (check.role("defectuoso"), check.role("referencia"))
    else {
        return vec!["a break exercise needs a defective and a reference program".to_owned()];
    };
    let mut problems: Vec<String> = defective
        .cases
        .iter()
        .filter(|record| !passes(record))
        .map(|record| {
            format!(
                "the defective program fails the visible case {:?}",
                record.inputs
            )
        })
        .collect();
    if defective.breakers.is_empty() {
        problems.push("the exercise lists no breaking input".to_owned());
    }
    for (broken, good) in defective.breakers.iter().zip(reference.breakers.iter()) {
        let differs = !broken.completed() && good.completed()
            || broken.completed()
                && good.completed()
                && !outputs_match(&good.output, &broken.output);
        if !differs {
            problems.push(format!(
                "the input {:?} does not break the program",
                broken.inputs
            ));
        }
    }
    problems
}

fn designed(check: &ExerciseCheck) -> Vec<String> {
    let mut problems = reference_passes(check);
    let mutants: Vec<&RoleRuns> = check.roles_named("mutante").collect();
    if mutants.len() < 3 {
        problems.push(format!(
            "has {} mutants instead of at least three",
            mutants.len()
        ));
    }
    for mutant in mutants {
        if mutant.solution.iter().all(passes) {
            problems.push(format!(
                "the solution cases do not catch the mutant `{}`",
                mutant.id
            ));
        }
    }
    problems
}

fn laps(check: &LapCheck) -> Vec<String> {
    let mut problems = Vec::new();
    if check.termination != "completed" {
        problems.push(format!("the traced program ended {}", check.termination));
    }
    if check.observed.len() != check.expected.len() {
        problems.push(format!(
            "the table has {} rows but the program printed {}",
            check.expected.len(),
            check.observed.len()
        ));
    }
    for (expected, observed) in check.expected.iter().zip(check.observed.iter()) {
        let cells: Vec<&str> = expected
            .cells
            .iter()
            .map(|cell| cell.trim_start_matches('?'))
            .collect();
        let same = cells.len() == observed.len()
            && cells
                .iter()
                .zip(observed.iter())
                .all(|(wanted, found)| values_match(wanted, found));
        if !same {
            problems.push(format!(
                "row {} promises {cells:?} but the program has {observed:?}",
                expected.label
            ));
        }
    }
    problems
}

pub fn check_exercise_shape(exercise: &ExerciseDocument) -> Vec<Violation> {
    let blocks = &exercise.blocks;
    let problems = match exercise.header.kind {
        ExerciseKind::Classify => classify_shape(blocks),
        ExerciseKind::Explain | ExerciseKind::Compare => choice_shape(blocks),
        ExerciseKind::Order => order_shape(blocks),
        ExerciseKind::Solve => solve_shape(blocks),
        _ => Vec::new(),
    };
    problems
        .into_iter()
        .map(|detail| Violation::new(RuleId::RouteExerciseVerified, exercise.path.clone(), detail))
        .collect()
}

fn classify_shape(blocks: &[SourceBlock]) -> Vec<String> {
    let (Some(RouteFence::Categories(categories)), Some(RouteFence::Elements(elements))) =
        (fence(blocks, "categorias"), fence(blocks, "elementos"))
    else {
        return vec!["a classify exercise needs `categorias` and `elementos`".to_owned()];
    };
    let mut problems: Vec<String> = elements
        .iter()
        .filter(|element| !categories.contains(&element.category))
        .map(|element| format!("the element category `{}` does not exist", element.category))
        .collect();
    for category in categories {
        if !elements.iter().any(|element| &element.category == category) {
            problems.push(format!("the category `{category}` has no element"));
        }
    }
    problems
}

fn choice_shape(blocks: &[SourceBlock]) -> Vec<String> {
    let Some(RouteFence::Choices(choices)) = fence(blocks, "opciones") else {
        return vec!["the exercise needs `opciones`".to_owned()];
    };
    let mut problems = Vec::new();
    let correct = choices.iter().filter(|choice| choice.correct).count();
    if correct != 1 {
        problems.push(format!("has {correct} correct options instead of one"));
    }
    if choices.iter().any(|choice| choice.justification.is_empty()) {
        problems.push("every option needs a justification".to_owned());
    }
    problems
}

fn order_shape(blocks: &[SourceBlock]) -> Vec<String> {
    if let Some(RouteFence::Steps(steps)) = fence(blocks, "pasos") {
        return (steps.len() < 3)
            .then(|| format!("has {} steps instead of at least three", steps.len()))
            .into_iter()
            .collect();
    }
    let lines = blocks
        .iter()
        .find_map(|block| match block {
            SourceBlock::Program(program) if program.role.as_deref() == Some("referencia") => Some(
                program
                    .code
                    .lines()
                    .filter(|line| !line.trim().is_empty())
                    .count(),
            ),
            _ => None,
        })
        .unwrap_or_default();
    (lines.saturating_sub(2) < 4)
        .then(|| "an ordering exercise needs at least four movable lines".to_owned())
        .into_iter()
        .collect()
}

fn solve_shape(blocks: &[SourceBlock]) -> Vec<String> {
    let Some(RouteFence::Cases(cases)) = fence(blocks, "casos") else {
        return vec!["a solve exercise needs `casos`".to_owned()];
    };
    let visible = cases.iter().filter(|case| !case.hidden).count();
    let hidden = cases.iter().filter(|case| case.hidden).count();
    let without_inputs = cases.iter().all(|case| case.inputs.is_empty());
    let enough = if without_inputs {
        visible >= 1
    } else {
        visible >= 2 && hidden >= 3
    };
    (!enough)
        .then(|| format!("has {visible} visible and {hidden} hidden cases"))
        .into_iter()
        .collect()
}
