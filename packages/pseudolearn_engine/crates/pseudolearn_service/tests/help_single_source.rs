use pseudolearn_service::help_catalog::{HelpLocale, cards};
use std::path::{Path, PathBuf};

const MINIMUM_PROSE_LENGTH: usize = 24;
const SCANNED_EXTENSIONS: [&str; 9] =
    ["rs", "dart", "arb", "ts", "tsx", "astro", "js", "mjs", "kt"];
const SKIPPED_DIRECTORIES: [&str; 6] = [
    "target",
    "node_modules",
    ".dart_tool",
    "build",
    "dist",
    ".git",
];

fn prose_needles() -> Vec<&'static str> {
    let mut needles = Vec::new();
    for card in cards() {
        for locale in [HelpLocale::Spanish, HelpLocale::English] {
            let content = card.content(locale);
            needles.push(content.summary);
            needles.push(content.purpose);
            needles.extend(content.constraints.iter().copied());
            needles.extend(content.common_errors.iter().copied());
            needles.extend(content.parts.iter().map(|part| part.text));
        }
    }
    needles.retain(|text| text.chars().count() >= MINIMUM_PROSE_LENGTH);
    needles
}

fn source_files(root: &Path, found: &mut Vec<PathBuf>) {
    let Ok(entries) = std::fs::read_dir(root) else {
        return;
    };
    for entry in entries.flatten() {
        let path = entry.path();
        let name = entry.file_name();
        if path.is_dir() {
            if !SKIPPED_DIRECTORIES.iter().any(|skipped| name == *skipped) {
                source_files(&path, found);
            }
        } else if path.extension().is_some_and(|extension| {
            SCANNED_EXTENSIONS
                .iter()
                .any(|scanned| extension == *scanned)
        }) {
            found.push(path);
        }
    }
}

fn find_copies(root: &Path, needles: &[&str]) -> Vec<String> {
    let mut files = Vec::new();
    source_files(root, &mut files);
    let mut copies = Vec::new();
    for file in files {
        let Ok(text) = std::fs::read_to_string(&file) else {
            continue;
        };
        for needle in needles {
            if text.contains(needle) {
                copies.push(format!("{}: {needle}", file.display()));
            }
        }
    }
    copies
}

fn repository_root() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).join("../../../..")
}

fn consumer_roots() -> Vec<PathBuf> {
    let root = repository_root();
    vec![
        root.join("packages/pseudolearn_engine/crates"),
        root.join("packages/pseudolearn_engine/xtask"),
        root.join("apps/pseudolearn_cli/src"),
        root.join("apps/pseudolearn_app/lib"),
        root.join("apps/pseudolearn_app/native/src"),
        root.join("apps/fe-pseudolearn/src"),
    ]
}

#[test]
fn the_catalog_has_prose_to_protect() {
    assert!(prose_needles().len() > 100);
}

#[test]
fn no_consumer_keeps_a_copy_of_catalog_prose() {
    let needles = prose_needles();
    for root in consumer_roots() {
        let copies: Vec<String> = find_copies(&root, &needles)
            .into_iter()
            .filter(|copy| !copy.contains("/tests/"))
            .collect();
        assert!(copies.is_empty(), "copied catalog prose: {copies:?}");
    }
}

#[test]
fn the_audit_roots_exist() {
    for root in consumer_roots() {
        assert!(root.is_dir(), "{} is not a directory", root.display());
    }
}

#[test]
fn the_scan_flags_a_deliberate_copy_and_accepts_clean_sources() -> Result<(), String> {
    let needles = prose_needles();
    let copied = needles.first().ok_or("catalog has no prose")?;
    let scratch = Path::new(env!("CARGO_TARGET_TMPDIR")).join("help_single_source");
    std::fs::create_dir_all(&scratch).map_err(|error| error.to_string())?;
    std::fs::write(
        scratch.join("violation.dart"),
        format!("const description = '{copied}';\n"),
    )
    .map_err(|error| error.to_string())?;
    assert_eq!(find_copies(&scratch, &needles).len(), 1);
    std::fs::write(
        scratch.join("violation.dart"),
        "const label = 'Explicar';\n",
    )
    .map_err(|error| error.to_string())?;
    assert!(find_copies(&scratch, &needles).is_empty());
    Ok(())
}
