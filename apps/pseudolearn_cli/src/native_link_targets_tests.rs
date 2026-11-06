use super::{TARGETS, host_target, lld_arguments};
use std::path::Path;

#[test]
fn each_target_builds_its_arguments_as_data() {
    for target in TARGETS {
        let arguments = lld_arguments(
            target,
            &[Path::new("a.o"), Path::new("b.a")],
            Path::new("out"),
        );
        let text: Vec<String> = arguments
            .iter()
            .map(|argument| argument.to_string_lossy().into_owned())
            .collect();
        assert_eq!(text.get(1).map(String::as_str), Some(target.flavor));
        assert_eq!(text.get(3).map(String::as_str), Some(target.architecture));
        assert!(text.ends_with(&["out".to_owned(), "a.o".to_owned(), "b.a".to_owned()]));
    }
}

#[test]
fn an_empty_input_list_still_names_the_output() {
    let Some(target) = TARGETS.first() else {
        return;
    };
    let arguments = lld_arguments(target, &[], Path::new("program"));
    assert_eq!(
        arguments
            .last()
            .map(|argument| argument.to_string_lossy().into_owned()),
        Some("program".to_owned())
    );
}

#[test]
fn the_host_target_is_one_of_the_declared_targets() {
    if let Some(target) = host_target() {
        assert!(TARGETS.contains(target));
    }
}
