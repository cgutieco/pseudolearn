use crate::numbers::from_count;
use crate::palette::ColorRole;
use crate::rails_draw::RailLabels;
use crate::rails_flow::{choice, repeated, sequence};
use crate::rails_grammar::RailNode;

pub const BOX_HEIGHT: f64 = 28.0;
pub const GAP: f64 = 14.0;
pub const GUTTER: f64 = 18.0;
pub const SIDE: f64 = 14.0;
pub const PADDING: f64 = 10.0;
pub const AVAILABLE: f64 = 340.0 - 2.0 * SIDE;

#[derive(Clone, Debug, PartialEq)]
pub enum Command {
    Line(Vec<(f64, f64)>),
    Head {
        tip: (f64, f64),
        direction: (f64, f64),
    },
    Terminal {
        origin: (f64, f64),
        width: f64,
        label: String,
        role: ColorRole,
    },
    Nonterminal {
        origin: (f64, f64),
        width: f64,
        label: String,
    },
}

impl Command {
    fn moved(self, offset: (f64, f64)) -> Self {
        let shift = |point: (f64, f64)| (point.0 + offset.0, point.1 + offset.1);
        match self {
            Self::Line(points) => Self::Line(points.into_iter().map(shift).collect()),
            Self::Head { tip, direction } => Self::Head {
                tip: shift(tip),
                direction,
            },
            Self::Terminal {
                origin,
                width,
                label,
                role,
            } => Self::Terminal {
                origin: shift(origin),
                width,
                label,
                role,
            },
            Self::Nonterminal {
                origin,
                width,
                label,
            } => Self::Nonterminal {
                origin: shift(origin),
                width,
                label,
            },
        }
    }
}

#[derive(Clone, Debug, Default, PartialEq)]
pub struct Piece {
    pub width: f64,
    pub top: f64,
    pub bottom: f64,
    pub exit: f64,
    pub commands: Vec<Command>,
}

impl Piece {
    pub fn place(&mut self, child: Piece, offset: (f64, f64)) {
        self.top = self.top.max(child.top - offset.1);
        self.bottom = self.bottom.max(offset.1 + child.bottom);
        self.commands.extend(
            child
                .commands
                .into_iter()
                .map(|command| command.moved(offset)),
        );
    }

    pub fn line(&mut self, points: Vec<(f64, f64)>) {
        self.commands.push(Command::Line(points));
    }
}

pub fn layout(tree: &RailNode, labels: &RailLabels<'_>) -> Result<Piece, String> {
    let piece = piece(tree, AVAILABLE, labels);
    if piece.width > AVAILABLE {
        return Err(format!(
            "the syntax diagram needs {:.0} units and only {AVAILABLE:.0} fit",
            piece.width
        ));
    }
    Ok(piece)
}

pub fn piece(node: &RailNode, limit: f64, labels: &RailLabels<'_>) -> Piece {
    match node {
        RailNode::Terminal(identity) => terminal(identity, labels),
        RailNode::Nonterminal(name) => nonterminal(name, labels),
        RailNode::Sequence(items) => sequence(items, limit, labels),
        RailNode::Choice(options) => {
            let pieces = options
                .iter()
                .map(|option| piece(option, limit - 2.0 * GUTTER, labels))
                .collect();
            choice(pieces)
        }
        RailNode::Optional(inner) => choice(vec![
            Piece::default(),
            piece(inner, limit - 2.0 * GUTTER, labels),
        ]),
        RailNode::Repeat(inner) => {
            let looped = repeated(piece(inner, limit - 2.0 * GUTTER - 2.0 * GAP, labels));
            choice(vec![Piece::default(), looped])
        }
    }
}

fn terminal(identity: &str, labels: &RailLabels<'_>) -> Piece {
    let (label, role) = (labels.terminal)(identity);
    let width = label_width(&label, 8.4, 24.0);
    let origin = (0.0, -BOX_HEIGHT / 2.0);
    boxed(
        Command::Terminal {
            origin,
            width,
            label,
            role,
        },
        width,
    )
}

fn nonterminal(name: &str, labels: &RailLabels<'_>) -> Piece {
    let label = (labels.nonterminal)(name);
    let width = label_width(&label, 7.0, 20.0);
    let origin = (0.0, -BOX_HEIGHT / 2.0);
    boxed(
        Command::Nonterminal {
            origin,
            width,
            label,
        },
        width,
    )
}

fn label_width(label: &str, per_character: f64, padding: f64) -> f64 {
    (from_count(label.chars().count()) * per_character + padding).max(32.0)
}

fn boxed(command: Command, width: f64) -> Piece {
    Piece {
        width,
        top: BOX_HEIGHT / 2.0,
        bottom: BOX_HEIGHT / 2.0,
        exit: 0.0,
        commands: vec![command],
    }
}
