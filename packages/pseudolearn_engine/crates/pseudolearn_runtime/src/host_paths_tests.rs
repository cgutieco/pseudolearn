use super::{join, normalize};

#[test]
fn normalizes_windows_drives_and_unc_paths() -> Result<(), crate::IoError> {
    assert_eq!(normalize("C:\\work\\..\\data.txt")?, "C:/data.txt");
    assert_eq!(
        normalize("\\\\server\\share\\folder\\file.txt")?,
        "//server/share/folder/file.txt"
    );
    assert_eq!(join("C:/work", "../data.txt", None)?, "C:/data.txt");
    Ok(())
}

#[test]
fn full_authority_accepts_absolute_and_parent_paths() -> Result<(), crate::IoError> {
    assert_eq!(join("work", "../data.txt", None)?, "data.txt");
    assert_eq!(join("work", "/absolute/file", None)?, "/absolute/file");
    Ok(())
}

#[test]
fn a_confined_root_rejects_escape_absolute_and_invalid_paths() -> Result<(), crate::IoError> {
    assert_eq!(join("work/sub", "file", Some("work/sub"))?, "work/sub/file");
    assert!(join("work/sub", "../outside", Some("work/sub")).is_err());
    assert!(join("work/sub", "/outside", Some("work/sub")).is_err());
    assert!(normalize("").is_err());
    assert!(normalize("a\0b").is_err());
    Ok(())
}
