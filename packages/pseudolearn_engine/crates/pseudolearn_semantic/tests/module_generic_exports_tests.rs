use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::Profile;
use pseudolearn_project::{
    FileInput, PackageInput, PackageKind, ProjectCatalog, ProjectInput, select_entry,
};
use pseudolearn_semantic::{HirModule, ProjectUnit, analyze_project};
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
        let (tree, parsed) = parse_module_source(source, Profile::Spanish);
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
            profile: Profile::Spanish,
        });
    }
    let entry =
        select_entry(&catalog, Some("app/main"), false).map_err(|error| format!("{error:?}"))?;
    let (module, diagnostics) = analyze_project(&catalog, &units, entry);
    Ok(Outcome {
        module,
        codes: diagnostics
            .iter()
            .map(|diagnostic| diagnostic.code)
            .collect(),
    })
}

const LIBRARY: &str = "Publico SubProceso identidad<T>(valor Como T) Como T\nRetornar valor;\nFinSubProceso\nPublico Registro Par<T>\nDefinir primero, segundo Como T;\nFinRegistro\nPublico Interfaz Medible<T>\nMetodo medir() Como T;\nFinInterfaz\nPublico Clase Caja<T>\nDefinir valor Como T;\nMetodo Constructor(inicial Como T)\nEste.valor <- inicial;\nFinMetodo\nMetodo actual() Como T\nRetornar Este.valor;\nFinMetodo\nFinClase\nPublico Variante Talvez<T>\nAlternativa Uno(v Como T)\nAlternativa Ninguno\nFinVariante\n";

const IMPORTS: &str = "Importar geo.genericos.identidad;\nImportar geo.genericos.Par;\nImportar geo.genericos.Medible;\nImportar geo.genericos.Caja;\nImportar geo.genericos.Talvez;\n";

fn codes(files: &[(&str, &str)]) -> Result<Vec<DiagnosticCode>, String> {
    Ok(run(files)?.codes)
}

fn instance_names(module: &HirModule) -> Vec<String> {
    module
        .records
        .iter()
        .map(|record| record.name.clone())
        .chain(module.classes.iter().map(|class| class.name.clone()))
        .chain(
            module
                .functions
                .iter()
                .map(|function| function.name.clone()),
        )
        .filter(|name| name.contains('<'))
        .collect()
}

#[test]
fn every_public_template_kind_is_imported_and_instantiated_in_the_consumer() -> Result<(), String> {
    let main = format!(
        "{IMPORTS}Clase Metro Realiza Medible<Entero>\nMetodo medir() Como Entero\nRetornar 3;\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir p Como Par<Entero> <- Par(1, 2);\nDefinir c Como Caja<Cadena> <- Nuevo Caja<Cadena>(\"xy\");\nDefinir t Como Talvez<Entero> <- Talvez.Uno(identidad(p.segundo));\nSegun t Hacer\nTalvez.Uno(n): Escribir n, c.actual();\nTalvez.Ninguno: Escribir 0;\nFinSegun\nFinAlgoritmo\n"
    );
    let outcome = run(&[("app/main", &main), ("geo/genericos", LIBRARY)])?;
    assert_eq!(outcome.codes, vec![]);
    let module = outcome.module.ok_or("no module")?;
    let names = instance_names(&module);
    for expected in [
        "geo.genericos.Par<integer>",
        "geo.genericos.Caja<string>",
        "geo.genericos.Talvez<integer>",
        "geo.genericos.identidad<integer>",
    ] {
        assert!(
            names.iter().any(|name| name == expected),
            "{expected}: {names:?}"
        );
    }
    Ok(())
}

