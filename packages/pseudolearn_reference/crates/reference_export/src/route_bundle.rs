use crate::manifest::digest;
use reference_model::{ExerciseLevel, LessonKind, PublishedExercise, PublishedLesson, Run};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::collections::{BTreeMap, BTreeSet};

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
#[serde(deny_unknown_fields)]
pub struct RoutePart {
    pub id: String,
    #[serde(rename = "numero")]
    pub number: String,
    #[serde(rename = "prefijo")]
    pub prefix: String,
    #[serde(rename = "titulo")]
    pub title: String,
    #[serde(rename = "lema")]
    pub motto: String,
    #[serde(rename = "resumen")]
    pub summary: String,
}

pub fn parse_route_parts(text: &str) -> Result<Vec<RoutePart>, String> {
    serde_json::from_str(text).map_err(|error| format!("invalid route parts file: {error}"))
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct RouteTerm {
    pub label: String,
    pub lesson: String,
    pub phrase: Vec<Run>,
}

pub struct RouteBundleInput<'input> {
    pub language: &'input str,
    pub profile: &'input str,
    pub engine: &'input str,
    pub specification: &'input str,
    pub parts: &'input [RoutePart],
    pub lessons: &'input [PublishedLesson],
    pub exercises: &'input [PublishedExercise],
    pub terms: &'input BTreeMap<String, RouteTerm>,
}

#[derive(Serialize)]
struct TocLesson<'toc> {
    id: &'toc str,
    number: &'toc str,
    kind: LessonKind,
    title: &'toc [Run],
    brief_problem: &'toc str,
    minutes: u32,
    levels: &'toc [ExerciseLevel],
    needs: Vec<&'toc str>,
    exercises: Vec<&'toc str>,
}

#[derive(Serialize)]
struct TocPart<'toc> {
    id: &'toc str,
    number: &'toc str,
    title: &'toc str,
    motto: &'toc str,
    summary: &'toc str,
    lessons: Vec<TocLesson<'toc>>,
}

#[derive(Serialize)]
struct RouteManifest<'manifest> {
    format: &'static str,
    language: &'manifest str,
    profile: &'manifest str,
    engine: &'manifest str,
    specification: &'manifest str,
    files: BTreeMap<String, String>,
}

pub const ROUTE_FORMAT: &str = "pseudolearn-route/1";

pub fn build_route_bundle(input: &RouteBundleInput<'_>) -> Result<crate::Bundle, String> {
    let mut files = BTreeMap::new();
    for lesson in input.lessons {
        files.insert(format!("lessons/{}.json", lesson.id), json(lesson)?);
    }
    for exercise in input.exercises {
        files.insert(format!("exercises/{}.json", exercise.id), json(exercise)?);
    }
    files.insert("toc.json".to_owned(), json(&toc(input))?);
    files.insert("terms.json".to_owned(), json(input.terms)?);
    files.insert(
        "spec-links.json".to_owned(),
        json(&spec_links(input.lessons, input.exercises))?,
    );
    let manifest = RouteManifest {
        format: ROUTE_FORMAT,
        language: input.language,
        profile: input.profile,
        engine: input.engine,
        specification: input.specification,
        files: files
            .iter()
            .map(|(path, text)| (path.clone(), digest(text)))
            .collect(),
    };
    files.insert("manifest.json".to_owned(), json(&manifest)?);
    Ok(crate::Bundle { files })
}

fn toc<'toc>(input: &'toc RouteBundleInput<'toc>) -> Vec<TocPart<'toc>> {
    input
        .parts
        .iter()
        .map(|part| TocPart {
            id: &part.id,
            number: &part.number,
            title: &part.title,
            motto: &part.motto,
            summary: &part.summary,
            lessons: input
                .lessons
                .iter()
                .filter(|lesson| lesson.part == part.prefix)
                .map(|lesson| toc_lesson(lesson, input.exercises))
                .collect(),
        })
        .collect()
}

fn toc_lesson<'toc>(
    lesson: &'toc PublishedLesson,
    exercises: &'toc [PublishedExercise],
) -> TocLesson<'toc> {
    TocLesson {
        id: &lesson.id,
        number: &lesson.number,
        kind: lesson.kind,
        title: &lesson.title,
        brief_problem: &lesson.brief_problem,
        minutes: lesson.minutes,
        levels: &lesson.levels,
        needs: lesson.needs.iter().map(|need| need.id.as_str()).collect(),
        exercises: exercises
            .iter()
            .filter(|exercise| exercise.lesson == lesson.id)
            .map(|exercise| exercise.id.as_str())
            .collect(),
    }
}

pub fn spec_links(
    lessons: &[PublishedLesson],
    exercises: &[PublishedExercise],
) -> BTreeMap<String, Vec<String>> {
    let mut links: BTreeMap<String, BTreeSet<String>> = BTreeMap::new();
    let lesson_values = lessons
        .iter()
        .map(|lesson| (lesson.id.as_str(), serde_json::to_value(lesson)));
    let exercise_values = exercises
        .iter()
        .map(|exercise| (exercise.lesson.as_str(), serde_json::to_value(exercise)));
    for (lesson, value) in lesson_values.chain(exercise_values) {
        let mut sections = BTreeSet::new();
        collect_sections(&value.unwrap_or(Value::Null), &mut sections);
        for section in sections {
            links.entry(section).or_default().insert(lesson.to_owned());
        }
    }
    links
        .into_iter()
        .map(|(section, lessons)| (section, lessons.into_iter().collect()))
        .collect()
}

fn collect_sections(value: &Value, sections: &mut BTreeSet<String>) {
    match value {
        Value::Object(map) => {
            let kind = map.get("type").and_then(Value::as_str);
            let names_section = matches!(kind, Some("spec_link" | "spec_figure"))
                || kind.is_none() && map.contains_key("section") && map.contains_key("number");
            if let (true, Some(section)) =
                (names_section, map.get("section").and_then(Value::as_str))
            {
                sections.insert(section.to_owned());
            }
            map.values()
                .for_each(|inner| collect_sections(inner, sections));
        }
        Value::Array(entries) => entries
            .iter()
            .for_each(|inner| collect_sections(inner, sections)),
        _ => {}
    }
}

fn json(value: &impl Serialize) -> Result<String, String> {
    serde_json::to_string(value)
        .map(|text| format!("{text}\n"))
        .map_err(|error| error.to_string())
}
