use std::path::PathBuf;

struct Vector {
    name: &'static str,
    file: &'static str,
    test: &'static str,
}

const REQUIRED: [&str; 24] = [
    "alternative_numeric_ipv4",
    "ipv4_mapped_ipv6",
    "ipv6_loopback",
    "unspecified_ipv4",
    "metadata_link_local",
    "trailing_dot_hostname",
    "uppercase_hostname",
    "user_info_hostname",
    "percent_encoded_hostname",
    "ungranted_port",
    "mixed_public_private_dns",
    "dns_rebinding",
    "redirect_to_http",
    "cross_origin_authorization_redirect",
    "environment_proxy",
    "crlf_header",
    "forbidden_header",
    "wrong_host_certificate",
    "expired_certificate",
    "self_signed_certificate",
    "gzip_expansion",
    "infinite_body",
    "never_responding_server",
    "seeded_combinations",
];

const REGISTRY: [Vector; 24] = [
    vector(
        "alternative_numeric_ipv4",
        "src/network_address_policy_tests.rs",
        "rejects_alternative_numeric_ip_forms",
    ),
    vector(
        "ipv4_mapped_ipv6",
        "src/network_address_policy_tests.rs",
        "rejects_ssrf_ranges_for_ipv4_and_ipv6",
    ),
    vector(
        "ipv6_loopback",
        "src/network_address_policy_tests.rs",
        "rejects_ssrf_ranges_for_ipv4_and_ipv6",
    ),
    vector(
        "unspecified_ipv4",
        "src/network_address_policy_tests.rs",
        "rejects_ssrf_ranges_for_ipv4_and_ipv6",
    ),
    vector(
        "metadata_link_local",
        "src/network_address_policy_tests.rs",
        "rejects_ssrf_ranges_for_ipv4_and_ipv6",
    ),
    vector(
        "trailing_dot_hostname",
        "src/network_resolver_tests.rs",
        "rejects_a_forbidden_address_from_a_trailing_dot_hostname",
    ),
    vector(
        "uppercase_hostname",
        "src/physical_network_tests.rs",
        "compares_hostnames_without_case_but_keeps_the_granted_port",
    ),
    vector(
        "user_info_hostname",
        "src/physical_network_tests.rs",
        "rejects_insecure_or_non_origin_network_values",
    ),
    vector(
        "percent_encoded_hostname",
        "src/physical_network_tests.rs",
        "rejects_insecure_or_non_origin_network_values",
    ),
    vector(
        "ungranted_port",
        "src/physical_network_tests.rs",
        "enforces_granted_origins_for_complete_request_urls",
    ),
    vector(
        "mixed_public_private_dns",
        "src/network_resolver_tests.rs",
        "rejects_every_address_if_any_resolution_is_forbidden",
    ),
    vector(
        "dns_rebinding",
        "src/network_resolver_tests.rs",
        "dns_rebinding_cannot_change_the_single_checked_snapshot",
    ),
    vector(
        "redirect_to_http",
        "tests/network_adapter_contract.rs",
        "matches_statuses_bodies_and_redirects_from_the_local_contract_server",
    ),
    vector(
        "cross_origin_authorization_redirect",
        "tests/network_adapter_contract.rs",
        "matches_statuses_bodies_and_redirects_from_the_local_contract_server",
    ),
    vector(
        "environment_proxy",
        "src/physical_network_tls_send_tests.rs",
        "ignores_the_https_proxy_environment_variable",
    ),
    vector(
        "crlf_header",
        "tests/network_security_vectors.rs",
        "crlf_request_headers_are_rejected_before_connecting",
    ),
    vector(
        "forbidden_header",
        "tests/network_security_vectors.rs",
        "forbidden_request_headers_are_rejected_before_connecting",
    ),
    vector(
        "wrong_host_certificate",
        "src/physical_network_tls_send_tests.rs",
        "rejects_expired_wrong_host_and_untrusted_self_signed_certificates",
    ),
    vector(
        "expired_certificate",
        "src/physical_network_tls_send_tests.rs",
        "rejects_expired_wrong_host_and_untrusted_self_signed_certificates",
    ),
    vector(
        "self_signed_certificate",
        "src/physical_network_tls_send_tests.rs",
        "rejects_expired_wrong_host_and_untrusted_self_signed_certificates",
    ),
    vector(
        "gzip_expansion",
        "tests/network_adapter_contract.rs",
        "matches_statuses_bodies_and_redirects_from_the_local_contract_server",
    ),
    vector(
        "infinite_body",
        "tests/network_adapter_contract.rs",
        "matches_statuses_bodies_and_redirects_from_the_local_contract_server",
    ),
    vector(
        "never_responding_server",
        "src/physical_network_stream_tests.rs",
        "times_out_when_server_never_sends_a_response",
    ),
    vector(
        "seeded_combinations",
        "src/network_resolver_tests.rs",
        "seeded_host_port_and_dns_combinations_preserve_address_policy",
    ),
];

const fn vector(name: &'static str, file: &'static str, test: &'static str) -> Vector {
    Vector { name, file, test }
}

fn read(relative: &str) -> Option<String> {
    let root = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    std::fs::read_to_string(root.join(relative)).ok()
}

fn uncovered(
    registry: &[Vector],
    required: &[&str],
    source: impl Fn(&str) -> Option<String>,
) -> Vec<String> {
    let mut missing: Vec<String> = required
        .iter()
        .filter(|name| registry.iter().all(|vector| vector.name != **name))
        .map(|name| format!("unregistered vector {name}"))
        .collect();
    for vector in registry {
        let declared =
            source(vector.file).is_some_and(|text| text.contains(&format!("fn {}(", vector.test)));
        if !declared {
            missing.push(format!(
                "vector {} has no test {}",
                vector.name, vector.test
            ));
        }
    }
    missing
}

#[test]
fn every_required_network_vector_has_a_test() {
    assert_eq!(uncovered(&REGISTRY, &REQUIRED, read), Vec::<String>::new());
}

#[test]
fn a_registered_vector_without_a_test_is_reported() {
    let registry = [vector(
        "alternative_numeric_ipv4",
        "tests/network_security_vectors.rs",
        "missing_test",
    )];
    assert_eq!(
        uncovered(&registry, &["alternative_numeric_ipv4"], read),
        vec!["vector alternative_numeric_ipv4 has no test missing_test".to_owned()]
    );
}

#[test]
fn a_required_vector_missing_from_the_registry_is_reported() {
    assert_eq!(
        uncovered(&[], &["alternative_numeric_ipv4"], read),
        vec!["unregistered vector alternative_numeric_ipv4".to_owned()]
    );
}

#[test]
fn an_unreadable_test_file_is_reported() {
    let registry = [vector(
        "alternative_numeric_ipv4",
        "tests/missing_network_tests.rs",
        "rejects_alternative_numeric_ip_forms",
    )];
    assert_eq!(
        uncovered(&registry, &["alternative_numeric_ipv4"], read).len(),
        1
    );
}
