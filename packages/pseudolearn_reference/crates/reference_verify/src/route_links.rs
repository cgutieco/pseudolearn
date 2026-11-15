use reference_model::{Block, PublishedSection, RuleId, Violation};
use serde::Serialize;
use serde_json::Value;
use std::collections::{BTreeMap, BTreeSet};

pub struct LinkTargets<'targets> {
    pub sections: &'targets BTreeMap<String, PublishedSection>,
    pub lessons: BTreeSet<String>,
}

pub fn check_route_links(
    location: &str,
    published: &impl Serialize,
    targets: &LinkTargets<'_>,
) -> Vec<Violation> {
    let value = serde_json::to_value(published).unwrap_or(Value::Null);
    let mut found = Vec::new();
    collect_links(&value, &mut found);
    found
        .into_iter()
        .filter_map(|link| problem(&link, targets))
        .map(|(rule, detail)| Violation::new(rule, location, detail))
        .collect()
}

fn collect_links(value: &Value, found: &mut Vec<Value>) {
    match value {
        Value::Object(map) => {
            let kind = map.get("type").and_then(Value::as_str);
            if matches!(kind, Some("spec_link" | "lesson_link")) {
                found.push(value.clone());
            }
            map.values().for_each(|inner| collect_links(inner, found));
        }
        Value::Array(entries) => entries.iter().for_each(|inner| collect_links(inner, found)),
        _ => {}
    }
}

fn problem(link: &Value, targets: &LinkTargets<'_>) -> Option<(RuleId, String)> {
    let text = |key: &str| link.get(key).and_then(Value::as_str).unwrap_or_default();
    if link.get("type").and_then(Value::as_str) == Some("lesson_link") {
        let lesson = text("lesson");
        return (!targets.lessons.contains(lesson)).then(|| {
            (
                RuleId::RouteLinkValid,
                format!("link to unknown lesson `{lesson}`"),
            )
        });
    }
    let section = text("section");
    let Some(published) = targets.sections.get(section) else {
        return Some((
            RuleId::RouteSpecLink,
            format!("link to unknown section `{section}`"),
        ));
    };
    let anchor = link.get("anchor").and_then(Value::as_str)?;
    let known = published
        .blocks
        .iter()
        .any(|block| matches!(block, Block::Heading { id, .. } if id == anchor));
    (!known).then(|| {
        (
            RuleId::RouteSpecLink,
            format!("section `{section}` has no anchor `{anchor}`"),
        )
    })
}
