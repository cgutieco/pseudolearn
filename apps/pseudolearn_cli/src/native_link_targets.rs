use std::ffi::OsString;
use std::path::{Path, PathBuf};

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) enum LinkFormat {
    MachO,
    Elf,
    Coff,
}

pub(crate) struct LinkInputs<'paths> {
    pub(crate) object: &'paths Path,
    pub(crate) archive: &'paths Path,
    pub(crate) support: &'paths [PathBuf],
    pub(crate) output: &'paths Path,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) struct LinkTarget {
    pub(crate) triple: &'static str,
    pub(crate) flavor: &'static str,
    pub(crate) architecture: &'static str,
    pub(crate) format: LinkFormat,
    pub(crate) executable_suffix: &'static str,
    pub(crate) object_name: &'static str,
    pub(crate) archive_name: &'static str,
    host: (&'static str, &'static str),
}

pub(crate) const TARGETS: &[LinkTarget] = &[
    LinkTarget {
        triple: "aarch64-apple-darwin",
        flavor: "darwin",
        architecture: "arm64",
        format: LinkFormat::MachO,
        executable_suffix: "",
        object_name: "program.o",
        archive_name: "runtime.a",
        host: ("macos", "aarch64"),
    },
    LinkTarget {
        triple: "x86_64-apple-darwin",
        flavor: "darwin",
        architecture: "x86_64",
        format: LinkFormat::MachO,
        executable_suffix: "",
        object_name: "program.o",
        archive_name: "runtime.a",
        host: ("macos", "x86_64"),
    },
    LinkTarget {
        triple: "x86_64-unknown-linux-musl",
        flavor: "gnu",
        architecture: "elf_x86_64",
        format: LinkFormat::Elf,
        executable_suffix: "",
        object_name: "program.o",
        archive_name: "runtime.a",
        host: ("linux", "x86_64"),
    },
    LinkTarget {
        triple: "x86_64-pc-windows-msvc",
        flavor: "link",
        architecture: "x64",
        format: LinkFormat::Coff,
        executable_suffix: ".exe",
        object_name: "program.obj",
        archive_name: "runtime.lib",
        host: ("windows", "x86_64"),
    },
];

const ELF_LEADING: &[&str] = &["crt1.o", "crti.o", "crtbegin.o"];
const ELF_LIBRARIES: &[&str] = &["libunwind.a", "libc.a"];
const ELF_TRAILING: &[&str] = &["crtend.o", "crtn.o"];

pub(crate) fn find_target(triple: &str) -> Option<&'static LinkTarget> {
    TARGETS.iter().find(|target| target.triple == triple)
}

pub(crate) fn host_target() -> Option<&'static LinkTarget> {
    TARGETS
        .iter()
        .find(|target| target.host == (std::env::consts::OS, std::env::consts::ARCH))
}

pub(crate) fn supported_triples() -> String {
    TARGETS
        .iter()
        .map(|target| target.triple)
        .collect::<Vec<_>>()
        .join(", ")
}

pub(crate) fn lld_arguments(target: &LinkTarget, inputs: &LinkInputs<'_>) -> Vec<OsString> {
    let mut arguments: Vec<OsString> = vec!["-flavor".into(), target.flavor.into()];
    match target.format {
        LinkFormat::MachO => mach_o_arguments(target, inputs, &mut arguments),
        LinkFormat::Elf => elf_arguments(target, inputs, &mut arguments),
        LinkFormat::Coff => coff_arguments(target, inputs, &mut arguments),
    }
    arguments
}

fn mach_o_arguments(target: &LinkTarget, inputs: &LinkInputs<'_>, arguments: &mut Vec<OsString>) {
    for flag in [
        "-arch",
        target.architecture,
        "-platform_version",
        "macos",
        "11.0",
        "11.0",
        "-dead_strip",
        "-o",
    ] {
        arguments.push(flag.into());
    }
    arguments.push(inputs.output.into());
    arguments.push(inputs.object.into());
    arguments.push(inputs.archive.into());
    arguments.extend(inputs.support.iter().map(OsString::from));
}

fn elf_arguments(target: &LinkTarget, inputs: &LinkInputs<'_>, arguments: &mut Vec<OsString>) {
    for flag in ["-m", target.architecture, "-static", "--gc-sections", "-o"] {
        arguments.push(flag.into());
    }
    arguments.push(inputs.output.into());
    push_named(arguments, inputs.support, ELF_LEADING);
    arguments.push(inputs.object.into());
    arguments.push(inputs.archive.into());
    arguments.push("--start-group".into());
    push_named(arguments, inputs.support, ELF_LIBRARIES);
    arguments.push("--end-group".into());
    push_named(arguments, inputs.support, ELF_TRAILING);
}

fn coff_arguments(target: &LinkTarget, inputs: &LinkInputs<'_>, arguments: &mut Vec<OsString>) {
    for flag in [
        "/nologo",
        "/subsystem:console",
        "/entry:mainCRTStartup",
        "/nodefaultlib",
        "/opt:ref",
    ] {
        arguments.push(flag.into());
    }
    arguments.push(format!("/machine:{}", target.architecture).into());
    let mut output = OsString::from("/out:");
    output.push(inputs.output);
    arguments.push(output);
    arguments.push(inputs.object.into());
    arguments.push(inputs.archive.into());
    arguments.extend(inputs.support.iter().map(OsString::from));
}

fn push_named(arguments: &mut Vec<OsString>, support: &[PathBuf], names: &[&str]) {
    for name in names {
        if let Some(path) = support
            .iter()
            .find(|path| path.file_name().is_some_and(|file| file == *name))
        {
            arguments.push(path.into());
        }
    }
}

#[cfg(test)]
#[path = "native_link_targets_tests.rs"]
mod native_link_targets_tests;
