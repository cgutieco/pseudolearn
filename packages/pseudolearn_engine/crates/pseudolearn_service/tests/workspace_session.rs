use pseudolearn_lexicon::Profile;
use pseudolearn_project::{
    Configuration, FileInput, HostGrants, ManifestRequest, PackageInput, PackageKind, ProjectInput,
};
use pseudolearn_service::{WorkspaceOptions, WorkspaceSession, WorkspaceSnapshot};
use std::collections::BTreeMap;

const MAIN: &str = "Importar geo.vectores.Doble;\nAlgoritmo P\nEscribir Doble(21);\nFinAlgoritmo\n";
const LIBRARY: &str =
    "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n";

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

fn project_files() -> Vec<FileInput> {
    vec![file("app/main", 1, MAIN), file("geo/vectores", 2, LIBRARY)]
}

fn codes(session: &WorkspaceSession) -> Vec<&'static str> {
    session
        .result()
        .diagnostics
        .iter()
        .map(|diagnostic| diagnostic.code.as_str())
        .collect()
}

#[test]
fn overlays_correct_errors_and_analyze_closed_imports() -> Result<(), String> {
    let mut initial = snapshot(project_files());
    let Some(first_file) = initial.project.files.first_mut() else {
        return Err("workspace fixture has no files".to_owned());
    };
    first_file.text = "@".to_owned();
    let mut session = WorkspaceSession::new(initial).map_err(|error| format!("{error:?}"))?;
    assert!(!codes(&session).is_empty());
    session
        .open_document("app/main", 1, MAIN.to_owned())
        .map_err(|error| format!("{error:?}"))?;
    assert!(codes(&session).is_empty());
    assert!(!session.result().imports.is_empty());
    assert!(session.matches_cold_analysis());
    Ok(())
}

#[test]
fn invalid_document_operations_preserve_workspace_revision() -> Result<(), String> {
    let mut session =
        WorkspaceSession::new(snapshot(project_files())).map_err(|error| format!("{error:?}"))?;
    let initial_revision = session.result().revision_id;
    assert_eq!(
        session.open_document("missing", 1, MAIN.to_owned()),
        Err(pseudolearn_service::WorkspaceError::DocumentNotFound)
    );
    assert_eq!(session.result().revision_id, initial_revision);
    session
        .open_document("app/main", 1, MAIN.to_owned())
        .map_err(|error| format!("{error:?}"))?;
    let open_revision = session.result().revision_id;
    assert_eq!(
        session.change_document("app/main", 1, "@".to_owned()),
        Err(pseudolearn_service::WorkspaceError::DocumentVersionDidNotAdvance)
    );
    assert_eq!(
        session.close_document("missing"),
        Err(pseudolearn_service::WorkspaceError::DocumentNotOpen)
    );
    assert_eq!(session.result().revision_id, open_revision);
    assert!(session.matches_cold_analysis());
    Ok(())
}

#[test]
fn body_changes_preserve_signatures_and_signature_changes_invalidate_importers()
-> Result<(), String> {
    let mut session =
        WorkspaceSession::new(snapshot(project_files())).map_err(|error| format!("{error:?}"))?;
    let body = LIBRARY.replace("n * 2", "n * 3");
    session
        .open_document("geo/vectores", 1, body)
        .map_err(|error| format!("{error:?}"))?;
    let invalidation = &session.result().invalidation;
    assert!(
        invalidation
            .changed_modules
            .contains(&"geo/vectores".to_owned())
    );
    assert!(
        !invalidation
            .signature_changed_modules
            .contains(&"geo/vectores".to_owned())
    );
    assert!(
        !invalidation
            .invalidated_modules
            .contains(&"app/main".to_owned())
    );
    let signature = "Publico SubProceso Doble(n Como Entero, factor Como Entero) Como Entero\nRetornar n * factor;\nFinSubProceso\n";
    session
        .change_document("geo/vectores", 2, signature.to_owned())
        .map_err(|error| format!("{error:?}"))?;
    assert!(
        session
            .result()
            .invalidation
            .signature_changed_modules
            .contains(&"geo/vectores".to_owned())
    );
    assert!(
        session
            .result()
            .invalidation
            .invalidated_modules
            .contains(&"app/main".to_owned())
    );
    assert!(session.matches_cold_analysis());
    Ok(())
}

#[test]
fn closing_an_overlay_restores_the_latest_snapshot_and_deleted_file() -> Result<(), String> {
    let mut session =
        WorkspaceSession::new(snapshot(project_files())).map_err(|error| format!("{error:?}"))?;
    session
        .open_document("app/main", 1, "@".to_owned())
        .map_err(|error| format!("{error:?}"))?;
    let mut latest = snapshot(vec![
        file("app/main", 1, "Algoritmo P\nEscribir 2;\nFinAlgoritmo\n"),
        file("geo/vectores", 2, LIBRARY),
    ]);
    latest.project.revision_id = 2;
    session
        .update_snapshot(latest, pseudolearn_service::SnapshotUpdateMode::Advance)
        .map_err(|error| format!("{error:?}"))?;
    assert!(!codes(&session).is_empty());
    session
        .close_document("app/main")
        .map_err(|error| format!("{error:?}"))?;
    assert!(codes(&session).is_empty());
    assert!(session.matches_cold_analysis());
    session
        .open_document("geo/vectores", 1, LIBRARY.to_owned())
        .map_err(|error| format!("{error:?}"))?;
    let mut deleted = snapshot(vec![file("app/main", 1, MAIN)]);
    deleted.project.revision_id = 3;
    session
        .update_snapshot(deleted, pseudolearn_service::SnapshotUpdateMode::Advance)
        .map_err(|error| format!("{error:?}"))?;
    session
        .close_document("geo/vectores")
        .map_err(|error| format!("{error:?}"))?;
    assert_eq!(
        session.change_document("geo/vectores", 2, LIBRARY.to_owned()),
        Err(pseudolearn_service::WorkspaceError::DocumentNotOpen)
    );
    assert!(!codes(&session).is_empty());
    assert!(session.matches_cold_analysis());
    Ok(())
}

