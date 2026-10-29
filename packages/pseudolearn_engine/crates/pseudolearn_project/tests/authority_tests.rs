use pseudolearn_project::{
    Configuration, HostGrants, LimitName, ManifestErrorCode, ManifestRequest, PermissionName,
    Provenance,
};

fn manifest(limits: &[(&str, u64)]) -> String {
    let mut text = String::from("schema = 1\n[package]\nname = \"a\"\nkind = \"library\"\n");
    if !limits.is_empty() {
        text.push_str("[requests.limits]\n");
    }
    for (name, value) in limits {
        text.push_str(&format!("{name} = {value}\n"));
    }
    text
}

fn grants(limits: &[(LimitName, u64)]) -> HostGrants {
    HostGrants {
        limits: limits.iter().copied().collect(),
        permissions: std::collections::BTreeSet::new(),
    }
}

fn resolve(text: &str, grants: &HostGrants) -> Result<Configuration, Vec<ManifestErrorCode>> {
    Configuration::resolve(&ManifestRequest {
        text,
        location: "a",
        grants,
        max_bytes: 4096,
    })
    .map_err(|errors| errors.into_iter().map(|error| error.code).collect())
}

#[test]
fn wider_grant_leaves_the_requested_value() -> Result<(), String> {
    let configuration = resolve(
        &manifest(&[("depth", 50)]),
        &grants(&[(LimitName::Depth, 80)]),
    )
    .map_err(|codes| format!("{codes:?}"))?;
    let authority = configuration
        .limits
        .get(&LimitName::Depth)
        .ok_or("no depth")?;
    assert_eq!(authority.effective, Some(50));
    assert!(matches!(authority.provenance, Provenance::Manifest(_)));
    Ok(())
}

#[test]
fn narrower_grant_cuts_the_request_and_names_the_host() -> Result<(), String> {
    let configuration = resolve(
        &manifest(&[("depth", 50)]),
        &grants(&[(LimitName::Depth, 20)]),
    )
    .map_err(|codes| format!("{codes:?}"))?;
    let authority = configuration
        .limits
        .get(&LimitName::Depth)
        .ok_or("no depth")?;
    assert_eq!(authority.effective, Some(20));
    assert_eq!(authority.provenance, Provenance::Host);
    Ok(())
}

#[test]
fn request_without_grant_is_rejected() {
    let outcome = resolve(
        &manifest(&[("cells", 9)]),
        &grants(&[(LimitName::Depth, 5)]),
    );
    assert_eq!(
        outcome.err(),
        Some(vec![ManifestErrorCode::LimitNotGranted])
    );
}

#[test]
fn grants_alone_apply_nothing() -> Result<(), String> {
    let configuration = resolve(&manifest(&[]), &grants(&[(LimitName::Depth, 5)]))
        .map_err(|codes| format!("{codes:?}"))?;
    assert!(configuration.limits.is_empty());
    Ok(())
}

#[test]
fn equal_request_and_grant_keep_the_manifest_provenance() -> Result<(), String> {
    let configuration = resolve(
        &manifest(&[("statements", 7)]),
        &grants(&[(LimitName::Statements, 7)]),
    )
    .map_err(|codes| format!("{codes:?}"))?;
    let authority = configuration
        .limits
        .get(&LimitName::Statements)
        .ok_or("none")?;
    assert_eq!(authority.effective, Some(7));
    assert!(matches!(authority.provenance, Provenance::Manifest(_)));
    Ok(())
}

#[test]
fn effective_value_never_exceeds_request_or_grant() -> Result<(), String> {
    let mut state: u64 = 17;
    let mut next = move |bound: u64| {
        state = state
            .wrapping_mul(6_364_136_223_846_793_005)
            .wrapping_add(1_442_695_040_888_963_407);
        state
            .checked_shr(33)
            .unwrap_or(0)
            .checked_rem(bound)
            .unwrap_or(0)
    };
    for _ in 0..500 {
        let requested = next(1000).saturating_add(1);
        let granted = next(1000).saturating_add(1);
        let configuration = resolve(
            &manifest(&[("micro_steps", requested)]),
            &grants(&[(LimitName::MicroSteps, granted)]),
        )
        .map_err(|codes| format!("{codes:?}"))?;
        let authority = configuration
            .limits
            .get(&LimitName::MicroSteps)
            .ok_or("none")?;
        let effective = authority.effective.ok_or("no effective value")?;
        assert!(effective <= requested && effective <= granted);
        assert_eq!(effective, requested.min(granted));
    }
    Ok(())
}

#[test]
fn requested_permission_is_effective_only_when_granted() -> Result<(), String> {
    let manifest_source = "schema = 1\n[package]\nname = \"pkg\"\nkind = \"library\"\n[requests]\npermissions = [\"consola\", \"reloj\"]\n";
    let mut granted_permissions = std::collections::BTreeSet::new();
    granted_permissions.insert(PermissionName::Console);
    let host_grants = HostGrants {
        limits: std::collections::BTreeMap::new(),
        permissions: granted_permissions,
    };
    let configuration = resolve(manifest_source, &host_grants)
        .map_err(|failure_codes| format!("{failure_codes:?}"))?;
    assert!(configuration.permissions.contains(&PermissionName::Console));
    assert!(!configuration.permissions.contains(&PermissionName::Clock));
    assert!(
        !configuration
            .permissions
            .contains(&PermissionName::Arguments)
    );
    Ok(())
}

#[test]
fn default_denial_when_no_permissions_granted() -> Result<(), String> {
    let manifest_source = "schema = 1\n[package]\nname = \"pkg\"\nkind = \"library\"\n[requests]\npermissions = [\"archivos_lectura\", \"temporizador\"]\n";
    let host_grants = HostGrants::default();
    let configuration = resolve(manifest_source, &host_grants)
        .map_err(|failure_codes| format!("{failure_codes:?}"))?;
    assert!(configuration.permissions.is_empty());
    Ok(())
}
