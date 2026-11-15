use crate::numbers::{escape, format_number, from_count, parse_number};
use crate::palette::{ColorRole, MONO_FAMILY, SANS_FAMILY};
use crate::writer::Writer;
use reference_model::RuleId;
use roxmltree::Node;

const ARROW_LENGTH: f64 = 8.0;
const ARROW_HALF_WIDTH: f64 = 4.5;

pub fn write_box(writer: &mut Writer<'_>, node: Node<'_, '_>) {
    let (Some(left), Some(top), Some(width), Some(height)) = (
        number(writer, node, "x"),
        number(writer, node, "y"),
        number(writer, node, "ancho"),
        number(writer, node, "alto"),
    ) else {
        return;
    };
    let role = role(writer, node, "rol", ColorRole::Ink);
    let opacity = optional_number(node, "fondo").unwrap_or(0.08);
    let dash = if node.has_attribute("discontinua") {
        " stroke-dasharray=\"5 4\""
    } else {
        ""
    };
    writer.push(&format!(
        "<rect x=\"{}\" y=\"{}\" width=\"{}\" height=\"{}\" rx=\"{}\" fill=\"{}\" fill-opacity=\"{}\" stroke=\"{}\" stroke-width=\"{}\"{dash}/>",
        format_number(left),
        format_number(top),
        format_number(width),
        format_number(height),
        format_number(optional_number(node, "esquina").unwrap_or(6.0)),
        role.sentinel(),
        format_number(opacity),
        role.sentinel(),
        format_number(optional_number(node, "trazo").unwrap_or(1.5)),
    ));
    if let Some(text) = node.attribute("texto") {
        let lines: Vec<String> = text
            .split('¶')
            .map(|line| writer.substitute(line))
            .collect();
        let center = (left + width / 2.0, top + height / 2.0);
        write_lines(writer, node, &lines, center);
    }
}

fn write_lines(writer: &mut Writer<'_>, node: Node<'_, '_>, lines: &[String], center: (f64, f64)) {
    let size = optional_number(node, "tamano").unwrap_or(14.0);
    writer.check_font_size(size);
    let leading = size * 1.25;
    let count = from_count(lines.len());
    let first = center.1 - (count - 1.0) * leading / 2.0 + size * 0.35;
    let color = role(writer, node, "colortexto", ColorRole::Ink);
    let family = if node.attribute("fuente") == Some("mono") {
        MONO_FAMILY
    } else {
        SANS_FAMILY
    };
    let weight = if node.has_attribute("negrita") {
        " font-weight=\"600\""
    } else {
        ""
    };
    let style = if node.has_attribute("cursiva") {
        " font-style=\"italic\""
    } else {
        ""
    };
    for (index, line) in lines.iter().enumerate() {
        let baseline = first + from_count(index) * leading;
        writer.push(&format!(
            "<text x=\"{}\" y=\"{}\" text-anchor=\"middle\" font-size=\"{}\" font-family=\"{family}\" fill=\"{}\"{weight}{style}>{}</text>",
            format_number(center.0),
            format_number(baseline),
            format_number(size),
            color.sentinel(),
            escape(line),
        ));
    }
}

pub fn write_arrow(writer: &mut Writer<'_>, node: Node<'_, '_>) {
    let points = parse_points(node.attribute("puntos").unwrap_or_default());
    let [.., before, tip] = points.as_slice() else {
        writer.report(RuleId::FigureContract, "an arrow needs at least two points");
        return;
    };
    let length = (tip.0 - before.0).hypot(tip.1 - before.1);
    if length <= ARROW_LENGTH {
        writer.report(
            RuleId::FigureContract,
            "the last arrow segment is too short",
        );
        return;
    }
    let direction = ((tip.0 - before.0) / length, (tip.1 - before.1) / length);
    let base = (
        tip.0 - direction.0 * ARROW_LENGTH,
        tip.1 - direction.1 * ARROW_LENGTH,
    );
    let mut shaft: Vec<(f64, f64)> = points.clone();
    if let Some(last) = shaft.last_mut() {
        *last = base;
    }
    let role = role(writer, node, "rol", ColorRole::Ink);
    write_shaft(writer, node, &shaft, role);
    let wing = (
        -direction.1 * ARROW_HALF_WIDTH,
        direction.0 * ARROW_HALF_WIDTH,
    );
    let head = [
        *tip,
        (base.0 + wing.0, base.1 + wing.1),
        (base.0 - wing.0, base.1 - wing.1),
    ];
    writer.push(&format!(
        "<polygon points=\"{}\" fill=\"{}\"/>",
        join_points(&head),
        role.sentinel()
    ));
}

fn write_shaft(writer: &mut Writer<'_>, node: Node<'_, '_>, shaft: &[(f64, f64)], role: ColorRole) {
    let dash = if node.has_attribute("discontinua") {
        " stroke-dasharray=\"5 4\""
    } else {
        ""
    };
    writer.push(&format!(
        "<polyline points=\"{}\" fill=\"none\" stroke=\"{}\" stroke-width=\"{}\" stroke-linecap=\"round\" stroke-linejoin=\"round\"{dash}/>",
        join_points(shaft),
        role.sentinel(),
        format_number(optional_number(node, "trazo").unwrap_or(1.5)),
    ));
}

fn parse_points(text: &str) -> Vec<(f64, f64)> {
    text.split_whitespace()
        .filter_map(|pair| {
            let (horizontal, vertical) = pair.split_once(',')?;
            Some((parse_number(horizontal)?, parse_number(vertical)?))
        })
        .collect()
}

fn join_points(points: &[(f64, f64)]) -> String {
    points
        .iter()
        .map(|(horizontal, vertical)| {
            format!(
                "{},{}",
                format_number(*horizontal),
                format_number(*vertical)
            )
        })
        .collect::<Vec<_>>()
        .join(" ")
}

fn number(writer: &mut Writer<'_>, node: Node<'_, '_>, name: &str) -> Option<f64> {
    let value = optional_number(node, name);
    if value.is_none() {
        writer.report(
            RuleId::FigureContract,
            format!("a kit piece needs the number `{name}`"),
        );
    }
    value
}

fn optional_number(node: Node<'_, '_>, name: &str) -> Option<f64> {
    node.attribute(name).and_then(parse_number)
}

fn role(writer: &mut Writer<'_>, node: Node<'_, '_>, name: &str, fallback: ColorRole) -> ColorRole {
    let Some(value) = node.attribute(name) else {
        return fallback;
    };
    ColorRole::from_name(value).unwrap_or_else(|| {
        writer.report(
            RuleId::FigureContract,
            format!("unknown color role `{value}`"),
        );
        fallback
    })
}