#[test]
fn resynchronization_compares_full_text_and_configuration_inputs() -> Result<(), String> {
    let mut current = snapshot(vec![file(
        "app/main",
        1,
        "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n",
    )]);
    current.options.requested_profile = Some(Profile::Spanish);
    current.options.dependency_inputs.insert(
        "app/pseudolearn.lock".to_owned(),
        "digest = \"aaaa\"\n".to_owned(),
    );
    let mut session =
        WorkspaceSession::new(current.clone()).map_err(|error| format!("{error:?}"))?;
    let same_size_text = "Algoritmo P\nEscribir 2;\nFinAlgoritmo\n";
    let Some(first_file) = current.project.files.first_mut() else {
        return Err("workspace fixture has no files".to_owned());
    };
    first_file.text = same_size_text.to_owned();
    current.options.dependency_inputs.insert(
        "app/pseudolearn.lock".to_owned(),
        "digest = \"bbbb\"\n".to_owned(),
    );
    session
        .update_snapshot(
            current,
            pseudolearn_service::SnapshotUpdateMode::Resynchronize,
        )
        .map_err(|error| format!("{error:?}"))?;
    assert!(
        session
            .result()
            .invalidation
            .changed_modules
            .contains(&"app/main".to_owned())
    );
    assert!(session.matches_cold_analysis());
    Ok(())
}

#[test]
fn manifests_update_profiles_and_project_structure() -> Result<(), String> {
    let grants = HostGrants::default();
    let manifest_text = "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"app/main\"]\nprofile = \"es\"\n";
    let configuration = Configuration::resolve(&ManifestRequest {
        text: manifest_text,
        location: "app",
        grants: &grants,
        max_bytes: 4096,
    })
    .map_err(|errors| format!("{errors:?}"))?;
    let mut initial = snapshot(vec![file("app/main", 1, MAIN)]);
    initial.project.packages = vec![configuration.package_input()];
    initial.options.configurations = vec![configuration];
    let mut session =
        WorkspaceSession::new(initial.clone()).map_err(|error| format!("{error:?}"))?;
    let english = manifest_text.replace("profile = \"es\"", "profile = \"en\"");
    let updated = Configuration::resolve(&ManifestRequest {
        text: &english,
        location: "app",
        grants: &grants,
        max_bytes: 4096,
    })
    .map_err(|errors| format!("{errors:?}"))?;
    initial.project.revision_id = 2;
    initial.project.packages = vec![updated.package_input()];
    initial.options.configurations = vec![updated];
    session
        .update_snapshot(initial, pseudolearn_service::SnapshotUpdateMode::Advance)
        .map_err(|error| format!("{error:?}"))?;
    assert!(
        session
            .result()
            .invalidation
            .signature_changed_modules
            .contains(&"app/main".to_owned())
    );
    assert!(session.matches_cold_analysis());
    Ok(())
}

#[test]
fn empty_projects_and_homonymous_roots_keep_session_identity() -> Result<(), String> {
    let empty =
        WorkspaceSession::new(snapshot(Vec::new())).map_err(|error| format!("{error:?}"))?;
    assert!(!empty.result().project_errors.is_empty());
    assert!(empty.matches_cold_analysis());
    let first = WorkspaceSession::new(snapshot(vec![file(
        "app/main",
        1,
        "Algoritmo P\nFinAlgoritmo\n",
    )]))
    .map_err(|error| format!("{error:?}"))?;
    let mut second_snapshot = snapshot(vec![file("app/main", 1, "Algoritmo P\nFinAlgoritmo\n")]);
    second_snapshot.project.project_id = 8;
    let second = WorkspaceSession::new(second_snapshot).map_err(|error| format!("{error:?}"))?;
    assert_eq!(first.result().project_id, 7);
    assert_eq!(second.result().project_id, 8);
    assert!(first.matches_cold_analysis() && second.matches_cold_analysis());
    Ok(())
}

#[test]
fn snapshot_file_order_does_not_change_analysis() -> Result<(), String> {
    let first =
        WorkspaceSession::new(snapshot(project_files())).map_err(|error| format!("{error:?}"))?;
    let reverse = vec![file("geo/vectores", 2, LIBRARY), file("app/main", 1, MAIN)];
    let second = WorkspaceSession::new(snapshot(reverse)).map_err(|error| format!("{error:?}"))?;
    assert_eq!(first.result().hir, second.result().hir);
    assert_eq!(first.result().diagnostics, second.result().diagnostics);
    assert_eq!(first.result().imports, second.result().imports);
    Ok(())
}