#[test]
fn two_consumer_modules_with_the_same_arguments_share_one_instance() -> Result<(), String> {
    let main = "Importar geo.genericos.Par;\nImportar app.otro.crear;\nAlgoritmo P\nDefinir a Como Par<Entero> <- Par(1, 2);\nDefinir b Como Par<Entero> <- crear();\nEscribir a = b;\nFinAlgoritmo\n";
    let other = "Importar geo.genericos.Par;\nPublico SubProceso crear() Como Par<Entero>\nRetornar Par(1, 2);\nFinSubProceso\n";
    let outcome = run(&[
        ("app/main", main),
        ("app/otro", other),
        ("geo/genericos", LIBRARY),
    ])?;
    assert_eq!(outcome.codes, vec![]);
    let module = outcome.module.ok_or("no module")?;
    let shared = module
        .records
        .iter()
        .filter(|record| record.name == "geo.genericos.Par<integer>")
        .count();
    assert_eq!(shared, 1);
    Ok(())
}

#[test]
fn a_private_template_cannot_be_imported() -> Result<(), String> {
    let library = "SubProceso oculta<T>(x Como T) Como T\nRetornar x;\nFinSubProceso\nRegistro Celda<T>\nDefinir v Como T;\nFinRegistro\n";
    let main = consumer_with(
        "Importar geo.privados.oculta;\nImportar geo.privados.Celda;\n",
        "",
    );
    assert_eq!(
        codes(&[("app/main", &main), ("geo/privados", library)])?,
        vec![DiagnosticCode::PrivateImport; 2]
    );
    Ok(())
}

#[test]
fn a_constraint_declared_in_another_package_is_checked_at_the_consumer() -> Result<(), String> {
    let library = "Publico Interfaz Contable\nMetodo cuenta() Como Entero;\nFinInterfaz\nPublico SubProceso contar<T: Contable>(x Como T) Como Entero\nRetornar x.cuenta();\nFinSubProceso\n";
    let main = consumer_with(
        "Importar geo.conteo.contar;\nImportar geo.conteo.Contable;\n",
        "Escribir contar(5);\n",
    );
    let outcome = run(&[("app/main", &main), ("geo/conteo", library)])?;
    assert_eq!(
        outcome.codes,
        vec![DiagnosticCode::GenericConstraintNotSatisfied]
    );
    let satisfied = consumer_with(
        "Importar geo.conteo.contar;\nImportar geo.conteo.Contable;\nClase Uno Realiza Contable\nMetodo cuenta() Como Entero\nRetornar 1;\nFinMetodo\nFinClase\n",
        "Escribir contar(Nuevo Uno());\n",
    );
    assert_eq!(
        codes(&[("app/main", &satisfied), ("geo/conteo", library)])?,
        vec![]
    );
    Ok(())
}

fn nested(depth: usize, root: &str) -> String {
    let mut text = root.to_owned();
    for _ in 0..depth {
        text = format!("Celda<{text}>");
    }
    text
}

#[test]
fn the_instance_limit_counts_instances_from_every_module() -> Result<(), String> {
    let library = "Publico Registro Celda<T>\nDefinir v Como T;\nFinRegistro\n";
    let first = format!(
        "Importar geo.celdas.Celda;\nPublico SubProceso uno(p Como {}) Como Entero\nRetornar 1;\nFinSubProceso\n",
        nested(32, "Entero")
    );
    let fits = format!(
        "Importar geo.celdas.Celda;\nImportar app.otro.uno;\nSubProceso dos(p Como {}) Como Entero\nRetornar 2;\nFinSubProceso\nAlgoritmo P\nFinAlgoritmo\n",
        nested(32, "Cadena")
    );
    let files = [
        ("app/main", fits.as_str()),
        ("app/otro", first.as_str()),
        ("geo/celdas", library),
    ];
    assert!(
        !codes(&files)?.contains(&DiagnosticCode::GenericInstanceLimitExceeded),
        "64 instances fit"
    );
    let exceeds = fits.replace(&nested(32, "Cadena"), &nested(33, "Cadena"));
    let files = [
        ("app/main", exceeds.as_str()),
        ("app/otro", first.as_str()),
        ("geo/celdas", library),
    ];
    assert!(codes(&files)?.contains(&DiagnosticCode::GenericInstanceLimitExceeded));
    Ok(())
}

