use reference_export::{
    ROUTE_FORMAT, RouteBundleInput, RoutePart, RouteTerm, build_route_bundle, spec_links,
};
use reference_model::{
    Evaluation, ExerciseKind, ExerciseLevel, LessonBlock, LessonKind, PublishedCase,
    PublishedExercise, PublishedLesson, RouteBlock, Run, SectionLink,
};
use serde_json::Value;
use std::collections::BTreeMap;

fn lesson() -> PublishedLesson {
    PublishedLesson {
        id: "inicio.base".to_owned(),
        number: "0.1".to_owned(),
        part: "inicio".to_owned(),
        kind: LessonKind::Lesson,
        title: vec![Run::Text {
            text: "Base".to_owned(),
        }],
        minutes: 10,
        levels: vec![ExerciseLevel::Seed],
        needs: Vec::new(),
        introduces: Vec::new(),
        brief_problem: "Algo".to_owned(),
        previous: None,
        next: None,
        blocks: vec![
            LessonBlock::Route(RouteBlock::SpecLinks {
                links: vec![SectionLink {
                    section: "control.si".to_owned(),
                    number: "6.1".to_owned(),
                    title: "Si".to_owned(),
                }],
            }),
            LessonBlock::Route(RouteBlock::Cycle { phases: vec![1, 2] }),
        ],
    }
}

fn exercise() -> PublishedExercise {
    PublishedExercise {
        id: "inicio.base.uno".to_owned(),
        lesson: "inicio.base".to_owned(),
        kind: ExerciseKind::Solve,
        level: ExerciseLevel::Seed,
        required: true,
        title: Vec::new(),
        statement: Vec::new(),
        restriction: Vec::new(),
        hints: vec![vec![Run::SpecLink {
            section: "control.mientras".to_owned(),
            anchor: None,
            text: "x".to_owned(),
        }]],
        variant: Vec::new(),
        explanation: Vec::new(),
        teachers: Vec::new(),
        program: None,
        starter_code: None,
        evaluation: Evaluation::Cases {
            cases: vec![PublishedCase {
                inputs: vec!["1".to_owned()],
                expected: "1".to_owned(),
                hidden: false,
            }],
            assertions: Vec::new(),
        },
    }
}

fn bundle() -> BTreeMap<String, Value> {
    let parts = vec![RoutePart {
        id: "parte-inicio".to_owned(),
        number: "0".to_owned(),
        prefix: "inicio".to_owned(),
        title: "Empezar".to_owned(),
        motto: String::new(),
        summary: "Resumen".to_owned(),
    }];
    let terms = BTreeMap::from([(
        "problema".to_owned(),
        RouteTerm {
            label: "problema".to_owned(),
            lesson: "inicio.base".to_owned(),
            phrase: Vec::new(),
        },
    )]);
    let built = build_route_bundle(&RouteBundleInput {
        language: "es",
        profile: "es",
        engine: "motor",
        specification: "huella",
        parts: &parts,
        lessons: &[lesson()],
        exercises: &[exercise()],
        terms: &terms,
    });
    assert!(built.is_ok());
    built
        .map(|bundle| {
            bundle
                .files
                .into_iter()
                .map(|(path, text)| (path, serde_json::from_str(&text).unwrap_or(Value::Null)))
                .collect()
        })
        .unwrap_or_default()
}

fn schema() -> Value {
    let path = format!(
        "{}/../../schemas/route-bundle.schema.json",
        env!("CARGO_MANIFEST_DIR")
    );
    serde_json::from_str(&std::fs::read_to_string(path).unwrap_or_default()).unwrap_or(Value::Null)
}

