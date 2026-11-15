#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) struct LinkerAsset {
    pub(crate) operating_system: &'static str,
    pub(crate) architecture: &'static str,
    pub(crate) url: &'static str,
    pub(crate) asset_sha256: &'static str,
    pub(crate) binary_name: &'static str,
    pub(crate) binary_size: u64,
}

pub(crate) const LINKER_VERSION: &str = "lld-23.1.5";
pub(crate) const BUNDLED_LINKER_NAME: &str = "lld";

pub(crate) const ASSETS: &[LinkerAsset] = &[
    LinkerAsset {
        operating_system: "macos",
        architecture: "aarch64",
        url: "https://github.com/cgutieco/pseudolearn/releases/download/linker-lld-23.1.5/lld-23.1.5-aarch64-apple-darwin.gz",
        asset_sha256: "ed0df4ca1b946592f1767d5f5f6a912a5acf98e4a585c25ce5568361b36dc3da",
        binary_name: "lld",
        binary_size: 146_162_912,
    },
    LinkerAsset {
        operating_system: "macos",
        architecture: "x86_64",
        url: "https://github.com/cgutieco/pseudolearn/releases/download/linker-lld-23.1.5/lld-23.1.5-x86_64-apple-darwin.gz",
        asset_sha256: "bf6e584ca5badd81dcb9e57081976b07a456b0bfafa8bb5d2b66b98ac87c66d2",
        binary_name: "lld",
        binary_size: 64_996_112,
    },
    LinkerAsset {
        operating_system: "linux",
        architecture: "x86_64",
        url: "https://github.com/cgutieco/pseudolearn/releases/download/linker-lld-23.1.5/lld-23.1.5-x86_64-unknown-linux-gnu.gz",
        asset_sha256: "0fc9dba3ecfcf5b2cfe341d89b5308829a335efbdcb47ae2ff5b331940db6f5a",
        binary_name: "lld",
        binary_size: 213_113_960,
    },
    LinkerAsset {
        operating_system: "windows",
        architecture: "x86_64",
        url: "https://github.com/cgutieco/pseudolearn/releases/download/linker-lld-23.1.5/lld-23.1.5-x86_64-pc-windows-msvc.exe.gz",
        asset_sha256: "4973932977c26832249ee2be6670e0caebc88d322d6a626c1b7c789f1c524475",
        binary_name: "lld.exe",
        binary_size: 76_348_928,
    },
];

pub(crate) fn asset_for(
    operating_system: &str,
    architecture: &str,
) -> Option<&'static LinkerAsset> {
    ASSETS.iter().find(|asset| {
        asset.operating_system == operating_system && asset.architecture == architecture
    })
}

pub(crate) fn host_asset() -> Option<&'static LinkerAsset> {
    asset_for(std::env::consts::OS, std::env::consts::ARCH)
}

#[cfg(test)]
#[path = "linker_assets_tests.rs"]
mod linker_assets_tests;
