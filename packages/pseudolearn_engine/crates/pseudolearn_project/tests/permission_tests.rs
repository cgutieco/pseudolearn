use pseudolearn_project::PermissionName;

#[test]
fn parses_network_permission_in_both_facets() {
    assert_eq!(PermissionName::parse("red"), Some(PermissionName::Network));
    assert_eq!(
        PermissionName::parse("network"),
        Some(PermissionName::Network)
    );
    assert_eq!(PermissionName::Network.as_str(), "red");
}

#[test]
fn rejects_permissions_outside_the_closed_vocabulary() {
    assert_eq!(PermissionName::parse("http"), None);
    assert_eq!(PermissionName::parse("network_access"), None);
}
