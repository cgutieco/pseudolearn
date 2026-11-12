use std::ffi::OsString;
use std::path::PathBuf;

struct CacheRoot {
    operating_system: &'static str,
    variable: &'static str,
    suffix: &'static [&'static str],
}

const CACHE_ROOTS: &[CacheRoot] = &[
    CacheRoot {
        operating_system: "macos",
        variable: "HOME",
        suffix: &["Library", "Caches"],
    },
    CacheRoot {
        operating_system: "linux",
        variable: "XDG_CACHE_HOME",
        suffix: &[],
    },
    CacheRoot {
        operating_system: "linux",
        variable: "HOME",
        suffix: &[".cache"],
    },
    CacheRoot {
        operating_system: "windows",
        variable: "LOCALAPPDATA",
        suffix: &[],
    },
];

const APPLICATION_DIRECTORY: &str = "pseudolearn";
const LINKER_DIRECTORY: &str = "linker";

pub(crate) fn linker_directory_for(
    operating_system: &str,
    version: &str,
    lookup: &dyn Fn(&str) -> Option<OsString>,
) -> Option<PathBuf> {
    CACHE_ROOTS
        .iter()
        .filter(|root| root.operating_system == operating_system)
        .find_map(|root| {
            let value = lookup(root.variable).filter(|value| !value.is_empty())?;
            let mut directory = PathBuf::from(value);
            directory.extend(root.suffix);
            Some(
                directory
                    .join(APPLICATION_DIRECTORY)
                    .join(LINKER_DIRECTORY)
                    .join(version),
            )
        })
}

pub(crate) fn host_linker_directory(version: &str) -> Option<PathBuf> {
    linker_directory_for(std::env::consts::OS, version, &|name| {
        std::env::var_os(name)
    })
}

#[cfg(test)]
#[path = "linker_cache_tests.rs"]
mod linker_cache_tests;
