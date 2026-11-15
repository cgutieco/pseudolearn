use crate::workspace::{load, section_order};

#[test]
fn orders_section_numbers_numerically() {
    let mut numbers = vec!["10.1", "2.10", "2.9", "A", "0.1"];
    numbers.sort_by_key(|number| section_order(number));
    assert_eq!(numbers, vec!["0.1", "2.9", "2.10", "10.1", "A"]);
}

#[test]
fn fails_on_a_missing_workspace() {
    assert!(load(std::path::Path::new("/nonexistent/reference")).is_err());
}
