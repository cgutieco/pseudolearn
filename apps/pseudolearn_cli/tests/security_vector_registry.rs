use std::path::PathBuf;

struct Vector {
    name: &'static str,
    file: &'static str,
    test: &'static str,
}

const REQUIRED: [&str; 8] = [
    "parent_escape",
    "absolute_path",
    "outgoing_symbolic_link",
    "nul_in_path",
    "rights_amplification",
    "use_after_close",
    "tape_bit_flip",
    "tape_truncation",
];

const REGISTRY: [Vector; 8] = [
    Vector {
        name: "parent_escape",
        file: "tests/security_vectors.rs",
        test: "parent_directory_escape_is_blocked",
    },
    Vector {
        name: "absolute_path",
        file: "tests/security_vectors.rs",
        test: "absolute_path_is_blocked",
    },
    Vector {
        name: "outgoing_symbolic_link",
        file: "tests/security_vectors.rs",
        test: "outgoing_symbolic_link_is_blocked",
    },
    Vector {
        name: "nul_in_path",
        file: "src/physical_host_tests.rs",
        test: "rejects_absolute_parent_and_nul_paths",
    },
    Vector {
        name: "rights_amplification",
        file: "tests/security_vectors.rs",
        test: "write_amplification_from_a_read_only_grant_is_blocked",
    },
    Vector {
        name: "use_after_close",
        file: "tests/security_vectors.rs",
        test: "use_after_close_is_blocked",
    },
    Vector {
        name: "tape_bit_flip",
        file: "tests/security_vectors.rs",
        test: "single_bit_flip_in_the_tape_is_rejected",
    },
    Vector {
        name: "tape_truncation",
        file: "tests/security_vectors.rs",
        test: "truncated_tape_is_rejected",
    },
];

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
fn every_required_attack_vector_has_a_blocking_test() {
    assert_eq!(uncovered(&REGISTRY, &REQUIRED, read), Vec::<String>::new());
}

#[test]
fn a_vector_without_a_test_is_reported() {
    let registry = [Vector {
        name: "parent_escape",
        file: "tests/security_vectors.rs",
        test: "does_not_exist",
    }];
    let missing = uncovered(&registry, &["parent_escape"], read);
    assert_eq!(
        missing,
        vec!["vector parent_escape has no test does_not_exist".to_owned()]
    );
}

#[test]
fn a_required_vector_missing_from_the_registry_is_reported() {
    let missing = uncovered(&[], &["parent_escape"], read);
    assert_eq!(
        missing,
        vec!["unregistered vector parent_escape".to_owned()]
    );
}

#[test]
fn an_unreadable_test_file_is_reported() {
    let registry = [Vector {
        name: "parent_escape",
        file: "tests/absent.rs",
        test: "parent_directory_escape_is_blocked",
    }];
    assert_eq!(uncovered(&registry, &["parent_escape"], read).len(), 1);
}
