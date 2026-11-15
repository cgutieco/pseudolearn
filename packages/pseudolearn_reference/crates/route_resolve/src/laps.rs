use reference_model::LapTable;

pub const LAP_OPEN: &str = "⟦";
pub const LAP_CLOSE: &str = "⟧";

pub fn instrument(code: &str, table: &LapTable) -> String {
    let probe = probe_line(&table.columns);
    let mut lines: Vec<String> = code.lines().map(str::to_owned).collect();
    let mut points = vec![table.mark];
    points.extend(table.start);
    points.sort_unstable();
    for point in points.into_iter().rev() {
        let position = point.saturating_sub(1).min(lines.len());
        lines.insert(position, probe.clone());
    }
    let mut instrumented = lines.join("\n");
    instrumented.push('\n');
    instrumented
}

fn probe_line(columns: &[String]) -> String {
    let joined = columns.join(", \"|\", ");
    format!("Escribir \"{LAP_OPEN}\", {joined}, \"{LAP_CLOSE}\";")
}

pub fn observed_rows(output: &str) -> Vec<Vec<String>> {
    output
        .lines()
        .filter_map(|line| {
            line.trim()
                .strip_prefix(LAP_OPEN)
                .and_then(|rest| rest.strip_suffix(LAP_CLOSE))
        })
        .map(|row| row.split('|').map(|cell| cell.trim().to_owned()).collect())
        .collect()
}
