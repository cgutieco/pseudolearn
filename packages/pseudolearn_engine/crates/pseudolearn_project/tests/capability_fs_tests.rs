use pseudolearn_project::{CapabilityFsError, ConfinedDirectory, FileRights};

#[test]
fn read_only_rights_allow_read_and_forbid_write() {
    let rights = FileRights::READ_ONLY;
    assert!(rights.read);
    assert!(!rights.write);
}

#[test]
fn read_write_rights_allow_both() {
    let rights = FileRights::READ_WRITE;
    assert!(rights.read);
    assert!(rights.write);
}

#[test]
fn attenuation_prevents_amplification() {
    let read_only = FileRights::READ_ONLY;
    let read_write = FileRights::READ_WRITE;
    let outcome = read_only.attenuate(read_write);
    assert_eq!(outcome, Err(CapabilityFsError::AmplificationDenied));
    let attenuated = read_write.attenuate(read_only);
    assert_eq!(attenuated, Ok(FileRights::READ_ONLY));
}

#[test]
fn confined_directory_validates_relative_subpaths() -> Result<(), String> {
    let directory = ConfinedDirectory::new("workspace/sandbox".to_owned(), FileRights::READ_WRITE)
        .ok_or("invalid root")?;
    assert_eq!(directory.root, "workspace/sandbox");
    let resolved = directory
        .resolve_subpath("records/student.csv")
        .map_err(|failure_code| format!("{failure_code:?}"))?;
    assert_eq!(resolved, "workspace/sandbox/records/student.csv");
    Ok(())
}

#[test]
fn confined_directory_derives_attenuated_subdirectory() -> Result<(), String> {
    let directory = ConfinedDirectory::new("workspace/sandbox".to_owned(), FileRights::READ_WRITE)
        .ok_or("invalid root")?;
    let subdirectory = directory
        .derive_subdirectory("reports", FileRights::READ_ONLY)
        .map_err(|failure_code| format!("{failure_code:?}"))?;
    assert_eq!(subdirectory.root, "workspace/sandbox/reports");
    assert_eq!(subdirectory.rights, FileRights::READ_ONLY);
    Ok(())
}

#[test]
fn confined_directory_rejects_parent_traversal() {
    let directory = ConfinedDirectory::new("workspace/sandbox".to_owned(), FileRights::READ_WRITE);
    let Some(valid_directory) = directory else {
        return;
    };
    let traversal_outcome = valid_directory.resolve_subpath("../outside.txt");
    assert_eq!(traversal_outcome, Err(CapabilityFsError::EscapeAttempt));
}

#[test]
fn confined_directory_rejects_absolute_paths() {
    let directory = ConfinedDirectory::new("workspace/sandbox".to_owned(), FileRights::READ_WRITE);
    let Some(valid_directory) = directory else {
        return;
    };
    let absolute_outcome = valid_directory.resolve_subpath("/etc/passwd");
    assert_eq!(absolute_outcome, Err(CapabilityFsError::InvalidPath));
}