#[test]
fn a_template_reexported_twice_keeps_one_identity_and_aliased_homonyms_stay_apart()
-> Result<(), String> {
    let chain = [
        (
            "app/main",
            "Importar geo.fachada.Par;\nImportar geo.otra.Par Como Doble;\nAlgoritmo P\nDefinir a Como Par<Entero> <- Par(1, 2);\nDefinir b Como Doble<Entero> <- a;\nEscribir b.primero;\nFinAlgoritmo\n",
        ),
        ("geo/fachada", "Exportar geo.genericos.Par;\n"),
        ("geo/otra", "Exportar geo.fachada.Par;\n"),
        ("geo/genericos", LIBRARY),
    ];
    assert_eq!(codes(&chain)?, vec![]);
    let homonyms = [
        (
            "app/main",
            "Importar geo.a.Par Como ParX;\nImportar geo.b.Par Como ParY;\nAlgoritmo P\nDefinir a Como ParX<Entero> <- ParX(1);\nDefinir b Como ParY<Entero> <- a;\nFinAlgoritmo\n",
        ),
        (
            "geo/a",
            "Publico Registro Par<T>\nDefinir v Como T;\nFinRegistro\n",
        ),
        (
            "geo/b",
            "Publico Registro Par<T>\nDefinir v Como T;\nFinRegistro\n",
        ),
    ];
    assert_eq!(
        codes(&homonyms)?,
        vec![DiagnosticCode::IncompatibleTypesInAssignment]
    );
    Ok(())
}

#[test]
fn an_unused_public_template_is_still_checked_in_its_own_module() -> Result<(), String> {
    let library = "Publico SubProceso sumar<T>(a Como T, b Como T) Como T\nRetornar a + b;\nFinSubProceso\nPublico Clase Doble<T>\nDefinir v Como T;\nMetodo doble() Como T\nRetornar Este.v * 2;\nFinMetodo\nFinClase\nPublico Interfaz Rota<T>\nMetodo m() Como Desconocido;\nFinInterfaz\n";
    let main = consumer_with("", "");
    let outcome = run(&[("app/main", &main), ("geo/sumas", library)])?;
    assert_eq!(
        outcome.codes,
        vec![
            DiagnosticCode::IncompatibleOperandTypes,
            DiagnosticCode::IncompatibleOperandTypes,
            DiagnosticCode::UndeclaredClass
        ]
    );
    Ok(())
}

#[test]
fn a_template_body_error_is_reported_once_even_with_consumers_in_two_modules() -> Result<(), String>
{
    let library =
        "Publico SubProceso sumar<T>(a Como T, b Como T) Como T\nRetornar a + b;\nFinSubProceso\n";
    let main = consumer_with("Importar geo.sumas.sumar;\n", "Escribir sumar(1, 2);\n");
    let other = "Importar geo.sumas.sumar;\nPublico SubProceso tres() Como Entero\nRetornar sumar(1, 2);\nFinSubProceso\n";
    let outcome = run(&[
        ("app/main", &main),
        ("app/otro", other),
        ("geo/sumas", library),
    ])?;
    assert_eq!(
        outcome.codes,
        vec![DiagnosticCode::IncompatibleOperandTypes]
    );
    Ok(())
}

fn consumer_with(imports: &str, body: &str) -> String {
    format!("{imports}Algoritmo P\n{body}FinAlgoritmo\n")
}

#[test]
fn a_subprogram_template_is_called_through_a_module_alias() -> Result<(), String> {
    let main = "Importar geo.genericos Como G;\nAlgoritmo P\nEscribir G.identidad(4), G.identidad(\"ab\");\nFinAlgoritmo\n";
    assert_eq!(
        codes(&[("app/main", main), ("geo/genericos", LIBRARY)])?,
        vec![]
    );
    let missing =
        "Importar geo.genericos Como G;\nAlgoritmo P\nEscribir G.ausente(4);\nFinAlgoritmo\n";
    assert_eq!(
        codes(&[("app/main", missing), ("geo/genericos", LIBRARY)])?,
        vec![DiagnosticCode::UnresolvedImport]
    );
    Ok(())
}
