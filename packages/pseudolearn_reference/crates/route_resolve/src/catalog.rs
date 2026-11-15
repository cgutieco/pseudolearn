use reference_format::summary_tags;
use reference_model::{
    CalloutKind, ExerciseDocument, ExerciseKind, ExerciseLevel, Inline, LessonDocument,
    LessonReference, SourceBlock, TermDefinition,
};
use std::collections::BTreeMap;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct TermCard {
    pub label: String,
    pub owner: LessonReference,
    pub summary: Vec<Inline>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ExerciseSummary {
    pub id: String,
    pub lesson: String,
    pub title: Vec<Inline>,
    pub kind: ExerciseKind,
    pub level: ExerciseLevel,
    pub required: bool,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct RouteCatalog {
    pub lessons: Vec<LessonReference>,
    pub labels: BTreeMap<String, String>,
    pub terms: BTreeMap<String, TermCard>,
    pub exercises: BTreeMap<String, ExerciseSummary>,
}

impl RouteCatalog {
    pub fn lesson(&self, identity: &str) -> Option<&LessonReference> {
        self.lessons.iter().find(|lesson| lesson.id == identity)
    }

    pub fn neighbours(
        &self,
        identity: &str,
    ) -> (Option<&LessonReference>, Option<&LessonReference>) {
        let position = self.lessons.iter().position(|lesson| lesson.id == identity);
        let previous = position
            .and_then(|index| index.checked_sub(1))
            .and_then(|index| self.lessons.get(index));
        let next = position
            .and_then(|index| index.checked_add(1))
            .and_then(|index| self.lessons.get(index));
        (previous, next)
    }
}

pub fn build_catalog(
    lessons: &[LessonDocument],
    exercises: &[ExerciseDocument],
    definitions: &BTreeMap<String, TermDefinition>,
) -> RouteCatalog {
    let mut catalog = RouteCatalog {
        labels: definitions
            .iter()
            .map(|(term, definition)| (term.clone(), definition.label.clone()))
            .collect(),
        ..RouteCatalog::default()
    };
    for lesson in lessons {
        let reference = LessonReference {
            id: lesson.header.id.clone(),
            number: lesson.header.number.clone(),
            title: lesson.header.title.replace('`', ""),
        };
        add_terms(&mut catalog, lesson, &reference);
        catalog.lessons.push(reference);
    }
    for exercise in exercises {
        catalog
            .exercises
            .insert(exercise.header.id.clone(), summary_of(exercise));
    }
    catalog
}

fn summary_of(exercise: &ExerciseDocument) -> ExerciseSummary {
    ExerciseSummary {
        id: exercise.header.id.clone(),
        lesson: exercise.header.lesson.clone(),
        title: exercise.title.clone(),
        kind: exercise.header.kind,
        level: exercise.header.level,
        required: exercise.header.required,
    }
}

fn add_terms(catalog: &mut RouteCatalog, lesson: &LessonDocument, owner: &LessonReference) {
    for entry in summary_entries(&lesson.blocks) {
        let (tags, text) = summary_tags(entry);
        for term in tags {
            if !lesson.header.introduces.contains(&term) {
                continue;
            }
            let label = catalog.labels.get(&term).cloned().unwrap_or_default();
            catalog.terms.insert(
                term,
                TermCard {
                    label,
                    owner: owner.clone(),
                    summary: text.clone(),
                },
            );
        }
    }
}

pub fn summary_entries(blocks: &[SourceBlock]) -> Vec<&[Inline]> {
    blocks
        .iter()
        .filter_map(|block| match block {
            SourceBlock::Callout {
                kind: CalloutKind::Summary,
                blocks,
                ..
            } => Some(blocks),
            _ => None,
        })
        .flatten()
        .flat_map(|block| match block {
            SourceBlock::List { entries, .. } => entries.iter().map(Vec::as_slice).collect(),
            _ => Vec::new(),
        })
        .collect()
}
