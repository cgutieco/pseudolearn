use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_lexicon::Profile;
use pseudolearn_project::{
    FileInput, PackageInput, PackageKind, ProjectCatalog, ProjectInput, select_entry,
};
use pseudolearn_semantic::{HirModule, ProjectUnit, SemanticOptions, analyze_project};
use pseudolearn_source::SourceId;
use pseudolearn_syntax::parse_module_source;
use std::collections::BTreeMap;

const MAIN: &str = "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n";

fn project(files: &[(&str, &str)]) -> ProjectInput {
    let package =
        |name: &str, kind, entries: &[&str], dependencies: &[(&str, &str)]| PackageInput {
            name: name.to_owned(),
            root: name.to_owned(),
            kind,
            entries: entries.iter().map(|entry| (*entry).to_owned()).collect(),
            dependencies: dependencies
                .iter()
                .map(|(alias, target)| ((*alias).to_owned(), (*target).to_owned()))
                .collect::<BTreeMap<_, _>>(),
        };
    ProjectInput {
        project_id: 1,
        revision_id: 1,
        packages: vec![
            package(
                "app",
                PackageKind::Application,
                &["app/main"],
                &[("geo", "geo")],
            ),
            package("geo", PackageKind::Library, &[], &[]),
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

fn analyze(files: &[(&str, &str)]) -> Result<(Option<HirModule>, Vec<Diagnostic>), String> {
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
    Ok(analyze_project(&catalog, &units, entry, options))
}

fn cycle_lexemes(diagnostics: &[Diagnostic]) -> Vec<String> {
    diagnostics
        .iter()
        .filter(|diagnostic| diagnostic.code == DiagnosticCode::ImportCycle)
        .filter_map(|diagnostic| diagnostic.arguments.get("lexeme"))
        .map(|argument| argument.text().into_owned())
        .collect()
}

#[test]
fn two_module_cycle_is_rejected_without_a_program() -> Result<(), String> {
    let files = [
        ("app/main", MAIN),
        ("geo/a", "Importar geo.b;\n"),
        ("geo/b", "Importar geo.a;\n"),
    ];
    let (module, diagnostics) = analyze(&files)?;
    assert!(module.is_none());
    assert_eq!(cycle_lexemes(&diagnostics), ["geo.a -> geo.b -> geo.a"]);
    Ok(())
}

#[test]
fn diagnostic_sits_in_the_smallest_module_and_relates_the_next_edges() -> Result<(), String> {
    let files = [
        ("app/main", MAIN),
        ("geo/a", "Importar geo.b;\n"),
        ("geo/b", "Importar geo.a;\n"),
    ];
    let (_, diagnostics) = analyze(&files)?;
    let cycle = diagnostics.first().ok_or("no diagnostic")?;
    assert_eq!(cycle.span.source_id, SourceId::new(2));
    let related: Vec<SourceId> = cycle.related.iter().map(|span| span.source_id).collect();
    assert_eq!(related, [SourceId::new(3)]);
    Ok(())
}

#[test]
fn self_import_is_a_cycle() -> Result<(), String> {
    let main = format!("Importar app.main;\n{MAIN}");
    let (module, diagnostics) = analyze(&[("app/main", &main)])?;
    assert!(module.is_none());
    assert_eq!(cycle_lexemes(&diagnostics), ["app.main -> app.main"]);
    Ok(())
}

#[test]
fn chain_does_not_depend_on_file_or_directive_order() -> Result<(), String> {
    let forward = [
        ("app/main", MAIN),
        ("geo/a", "Importar geo.c;\nImportar geo.b;\n"),
        ("geo/b", "Importar geo.d;\n"),
        ("geo/c", "Importar geo.d;\n"),
        ("geo/d", "Importar geo.a;\n"),
    ];
    let reversed = [
        ("geo/d", "Importar geo.a;\n"),
        ("geo/c", "Importar geo.d;\n"),
        ("geo/b", "Importar geo.d;\n"),
        ("geo/a", "Importar geo.b;\nImportar geo.c;\n"),
        ("app/main", MAIN),
    ];
    let expected = ["geo.a -> geo.b -> geo.d -> geo.a"];
    assert_eq!(cycle_lexemes(&analyze(&forward)?.1), expected);
    assert_eq!(cycle_lexemes(&analyze(&reversed)?.1), expected);
    Ok(())
}

#[test]
fn a_cycle_stops_the_analysis_of_bodies() -> Result<(), String> {
    let broken =
        "Importar geo.b;\nPublico SubProceso F() Como Entero\nRetornar \"x\";\nFinSubProceso\n";
    let files = [
        ("app/main", MAIN),
        ("geo/a", broken),
        ("geo/b", "Importar geo.a;\n"),
    ];
    let (_, diagnostics) = analyze(&files)?;
    let codes: Vec<_> = diagnostics
        .iter()
        .map(|diagnostic| diagnostic.code)
        .collect();
    assert_eq!(codes, [DiagnosticCode::ImportCycle]);
    Ok(())
}

#[test]
fn a_missing_symbol_still_leaves_the_module_edge() -> Result<(), String> {
    let files = [
        ("app/main", MAIN),
        ("geo/a", "Importar geo.b.Nada;\n"),
        ("geo/b", "Importar geo.a;\n"),
    ];
    let (_, diagnostics) = analyze(&files)?;
    assert_eq!(cycle_lexemes(&diagnostics).len(), 1);
    let unresolved = diagnostics
        .iter()
        .filter(|diagnostic| diagnostic.code == DiagnosticCode::UnresolvedImport)
        .count();
    assert_eq!(unresolved, 1);
    Ok(())
}

#[test]
fn diamond_imports_are_accepted() -> Result<(), String> {
    let side = "Importar geo.base;\n";
    let files = [
        ("app/main", MAIN),
        ("geo/left", side),
        ("geo/right", side),
        ("geo/base", ""),
    ];
    let (module, diagnostics) = analyze(&files)?;
    assert!(cycle_lexemes(&diagnostics).is_empty());
    assert!(module.is_some());
    Ok(())
}

#[test]
fn mutual_recursion_inside_one_module_is_not_a_cycle() -> Result<(), String> {
    let parity = "SubProceso A(n Como Entero) Como Entero\nRetornar B(n);\nFinSubProceso\nSubProceso B(n Como Entero) Como Entero\nRetornar A(n);\nFinSubProceso\n";
    let (module, diagnostics) = analyze(&[("app/main", MAIN), ("geo/mutua", parity)])?;
    assert!(cycle_lexemes(&diagnostics).is_empty());
    assert!(module.is_some());
    Ok(())
}
