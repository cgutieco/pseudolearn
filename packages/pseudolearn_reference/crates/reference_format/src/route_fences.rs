use crate::fence::FenceOpening;
use crate::inline_parser::parse_inline;
use reference_model::{
    AssertionSource, CaseSource, ChoiceSource, ElementSource, LapSource, LapTable, RouteFence,
};

pub fn route_fence(opening: &FenceOpening, name: &str) -> Option<RouteFence> {
    (name == "figura-especificacion").then(|| RouteFence::SpecFigure {
        section: opening.attribute("seccion").unwrap_or_default().to_owned(),
        figure: opening.attribute("figura").unwrap_or_default().to_owned(),
    })
}

pub fn route_body(opening: &FenceOpening, body: &str) -> Result<Option<RouteFence>, String> {
    let lines: Vec<&str> = body
        .lines()
        .map(str::trim)
        .filter(|line| !line.is_empty())
        .collect();
    let fence = match opening.name.as_str() {
        "vueltas" => RouteFence::Laps(laps(opening, &lines)?),
        "casos" => RouteFence::Cases(cases(&lines, true)?),
        "rompe" => RouteFence::Breakers(cases(&lines, false)?),
        "casos-solucion" => RouteFence::SolutionCases {
            minimum: number(opening, "minimo")?,
            maximum: number(opening, "maximo")?,
            cases: cases(&lines, false)?,
        },
        "pasos" => RouteFence::Steps(entries(&lines)?),
        "categorias" => {
            RouteFence::Categories(lines.iter().map(|line| bullet(line).to_owned()).collect())
        }
        "elementos" => RouteFence::Elements(elements(&lines)?),
        "opciones" => RouteFence::Choices(choices(&lines)?),
        "aserciones" => RouteFence::Assertions(assertions(&lines)),
        _ => return Ok(None),
    };
    Ok(Some(fence))
}

fn number(opening: &FenceOpening, key: &str) -> Result<usize, String> {
    let text = opening
        .attribute(key)
        .ok_or_else(|| format!("the `{}` block needs `{key}`", opening.name))?;
    text.parse::<usize>()
        .map_err(|_| format!("invalid number `{text}` for `{key}`"))
}

fn laps(opening: &FenceOpening, lines: &[&str]) -> Result<LapTable, String> {
    let columns = opening
        .attribute("columnas")
        .unwrap_or_default()
        .split(',')
        .map(|column| column.trim().to_owned())
        .filter(|column| !column.is_empty())
        .collect::<Vec<String>>();
    if columns.is_empty() {
        return Err("the `vueltas` block needs `columnas`".to_owned());
    }
    let start = match opening.attribute("inicio") {
        Some(_) => Some(number(opening, "inicio")?),
        None => None,
    };
    let rows = lines
        .iter()
        .map(|line| {
            let mut cells = cells(line).into_iter();
            LapSource {
                label: cells.next().unwrap_or_default(),
                cells: cells.collect(),
            }
        })
        .collect();
    Ok(LapTable {
        mark: number(opening, "marca")?,
        start,
        columns,
        rows,
    })
}

fn cells(line: &str) -> Vec<String> {
    line.split(" | ")
        .map(|cell| cell.trim().to_owned())
        .collect()
}

fn cases(lines: &[&str], with_visibility: bool) -> Result<Vec<CaseSource>, String> {
    lines
        .iter()
        .map(|line| case(line, with_visibility))
        .collect()
}

fn case(line: &str, with_visibility: bool) -> Result<CaseSource, String> {
    let mut columns = cells(line).into_iter();
    let hidden = if with_visibility {
        match columns.next().as_deref() {
            Some("visible") => false,
            Some("oculto") => true,
            other => {
                return Err(format!(
                    "a case starts with visible or oculto, not {other:?}"
                ));
            }
        }
    } else {
        false
    };
    let inputs = columns
        .next()
        .map(|text| split_inputs(&text))
        .unwrap_or_default();
    let expected = columns.next().map(|text| text.replace(" ⏎ ", "\n"));
    Ok(CaseSource {
        hidden,
        inputs,
        expected,
    })
}

fn split_inputs(text: &str) -> Vec<String> {
    if text.is_empty() || text == "—" {
        return Vec::new();
    }
    text.split(" ; ").map(str::to_owned).collect()
}

fn bullet(line: &str) -> &str {
    line.strip_prefix("- ").unwrap_or(line).trim()
}

fn entries(lines: &[&str]) -> Result<Vec<Vec<reference_model::Inline>>, String> {
    lines
        .iter()
        .map(|line| parse_inline(bullet(line)))
        .collect()
}

fn elements(lines: &[&str]) -> Result<Vec<ElementSource>, String> {
    lines
        .iter()
        .map(|line| {
            let (text, category) = bullet(line)
                .rsplit_once(" | ")
                .ok_or_else(|| format!("an element needs `text | category`: {line}"))?;
            Ok(ElementSource {
                text: parse_inline(text.trim())?,
                category: category.trim().to_owned(),
            })
        })
        .collect()
}

fn choices(lines: &[&str]) -> Result<Vec<ChoiceSource>, String> {
    lines
        .iter()
        .map(|line| {
            let entry = bullet(line);
            let (correct, rest) = match entry.strip_prefix("[x] ") {
                Some(rest) => (true, rest),
                None => (false, entry.strip_prefix("[ ] ").unwrap_or(entry)),
            };
            let (text, justification) = rest.split_once(" | ").unwrap_or((rest, ""));
            Ok(ChoiceSource {
                correct,
                text: parse_inline(text.trim())?,
                justification: parse_inline(justification.trim())?,
            })
        })
        .collect()
}

fn assertions(lines: &[&str]) -> Vec<AssertionSource> {
    lines
        .iter()
        .map(|line| {
            let mut fields = cells(bullet(line));
            let requirement = fields.pop().unwrap_or_default();
            let kind = if fields.is_empty() {
                String::new()
            } else {
                fields.remove(0)
            };
            AssertionSource {
                kind,
                fields,
                requirement,
            }
        })
        .collect()
}
