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

const TYPES: &str = "Publico Constante Limite Como Entero <- 7;\nPublico Enumerado Color\nRojo, Verde\nFinEnumerado\nPublico Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nPublico Interfaz Medible\nMetodo Medida() Como Entero;\nFinInterfaz\n";

fn consumer(imports: &str, body: &str) -> String {
    format!("{imports}Algoritmo P\n{body}FinAlgoritmo\n")
}

fn codes(files: &[(&str, &str)]) -> Result<Vec<DiagnosticCode>, String> {
    Ok(run(files)?.codes)
}

#[test]
fn every_public_type_kind_and_constant_is_imported_without_diagnostics() -> Result<(), String> {
    let main = consumer(
        "Importar geo.tipos.Limite;\nImportar geo.tipos.Color;\nImportar geo.tipos.Punto;\nImportar geo.tipos.Medible;\n",
        "Definir c Como Color <- Color.Verde;\nDefinir p Como Punto <- Punto(Limite, 2);\nEscribir c, p.x;\n",
    );
    assert_eq!(codes(&[("app/main", &main), ("geo/tipos", TYPES)])?, vec![]);
    Ok(())
}

#[test]
fn an_imported_record_and_enum_keep_the_identity_of_their_owner() -> Result<(), String> {
    let main = consumer(
        "Importar geo.tipos.Punto Como P;\nImportar geo.tipos.Punto Como Q;\nImportar geo.tipos.Color Como C;\n",
        "Definir a Como P <- P(1, 2);\nDefinir b Como Q <- a;\nDefinir c Como C <- C.Rojo;\nEscribir b.x, c;\n",
    );
    let outcome = run(&[("app/main", &main), ("geo/tipos", TYPES)])?;
    assert!(outcome.codes.is_empty());
    let module = outcome.module.ok_or("no module")?;
    assert_eq!(module.records.len(), 1);
    assert_eq!(module.enums.len(), 1);
    Ok(())
}

#[test]
fn private_units_of_every_kind_cannot_be_imported() -> Result<(), String> {
    let library = "Constante Interna Como Entero <- 1;\nEnumerado Oculto\nA, B\nFinEnumerado\nPrivado Registro Cerrado\nDefinir x Como Entero;\nFinRegistro\nInterfaz Reservada\nMetodo M() Como Entero;\nFinInterfaz\n";
    let main = consumer(
        "Importar geo.tipos.Interna;\nImportar geo.tipos.Oculto;\nImportar geo.tipos.Cerrado;\nImportar geo.tipos.Reservada;\n",
        "",
    );
    assert_eq!(
        codes(&[("app/main", &main), ("geo/tipos", library)])?,
        vec![DiagnosticCode::PrivateImport; 4]
    );
    Ok(())
}

#[test]
fn a_missing_type_symbol_is_an_unresolved_import() -> Result<(), String> {
    let main = consumer("Importar geo.tipos.Ausente;\n", "");
    assert_eq!(
        codes(&[("app/main", &main), ("geo/tipos", TYPES)])?,
        vec![DiagnosticCode::UnresolvedImport]
    );
    Ok(())
}

#[test]
fn an_imported_type_colliding_with_a_local_class_is_reported() -> Result<(), String> {
    let main = "Importar geo.tipos.Punto;\nClase Punto\nFinClase\nAlgoritmo P\nFinAlgoritmo\n";
    assert_eq!(
        codes(&[("app/main", main), ("geo/tipos", TYPES)])?,
        vec![DiagnosticCode::ImportNameCollision]
    );
    Ok(())
}

