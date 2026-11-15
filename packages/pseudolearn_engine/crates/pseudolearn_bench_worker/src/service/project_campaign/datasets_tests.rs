use crate::service::project_campaign::datasets::{Edit, GraphPlan, graph};
use crate::service::project_campaign::functional::judge;
use crate::service::project_campaign::profiles::{PAIR_COUNT, modules_dataset, pairs_dataset};
use crate::service::project_campaign::shapes::Shape;

fn plan(shape: Shape, count: usize, edit: Edit) -> GraphPlan {
    GraphPlan {
        shape,
        count,
        lines_per_file: 9,
        edit,
    }
}

#[test]
fn every_shape_runs_to_the_expected_output_derived_from_its_formula() {
    for shape in Shape::ALL {
        for count in [3, 4, 10] {
            let dataset = graph(&plan(shape, count, Edit::None));
            assert_eq!(judge(&dataset), None, "{}", dataset.name);
        }
    }
}

#[test]
fn a_body_edit_changes_the_expected_output_and_a_signature_edit_does_not() {
    let base = graph(&plan(Shape::Star, 10, Edit::None));
    let body = graph(&plan(Shape::Star, 10, Edit::Body));
    let signature = graph(&plan(Shape::Star, 10, Edit::Signature));
    assert_ne!(base.expected_output, body.expected_output);
    assert_eq!(base.expected_output, signature.expected_output);
    assert_ne!(
        base.files.get(1).map(|file| &file.text),
        signature.files.get(1).map(|file| &file.text)
    );
    assert_eq!(judge(&body), None);
    assert_eq!(judge(&signature), None);
}

#[test]
fn generation_is_deterministic_and_a_wrong_expectation_is_caught() {
    let first = graph(&plan(Shape::Chain, 10, Edit::None));
    let second = graph(&plan(Shape::Chain, 10, Edit::None));
    assert_eq!(
        first.files.get(3).map(|file| &file.text),
        second.files.get(3).map(|file| &file.text)
    );
    let mut wrong = graph(&plan(Shape::Chain, 10, Edit::None));
    wrong.expected_output = "0\n".to_owned();
    assert!(judge(&wrong).is_some());
}

#[test]
fn the_library_shape_keeps_its_leaves_in_the_library_package() {
    let dataset = graph(&plan(Shape::Library, 5, Edit::None));
    assert_eq!(dataset.packages.len(), 2);
    assert!(
        dataset
            .files
            .iter()
            .skip(1)
            .all(|file| file.path.starts_with("lib/"))
    );
}

#[test]
fn mixed_profile_datasets_run_equal_to_their_single_profile_controls() {
    for (mixed, control) in [
        (modules_dataset(true), modules_dataset(false)),
        (pairs_dataset(true), pairs_dataset(false)),
    ] {
        assert_eq!(mixed.expected_output, control.expected_output);
        assert_eq!(judge(&mixed), None, "{}", mixed.name);
        assert_eq!(judge(&control), None, "{}", control.name);
        assert!(control.files.iter().all(|file| file.profile.is_none()));
    }
}

#[test]
fn the_pairs_declare_their_keyword_collisions_and_alias_them() {
    let mixed = pairs_dataset(true);
    let entry = mixed.files.first().map_or("", |file| file.text.as_str());
    assert_eq!(entry.matches(" Como Alias").count(), 5);
    assert_eq!(mixed.files.len(), 2 * PAIR_COUNT + 1);
    assert!(
        pairs_dataset(false)
            .files
            .first()
            .is_some_and(|file| !file.text.contains(" Como Alias"))
    );
}
