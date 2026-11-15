use super::{ASSETS, LINKER_VERSION, asset_for, host_asset};

#[test]
fn every_asset_pins_a_sha256_and_a_release_url_of_the_version() {
    for asset in ASSETS {
        assert_eq!(asset.asset_sha256.len(), 64);
        assert!(
            asset
                .asset_sha256
                .bytes()
                .all(|byte| byte.is_ascii_hexdigit())
        );
        assert!(asset.url.starts_with(
            "https://github.com/cgutieco/pseudolearn/releases/download/linker-lld-23.1.5/"
        ));
        assert!(
            std::path::Path::new(asset.url)
                .extension()
                .is_some_and(|extension| extension.eq_ignore_ascii_case("gz"))
        );
        assert!(asset.url.contains(LINKER_VERSION));
        assert!(asset.binary_size > 0);
    }
}

#[test]
fn each_host_has_at_most_one_asset() {
    for (position, asset) in ASSETS.iter().enumerate() {
        assert!(ASSETS.iter().skip(position.saturating_add(1)).all(|other| {
            (other.operating_system, other.architecture)
                != (asset.operating_system, asset.architecture)
        }));
    }
}

#[test]
fn the_four_supported_hosts_have_an_asset_and_others_do_not() {
    for (system, architecture) in [
        ("macos", "aarch64"),
        ("macos", "x86_64"),
        ("linux", "x86_64"),
        ("windows", "x86_64"),
    ] {
        assert!(asset_for(system, architecture).is_some());
    }
    assert_eq!(asset_for("linux", "aarch64"), None);
    assert_eq!(asset_for("", ""), None);
}

#[test]
fn windows_assets_name_an_exe_binary() {
    assert_eq!(
        asset_for("windows", "x86_64").map(|asset| asset.binary_name),
        Some("lld.exe")
    );
    assert_eq!(
        asset_for("macos", "aarch64").map(|asset| asset.binary_name),
        Some("lld")
    );
}

#[test]
fn the_host_asset_matches_the_running_system() {
    if let Some(asset) = host_asset() {
        assert_eq!(asset.operating_system, std::env::consts::OS);
        assert_eq!(asset.architecture, std::env::consts::ARCH);
    }
}
