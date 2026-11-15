use serde_json::Value;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) enum Stream {
    Output,
    Error,
}

pub(crate) fn error_ranges(response: &Value) -> Vec<(usize, usize)> {
    response
        .get("error_ranges")
        .and_then(Value::as_array)
        .map(|ranges| {
            ranges
                .iter()
                .filter_map(|range| {
                    let bounds = range.as_array()?;
                    let start = usize::try_from(bounds.first()?.as_u64()?).ok()?;
                    let end = usize::try_from(bounds.get(1)?.as_u64()?).ok()?;
                    Some((start, end))
                })
                .collect()
        })
        .unwrap_or_default()
}

pub(crate) fn segments<'text>(
    output: &'text str,
    printed: usize,
    errors: &[(usize, usize)],
) -> Vec<(Stream, &'text str)> {
    let mut found = Vec::new();
    let mut cursor = printed;
    for (start, end) in errors {
        let start = (*start).max(cursor);
        if *end <= start {
            continue;
        }
        if let Some(plain) = output.get(cursor..start).filter(|text| !text.is_empty()) {
            found.push((Stream::Output, plain));
        }
        if let Some(failed) = output.get(start..*end) {
            found.push((Stream::Error, failed));
        }
        cursor = *end;
    }
    if let Some(rest) = output.get(cursor..).filter(|text| !text.is_empty()) {
        found.push((Stream::Output, rest));
    }
    found
}

#[cfg(test)]
mod tests {
    use super::{Stream, segments};

    #[test]
    fn splits_output_around_error_ranges_in_program_order() {
        let found = segments("ab\nERR\ncd\n", 0, &[(3, 7)]);
        assert_eq!(
            found,
            vec![
                (Stream::Output, "ab\n"),
                (Stream::Error, "ERR\n"),
                (Stream::Output, "cd\n")
            ]
        );
    }

    #[test]
    fn skips_what_was_already_printed() {
        let found = segments("ab\nERR\ncd\n", 7, &[(3, 7)]);
        assert_eq!(found, vec![(Stream::Output, "cd\n")]);
    }

    #[test]
    fn keeps_a_partly_printed_error_range_from_the_cursor() {
        let found = segments("ab\nERR\n", 5, &[(3, 7)]);
        assert_eq!(found, vec![(Stream::Error, "R\n")]);
    }

    #[test]
    fn without_ranges_everything_is_plain_output() {
        assert_eq!(segments("abc", 1, &[]), vec![(Stream::Output, "bc")]);
        assert_eq!(segments("abc", 3, &[]), Vec::new());
    }
}
