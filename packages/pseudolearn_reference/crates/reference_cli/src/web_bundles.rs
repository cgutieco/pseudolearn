use reference_export::Bundle;
use std::collections::BTreeMap;

const TABLE_OF_CONTENTS: &str = "toc.json";
const SPECIFICATION_PREFIXES: [&str; 1] = ["sections/"];
const ROUTE_PREFIXES: [&str; 2] = ["lessons/", "exercises/"];

pub fn web_editions(bundles: &BTreeMap<String, Bundle>) -> BTreeMap<String, Bundle> {
    profile_editions(bundles, &SPECIFICATION_PREFIXES)
}

pub fn web_route_editions(bundles: &BTreeMap<String, Bundle>) -> BTreeMap<String, Bundle> {
    profile_editions(bundles, &ROUTE_PREFIXES)
}

fn profile_editions(
    bundles: &BTreeMap<String, Bundle>,
    prefixes: &[&str],
) -> BTreeMap<String, Bundle> {
    bundles
        .iter()
        .filter_map(|(edition, bundle)| {
            let (language, profile) = edition.split_once('/')?;
            (language == profile).then(|| (language.to_owned(), web_bundle(bundle, prefixes)))
        })
        .collect()
}

fn web_bundle(bundle: &Bundle, prefixes: &[&str]) -> Bundle {
    Bundle {
        files: bundle
            .files
            .iter()
            .filter(|(path, _)| is_web_file(path, prefixes))
            .map(|(path, text)| (path.clone(), text.clone()))
            .collect(),
    }
}

fn is_web_file(path: &str, prefixes: &[&str]) -> bool {
    path == TABLE_OF_CONTENTS || prefixes.iter().any(|prefix| path.starts_with(prefix))
}
