use crate::RouteContext;
use crate::lesson_blocks::lesson_blocks;
use crate::zones::list_entries;
use reference_model::{
    CalloutKind, ExampleCheck, ExerciseCheck, ExerciseDocument, LessonBlock, ProgramSource,
    PublishedExercise, RouteFence, RuleId, SourceBlock, Violation,
};
use reference_resolve::{Collector, SpanishReuse, program_block, resolve_runs};
use std::collections::BTreeMap;

#[derive(Clone, Debug)]
pub struct ResolvedExercise {
    pub exercise: PublishedExercise,
    pub check: Option<ExerciseCheck>,
    pub examples: Vec<ExampleCheck>,
    pub violations: Vec<Violation>,
}

#[derive(Clone, Debug, Default)]
pub struct ExerciseParts {
    pub callouts: BTreeMap<CalloutKind, Vec<SourceBlock>>,
    pub programs: Vec<ProgramSource>,
    pub fences: Vec<RouteFence>,
}

impl ExerciseParts {
    pub fn fence(&self, name: &str) -> Option<&RouteFence> {
        self.fences.iter().find(|fence| fence.name() == name)
    }

    pub fn program(&self, role: &str) -> Option<&ProgramSource> {
        self.programs
            .iter()
            .find(|program| program.role.as_deref() == Some(role))
    }
}

pub fn resolve_exercise(
    context: &RouteContext<'_>,
    document: &ExerciseDocument,
    spanish: Option<&ExerciseDocument>,
    reuse: &SpanishReuse,
) -> ResolvedExercise {
    let mut collector = Collector {
        location: document.path.clone(),
        section_number: document.header.id.clone(),
        reuse,
        violations: Vec::new(),
        examples: Vec::new(),
        figures: 0,
        headings: 0,
        forms: 0,
        programs: BTreeMap::new(),
    };
    let parts = gather(&mut collector, document, spanish);
    let exercise = publish(context, &mut collector, document, &parts);
    let check = crate::evaluation::exercise_check(context, document, &parts);
    ResolvedExercise {
        exercise,
        check,
        examples: collector.examples,
        violations: collector.violations,
    }
}

fn gather(
    collector: &mut Collector<'_>,
    document: &ExerciseDocument,
    spanish: Option<&ExerciseDocument>,
) -> ExerciseParts {
    let mut parts = ExerciseParts::default();
    for block in &document.blocks {
        match block {
            SourceBlock::Callout { kind, blocks, .. } => {
                parts.callouts.insert(*kind, blocks.clone());
            }
            SourceBlock::Program(program) => parts.programs.push(effective(collector, program)),
            SourceBlock::Route(fence) => parts.fences.push(fence.clone()),
            _ => collector.report(
                RuleId::RouteFormat,
                "an exercise only holds boxes, programs and data blocks",
            ),
        }
    }
    if let Some(spanish) = spanish {
        crate::evaluation::reuse_fences(&mut parts, spanish);
    }
    parts
}

fn effective(collector: &mut Collector<'_>, written: &ProgramSource) -> ProgramSource {
    if !written.code.trim().is_empty() {
        return written.clone();
    }
    match collector.reuse.programs.get(&written.id) {
        Some(reused) => reused.clone(),
        None => {
            collector.report(
                RuleId::RouteFormat,
                format!("program `{}` has no Spanish source to reuse", written.id),
            );
            written.clone()
        }
    }
}

fn publish(
    context: &RouteContext<'_>,
    collector: &mut Collector<'_>,
    document: &ExerciseDocument,
    parts: &ExerciseParts,
) -> PublishedExercise {
    let header = &document.header;
    let mut section = |kind: CalloutKind| -> Vec<LessonBlock> {
        let blocks = parts.callouts.get(&kind).cloned().unwrap_or_default();
        lesson_blocks(context, collector, &blocks)
    };
    let statement = section(CalloutKind::Statement);
    let restriction = section(CalloutKind::Restriction);
    let variant = section(CalloutKind::Variant);
    let explanation = section(CalloutKind::Explanation);
    let hints = hints(context, parts);
    check_translated_order(context, collector, header.kind, parts);
    PublishedExercise {
        id: header.id.clone(),
        lesson: header.lesson.clone(),
        kind: header.kind,
        level: header.level,
        required: header.required,
        title: resolve_runs(context.resolution, &document.title),
        statement,
        restriction,
        hints,
        variant,
        explanation,
        program: visible_program(context, collector, parts),
        starter_code: parts
            .program("inicial")
            .map(|program| crate::evaluation::edition_code(context, program)),
        evaluation: crate::evaluation::evaluation(context, document, parts),
    }
}

fn hints(context: &RouteContext<'_>, parts: &ExerciseParts) -> Vec<Vec<reference_model::Run>> {
    parts
        .callouts
        .get(&CalloutKind::Hints)
        .map(|blocks| {
            list_entries(blocks)
                .into_iter()
                .map(|entry| resolve_runs(context.resolution, entry))
                .collect()
        })
        .unwrap_or_default()
}

fn visible_program(
    context: &RouteContext<'_>,
    collector: &mut Collector<'_>,
    parts: &ExerciseParts,
) -> Option<reference_model::ProgramBlock> {
    if let Some(shown) = parts.program("objeto") {
        return program_block(context.resolution, collector, shown);
    }
    let mut shown = parts
        .program("inicial")
        .or_else(|| parts.program("defectuoso"))?
        .clone();
    shown.execute = false;
    program_block(context.resolution, collector, &shown)
}

fn check_translated_order(
    context: &RouteContext<'_>,
    collector: &mut Collector<'_>,
    kind: reference_model::ExerciseKind,
    parts: &ExerciseParts,
) {
    let Some(reference) = parts.program("referencia") else {
        return;
    };
    if kind != reference_model::ExerciseKind::Order || parts.fence("pasos").is_some() {
        return;
    }
    let spanish = crate::program_blocks(&reference.code).1.len();
    let translated = crate::program_blocks(&crate::evaluation::edition_code(context, reference))
        .1
        .len();
    if spanish != translated {
        collector.report(
            RuleId::RouteExerciseVerified,
            format!("the translated program has {translated} movable lines instead of {spanish}"),
        );
    }
}