#[test]
fn reexporting_a_private_type_is_reported_and_a_public_one_chains() -> Result<(), String> {
    let base = "Registro Oculto\nDefinir x Como Entero;\nFinRegistro\nPublico Constante Limite Como Entero <- 9;\n";
    let chain = [
        (
            "app/main",
            "Importar geo.alto.Limite;\nAlgoritmo P\nEscribir Limite;\nFinAlgoritmo\n",
        ),
        ("geo/alto", "Exportar geo.medio.Limite;\n"),
        ("geo/medio", "Exportar geo.base.Limite;\n"),
        ("geo/base", base),
    ];
    assert_eq!(codes(&chain)?, vec![]);
    let private = [
        ("app/main", "Algoritmo P\nFinAlgoritmo\n"),
        ("geo/fachada", "Exportar geo.base.Oculto;\n"),
        ("geo/base", base),
    ];
    assert_eq!(codes(&private)?, vec![DiagnosticCode::PrivateReexport]);
    Ok(())
}

#[test]
fn two_different_exports_with_one_name_are_ambiguous_but_the_same_identity_twice_is_not()
-> Result<(), String> {
    let first = "Publico Registro Punto\nDefinir w Como Entero;\nFinRegistro\n";
    let second = "Publico Registro Punto\nDefinir v Como Entero;\nFinRegistro\n";
    let main = "Importar geo.fachada.Punto;\nAlgoritmo P\nFinAlgoritmo\n";
    let ambiguous = [
        ("app/main", main),
        (
            "geo/fachada",
            "Exportar geo.a.Punto;\nExportar geo.b.Punto;\n",
        ),
        ("geo/a", first),
        ("geo/b", second),
    ];
    assert_eq!(codes(&ambiguous)?, vec![DiagnosticCode::AmbiguousReexport]);
    let repeated = [
        ("app/main", main),
        (
            "geo/fachada",
            "Exportar geo.a.Punto;\nExportar geo.a.Punto;\n",
        ),
        ("geo/a", first),
    ];
    assert_eq!(codes(&repeated)?, vec![]);
    Ok(())
}

#[test]
fn an_empty_enum_is_importable_and_has_no_members() -> Result<(), String> {
    let library = "Publico Enumerado Vacio\nFinEnumerado\n";
    let imported = consumer("Importar geo.tipos.Vacio;\n", "");
    assert_eq!(
        codes(&[("app/main", &imported), ("geo/tipos", library)])?,
        vec![]
    );
    let member = consumer("Importar geo.tipos.Vacio;\n", "Escribir Vacio.Alfa;\n");
    assert_eq!(
        codes(&[("app/main", &member), ("geo/tipos", library)])?,
        vec![DiagnosticCode::UndefinedEnumMember]
    );
    Ok(())
}

#[test]
fn a_constant_cycle_in_a_library_is_reported_once_and_an_import_cycle_stops_analysis()
-> Result<(), String> {
    let cycle = "Publico Constante Alfa Como Entero <- Beta + 1;\nConstante Beta Como Entero <- Alfa + 1;\n";
    let main = consumer("Importar geo.ciclo.Alfa;\n", "Escribir Alfa;\n");
    assert_eq!(
        codes(&[("app/main", &main), ("geo/ciclo", cycle)])?,
        vec![DiagnosticCode::CircularConstantDefinition]
    );
    let imports = [
        ("app/main", main.as_str()),
        (
            "geo/ciclo",
            "Importar geo.otro.Beta;\nPublico Constante Alfa Como Entero <- 1;\n",
        ),
        (
            "geo/otro",
            "Importar geo.ciclo.Alfa;\nPublico Constante Beta Como Entero <- 1;\n",
        ),
    ];
    assert_eq!(codes(&imports)?, vec![DiagnosticCode::ImportCycle]);
    Ok(())
}

#[test]
fn a_text_constant_at_the_limit_is_imported_and_one_byte_more_is_rejected() -> Result<(), String> {
    let main = consumer(
        "Importar geo.tipos.Grande;\n",
        "Escribir Longitud(Grande);\n",
    );
    let within = format!(
        "Publico Constante Grande Como Cadena <- \"{}\";\n",
        "a".repeat(65_536)
    );
    assert_eq!(
        codes(&[("app/main", &main), ("geo/tipos", &within)])?,
        vec![]
    );
    let beyond = format!(
        "Publico Constante Grande Como Cadena <- \"{}\";\n",
        "a".repeat(65_537)
    );
    assert_eq!(
        codes(&[("app/main", &main), ("geo/tipos", &beyond)])?,
        vec![DiagnosticCode::ConstantBudgetExceeded]
    );
    Ok(())
}

