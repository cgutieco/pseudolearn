use crate::numbers::{escape, format_number};
use crate::palette::{ColorRole, MONO_FAMILY, SANS_FAMILY};
use crate::rails_layout::{BOX_HEIGHT, Command, PADDING, Piece, SIDE};

pub struct RailLabels<'labels> {
    pub terminal: &'labels dyn Fn(&str) -> (String, ColorRole),
    pub nonterminal: &'labels dyn Fn(&str) -> String,
    pub title: String,
    pub description: String,
}

pub fn draw(piece: &Piece, labels: &RailLabels<'_>) -> String {
    let origin = (SIDE, PADDING + piece.top);
    let height = PADDING * 2.0 + piece.top + piece.bottom;
    let ink = ColorRole::Ink.sentinel();
    let mut svg = format!(
        "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 340 {h}\" width=\"340\" height=\"{h}\"><title>{}</title><desc>{}</desc>",
        escape(&labels.title),
        escape(&labels.description),
        h = format_number(height),
    );
    let exit = (origin.0 + piece.width, origin.1 + piece.exit);
    svg.push_str(&line(&[(5.0, origin.1), origin], ink));
    svg.push_str(&line(&[exit, (335.0, exit.1)], ink));
    for (center_x, center_y) in [(5.0, origin.1), (335.0, exit.1)] {
        svg.push_str(&format!(
            "<circle cx=\"{}\" cy=\"{}\" r=\"4\" fill=\"{ink}\"/>",
            format_number(center_x),
            format_number(center_y)
        ));
    }
    for command in &piece.commands {
        svg.push_str(&draw_command(command, origin));
    }
    svg.push_str("</svg>");
    svg
}

fn draw_command(command: &Command, origin: (f64, f64)) -> String {
    let shift = |point: (f64, f64)| (point.0 + origin.0, point.1 + origin.1);
    let ink = ColorRole::Ink.sentinel();
    match command {
        Command::Line(points) => {
            let moved: Vec<(f64, f64)> = points.iter().copied().map(shift).collect();
            line(&moved, ink)
        }
        Command::Head { tip, direction } => head(shift(*tip), *direction),
        Command::Terminal {
            origin: corner,
            width,
            label,
            role,
        } => {
            let corner = shift(*corner);
            pill(corner, *width, *role) + &label_text(corner, *width, label, true)
        }
        Command::Nonterminal {
            origin: corner,
            width,
            label,
        } => {
            let corner = shift(*corner);
            slot(corner, *width) + &label_text(corner, *width, label, false)
        }
    }
}

fn line(points: &[(f64, f64)], ink: &str) -> String {
    let path: Vec<String> = points
        .iter()
        .enumerate()
        .map(|(index, point)| {
            let verb = if index == 0 { "M" } else { "L" };
            format!(
                "{verb}{} {}",
                format_number(point.0),
                format_number(point.1)
            )
        })
        .collect();
    format!(
        "<path d=\"{}\" fill=\"none\" stroke=\"{ink}\" stroke-width=\"1.5\" stroke-linejoin=\"round\"/>",
        path.join(" ")
    )
}

fn head(tip: (f64, f64), direction: (f64, f64)) -> String {
    let base = (tip.0 - direction.0 * 6.0, tip.1 - direction.1 * 6.0);
    let wing = (-direction.1 * 3.5, direction.0 * 3.5);
    format!(
        "<polygon points=\"{},{} {},{} {},{}\" fill=\"{}\"/>",
        format_number(tip.0),
        format_number(tip.1),
        format_number(base.0 + wing.0),
        format_number(base.1 + wing.1),
        format_number(base.0 - wing.0),
        format_number(base.1 - wing.1),
        ColorRole::Ink.sentinel()
    )
}

fn pill(corner: (f64, f64), width: f64, role: ColorRole) -> String {
    format!(
        "<rect x=\"{}\" y=\"{}\" width=\"{}\" height=\"{}\" rx=\"14\" fill=\"{color}\" fill-opacity=\"0.14\" stroke=\"{color}\" stroke-width=\"1.5\"/>",
        format_number(corner.0),
        format_number(corner.1),
        format_number(width),
        format_number(BOX_HEIGHT),
        color = role.sentinel(),
    )
}

fn slot(corner: (f64, f64), width: f64) -> String {
    format!(
        "<rect x=\"{}\" y=\"{}\" width=\"{}\" height=\"{}\" rx=\"5\" fill=\"{color}\" fill-opacity=\"0.10\" stroke=\"{color}\" stroke-width=\"1.5\" stroke-dasharray=\"5 4\"/>",
        format_number(corner.0),
        format_number(corner.1),
        format_number(width),
        format_number(BOX_HEIGHT),
        color = ColorRole::Slot.sentinel(),
    )
}

fn label_text(corner: (f64, f64), width: f64, label: &str, terminal: bool) -> String {
    let (family, size, style) = if terminal {
        (MONO_FAMILY, 14.0, " font-weight=\"600\"")
    } else {
        (SANS_FAMILY, 13.0, " font-style=\"italic\"")
    };
    format!(
        "<text x=\"{}\" y=\"{}\" text-anchor=\"middle\" font-size=\"{}\" font-family=\"{family}\" fill=\"{}\"{style}>{}</text>",
        format_number(corner.0 + width / 2.0),
        format_number(corner.1 + BOX_HEIGHT / 2.0 + size * 0.35),
        format_number(size),
        ColorRole::Ink.sentinel(),
        escape(label),
    )
}
