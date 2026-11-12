use crate::linker_assets::LinkerAsset;
use sha2::{Digest, Sha256};
use std::fmt::Write;
use std::io::Read;
use std::path::{Path, PathBuf};
use std::time::Duration;

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) enum LinkerUnavailable {
    CacheUnavailable,
    DownloadFailed(String),
    ChecksumMismatch(String),
}

pub(crate) trait AssetFetcher {
    fn fetch(&self, url: &str, destination: &Path) -> bool;
}

pub(crate) struct NetworkFetcher;

const DOWNLOAD_LIMIT: u64 = 512 * 1024 * 1024;
const DOWNLOAD_TIMEOUT: Duration = Duration::from_mins(15);
const REDIRECT_LIMIT: u8 = 5;
const USER_AGENT: &str = "pseudolearn-cli";

impl AssetFetcher for NetworkFetcher {
    fn fetch(&self, url: &str, destination: &Path) -> bool {
        let request = pseudolearn_host::DownloadRequest {
            url: url.to_owned(),
            byte_limit: DOWNLOAD_LIMIT,
            redirect_limit: REDIRECT_LIMIT,
            timeout: DOWNLOAD_TIMEOUT,
            user_agent: USER_AGENT.to_owned(),
        };
        let tls = pseudolearn_host::TlsConfiguration::from_host_roots(Vec::new());
        pseudolearn_host::download_to_file(&request, destination, &tls).is_ok()
    }
}

struct StagedFiles(Vec<PathBuf>);

impl Drop for StagedFiles {
    fn drop(&mut self) {
        for path in &self.0 {
            let _removed = std::fs::remove_file(path);
        }
    }
}

pub(crate) fn installed_linker(
    asset: &LinkerAsset,
    directory: &Path,
    fetcher: &dyn AssetFetcher,
) -> Result<PathBuf, LinkerUnavailable> {
    let binary = directory.join(asset.binary_name);
    if file_size(&binary) == Some(asset.binary_size) {
        return Ok(binary);
    }
    std::fs::create_dir_all(directory).map_err(|_| LinkerUnavailable::CacheUnavailable)?;
    let stem = format!(".{}-{}-{}", asset.binary_name, std::process::id(), nanos());
    let staged = StagedFiles(vec![
        directory.join(format!("{stem}.gz")),
        directory.join(format!("{stem}.partial")),
    ]);
    let [compressed, expanded] = staged.0.as_slice() else {
        return Err(LinkerUnavailable::CacheUnavailable);
    };
    let failed_download = || LinkerUnavailable::DownloadFailed(asset.url.to_owned());
    let mismatch = || LinkerUnavailable::ChecksumMismatch(asset.url.to_owned());
    if !fetcher.fetch(asset.url, compressed) {
        return Err(failed_download());
    }
    if sha256_hex(compressed).as_deref() != Some(asset.asset_sha256) {
        return Err(mismatch());
    }
    expand(compressed, expanded).map_err(|_| mismatch())?;
    if file_size(expanded) != Some(asset.binary_size) {
        return Err(mismatch());
    }
    mark_executable(expanded).map_err(|_| LinkerUnavailable::CacheUnavailable)?;
    std::fs::rename(expanded, &binary).map_err(|_| LinkerUnavailable::CacheUnavailable)?;
    Ok(binary)
}

fn file_size(path: &Path) -> Option<u64> {
    std::fs::metadata(path)
        .ok()
        .filter(std::fs::Metadata::is_file)
        .map(|metadata| metadata.len())
}

fn nanos() -> u128 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map_or(0, |duration| duration.as_nanos())
}

pub(crate) fn sha256_hex(path: &Path) -> Option<String> {
    let mut file = std::fs::File::open(path).ok()?;
    let mut hasher = Sha256::new();
    let mut block = vec![0_u8; 1 << 16];
    loop {
        let count = file.read(&mut block).ok()?;
        if count == 0 {
            break;
        }
        hasher.update(block.get(..count)?);
    }
    Some(
        hasher
            .finalize()
            .iter()
            .fold(String::new(), |mut text, byte| {
                let _written = write!(text, "{byte:02x}");
                text
            }),
    )
}

fn expand(compressed: &Path, expanded: &Path) -> std::io::Result<()> {
    let mut decoder = flate2::read::GzDecoder::new(std::fs::File::open(compressed)?);
    let mut output = std::fs::File::create(expanded)?;
    std::io::copy(&mut decoder, &mut output)?;
    Ok(())
}

#[cfg(unix)]
fn mark_executable(path: &Path) -> std::io::Result<()> {
    use std::os::unix::fs::PermissionsExt;
    std::fs::set_permissions(path, std::fs::Permissions::from_mode(0o755))
}

#[cfg(not(unix))]
fn mark_executable(_path: &Path) -> std::io::Result<()> {
    Ok(())
}

#[cfg(test)]
#[path = "linker_download_tests.rs"]
mod linker_download_tests;
