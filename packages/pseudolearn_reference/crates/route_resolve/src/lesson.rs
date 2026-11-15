use crate::RouteContext;
use crate::lesson_blocks::lesson_blocks;
use reference_model::{
    ExampleCheck, LessonDocument, LessonReference, PublishedLesson, TermEntry, Violation,
};
use reference_resolve::{Collector, SpanishReuse, resolve_runs};
use std::collections::BTreeMap;

#[derive(Clone, Debug)]
pub struct ResolvedLesson {
    pub lesson: PublishedLesson,
    pub examples: Vec<ExampleCheck>,
    pub violations: Vec<Violation>,
}

pub fn resolve_lesson(
    context: &RouteContext<'_>,
    document: &LessonDocument,
    reuse: &SpanishReuse,
) -> ResolvedLesson {
    let mut collector = Collector {
        location: document.path.clone(),
        section_number: document.header.number.clone(),
        reuse,
        violations: Vec::new(),
        examples: Vec::new(),
        figures: 0,
        headings: 0,
        forms: 0,
        programs: BTreeMap::new(),
    };
    let blocks = lesson_blocks(context, &mut collector, &document.blocks);
    let (previous, next) = context.catalog.neighbours(&document.header.id);
    let header = &document.header;
    ResolvedLesson {
        lesson: PublishedLesson {
            id: header.id.clone(),
            number: header.number.clone(),
            part: part_of(&header.id),
            kind: header.kind,
            title: resolve_runs(context.resolution, &document.title),
            minutes: header.minutes,
            levels: levels(context, &header.id),
            needs: references(context, &header.needs),
            introduces: terms(context, &header.introduces),
            brief_problem: header.brief_problem.clone(),
            previous: previous.cloned(),
            next: next.cloned(),
            blocks,
        },
        examples: collector.examples,
        violations: collector.violations,
    }
}

pub fn part_of(lesson: &str) -> String {
    lesson.split('.').next().unwrap_or(lesson).to_owned()
}

fn levels(context: &RouteContext<'_>, lesson: &str) -> Vec<reference_model::ExerciseLevel> {
    let mut levels: Vec<_> = context
        .catalog
        .exercises
        .values()
        .filter(|exercise| exercise.lesson == lesson)
        .map(|exercise| exercise.level)
        .collect();
    levels.sort();
    levels.dedup();
    levels
}

fn references(context: &RouteContext<'_>, lessons: &[String]) -> Vec<LessonReference> {
    lessons
        .iter()
        .filter_map(|lesson| context.catalog.lesson(lesson).cloned())
        .collect()
}

fn terms(context: &RouteContext<'_>, introduced: &[String]) -> Vec<TermEntry> {
    introduced
        .iter()
        .map(|term| TermEntry {
            id: term.clone(),
            label: context
                .catalog
                .labels
                .get(term)
                .cloned()
                .unwrap_or_default(),
        })
        .collect()
}
