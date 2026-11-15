use reference_model::{ExerciseDocument, LessonDocument, TermDefinition};
use std::collections::BTreeMap;

pub struct RouteBook<'book> {
    pub lessons: &'book [LessonDocument],
    pub exercises: &'book [ExerciseDocument],
    pub terms: &'book BTreeMap<String, TermDefinition>,
}

impl RouteBook<'_> {
    pub fn position(&self, lesson: &str) -> Option<usize> {
        self.lessons
            .iter()
            .position(|document| document.header.id == lesson)
    }

    pub fn owner(&self, term: &str) -> Option<usize> {
        self.lessons
            .iter()
            .position(|document| document.header.introduces.iter().any(|owned| owned == term))
    }

    pub fn exercises_of<'this>(
        &'this self,
        lesson: &'this str,
    ) -> impl Iterator<Item = &'this ExerciseDocument> + 'this {
        self.exercises
            .iter()
            .filter(move |exercise| exercise.header.lesson == lesson)
    }
}
