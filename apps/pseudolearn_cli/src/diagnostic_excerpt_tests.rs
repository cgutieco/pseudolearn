use super::excerpt;

#[test]
fn points_at_the_missing_terminator_column() {
    let source = "Algoritmo P\n  x <- 1\nFinAlgoritmo\n";

    assert_eq!(
        excerpt(source, 2, 9),
        "    2 |   x <- 1\n      |         ^\n"
    );
}

#[test]
fn widens_the_gutter_with_the_line_number() {
    let source = format!("{}abc\n", "\n".repeat(11));

    assert_eq!(excerpt(&source, 12, 2), "    12 | abc\n       |  ^\n");
}

#[test]
fn shows_only_the_first_line_of_a_span_start() {
    assert_eq!(excerpt("a\r\nb\r\n", 1, 1), "    1 | a\n      | ^\n");
}

#[test]
fn expands_tabs_to_four_columns_before_aligning() {
    assert_eq!(excerpt("\tx\n", 1, 2), "    1 |     x\n      |     ^\n");
}

#[test]
fn trims_a_long_line_around_the_marker_with_ellipses() {
    let source = format!("{}\n", "a".repeat(200));
    let expected_line = format!("…{}…", "a".repeat(78));

    let rendered = excerpt(&source, 1, 100);

    assert_eq!(
        rendered,
        format!("    1 | {expected_line}\n      | {}^\n", " ".repeat(40))
    );
}

#[test]
fn keeps_the_start_of_a_long_line_when_the_marker_is_near_it() {
    let source = format!("{}\n", "b".repeat(200));
    let expected_line = format!("{}…", "b".repeat(79));

    assert_eq!(
        excerpt(&source, 1, 1),
        format!("    1 | {expected_line}\n      | ^\n")
    );
}

#[test]
fn renders_an_empty_source_first_line() {
    assert_eq!(excerpt("", 1, 1), "    1 | \n      | ^\n");
}

#[test]
fn renders_nothing_for_a_line_outside_the_source() {
    assert_eq!(excerpt("a\n", 0, 1), "");
    assert_eq!(excerpt("a\n", 9, 1), "");
}