fn valid(root: &Value, schema: &Value, value: &Value) -> Result<(), String> {
    if let Some(reference) = schema.get("$ref").and_then(Value::as_str) {
        let name = reference.trim_start_matches("#/$defs/");
        let target = root
            .get("$defs")
            .and_then(|defs| defs.get(name))
            .unwrap_or(&Value::Null);
        return valid(root, target, value);
    }
    if let Some(options) = schema.get("enum").and_then(Value::as_array) {
        return options
            .contains(value)
            .then_some(())
            .ok_or_else(|| format!("{value} is not one of {options:?}"));
    }
    match schema.get("type").and_then(Value::as_str) {
        Some("object") => valid_object(root, schema, value),
        Some("array") => {
            let entries = value
                .as_array()
                .ok_or_else(|| format!("{value} is not an array"))?;
            let entry_schema = schema.get("items").unwrap_or(&Value::Null);
            entries
                .iter()
                .try_for_each(|entry| valid(root, entry_schema, entry))
        }
        Some("string") => value
            .is_string()
            .then_some(())
            .ok_or_else(|| format!("{value} is not a string")),
        Some("integer") => value
            .is_u64()
            .then_some(())
            .ok_or_else(|| format!("{value} is not an integer")),
        Some("boolean") => value
            .is_boolean()
            .then_some(())
            .ok_or_else(|| format!("{value} is not a boolean")),
        _ => Ok(()),
    }
}

fn valid_object(root: &Value, schema: &Value, value: &Value) -> Result<(), String> {
    let map = value
        .as_object()
        .ok_or_else(|| format!("{value} is not an object"))?;
    for key in schema
        .get("required")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
    {
        let key = key.as_str().unwrap_or_default();
        if !map.contains_key(key) {
            return Err(format!("missing `{key}`"));
        }
    }
    let properties = schema.get("properties").and_then(Value::as_object);
    for (key, inner) in map {
        match (
            properties.and_then(|known| known.get(key)),
            schema.get("additionalProperties"),
        ) {
            (Some(property), _) | (None, Some(property)) => valid(root, property, inner)?,
            (None, None) => {}
        }
    }
    Ok(())
}

fn definition<'schema>(root: &'schema Value, name: &str) -> &'schema Value {
    root.get("$defs")
        .and_then(|defs| defs.get(name))
        .unwrap_or(&Value::Null)
}

#[test]
fn every_route_file_follows_the_schema() {
    let root = schema();
    let files = bundle();
    assert_eq!(files.len(), 6);
    for (path, value) in &files {
        let expected = match path.as_str() {
            "toc.json" => definition(&root, "toc"),
            "terms.json" => definition(&root, "terms"),
            "spec-links.json" => definition(&root, "specLinks"),
            "manifest.json" => definition(&root, "manifest"),
            other if other.starts_with("exercises/") => definition(&root, "exercise"),
            _ => &root,
        };
        assert_eq!(valid(&root, expected, value), Ok(()), "{path}");
    }
    assert_eq!(
        files
            .get("manifest.json")
            .and_then(|manifest| manifest.get("format")),
        Some(&Value::String(ROUTE_FORMAT.to_owned()))
    );
}

#[test]
fn the_schema_rejects_an_unknown_block_or_a_missing_field() {
    let root = schema();
    let mut broken = serde_json::to_value(lesson()).unwrap_or(Value::Null);
    if let Some(map) = broken.as_object_mut() {
        map.insert(
            "blocks".to_owned(),
            serde_json::json!([{"type": "pelicula"}]),
        );
    }
    assert!(valid(&root, &root, &broken).is_err());
    let mut incomplete = serde_json::to_value(exercise()).unwrap_or(Value::Null);
    if let Some(map) = incomplete.as_object_mut() {
        map.remove("evaluation");
    }
    assert!(valid(&root, definition(&root, "exercise"), &incomplete).is_err());
}

#[test]
fn reverse_links_come_from_lessons_and_their_exercises() {
    let links = spec_links(&[lesson()], &[exercise()]);
    assert_eq!(
        links.keys().cloned().collect::<Vec<String>>(),
        vec!["control.mientras".to_owned(), "control.si".to_owned()]
    );
    assert_eq!(
        links.get("control.si"),
        Some(&vec!["inicio.base".to_owned()])
    );
}
