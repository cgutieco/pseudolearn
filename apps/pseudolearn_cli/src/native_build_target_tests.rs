use super::{executable_suffix, link_failure, requested_target};
use crate::error::CliError;
use crate::linker_download::LinkerUnavailable;
use crate::native_link_targets::find_target;
use crate::native_linker::LinkFailure;

const SUPPORTED: &str =
    "aarch64-apple-darwin, x86_64-apple-darwin, x86_64-unknown-linux-musl, x86_64-pc-windows-msvc";

#[test]
fn a_triple_outside_the_closed_list_is_a_usage_error_naming_the_list() {
    let refused = requested_target(Some("riscv64gc-unknown-linux-gnu"), "es");
    assert_eq!(
        refused,
        Err(CliError::Usage(format!(
            "pseudo: el destino nativo riscv64gc-unknown-linux-gnu no está disponible; destinos admitidos: {SUPPORTED}\n"
        )))
    );
    assert!(matches!(
        requested_target(Some(""), "en"),
        Err(CliError::Usage(_))
    ));
}

#[test]
fn the_default_target_is_the_host_when_its_runtime_is_embedded() {
    let chosen = requested_target(None, "es");
    if let Ok(Some(target)) = chosen {
        assert!(crate::runtime_archive::archive_for(target.triple).is_some());
    }
}

#[test]
fn a_listed_target_without_an_embedded_runtime_is_operational() {
    for target in crate::native_link_targets::TARGETS {
        let outcome = requested_target(Some(target.triple), "en");
        if crate::runtime_archive::archive_for(target.triple).is_none() {
            assert_eq!(
                outcome,
                Err(CliError::Operational(format!(
                    "pseudo: this pseudo binary does not include the runtime for target {}\n",
                    target.triple
                )))
            );
        } else {
            assert_eq!(
                outcome.map(|found| found.map(|chosen| chosen.triple)),
                Ok(Some(target.triple))
            );
        }
    }
}

#[test]
fn the_windows_target_names_its_output_with_exe() {
    assert_eq!(
        executable_suffix(find_target("x86_64-pc-windows-msvc")),
        ".exe"
    );
    assert_eq!(
        executable_suffix(find_target("x86_64-unknown-linux-musl")),
        ""
    );
    assert_eq!(executable_suffix(None), std::env::consts::EXE_SUFFIX);
}

#[test]
fn each_unavailable_cause_has_its_own_message() {
    let url = "https://example.invalid/lld.gz".to_owned();
    let cases = [
        (
            LinkFailure::Unavailable(LinkerUnavailable::CacheUnavailable),
            "pseudo: cannot obtain the bundled linker: no user cache directory\n".to_owned(),
        ),
        (
            LinkFailure::Unavailable(LinkerUnavailable::DownloadFailed(url.clone())),
            format!("pseudo: cannot obtain the bundled linker: the download of {url} failed\n"),
        ),
        (
            LinkFailure::Unavailable(LinkerUnavailable::ChecksumMismatch(url.clone())),
            format!(
                "pseudo: cannot obtain the bundled linker: the SHA-256 checksum of {url} does not match\n"
            ),
        ),
        (
            LinkFailure::Failed("lld: error: undefined symbol: x".to_owned()),
            "pseudo: linking the executable failed\nlld: error: undefined symbol: x\n".to_owned(),
        ),
    ];
    for (failure, expected) in cases {
        assert_eq!(
            link_failure("en", &failure),
            CliError::Operational(expected)
        );
    }
}
