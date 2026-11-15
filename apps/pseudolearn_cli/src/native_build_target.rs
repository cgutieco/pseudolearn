use crate::error::CliError;
use crate::linker_download::LinkerUnavailable;
use crate::messages;
use crate::native_link_targets::{LinkTarget, find_target, host_target, supported_triples};
use crate::native_linker::LinkFailure;

pub(crate) fn requested_target(
    requested: Option<&str>,
    locale: &str,
) -> Result<Option<&'static LinkTarget>, CliError> {
    let target = match requested {
        None => host_target(),
        Some(triple) => Some(find_target(triple).ok_or_else(|| {
            CliError::Usage(messages::render(
                "nativeTargetUnavailable",
                locale,
                &[("target", triple), ("targets", &supported_triples())],
            ))
        })?),
    };
    if let Some(chosen) = target
        && crate::runtime_archive::archive_for(chosen.triple).is_none()
    {
        return Err(CliError::Operational(messages::render(
            "nativeTargetRuntimeMissing",
            locale,
            &[("target", chosen.triple)],
        )));
    }
    Ok(target)
}

pub(crate) fn executable_suffix(target: Option<&LinkTarget>) -> &'static str {
    target.map_or(std::env::consts::EXE_SUFFIX, |chosen| {
        chosen.executable_suffix
    })
}

pub(crate) fn link_failure(locale: &str, failure: &LinkFailure) -> CliError {
    let message = match failure {
        LinkFailure::RuntimeMissing(triple) => {
            messages::render("nativeTargetRuntimeMissing", locale, &[("target", triple)])
        }
        LinkFailure::Unavailable(LinkerUnavailable::CacheUnavailable) => {
            messages::render("linkerCacheUnavailable", locale, &[])
        }
        LinkFailure::Unavailable(LinkerUnavailable::DownloadFailed(url)) => {
            messages::render("linkerDownloadFailed", locale, &[("url", url)])
        }
        LinkFailure::Unavailable(LinkerUnavailable::ChecksumMismatch(url)) => {
            messages::render("linkerChecksumMismatch", locale, &[("url", url)])
        }
        LinkFailure::Failed(report) => {
            let mut text = messages::render("linkerFailed", locale, &[]);
            text.push_str(report);
            if !text.ends_with('\n') {
                text.push('\n');
            }
            text
        }
    };
    CliError::Operational(message)
}

#[cfg(test)]
#[path = "native_build_target_tests.rs"]
mod native_build_target_tests;
