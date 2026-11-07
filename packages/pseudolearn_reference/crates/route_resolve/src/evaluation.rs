use crate::RouteContext;
use crate::exercise::ExerciseParts;
use crate::exercise_runs::{CaseSets, execute, lap_check, published_cases, role_runs};
use reference_model::{
    CaseSource, ChoiceEntry, ClassifiedElement, Evaluation, ExerciseCheck, ExerciseDocument,
    ExerciseKind, LapCell, LapRow, Profile, ProgramSource, RouteFence, SourceBlock,
};
use reference_resolve::{resolve_runs, target_code, with_final_newline};

pub fn reuse_fences(parts: &mut ExerciseParts, spanish: &ExerciseDocument) {
    for fence in &mut parts.fences {
        if !is_empty(fence) {
            continue;
        }
        let name = fence.name();
        let original = spanish.blocks.iter().find_map(|block| match block {
            SourceBlock::Route(candidate) if candidate.name() == name => Some(candidate.clone()),
            _ => None,
        });
        if let Some(original) = original {
            *fence = original;
        }
    }
}

fn is_empty(fence: &RouteFence) -> bool {
    match fence {
        RouteFence::Cases(cases) | RouteFence::Breakers(cases) => cases.is_empty(),
        RouteFence::SolutionCases { cases, .. } => cases.is_empty(),
        RouteFence::Laps(table) => table.rows.is_empty(),
        _ => false,
    }
}

pub fn cases<'parts>(parts: &'parts ExerciseParts, name: &str) -> &'parts [CaseSource] {
    match parts.fence(name) {
        Some(RouteFence::Cases(cases) | RouteFence::Breakers(cases)) => cases,
        Some(RouteFence::SolutionCases { cases, .. }) => cases,
        _ => &[],
    }
}

pub fn exercise_check(
    context: &RouteContext<'_>,
    document: &ExerciseDocument,
    parts: &ExerciseParts,
) -> Option<ExerciseCheck> {
    if context.resolution.profile != Profile::Spanish {
        return None;
    }
    let sets = CaseSets {
        cases: cases(parts, "casos"),
        breakers: cases(parts, "rompe"),
        solution: cases(parts, "casos-solucion"),
    };
    let laps = match (parts.fence("vueltas"), parts.program("objeto")) {
        (Some(RouteFence::Laps(table)), Some(program)) => {
            Some(lap_check(context, program, table, Profile::Spanish))
        }
        _ => None,
    };
    Some(ExerciseCheck {
        location: document.path.clone(),
        kind: document.header.kind,
        roles: parts
            .programs
            .iter()
            .filter(|program| program.role.as_deref() != Some("objeto"))
            .map(|program| role_runs(context, program, &sets))
            .collect(),
        laps,
    })
}

pub fn evaluation(
    context: &RouteContext<'_>,
    document: &ExerciseDocument,
    parts: &ExerciseParts,
) -> Evaluation {
    match document.header.kind {
        ExerciseKind::Predict => Evaluation::Predict {
            output: parts
                .program("objeto")
                .map(|program| visible_output(context, program))
                .unwrap_or_default(),
        },
        ExerciseKind::Trace => trace(context, parts),
        ExerciseKind::Order => crate::evaluation_order::order(context, document, parts),
        ExerciseKind::Break => break_evaluation(context, parts),
        ExerciseKind::DesignTests => design(context, parts),
        ExerciseKind::Classify => classify(context, parts),
        ExerciseKind::Explain | ExerciseKind::Compare => choice(context, parts),
        ExerciseKind::Solve | ExerciseKind::Modify | ExerciseKind::FindError => Evaluation::Cases {
            cases: reference_cases(context, parts, "casos"),
            assertions: crate::evaluation_order::assertions(parts),
        },
    }
}

fn visible_output(context: &RouteContext<'_>, program: &ProgramSource) -> String {
    execute(
        context,
        program,
        &program.inputs,
        context.resolution.profile,
    )
    .output
    .trim_end_matches('\n')
    .to_owned()
}

