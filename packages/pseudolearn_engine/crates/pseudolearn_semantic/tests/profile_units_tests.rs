use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::Profile;
use pseudolearn_project::{
    FileInput, PackageInput, PackageKind, ProjectCatalog, ProjectInput, select_entry,
};
use pseudolearn_semantic::{ProjectUnit, SemanticOptions, analyze_project};
use pseudolearn_syntax::parse_module_source;
use std::collections::BTreeMap;

const SPANISH_LIBRARY: &str = "Publico SubProceso while()\nEscribir 1;\nFinSubProceso\n";
const ENGLISH_LIBRARY: &str = "public subroutine Mientras()\nwrite 2;\nendSubroutine\n";

fn project(files: &[(&str, &str)]) -> ProjectInput {
    ProjectInput {
        project_id: 1,
        revision_id: 1,
        packages: vec![PackageInput {
            name: "app".to_owned(),
            root: "app".to_owned(),
            kind: PackageKind::Application,
            entries: vec!["app/main".to_owned()],
            dependencies: BTreeMap::new(),
        }],
        files: files
            .iter()
            .enumerate()
            .map(|(index, (path, text))| FileInput {
                path: (*path).to_owned(),
                source_id: u32::try_from(index).unwrap_or(0).saturating_add(1),
                text: (*text).to_owned(),
            })
            .collect(),
    }
}

fn codes(files: &[(&str, &str, Profile)]) -> Result<Vec<DiagnosticCode>, String> {
    let plain: Vec<(&str, &str)> = files.iter().map(|(path, text, _)| (*path, *text)).collect();
    let catalog =
        ProjectCatalog::build(&project(&plain)).map_err(|failure| format!("{failure:?}"))?;
    let mut trees = Vec::new();
    for (module, (_, _, profile)) in catalog.modules().iter().zip(ordered(files)) {
        let source = catalog.source(module.id).ok_or("missing source")?;
        let (tree, parsed) = parse_module_source(source, profile, None);
        if !parsed.is_empty() {
            return Err(format!("parse diagnostics: {parsed:?}"));
        }
        trees.push(tree);
    }
    let mut units = Vec::new();
    for ((module, tree), (_, _, profile)) in
        catalog.modules().iter().zip(&trees).zip(ordered(files))
    {
        let source = catalog.source(module.id).ok_or("missing source")?;
        units.push(ProjectUnit {
            module: module.id,
            tree,
            source,
            profile,
        });
    }
    let entry =
        select_entry(&catalog, Some("app/main"), false).map_err(|error| format!("{error:?}"))?;
    let options = SemanticOptions {
        profile: Profile::Spanish,
        strict: false,
    };
    let (_, diagnostics) = analyze_project(&catalog, &units, entry, options);
    Ok(diagnostics
        .iter()
        .map(|diagnostic| diagnostic.code)
        .collect())
}

fn ordered<'files>(
    files: &'files [(&'files str, &'files str, Profile)],
) -> Vec<(&'files str, &'files str, Profile)> {
    let mut sorted = files.to_vec();
    sorted.sort_by(|left, right| left.0.cmp(right.0));
    sorted
}

#[test]
fn english_unit_imports_a_spanish_unit_symbol_that_is_reserved_in_english() -> Result<(), String> {
    let main = "import app.util.while as run;\nalgorithm P\nrun();\nendAlgorithm\n";
    let found = codes(&[
        ("app/main", main, Profile::English),
        ("app/util", SPANISH_LIBRARY, Profile::Spanish),
    ])?;
    assert!(found.is_empty(), "{found:?}");
    Ok(())
}

#[test]
fn reserved_name_without_an_alias_is_rejected_in_the_importing_profile() -> Result<(), String> {
    let main = "import app.util.while;\nalgorithm P\nendAlgorithm\n";
    let found = codes(&[
        ("app/main", main, Profile::English),
        ("app/util", SPANISH_LIBRARY, Profile::Spanish),
    ])?;
    assert_eq!(found, vec![DiagnosticCode::ReservedImportNeedsAlias]);
    Ok(())
}

#[test]
fn foreign_reserved_word_is_a_legal_name_without_an_alias() -> Result<(), String> {
    let main = "Importar app.util.while;\nAlgoritmo P\nwhile();\nFinAlgoritmo\n";
    let found = codes(&[
        ("app/main", main, Profile::Spanish),
        ("app/util", SPANISH_LIBRARY, Profile::Spanish),
    ])?;
    assert!(found.is_empty(), "{found:?}");
    Ok(())
}

#[test]
fn spanish_unit_needs_an_alias_for_an_english_symbol_named_like_a_spanish_keyword()
-> Result<(), String> {
    let bare = "Importar app.util.Mientras;\nAlgoritmo P\nFinAlgoritmo\n";
    let found = codes(&[
        ("app/main", bare, Profile::Spanish),
        ("app/util", ENGLISH_LIBRARY, Profile::English),
    ])?;
    assert_eq!(found, vec![DiagnosticCode::ReservedImportNeedsAlias]);
    let aliased = "Importar app.util.Mientras Como M;\nAlgoritmo P\nM();\nFinAlgoritmo\n";
    let found = codes(&[
        ("app/main", aliased, Profile::Spanish),
        ("app/util", ENGLISH_LIBRARY, Profile::English),
    ])?;
    assert!(found.is_empty(), "{found:?}");
    Ok(())
}

#[test]
fn module_imported_under_a_reserved_last_segment_needs_an_alias() -> Result<(), String> {
    let main = "import app.while;\nalgorithm P\nendAlgorithm\n";
    let found = codes(&[
        ("app/main", main, Profile::English),
        ("app/while", SPANISH_LIBRARY, Profile::Spanish),
    ])?;
    assert_eq!(found, vec![DiagnosticCode::ReservedImportNeedsAlias]);
    Ok(())
}

#[test]
fn each_unit_resolves_standard_functions_with_its_own_profile() -> Result<(), String> {
    let main =
        "import app.util as U;\nalgorithm P\nwrite length(\"ab\");\nU.show();\nendAlgorithm\n";
    let library = "Publico SubProceso show()\nEscribir longitud(\"abc\");\nFinSubProceso\n";
    let found = codes(&[
        ("app/main", main, Profile::English),
        ("app/util", library, Profile::Spanish),
    ])?;
    assert!(found.is_empty(), "{found:?}");
    Ok(())
}
