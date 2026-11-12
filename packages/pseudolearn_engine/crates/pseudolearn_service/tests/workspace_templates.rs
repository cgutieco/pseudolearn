use pseudolearn_project::{FileInput, PackageInput, PackageKind, ProjectInput};
use pseudolearn_service::{WorkspaceOptions, WorkspaceSession, WorkspaceSnapshot};
use std::collections::BTreeMap;

fn package_inputs() -> Vec<PackageInput> {
    vec![
        PackageInput {
            name: "app".to_owned(),
            root: "app".to_owned(),
            kind: PackageKind::Application,
            entries: vec!["app/main".to_owned()],
            dependencies: BTreeMap::from([("geo".to_owned(), "geo".to_owned())]),
        },
        PackageInput {
            name: "geo".to_owned(),
            root: "geo".to_owned(),
            kind: PackageKind::Library,
            entries: Vec::new(),
            dependencies: BTreeMap::new(),
        },
    ]
}

fn file(path: &str, source_id: u32, text: &str) -> FileInput {
    FileInput {
        path: path.to_owned(),
        source_id,
        text: text.to_owned(),
    }
}

fn snapshot(files: Vec<FileInput>) -> WorkspaceSnapshot {
    WorkspaceSnapshot {
        project: ProjectInput {
            project_id: 7,
            revision_id: 1,
            packages: package_inputs(),
            files,
        },
        options: WorkspaceOptions::default(),
    }
}

const MAIN: &str =
    "Importar geo.vectores.identidad;\nAlgoritmo P\nEscribir identidad(21);\nFinAlgoritmo\n";
const OTHER: &str = "Importar geo.vectores.Doble;\nPublico SubProceso usar() Como Entero\nRetornar Doble(2);\nFinSubProceso\n";
const LIBRARY: &str = "Publico SubProceso identidad<T>(valor Como T) Como T\nRetornar valor;\nFinSubProceso\nPublico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n";

fn invalidated_after(edited: &str) -> Result<Vec<String>, String> {
    let files = vec![
        file("app/main", 1, MAIN),
        file("geo/vectores", 2, LIBRARY),
        file("app/otro", 3, OTHER),
    ];
    let mut session =
        WorkspaceSession::new(snapshot(files)).map_err(|error| format!("{error:?}"))?;
    session
        .open_document("geo/vectores", 1, edited.to_owned())
        .map_err(|error| format!("{error:?}"))?;
    assert!(session.matches_cold_analysis());
    Ok(session.result().invalidation.invalidated_modules.clone())
}

#[test]
fn editing_a_template_body_invalidates_only_the_modules_that_instantiate_it() -> Result<(), String>
{
    let invalidated =
        invalidated_after(&LIBRARY.replace("Retornar valor;", "Escribir 1;\nRetornar valor;"))?;
    assert!(
        invalidated.contains(&"app/main".to_owned()),
        "{invalidated:?}"
    );
    assert!(
        !invalidated.contains(&"app/otro".to_owned()),
        "{invalidated:?}"
    );
    Ok(())
}

#[test]
fn editing_an_ordinary_body_keeps_every_importer() -> Result<(), String> {
    let invalidated = invalidated_after(&LIBRARY.replace("n * 2", "n * 3"))?;
    assert_eq!(invalidated, vec!["geo/vectores".to_owned()]);
    Ok(())
}