fn signature_codes(library: &str) -> Result<Vec<DiagnosticCode>, String> {
    let main = consumer("", "");
    codes(&[("app/main", &main), ("geo/tipos", library)])
}

const PRIVATE_RECORD: &str = "Registro Oculto\nDefinir x Como Entero;\nFinRegistro\n";

#[test]
fn a_public_subprogram_naming_a_private_type_is_reported_once_per_appearance() -> Result<(), String>
{
    let parameter = format!(
        "{PRIVATE_RECORD}Publico SubProceso Suma(p Como Oculto) Como Entero\nRetornar p.x;\nFinSubProceso\n"
    );
    assert_eq!(
        signature_codes(&parameter)?,
        vec![DiagnosticCode::PrivateTypeInPublicSignature]
    );
    let both = format!(
        "{PRIVATE_RECORD}Publico SubProceso Copia(p Como Oculto) Como Oculto\nRetornar p;\nFinSubProceso\n"
    );
    assert_eq!(
        signature_codes(&both)?,
        vec![DiagnosticCode::PrivateTypeInPublicSignature; 2]
    );
    let nested = "Enumerado Oculto\nA, B\nFinEnumerado\nPublico SubProceso Suma(p Como Opcional<Oculto>) Como Entero\nRetornar 1;\nFinSubProceso\n";
    assert_eq!(
        signature_codes(nested)?,
        vec![DiagnosticCode::PrivateTypeInPublicSignature]
    );
    Ok(())
}

#[test]
fn private_signatures_and_bodies_may_use_private_types() -> Result<(), String> {
    let library = format!(
        "{PRIVATE_RECORD}SubProceso Interna(p Como Oculto) Como Entero\nRetornar p.x;\nFinSubProceso\nPublico SubProceso Suma(n Como Entero) Como Entero\nDefinir t Como Oculto <- Oculto(n);\nRetornar Interna(t);\nFinSubProceso\n"
    );
    assert_eq!(signature_codes(&library)?, vec![]);
    Ok(())
}

#[test]
fn a_public_class_exposes_only_its_non_private_members() -> Result<(), String> {
    let library = format!(
        "{PRIVATE_RECORD}Publico Clase Caja\nPublico Definir campo Como Oculto;\nPublico Metodo M(a Como Oculto) Como Entero\nRetornar 1;\nFinMetodo\nPrivado Metodo N(a Como Oculto)\nFinMetodo\nFinClase\n"
    );
    assert_eq!(
        signature_codes(&library)?,
        vec![DiagnosticCode::PrivateTypeInPublicSignature; 2]
    );
    let private_class =
        format!("{PRIVATE_RECORD}Clase Caja\nPublico Definir campo Como Oculto;\nFinClase\n");
    assert_eq!(signature_codes(&private_class)?, vec![]);
    Ok(())
}

#[test]
fn public_interfaces_and_records_expose_every_signature() -> Result<(), String> {
    let library = "Enumerado Oculto\nA, B\nFinEnumerado\nPublico Interfaz Medible\nMetodo Medida(a Como Oculto) Como Entero;\nFinInterfaz\nPublico Registro Marco\nDefinir e Como Oculto;\nFinRegistro\n";
    assert_eq!(
        signature_codes(library)?,
        vec![DiagnosticCode::PrivateTypeInPublicSignature; 2]
    );
    let public_only = "Publico Enumerado Visible\nA, B\nFinEnumerado\nPublico Registro Marco\nDefinir e Como Visible;\nFinRegistro\n";
    assert_eq!(signature_codes(public_only)?, vec![]);
    Ok(())
}
