use super::linker_directory_for;
use std::ffi::OsString;
use std::path::PathBuf;

fn lookup_from(
    pairs: &'static [(&'static str, &'static str)],
) -> impl Fn(&str) -> Option<OsString> {
    move |name| {
        pairs
            .iter()
            .find(|(variable, _)| *variable == name)
            .map(|(_, value)| OsString::from(value))
    }
}

fn expected(parts: &[&str]) -> PathBuf {
    let mut path = PathBuf::new();
    path.extend(parts);
    path.join("pseudolearn").join("linker").join("v1")
}

#[test]
fn macos_uses_the_library_caches_of_home() {
    let lookup = lookup_from(&[("HOME", "/home/user")]);
    assert_eq!(
        linker_directory_for("macos", "v1", &lookup),
        Some(expected(&["/home/user", "Library", "Caches"]))
    );
}

#[test]
fn linux_prefers_xdg_cache_home_over_home() {
    let lookup = lookup_from(&[("HOME", "/home/user"), ("XDG_CACHE_HOME", "/cache")]);
    assert_eq!(
        linker_directory_for("linux", "v1", &lookup),
        Some(expected(&["/cache"]))
    );
}

#[test]
fn linux_falls_back_to_the_dot_cache_of_home() {
    let lookup = lookup_from(&[("HOME", "/home/user"), ("XDG_CACHE_HOME", "")]);
    assert_eq!(
        linker_directory_for("linux", "v1", &lookup),
        Some(expected(&["/home/user", ".cache"]))
    );
}

#[test]
fn windows_uses_local_app_data() {
    let lookup = lookup_from(&[("LOCALAPPDATA", "C:/Users/user/AppData/Local")]);
    assert_eq!(
        linker_directory_for("windows", "v1", &lookup),
        Some(expected(&["C:/Users/user/AppData/Local"]))
    );
}

#[test]
fn empty_or_missing_variables_leave_no_cache_directory() {
    let lookup = lookup_from(&[("HOME", ""), ("LOCALAPPDATA", "")]);
    assert_eq!(linker_directory_for("macos", "v1", &lookup), None);
    assert_eq!(linker_directory_for("windows", "v1", &lookup), None);
    assert_eq!(linker_directory_for("linux", "v1", &lookup_from(&[])), None);
}

#[test]
fn an_unknown_operating_system_has_no_cache_directory() {
    let lookup = lookup_from(&[("HOME", "/home/user")]);
    assert_eq!(linker_directory_for("plan9", "v1", &lookup), None);
}