pub fn reference_cases(
    context: &RouteContext<'_>,
    parts: &ExerciseParts,
    name: &str,
) -> Vec<reference_model::PublishedCase> {
    parts
        .program("referencia")
        .map(|reference| published_cases(context, reference, cases(parts, name)))
        .unwrap_or_default()
}

pub fn edition_code(context: &RouteContext<'_>, program: &ProgramSource) -> String {
    target_code(context.resolution, &with_final_newline(&program.code))
}

fn trace(context: &RouteContext<'_>, parts: &ExerciseParts) -> Evaluation {
    let (Some(RouteFence::Laps(table)), Some(program)) =
        (parts.fence("vueltas"), parts.program("objeto"))
    else {
        return Evaluation::Trace {
            columns: Vec::new(),
            rows: Vec::new(),
        };
    };
    let observed = lap_check(context, program, table, context.resolution.profile).observed;
    let rows = table
        .rows
        .iter()
        .zip(observed)
        .map(|(source, values)| LapRow {
            label: source.label.clone(),
            cells: values
                .into_iter()
                .zip(source.cells.iter())
                .map(|(value, cell)| LapCell {
                    value,
                    editable: cell.starts_with('?'),
                })
                .collect(),
        })
        .collect();
    Evaluation::Trace {
        columns: table.columns.clone(),
        rows,
    }
}

fn reads(parts: &ExerciseParts) -> usize {
    cases(parts, "casos")
        .iter()
        .map(|case| case.inputs.len())
        .max()
        .unwrap_or_default()
}

fn break_evaluation(context: &RouteContext<'_>, parts: &ExerciseParts) -> Evaluation {
    let code = |role: &str| {
        parts
            .program(role)
            .map(|program| edition_code(context, program))
            .unwrap_or_default()
    };
    Evaluation::Break {
        defective: code("defectuoso"),
        reference: code("referencia"),
        reads: reads(parts),
        cases: reference_cases(context, parts, "casos"),
    }
}

fn design(context: &RouteContext<'_>, parts: &ExerciseParts) -> Evaluation {
    let (minimum, maximum) = match parts.fence("casos-solucion") {
        Some(RouteFence::SolutionCases {
            minimum, maximum, ..
        }) => (*minimum, *maximum),
        _ => (0, 0),
    };
    let solution_reads = cases(parts, "casos-solucion")
        .iter()
        .map(|case| case.inputs.len())
        .max()
        .unwrap_or_default();
    Evaluation::DesignTests {
        reference: parts
            .program("referencia")
            .map(|program| edition_code(context, program))
            .unwrap_or_default(),
        mutants: parts
            .programs
            .iter()
            .filter(|program| program.role.as_deref() == Some("mutante"))
            .map(|program| edition_code(context, program))
            .collect(),
        reads: reads(parts).max(solution_reads),
        minimum,
        maximum,
    }
}

fn classify(context: &RouteContext<'_>, parts: &ExerciseParts) -> Evaluation {
    let categories = match parts.fence("categorias") {
        Some(RouteFence::Categories(categories)) => categories.clone(),
        _ => Vec::new(),
    };
    let elements = match parts.fence("elementos") {
        Some(RouteFence::Elements(elements)) => elements
            .iter()
            .map(|element| ClassifiedElement {
                runs: resolve_runs(context.resolution, &element.text),
                category: categories
                    .iter()
                    .position(|category| *category == element.category)
                    .unwrap_or(usize::MAX),
            })
            .collect(),
        _ => Vec::new(),
    };
    Evaluation::Classify {
        categories,
        elements,
    }
}

fn choice(context: &RouteContext<'_>, parts: &ExerciseParts) -> Evaluation {
    let options = match parts.fence("opciones") {
        Some(RouteFence::Choices(choices)) => choices
            .iter()
            .map(|choice| ChoiceEntry {
                runs: resolve_runs(context.resolution, &choice.text),
                justification: resolve_runs(context.resolution, &choice.justification),
                correct: choice.correct,
            })
            .collect(),
        _ => Vec::new(),
    };
    Evaluation::Choice { options }
}
