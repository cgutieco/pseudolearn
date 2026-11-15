pub fn cells(row: &str) -> Vec<String> {
    let inner = row.trim().trim_start_matches('|').trim_end_matches('|');
    inner
        .split('|')
        .map(|cell| cell.trim().to_owned())
        .collect()
}

pub fn is_separator(cells: &[String]) -> bool {
    !cells.is_empty()
        && cells.iter().all(|cell| {
            !cell.is_empty() && cell.chars().all(|character| matches!(character, '-' | ':'))
        })
}

pub fn assemble_table(rows: Vec<Vec<String>>) -> Result<reference_model::SourceBlock, String> {
    let mut parsed = Vec::new();
    for row in rows.into_iter().filter(|row| !is_separator(row)) {
        let cells = row
            .iter()
            .map(|cell| crate::inline_parser::parse_inline(cell))
            .collect::<Result<Vec<_>, String>>()?;
        parsed.push(cells);
    }
    let mut rows = parsed.into_iter();
    let header = rows
        .next()
        .ok_or_else(|| "a table needs a header row".to_owned())?;
    Ok(reference_model::SourceBlock::Table {
        header,
        rows: rows.collect(),
    })
}
