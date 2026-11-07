use crate::rails_draw::RailLabels;
use crate::rails_grammar::RailNode;
use crate::rails_layout::{Command, GAP, GUTTER, Piece, piece};

const BRANCH_GAP: f64 = 10.0;
const ROW_GAP: f64 = 24.0;
const MARGIN: f64 = 8.0;

pub fn sequence(items: &[RailNode], limit: f64, labels: &RailLabels<'_>) -> Piece {
    let children: Vec<Piece> = items
        .iter()
        .map(|member| piece(member, limit - 2.0 * MARGIN, labels))
        .collect();
    let single: f64 = children.iter().map(|child| child.width + GAP).sum();
    if single <= limit {
        return row(children);
    }
    wrapped(rows(children, limit - 2.0 * MARGIN))
}

fn rows(children: Vec<Piece>, limit: f64) -> Vec<Piece> {
    let mut grouped: Vec<Vec<Piece>> = Vec::new();
    let mut width = 0.0;
    for child in children {
        let needed = child.width + GAP;
        match grouped.last_mut() {
            Some(current) if width + needed <= limit => current.push(child),
            _ => {
                grouped.push(vec![child]);
                width = 0.0;
            }
        }
        width += needed;
    }
    grouped.into_iter().map(row).collect()
}

fn row(children: Vec<Piece>) -> Piece {
    let mut result = Piece::default();
    let mut cursor = (0.0, 0.0);
    for child in children {
        result.line(vec![cursor, (cursor.0 + GAP, cursor.1)]);
        result.commands.push(Command::Head {
            tip: (cursor.0 + GAP, cursor.1),
            direction: (1.0, 0.0),
        });
        let width = child.width;
        let exit = child.exit;
        result.place(child, (cursor.0 + GAP, cursor.1));
        cursor = (cursor.0 + GAP + width, cursor.1 + exit);
    }
    result.width = cursor.0;
    result.exit = cursor.1;
    result
}

fn wrapped(lines: Vec<Piece>) -> Piece {
    let width = lines.iter().map(|line| line.width).fold(0.0, f64::max) + 2.0 * MARGIN;
    let mut result = Piece {
        width,
        ..Piece::default()
    };
    result.line(vec![(0.0, 0.0), (MARGIN, 0.0)]);
    let mut baseline = 0.0;
    let mut previous: Option<(f64, f64, f64)> = None;
    for line in lines {
        if let Some((end, exit, bottom)) = previous {
            let turn = bottom + ROW_GAP / 2.0;
            baseline = bottom + ROW_GAP + line.top;
            result.line(vec![
                (end, exit),
                (width - 2.0, exit),
                (width - 2.0, turn),
                (2.0, turn),
                (2.0, baseline),
                (MARGIN, baseline),
            ]);
        }
        let end = MARGIN + line.width;
        let exit = baseline + line.exit;
        let bottom = baseline + line.bottom;
        result.place(line, (MARGIN, baseline));
        previous = Some((end, exit, bottom));
        result.exit = exit;
    }
    if let Some((end, exit, _)) = previous {
        result.line(vec![(end, exit), (width, exit)]);
    }
    result
}

pub fn choice(options: Vec<Piece>) -> Piece {
    let inner = options
        .iter()
        .map(|option| option.width)
        .fold(0.0, f64::max);
    let width = inner + 2.0 * GUTTER;
    let mut result = Piece {
        width,
        ..Piece::default()
    };
    let mut baseline: f64 = 0.0;
    let mut first_exit = 0.0;
    for (index, option) in options.into_iter().enumerate() {
        if index > 0 {
            baseline = result.bottom + BRANCH_GAP + option.top;
        }
        let exit = baseline + option.exit;
        if index == 0 {
            first_exit = exit;
        }
        connect_branch(
            &mut result,
            (baseline, exit, first_exit),
            GUTTER + option.width,
        );
        result.place(option, (GUTTER, baseline));
    }
    result.exit = first_exit;
    result
}

fn connect_branch(result: &mut Piece, (baseline, exit, first_exit): (f64, f64, f64), end: f64) {
    let width = result.width;
    let rail = GUTTER / 2.0;
    if baseline == 0.0 {
        result.line(vec![(0.0, 0.0), (GUTTER, 0.0)]);
        result.line(vec![(end, exit), (width, exit)]);
        return;
    }
    result.line(vec![
        (0.0, 0.0),
        (rail, 0.0),
        (rail, baseline),
        (GUTTER, baseline),
    ]);
    result.line(vec![
        (end, exit),
        (width - rail, exit),
        (width - rail, first_exit),
        (width, first_exit),
    ]);
}

pub fn repeated(child: Piece) -> Piece {
    let width = child.width + 2.0 * GAP;
    let mut result = Piece {
        width,
        ..Piece::default()
    };
    let exit = child.exit;
    let below = child.bottom.max(exit) + 12.0;
    result.line(vec![(0.0, 0.0), (GAP, 0.0)]);
    result.line(vec![(GAP + child.width, exit), (width, exit)]);
    result.line(vec![
        (width - GAP / 2.0, exit),
        (width - GAP / 2.0, below),
        (GAP / 2.0, below),
        (GAP / 2.0, 6.0),
    ]);
    result.commands.push(Command::Head {
        tip: (GAP / 2.0, 1.0),
        direction: (0.0, -1.0),
    });
    result.place(child, (GAP, 0.0));
    result.bottom = result.bottom.max(below + 2.0);
    result.exit = exit;
    result
}
