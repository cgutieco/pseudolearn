use std::ffi::OsString;
use std::path::Path;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) struct LinkTarget {
    pub(crate) triple: &'static str,
    pub(crate) flavor: &'static str,
    pub(crate) architecture: &'static str,
    pub(crate) stubs: bool,
}

pub(crate) const TARGETS: &[LinkTarget] = &[
    LinkTarget {
        triple: "aarch64-apple-darwin",
        flavor: "darwin",
        architecture: "arm64",
        stubs: true,
    },
    LinkTarget {
        triple: "x86_64-apple-darwin",
        flavor: "darwin",
        architecture: "x86_64",
        stubs: true,
    },
];

pub(crate) fn host_target() -> Option<&'static LinkTarget> {
    let triple = if cfg!(all(target_os = "macos", target_arch = "aarch64")) {
        "aarch64-apple-darwin"
    } else if cfg!(all(target_os = "macos", target_arch = "x86_64")) {
        "x86_64-apple-darwin"
    } else {
        return None;
    };
    TARGETS.iter().find(|target| target.triple == triple)
}

pub(crate) fn lld_arguments(target: &LinkTarget, inputs: &[&Path], output: &Path) -> Vec<OsString> {
    let mut arguments: Vec<OsString> = [
        "-flavor",
        target.flavor,
        "-arch",
        target.architecture,
        "-platform_version",
        "macos",
        "11.0",
        "11.0",
        "-dead_strip",
        "-o",
    ]
    .iter()
    .map(OsString::from)
    .collect();
    arguments.push(output.as_os_str().to_owned());
    arguments.extend(inputs.iter().map(|input| input.as_os_str().to_owned()));
    arguments
}

#[cfg(test)]
#[path = "native_link_targets_tests.rs"]
mod native_link_targets_tests;
