use pseudolearn_api::{ApiSourceIdentity, ExecuteRequest, tape_wire::build_identity};

fn request(program: &str) -> ExecuteRequest {
    ExecuteRequest {
        program: program.to_owned(),
        ..ExecuteRequest::default()
    }
}

#[test]
fn package_graph_digest_is_a_real_deterministic_digest() {
    let first = build_identity(&request("Algoritmo Main\nFinAlgoritmo\n"));
    let second = build_identity(&request("Algoritmo Main\nFinAlgoritmo\n"));
    assert_eq!(first.package_graph_digest, second.package_graph_digest);
    assert_ne!(first.package_graph_digest, "none");
    assert_eq!(first.package_graph_digest.len(), 64);
}

#[test]
fn package_graph_digest_changes_with_the_program() {
    let first = build_identity(&request("Algoritmo Main\nFinAlgoritmo\n"));
    let other = build_identity(&request("Algoritmo Main\nEscribir 1;\nFinAlgoritmo\n"));
    assert_ne!(first.package_graph_digest, other.package_graph_digest);
}

#[test]
fn package_graph_digest_changes_with_the_project_revision() {
    let plain = request("Algoritmo Main\nFinAlgoritmo\n");
    let versioned = ExecuteRequest {
        source: Some(ApiSourceIdentity {
            project_id: 1,
            revision_id: 2,
            source_id: 3,
        }),
        ..plain.clone()
    };
    assert_ne!(
        build_identity(&plain).package_graph_digest,
        build_identity(&versioned).package_graph_digest
    );
}
