use crate::book::Book;
use reference_model::{ExerciseKind, ExerciseLevel, Profile};
use std::collections::BTreeMap;

pub fn print_route_coverage(book: &Book) {
    let Some(edition) = book.route_editions.iter().find(|edition| {
        edition.language == Profile::Spanish && edition.profile == Profile::Spanish
    }) else {
        println!("route           no lessons");
        return;
    };
    println!("route lessons   {}", edition.lessons.len());
    for lesson in &edition.lessons {
        println!(
            "  {:<6} {:<28} terms {:>2}",
            lesson.number,
            lesson.id,
            lesson.introduces.len()
        );
    }
    let mut mix: BTreeMap<(ExerciseKind, ExerciseLevel), usize> = BTreeMap::new();
    for exercise in &edition.exercises {
        let counter = mix.entry((exercise.kind, exercise.level)).or_default();
        *counter = counter.saturating_add(1);
    }
    println!("route exercises {}", edition.exercises.len());
    for ((kind, level), count) in &mix {
        println!("  {kind:?} {level:?}: {count}");
    }
    let links = reference_export::spec_links(&edition.lessons, &edition.exercises);
    println!("route sections  {} linked", links.len());
    for (section, lessons) in &links {
        println!("  {section:<28} {}", lessons.join(", "));
    }
    let unlinked: Vec<&String> = edition
        .specification
        .keys()
        .filter(|section| !links.contains_key(*section))
        .collect();
    println!("route unlinked  {}", unlinked.len());
    for section in unlinked {
        println!("  unlinked {section}");
    }
}
