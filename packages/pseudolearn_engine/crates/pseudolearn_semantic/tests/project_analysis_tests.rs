use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::Profile;
use pseudolearn_project::{
    FileInput, PackageInput, PackageKind, ProjectCatalog, ProjectInput, select_entry,
};
use pseudolearn_semantic::{
    HirExpression, HirModule, ProjectUnit, SemanticOptions, analyze_project,
};
use pseudolearn_syntax::parse_module_source;
use std::collections::BTreeMap;

struct Outcome {
    module: Option<HirModule>,
    codes: Vec<DiagnosticCode>,
}

fn project(files: &[(&str, &str)]) -> ProjectInput {
    let mut dependencies = BTreeMap::new();
    dependencies.insert("geo".to_owned(), "geo".to_owned());
    ProjectInput {
        project_id: 1,
        revision_id: 1,
        packages: vec![
            PackageInput {
                name: "app".to_owned(),
                root: "app".to_owned(),
                kind: PackageKind::Application,
                entries: vec!["app/main".to_owned()],
                dependencies,
            },
            PackageInput {
                name: "geo".to_owned(),
                root: "geo".to_owned(),
                kind: PackageKind::Library,
                entries: Vec::new(),
                dependencies: BTreeMap::new(),
            },
        ],
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

fn run(files: &[(&str, &str)]) -> Result<Outcome, String> {
    let catalog =
        ProjectCatalog::build(&project(files)).map_err(|failure| format!("{failure:?}"))?;
    let mut trees = Vec::new();
    for module in catalog.modules() {
        let source = catalog.source(module.id).ok_or("missing source")?;
        let (tree, parsed) = parse_module_source(source, Profile::Spanish, None);
        if !parsed.is_empty() {
            return Err(format!("parse diagnostics: {parsed:?}"));
        }
        trees.push(tree);
    }
    let mut units = Vec::new();
    for (module, tree) in catalog.modules().iter().zip(&trees) {
        let source = catalog.source(module.id).ok_or("missing source")?;
        units.push(ProjectUnit {
            module: module.id,
            tree,
            source,
        });
    }
    let entry =
        select_entry(&catalog, Some("app/main"), false).map_err(|error| format!("{error:?}"))?;
    let options = SemanticOptions {
        profile: Profile::Spanish,
        strict: false,
    };
    let (module, diagnostics) = analyze_project(&catalog, &units, entry, options);
    Ok(Outcome {
        module,
        codes: diagnostics
            .iter()
            .map(|diagnostic| diagnostic.code)
            .collect(),
    })
}

const LIBRARY: &str =
    "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n";

fn main_with(imports: &str, body: &str) -> String {
    format!("{imports}Algoritmo P\n{body}FinAlgoritmo\n")
}

fn codes_for(imports: &str, body: &str, library: &str) -> Result<Vec<DiagnosticCode>, String> {
    let main = main_with(imports, body);
    Ok(run(&[("app/main", &main), ("geo/vectores", library)])?.codes)
}

#[test]
fn symbol_import_with_alias_resolves_to_one_function() -> Result<(), String> {
    let main = main_with(
        "Importar geo.vectores.Doble Como D;\nImportar geo.vectores.Doble Como E;\n",
        "Escribir D(1);\nEscribir E(2);\n",
    );
    let outcome = run(&[("app/main", &main), ("geo/vectores", LIBRARY)])?;
    assert!(outcome.codes.is_empty());
    let module = outcome.module.ok_or("no module")?;
    let callees: Vec<_> = module
        .expressions
        .kinds
        .iter()
        .filter_map(|kind| match kind {
            HirExpression::Call { function, .. } => Some(*function),
            _ => None,
        })
        .collect();
    assert_eq!(callees.len(), 2);
    assert_eq!(callees.first(), callees.get(1));
    assert_eq!(module.functions.len(), 2);
    Ok(())
}

#[test]
fn project_functions_are_named_by_module_and_flagged_as_exported() -> Result<(), String> {
    let main = main_with("Importar geo.vectores.Doble;\n", "Escribir Doble(1);\n");
    let module = run(&[("app/main", &main), ("geo/vectores", LIBRARY)])?
        .module
        .ok_or("no module")?;
    assert!(
        module
            .functions
            .iter()
            .any(|function| function.name == "geo.vectores.Doble")
    );
    assert_eq!(module.units.exported.len(), 1);
    assert!(module.units.entry.is_some());
    Ok(())
}

#[test]
fn module_alias_calls_the_exported_function() -> Result<(), String> {
    let codes = codes_for(
        "Importar geo.vectores Como V;\n",
        "Escribir V.Doble(5);\n",
        LIBRARY,
    )?;
    assert!(codes.is_empty(), "{codes:?}");
    Ok(())
}

#[test]
fn private_missing_and_unknown_imports_are_diagnosed() -> Result<(), String> {
    let library = "SubProceso Oculta()\nFinSubProceso\n";
    let private = codes_for("Importar geo.vectores.Oculta;\n", "Escribir 1;\n", library)?;
    assert_eq!(private, [DiagnosticCode::PrivateImport]);
    let missing = codes_for("Importar geo.vectores.Nada;\n", "Escribir 1;\n", LIBRARY)?;
    assert_eq!(missing, [DiagnosticCode::UnresolvedImport]);
    let unknown = codes_for("Importar zzz.vectores.Doble;\n", "Escribir 1;\n", LIBRARY)?;
    assert_eq!(unknown, [DiagnosticCode::UnresolvedModule]);
    Ok(())
}

#[test]
fn local_declaration_and_import_with_the_same_name_collide() -> Result<(), String> {
    let local = "SubProceso Doble(n Como Entero) Como Entero\nRetornar n;\nFinSubProceso\n";
    let main = format!(
        "Importar geo.vectores.Doble;\n{local}Algoritmo P\nEscribir Doble(1);\nFinAlgoritmo\n"
    );
    let outcome = run(&[("app/main", &main), ("geo/vectores", LIBRARY)])?;
    assert!(outcome.codes.contains(&DiagnosticCode::ImportNameCollision));
    Ok(())
}

#[test]
fn reexport_chain_keeps_the_original_identity() -> Result<(), String> {
    let files = [
        (
            "app/main",
            "Importar geo.puente.Doble;\nAlgoritmo P\nEscribir Doble(3);\nFinAlgoritmo\n",
        ),
        ("geo/base", LIBRARY),
        ("geo/puente", "Exportar geo.base.Doble;\n"),
    ];
    let outcome = run(&files)?;
    assert!(outcome.codes.is_empty(), "{:?}", outcome.codes);
    let module = outcome.module.ok_or("no module")?;
    assert_eq!(module.functions.len(), 2);
    Ok(())
}

#[test]
fn private_and_ambiguous_reexports_are_diagnosed() -> Result<(), String> {
    let private = [
        ("app/main", "Algoritmo P\nFinAlgoritmo\n"),
        ("geo/base", "SubProceso Oculta()\nFinSubProceso\n"),
        ("geo/puente", "Exportar geo.base.Oculta;\n"),
    ];
    assert!(
        run(&private)?
            .codes
            .contains(&DiagnosticCode::PrivateReexport)
    );
    let ambiguous = [
        ("app/main", "Algoritmo P\nFinAlgoritmo\n"),
        ("geo/base", LIBRARY),
        (
            "geo/puente",
            "Exportar geo.base.Doble;\nPublico SubProceso Doble(n Como Entero) Como Entero\nRetornar n;\nFinSubProceso\n",
        ),
    ];
    assert!(
        run(&ambiguous)?
            .codes
            .contains(&DiagnosticCode::AmbiguousReexport)
    );
    Ok(())
}

#[test]
fn reexport_cycles_terminate() -> Result<(), String> {
    let files = [
        ("app/main", "Algoritmo P\nFinAlgoritmo\n"),
        ("geo/a", "Exportar geo.b.Nombre;\n"),
        ("geo/b", "Exportar geo.a.Nombre;\n"),
    ];
    let outcome = run(&files)?;
    assert!(!outcome.codes.is_empty());
    Ok(())
}

#[test]
fn entry_without_algorithm_and_algorithm_outside_entry_are_diagnosed() -> Result<(), String> {
    let missing = run(&[("app/main", LIBRARY)])?;
    assert!(
        missing
            .codes
            .contains(&DiagnosticCode::EntryMissingAlgorithm)
    );
    let main = main_with("", "Escribir 1;\n");
    let outside = run(&[
        ("app/main", &main),
        ("geo/vectores", "Algoritmo Q\nFinAlgoritmo\n"),
    ])?;
    assert!(
        outside
            .codes
            .contains(&DiagnosticCode::AlgorithmOutsideEntry)
    );
    Ok(())
}

#[test]
fn library_module_without_algorithm_is_valid() -> Result<(), String> {
    let main = main_with("", "Escribir 1;\n");
    let outcome = run(&[("app/main", &main), ("geo/vectores", LIBRARY)])?;
    assert!(outcome.codes.is_empty());
    assert!(outcome.module.is_some());
    Ok(())
}

#[test]
fn imported_class_shares_the_identity_of_its_origin() -> Result<(), String> {
    let library = "Publico Clase Caja\nMetodo Constructor()\nFinMetodo\nFinClase\n";
    let main = main_with(
        "Importar geo.vectores.Caja Como C;\n",
        "Definir c Como C;\nc <- Nuevo C();\n",
    );
    let outcome = run(&[("app/main", &main), ("geo/vectores", library)])?;
    assert!(
        outcome
            .codes
            .iter()
            .all(|code| *code != DiagnosticCode::UndeclaredClass)
    );
    assert_eq!(outcome.module.ok_or("no module")?.classes.len(), 1);
    Ok(())
}
