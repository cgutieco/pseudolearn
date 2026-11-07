use crate::workspace_files::{files_with_extension, read, relative};
use reference_export::{RoutePart, parse_route_parts};
use reference_model::{ExerciseDocument, LessonDocument, Profile, TermDefinition, Violation};
use std::collections::BTreeMap;
use std::path::Path;

#[derive(Default)]
pub struct RouteLanguage {
    pub lessons: Vec<LessonDocument>,
    pub exercises: Vec<ExerciseDocument>,
    pub parts: Vec<RoutePart>,
    pub terms: BTreeMap<String, TermDefinition>,
}

pub fn load_routes(
    root: &Path,
    violations: &mut Vec<Violation>,
) -> Result<BTreeMap<Profile, RouteLanguage>, String> {
    let mut routes = BTreeMap::new();
    for profile in Profile::all() {
        routes.insert(profile, load_route(root, profile, violations)?);
    }
    Ok(routes)
}

fn load_route(
    root: &Path,
    profile: Profile,
    violations: &mut Vec<Violation>,
) -> Result<RouteLanguage, String> {
    let directory = root.join("route").join(profile.code());
    if !directory.exists() {
        return Ok(RouteLanguage::default());
    }
    let mut language = RouteLanguage {
        parts: parse_route_parts(&read(&directory.join("partes.json"))?)?,
        terms: serde_json::from_str(&read(&directory.join("terminos.json"))?)
            .map_err(|error| format!("invalid route terms: {error}"))?,
        ..RouteLanguage::default()
    };
    for path in files_with_extension(&directory, "md")? {
        add_document(&mut language, (root, &path), violations)?;
    }
    language
        .lessons
        .sort_by(|left, right| left.path.cmp(&right.path));
    language
        .exercises
        .sort_by(|left, right| left.path.cmp(&right.path));
    Ok(language)
}

fn add_document(
    language: &mut RouteLanguage,
    (root, path): (&Path, &Path),
    violations: &mut Vec<Violation>,
) -> Result<(), String> {
    let location = relative(root, path);
    let text = read(path)?;
    let is_exercise = path
        .parent()
        .and_then(Path::file_name)
        .is_some_and(|name| name == "ejercicios");
    let outcome = if is_exercise {
        reference_format::parse_exercise(&location, &text)
            .map(|document| language.exercises.push(document))
    } else {
        reference_format::parse_lesson(&location, &text)
            .map(|document| language.lessons.push(document))
    };
    if let Err(violation) = outcome {
        violations.push(violation);
    }
    Ok(())
}
