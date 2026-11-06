use super::{
    LinkFormat, LinkInputs, TARGETS, find_target, host_target, lld_arguments, supported_triples,
};
use std::path::{Path, PathBuf};

fn rendered(triple: &str, support: &[PathBuf]) -> Vec<String> {
    let Some(target) = find_target(triple) else {
        return Vec::new();
    };
    let inputs = LinkInputs {
        object: Path::new("w/program.o"),
        archive: Path::new("w/runtime.a"),
        support,
        output: Path::new("w/program"),
    };
    lld_arguments(target, &inputs)
        .iter()
        .map(|argument| argument.to_string_lossy().into_owned())
        .collect()
}

fn paths(names: &[&str]) -> Vec<PathBuf> {
    names.iter().map(|name| Path::new("w").join(name)).collect()
}

#[test]
fn mach_o_targets_link_with_the_darwin_flavor_and_generated_stubs() {
    assert_eq!(
        rendered("aarch64-apple-darwin", &paths(&["system.tbd"])),
        [
            "-flavor",
            "darwin",
            "-arch",
            "arm64",
            "-platform_version",
            "macos",
            "11.0",
            "11.0",
            "-dead_strip",
            "-o",
            "w/program",
            "w/program.o",
            "w/runtime.a",
            "w/system.tbd",
        ]
    );
    let intel = rendered("x86_64-apple-darwin", &[]);
    assert_eq!(intel.get(3).map(String::as_str), Some("x86_64"));
}

#[test]
fn the_elf_target_links_statically_between_the_musl_start_and_end_objects() {
    let support = paths(&[
        "crt1.o",
        "crti.o",
        "crtbegin.o",
        "crtend.o",
        "crtn.o",
        "libc.a",
        "libunwind.a",
    ]);
    assert_eq!(
        rendered("x86_64-unknown-linux-musl", &support),
        [
            "-flavor",
            "gnu",
            "-m",
            "elf_x86_64",
            "-static",
            "--gc-sections",
            "-o",
            "w/program",
            "w/crt1.o",
            "w/crti.o",
            "w/crtbegin.o",
            "w/program.o",
            "w/runtime.a",
            "--start-group",
            "w/libunwind.a",
            "w/libc.a",
            "--end-group",
            "w/crtend.o",
            "w/crtn.o",
        ]
    );
}

#[test]
fn missing_elf_support_files_are_left_out() {
    let text = rendered("x86_64-unknown-linux-musl", &paths(&["crt1.o"]));
    assert!(text.contains(&"w/crt1.o".to_owned()));
    assert!(!text.iter().any(|argument| argument.ends_with("libc.a")));
}

#[test]
fn the_coff_target_uses_its_own_entry_without_default_libraries() {
    assert_eq!(
        rendered("x86_64-pc-windows-msvc", &paths(&["kernel32.lib"])),
        [
            "-flavor",
            "link",
            "/nologo",
            "/subsystem:console",
            "/entry:mainCRTStartup",
            "/nodefaultlib",
            "/opt:ref",
            "/machine:x64",
            "/out:w/program",
            "w/program.o",
            "w/runtime.a",
            "w/kernel32.lib",
        ]
    );
}

#[test]
fn only_the_windows_target_produces_an_exe() {
    for target in TARGETS {
        assert_eq!(
            target.executable_suffix == ".exe",
            target.format == LinkFormat::Coff
        );
    }
}

#[test]
fn the_supported_list_is_the_closed_list_of_four_targets() {
    assert_eq!(
        supported_triples(),
        "aarch64-apple-darwin, x86_64-apple-darwin, x86_64-unknown-linux-musl, x86_64-pc-windows-msvc"
    );
    assert!(find_target("riscv64gc-unknown-linux-gnu").is_none());
    assert!(find_target("").is_none());
}

#[test]
fn the_host_target_is_one_of_the_declared_targets() {
    if let Some(target) = host_target() {
        assert!(
            TARGETS
                .iter()
                .any(|declared| declared.triple == target.triple)
        );
    }
}
