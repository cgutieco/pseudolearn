use pseudolearn_project::{CapabilityFsError, ConfinedDirectory, FileRights};

#[test]
fn parent_traversal_deep_is_rejected() -> Result<(), String> {
    let directory = ConfinedDirectory::new("sandbox/root".to_owned(), FileRights::READ_ONLY);
    let valid = directory.ok_or("invalid directory")?;
    let outcome = valid.resolve_subpath("a/b/../../../etc/shadow");
    assert_eq!(outcome, Err(CapabilityFsError::EscapeAttempt));
    Ok(())
}

#[test]
fn current_directory_segment_is_rejected() -> Result<(), String> {
    let directory = ConfinedDirectory::new("sandbox/root".to_owned(), FileRights::READ_ONLY);
    let valid = directory.ok_or("invalid directory")?;
    let outcome = valid.resolve_subpath("sub/./file.txt");
    assert_eq!(outcome, Err(CapabilityFsError::EscapeAttempt));
    Ok(())
}

#[test]
fn absolute_path_escape_is_rejected() -> Result<(), String> {
    let directory = ConfinedDirectory::new("sandbox/root".to_owned(), FileRights::READ_WRITE);
    let valid = directory.ok_or("invalid directory")?;
    let outcome = valid.resolve_subpath("/var/log/system.log");
    assert_eq!(outcome, Err(CapabilityFsError::InvalidPath));
    Ok(())
}

#[test]
fn rights_attenuation_is_monotonic() {
    let read_only = FileRights::READ_ONLY;
    let read_write = FileRights::READ_WRITE;
    assert_eq!(read_write.attenuate(read_only), Ok(FileRights::READ_ONLY));
    assert_eq!(
        read_only.attenuate(read_write),
        Err(CapabilityFsError::AmplificationDenied)
    );
}
