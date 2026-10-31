use crate::dap_sources::{SourceSnapshot, Sources};
use serde_json::json;

fn snapshots() -> Sources {
    let mut sources = Sources {
        lines_start_at_one: true,
        columns_start_at_one: true,
        ..Sources::default()
    };
    sources.snapshots.insert(
        0,
        SourceSnapshot {
            path: "/ñ/a.pseudo".to_owned(),
            text: "a𝄞b\r\nsecond".to_owned(),
            revision: None,
        },
    );
    sources
}

#[test]
fn unicode_positions_convert_once_without_splitting_surrogates() -> Result<(), String> {
    let sources = snapshots();
    assert_eq!(sources.location(0, 1, 3), (1, 4));
    assert_eq!(sources.core_location(0, 1, 4)?, (1, 3));
    assert!(sources.core_location(0, 1, 3).is_err());
    assert_eq!(sources.core_location(0, 2, 1)?, (2, 1));
    Ok(())
}

#[test]
fn source_references_preserve_zero_source_and_reject_foreign_identity() -> Result<(), String> {
    let sources = snapshots();
    assert_eq!(sources.identifier(&json!({"sourceReference":1}))?, 0);
    assert!(sources.identifier(&json!({"sourceReference":0})).is_err());
    assert!(
        sources
            .identifier(&json!({"path":"/ñ/a.pseudo/other"}))
            .is_err()
    );
    Ok(())
}

#[test]
fn zero_based_clients_receive_zero_based_coordinates() -> Result<(), String> {
    let mut sources = snapshots();
    sources.lines_start_at_one = false;
    sources.columns_start_at_one = false;
    assert_eq!(sources.location(0, 1, 3), (0, 3));
    assert_eq!(sources.core_location(0, 0, 3)?, (1, 3));
    Ok(())
}

#[test]
fn a_non_canonical_request_path_resolves_to_its_snapshot_and_an_unknown_one_is_rejected()
-> Result<(), Box<dyn std::error::Error>> {
    let directory = std::env::temp_dir().join("pseudo_dap_sources_canonical");
    std::fs::create_dir_all(directory.join("inner"))?;
    let file = directory.join("inner").join("a.pseudo");
    std::fs::write(&file, "")?;
    let mut sources = Sources::default();
    sources.snapshots.insert(
        3,
        SourceSnapshot {
            path: std::fs::canonicalize(&file)?.to_string_lossy().into_owned(),
            text: String::new(),
            revision: None,
        },
    );
    let detour = directory
        .join("inner")
        .join("..")
        .join("inner")
        .join("a.pseudo");
    let resolved = sources.identifier(&json!({"path":detour.to_string_lossy()}));
    let missing =
        sources.identifier(&json!({"path":directory.join("absent.pseudo").to_string_lossy()}));
    std::fs::remove_dir_all(&directory)?;
    assert_eq!(resolved, Ok(3));
    assert!(missing.is_err());
    Ok(())
}
