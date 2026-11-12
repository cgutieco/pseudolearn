use crate::program_view::ViewNode;
use serde_json::{Value, json};

const LOOP_KINDS: [&str; 4] = ["for_loop", "for_each_loop", "while_loop", "repeat_loop"];
const UNIT_KINDS: [&str; 5] = [
    "algorithm_unit",
    "subroutine",
    "method_member",
    "constructor_member",
    "function_literal",
];

#[derive(Clone, Copy, Eq, PartialEq)]
enum ExitKind {
    Break,
    Return,
    Propagation,
}

impl ExitKind {
    fn from_syntax(syntax_kind: &str) -> Option<Self> {
        match syntax_kind {
            "break_statement" => Some(Self::Break),
            "return_statement" => Some(Self::Return),
            "propagation" => Some(Self::Propagation),
            _ => None,
        }
    }

    fn name(self) -> &'static str {
        match self {
            Self::Break => "break",
            Self::Return => "return",
            Self::Propagation => "propagation",
        }
    }
}

struct ExitPath {
    target: Option<usize>,
    cleanups: Vec<usize>,
}

pub(crate) fn annotate(nodes: &mut [ViewNode], revision: &str) {
    for (ordinal, name, value) in exit_attributes(nodes, revision) {
        if let Some(node) = nodes.get_mut(ordinal) {
            node.attributes.push((name, value));
        }
    }
}

fn exit_attributes(nodes: &[ViewNode], revision: &str) -> Vec<(usize, &'static str, Value)> {
    let identities = Identities { revision, nodes };
    let mut attributes = Vec::new();
    for (ordinal, node) in nodes.iter().enumerate() {
        if let Some(kind) = ExitKind::from_syntax(node.syntax_kind) {
            let path = exit_path(nodes, ordinal, kind);
            attributes.push((
                ordinal,
                "control_exit",
                exit_value(&identities, kind, &path),
            ));
        }
        if node.syntax_kind == "body" {
            attributes.extend(body_cleanup_attributes(nodes, &identities, ordinal));
        }
    }
    attributes
}

fn body_cleanup_attributes(
    nodes: &[ViewNode],
    identities: &Identities<'_>,
    ordinal: usize,
) -> Vec<(usize, &'static str, Value)> {
    let registered = registered_cleanups(nodes, ordinal, None);
    if registered.is_empty() {
        return Vec::new();
    }
    let mut attributes = vec![(ordinal, "normal_cleanups", identities.list(&registered))];
    for cleanup in registered {
        attributes.push((cleanup, "cleanup_scope_node_id", identities.value(ordinal)));
    }
    attributes
}

struct Identities<'view> {
    revision: &'view str,
    nodes: &'view [ViewNode],
}

impl Identities<'_> {
    fn value(&self, ordinal: usize) -> Value {
        self.nodes.get(ordinal).map_or(Value::Null, |node| {
            json!(crate::program_view::node_identifier(
                self.revision,
                node.source,
                ordinal
            ))
        })
    }

    fn list(&self, ordinals: &[usize]) -> Value {
        Value::Array(
            ordinals
                .iter()
                .map(|ordinal| self.value(*ordinal))
                .collect(),
        )
    }
}

fn exit_value(identities: &Identities<'_>, kind: ExitKind, path: &ExitPath) -> Value {
    json!({
        "kind": kind.name(),
        "target_node_id": path.target.map_or(Value::Null, |target| identities.value(target)),
        "cleanups": identities.list(&path.cleanups),
    })
}

fn exit_path(nodes: &[ViewNode], exit: usize, kind: ExitKind) -> ExitPath {
    let mut cleanups = Vec::new();
    let mut current = exit;
    while let Some(parent) = nodes.get(current).and_then(|node| node.parent) {
        let Some(owner) = nodes.get(parent) else {
            break;
        };
        if owner.syntax_kind == "defer_statement" {
            return ExitPath {
                target: None,
                cleanups: Vec::new(),
            };
        }
        if owner.syntax_kind == "body" {
            cleanups.extend(registered_cleanups(nodes, parent, Some(current)));
        }
        if kind == ExitKind::Break && LOOP_KINDS.contains(&owner.syntax_kind) {
            return ExitPath {
                target: Some(parent),
                cleanups,
            };
        }
        if UNIT_KINDS.contains(&owner.syntax_kind) {
            return ExitPath {
                target: (kind != ExitKind::Break).then_some(parent),
                cleanups: if kind == ExitKind::Break {
                    Vec::new()
                } else {
                    cleanups
                },
            };
        }
        current = parent;
    }
    ExitPath {
        target: None,
        cleanups: Vec::new(),
    }
}

fn registered_cleanups(nodes: &[ViewNode], body: usize, until: Option<usize>) -> Vec<usize> {
    let Some(owner) = nodes.get(body) else {
        return Vec::new();
    };
    let mut ordered: Vec<usize> = owner.children.clone();
    ordered.sort_by_key(|child| nodes.get(*child).map_or(0, |node| node.start_byte));
    let mut registered = Vec::new();
    for child in ordered {
        if Some(child) == until {
            break;
        }
        if let Some(cleanup) = deferred_statement(nodes, child) {
            registered.push(cleanup);
        }
    }
    registered.reverse();
    registered
}

fn deferred_statement(nodes: &[ViewNode], statement: usize) -> Option<usize> {
    let node = nodes.get(statement)?;
    if node.syntax_kind == "defer_statement" {
        return Some(statement);
    }
    if node.syntax_kind != "statement" {
        return None;
    }
    node.children.iter().copied().find(|child| {
        nodes
            .get(*child)
            .is_some_and(|inner| inner.syntax_kind == "defer_statement")
    })
}
