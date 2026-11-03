use pseudolearn_project::{Configuration, HostGrants, ManifestErrorCode, ManifestRequest};

#[test]
fn retired_authority_field_is_rejected_even_when_empty() {
    let grants = HostGrants::default();
    for value in ["[]", "[\"red\"]", "[\"unknown\"]"] {
        let text = format!(
            "schema = 1\n[package]\nname = \"pkg\"\nkind = \"library\"\n[requests]\npermissions = {value}\n"
        );
        let request = ManifestRequest {
            text: &text,
            location: "app",
            grants: &grants,
            max_bytes: 4096,
        };
        let errors = Configuration::resolve(&request).err().unwrap_or_default();
        assert!(
            errors
                .iter()
                .any(|error| error.code == ManifestErrorCode::UnknownField)
        );
    }
}
