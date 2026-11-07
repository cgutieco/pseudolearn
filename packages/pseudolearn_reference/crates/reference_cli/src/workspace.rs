use crate::workspace_files::{files_with_extension, read, relative};
use reference_corpus::Corpus;
use reference_export::{PartDefinition, parse_parts};
use reference_model::{Profile, SourceDocument, Violation};
use reference_resolve::{AliasTable, CategoryTable, LanguagePack};
use reference_verify::{AnchorLock, CoverageExclusions};
use std::collections::BTreeMap;
use std::path::{Path, PathBuf};

pub struct Language {
    pub documents: Vec<SourceDocument>,
    pub parts: Vec<PartDefinition>,
    pub pack: LanguagePack,
}

pub struct Workspace {
    pub root: PathBuf,
    pub corpus: Corpus,
    pub categories: CategoryTable,
    pub aliases: AliasTable,
    pub figures: BTreeMap<String, String>,
    pub languages: BTreeMap<Profile, Language>,
    pub format_violations: Vec<Violation>,
    pub lock: AnchorLock,
    pub exclusions: CoverageExclusions,
}

pub const LOCK_FILE: &str = "reference.lock.json";

pub fn load(root: &Path) -> Result<Workspace, String> {
    let corpus = Corpus::from_export(&read(
        &root.join("../pseudolearn_spec/specifications/export.json"),
    )?)?;
    let categories = CategoryTable::from_json(&read(&root.join("categories.json"))?)?;
    let aliases = AliasTable::from_json(&read(&root.join("aliases.json"))?)?;
    let mut figures = BTreeMap::new();
    for path in files_with_extension(&root.join("figures"), "svg")? {
        let identity = path
            .file_stem()
            .map(|stem| stem.to_string_lossy().into_owned())
            .unwrap_or_default();
        figures.insert(identity, read(&path)?);
    }
    let mut format_violations = Vec::new();
    let mut languages = BTreeMap::new();
    for profile in Profile::all() {
        languages.insert(profile, language(root, profile, &mut format_violations)?);
    }
    let lock_path = root.join(LOCK_FILE);
    let lock = if lock_path.exists() {
        serde_json::from_str(&read(&lock_path)?)
            .map_err(|error| format!("invalid lock: {error}"))?
    } else {
        AnchorLock::new()
    };
    let exclusions = serde_json::from_str(&read(&root.join("coverage-exclusions.json"))?)
        .map_err(|error| format!("invalid coverage exclusions: {error}"))?;
    Ok(Workspace {
        root: root.to_path_buf(),
        corpus,
        categories,
        aliases,
        figures,
        languages,
        format_violations,
        lock,
        exclusions,
    })
}

fn language(
    root: &Path,
    profile: Profile,
    violations: &mut Vec<Violation>,
) -> Result<Language, String> {
    let directory = root.join("content").join(profile.code());
    let mut documents = Vec::new();
    for path in files_with_extension(&directory, "md")? {
        let location = relative(root, &path);
        match reference_format::parse_document(&location, &read(&path)?) {
            Ok(document) => documents.push(document),
            Err(violation) => violations.push(violation),
        }
    }
    documents.sort_by_key(|document| section_order(&document.header.number));
    let parts = parse_parts(&read(&directory.join("partes.json"))?)?;
    let pack = LanguagePack::from_json(&read(
        &root
            .join("figures/strings")
            .join(format!("{}.json", profile.code())),
    )?)?;
    Ok(Language {
        documents,
        parts,
        pack,
    })
}

pub fn section_order(number: &str) -> Vec<(u32, String)> {
    number
        .split('.')
        .map(|component| {
            (
                component.parse::<u32>().unwrap_or(u32::MAX),
                component.to_owned(),
            )
        })
        .collect()
}
