use super::{AssetFetcher, LinkerUnavailable, installed_linker, sha256_hex};
use crate::linker_assets::LinkerAsset;
use sha2::{Digest, Sha256};
use std::cell::Cell;
use std::fmt::Write as TextWrite;
use std::io::Write;
use std::path::{Path, PathBuf};

const PAYLOAD: &[u8] = b"#!/bin/sh\necho linker\n";
const URL: &str = "https://example.invalid/lld.gz";

struct Scratch(PathBuf);

impl Drop for Scratch {
    fn drop(&mut self) {
        let _removed = std::fs::remove_dir_all(&self.0);
    }
}

fn scratch(label: &str) -> Scratch {
    Scratch(std::env::temp_dir().join(format!("pseudo_linker_{label}_{}", std::process::id())))
}

struct ServedBytes {
    bytes: Vec<u8>,
    calls: Cell<u32>,
}

impl AssetFetcher for ServedBytes {
    fn fetch(&self, _url: &str, destination: &Path) -> bool {
        self.calls.set(self.calls.get().saturating_add(1));
        std::fs::write(destination, &self.bytes).is_ok()
    }
}

struct Offline;

impl AssetFetcher for Offline {
    fn fetch(&self, _url: &str, _destination: &Path) -> bool {
        false
    }
}

fn compressed(payload: &[u8]) -> Vec<u8> {
    let mut encoder = flate2::write::GzEncoder::new(Vec::new(), flate2::Compression::fast());
    let _written = encoder.write_all(payload);
    encoder.finish().unwrap_or_default()
}

fn digest(bytes: &[u8]) -> String {
    Sha256::digest(bytes)
        .iter()
        .fold(String::new(), |mut text, byte| {
            let _written = write!(text, "{byte:02x}");
            text
        })
}

fn asset(sha256: String, size: usize) -> LinkerAsset {
    LinkerAsset {
        operating_system: "test",
        architecture: "test",
        url: URL,
        asset_sha256: Box::leak(sha256.into_boxed_str()),
        binary_name: "lld",
        binary_size: u64::try_from(size).unwrap_or(u64::MAX),
    }
}

fn served(bytes: Vec<u8>) -> ServedBytes {
    ServedBytes {
        bytes,
        calls: Cell::new(0),
    }
}

fn leftovers(directory: &Path) -> Vec<String> {
    std::fs::read_dir(directory)
        .map(|entries| {
            entries
                .filter_map(Result::ok)
                .map(|entry| entry.file_name().to_string_lossy().into_owned())
                .filter(|name| name.starts_with('.'))
                .collect()
        })
        .unwrap_or_default()
}

#[test]
fn a_matching_checksum_installs_the_expanded_linker() {
    let directory = scratch("matching");
    let archive = compressed(PAYLOAD);
    let fetcher = served(archive.clone());
    let installed = installed_linker(
        &asset(digest(&archive), PAYLOAD.len()),
        &directory.0,
        &fetcher,
    );
    let path = directory.0.join("lld");
    assert_eq!(installed, Ok(path.clone()));
    assert_eq!(std::fs::read(&path).unwrap_or_default(), PAYLOAD);
    assert_eq!(leftovers(&directory.0), Vec::<String>::new());
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        let mode = std::fs::metadata(&path).map_or(0, |metadata| metadata.permissions().mode());
        assert_eq!(mode & 0o111, 0o111);
    }
}

#[test]
fn a_wrong_checksum_is_rejected_without_installing() {
    let directory = scratch("wrong");
    let fetcher = served(compressed(PAYLOAD));
    let installed = installed_linker(
        &asset(digest(b"other"), PAYLOAD.len()),
        &directory.0,
        &fetcher,
    );
    assert_eq!(
        installed,
        Err(LinkerUnavailable::ChecksumMismatch(URL.to_owned()))
    );
    assert!(!directory.0.join("lld").exists());
    assert_eq!(leftovers(&directory.0), Vec::<String>::new());
}

#[test]
fn an_unreachable_publication_is_a_download_failure() {
    let directory = scratch("offline");
    let installed = installed_linker(&asset(digest(b"x"), 1), &directory.0, &Offline);
    assert_eq!(
        installed,
        Err(LinkerUnavailable::DownloadFailed(URL.to_owned()))
    );
    assert!(!directory.0.join("lld").exists());
    assert_eq!(leftovers(&directory.0), Vec::<String>::new());
}

#[test]
fn a_cached_linker_of_the_pinned_size_is_reused_without_fetching() {
    let directory = scratch("cached");
    let _created = std::fs::create_dir_all(&directory.0);
    let _written = std::fs::write(directory.0.join("lld"), PAYLOAD);
    let fetcher = served(Vec::new());
    let installed = installed_linker(&asset(digest(b"x"), PAYLOAD.len()), &directory.0, &fetcher);
    assert_eq!(installed, Ok(directory.0.join("lld")));
    assert_eq!(fetcher.calls.get(), 0);
}

#[test]
fn a_cached_linker_of_another_size_is_replaced() {
    let directory = scratch("stale");
    let _created = std::fs::create_dir_all(&directory.0);
    let _written = std::fs::write(directory.0.join("lld"), b"stale");
    let archive = compressed(PAYLOAD);
    let fetcher = served(archive.clone());
    let installed = installed_linker(
        &asset(digest(&archive), PAYLOAD.len()),
        &directory.0,
        &fetcher,
    );
    assert_eq!(installed, Ok(directory.0.join("lld")));
    assert_eq!(fetcher.calls.get(), 1);
    assert_eq!(
        std::fs::read(directory.0.join("lld")).unwrap_or_default(),
        PAYLOAD
    );
}

#[test]
fn an_expanded_size_other_than_the_pinned_one_is_a_mismatch() {
    let directory = scratch("size");
    let archive = compressed(PAYLOAD);
    let fetcher = served(archive.clone());
    let installed = installed_linker(
        &asset(digest(&archive), PAYLOAD.len().saturating_add(1)),
        &directory.0,
        &fetcher,
    );
    assert_eq!(
        installed,
        Err(LinkerUnavailable::ChecksumMismatch(URL.to_owned()))
    );
    assert!(!directory.0.join("lld").exists());
}

#[test]
fn the_checksum_of_an_empty_file_is_the_known_digest() {
    let directory = scratch("empty");
    let _created = std::fs::create_dir_all(&directory.0);
    let path = directory.0.join("empty");
    let _written = std::fs::write(&path, b"");
    assert_eq!(
        sha256_hex(&path).as_deref(),
        Some("e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
    );
    assert_eq!(sha256_hex(&directory.0.join("absent")), None);
}
