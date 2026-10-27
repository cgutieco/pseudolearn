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

fn changed(change: impl Fn(&mut ExecuteRequest)) -> pseudolearn_timeline::ExecutionIdentity {
    let mut changed = request("Algoritmo Main\nFinAlgoritmo\n");
    change(&mut changed);
    build_identity(&changed)
}

#[test]
fn identical_requests_yield_identical_identities() {
    let baseline = build_identity(&request("Algoritmo Main\nFinAlgoritmo\n"));
    assert!(baseline.matches(&changed(|_| {})));
}

#[test]
fn every_identity_component_changes_the_identity() {
    let baseline = build_identity(&request("Algoritmo Main\nFinAlgoritmo\n"));
    let variants = [
        changed(|request| request.seed = request.seed.wrapping_add(1)),
        changed(|request| request.limits.statements = Some(10)),
        changed(|request| request.limits.micro_steps = Some(10)),
        changed(|request| request.strictness = "flexible".to_owned()),
        changed(|request| request.profile = "en".to_owned()),
        changed(|request| request.program.push('\n')),
        changed(|request| {
            request.host = Some(serde_json::json!({"permissions":["reloj"]}));
        }),
    ];
    for (index, variant) in variants.iter().enumerate() {
        assert!(!baseline.matches(variant), "variant {index}");
    }
}
