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

#[test]
fn macos_style_paths_keep_spaces_unicode_and_the_root() -> Result<(), crate::IoError> {
    assert_eq!(
        normalize("/Users/ana/Mis Documentos/../ñandú/./datos.txt")?,
        "/Users/ana/ñandú/datos.txt"
    );
    assert_eq!(
        join("/Users/ana", "../bea/notas.txt", None)?,
        "/Users/bea/notas.txt"
    );
    assert_eq!(normalize("/..")?, "/");
    Ok(())
}

#[test]
fn windows_drive_relative_and_mixed_separators_resolve_against_the_working_folder()
-> Result<(), crate::IoError> {
    assert_eq!(
        join("C:/work", "sub\\file.txt", None)?,
        "C:/work/sub/file.txt"
    );
    assert_eq!(
        join("C:/work", "D:\\other\\..\\file.txt", None)?,
        "D:/file.txt"
    );
    assert_eq!(
        join("//server/share", "..\\file.txt", None)?,
        "//server/file.txt"
    );
    Ok(())
}

#[test]
fn a_confined_root_rejects_drive_letters_and_unc_prefixes() {
    assert!(join("work", "C:\\outside", Some("work")).is_err());
    assert!(join("work", "\\\\server\\share", Some("work")).is_err());
}
