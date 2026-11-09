use reference_export::Bundle;
use std::collections::BTreeMap;

const TABLE_OF_CONTENTS: &str = "toc.json";
const SECTIONS_DIRECTORY: &str = "sections/";

pub fn web_editions(bundles: &BTreeMap<String, Bundle>) -> BTreeMap<String, Bundle> {
    bundles
        .iter()
        .filter_map(|(edition, bundle)| {
            let (language, profile) = edition.split_once('/')?;
            (language == profile).then(|| (language.to_owned(), web_bundle(bundle)))
        })
        .collect()
}

fn web_bundle(bundle: &Bundle) -> Bundle {
    Bundle {
        files: bundle
            .files
            .iter()
            .filter(|(path, _)| is_web_file(path))
            .map(|(path, text)| (path.clone(), text.clone()))
            .collect(),
    }
}

fn is_web_file(path: &str) -> bool {
    path == TABLE_OF_CONTENTS || path.starts_with(SECTIONS_DIRECTORY)
}
