use std::path::PathBuf;

struct Vector {
    name: &'static str,
    file: &'static str,
    test: &'static str,
}

const REQUIRED: [&str; 11] = [
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
];

const REGISTRY: [Vector; 11] = [
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
        "../../packages/pseudolearn_engine/crates/pseudolearn_host/src/physical_network_tls_send_tests.rs",
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
        "../../packages/pseudolearn_engine/crates/pseudolearn_host/src/physical_network_tls_send_tests.rs",
        "rejects_expired_wrong_host_and_untrusted_self_signed_certificates",
    ),
    vector(
        "expired_certificate",
        "../../packages/pseudolearn_engine/crates/pseudolearn_host/src/physical_network_tls_send_tests.rs",
        "rejects_expired_wrong_host_and_untrusted_self_signed_certificates",
    ),
    vector(
        "self_signed_certificate",
        "../../packages/pseudolearn_engine/crates/pseudolearn_host/src/physical_network_tls_send_tests.rs",
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
        "../../packages/pseudolearn_engine/crates/pseudolearn_host/src/physical_network_stream_tests.rs",
        "times_out_when_server_never_sends_a_response",
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
