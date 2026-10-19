use pseudolearn_source::{SourceText, Span};
use pseudolearn_syntax::{ModuleSchema, NodeKind, SyntaxTree, UnitDeclaration, UnitKind};
use std::collections::hash_map::DefaultHasher;
use std::hash::{Hash, Hasher};

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct UnitFingerprint {
    pub name: String,
    pub kind: NodeKind,
    pub span: Span,
    pub signature_hash: u64,
    pub body_hash: u64,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct PartitionReport {
    pub units: Vec<UnitFingerprint>,
    pub signature_invalidated: bool,
    pub unchanged_count: usize,
    pub affected_count: usize,
}

pub fn partition_units(tree: &SyntaxTree, source: &SourceText) -> Vec<UnitFingerprint> {
    let schema = ModuleSchema::extract(tree, source);
    schema
        .units
        .iter()
        .map(|declaration| compute_unit_fingerprint(declaration, source))
        .collect()
}

enum Comparison {
    Unchanged,
    BodyChanged,
    SignatureChanged,
}

fn compare_unit(counterpart: Option<&UnitFingerprint>, unit: &UnitFingerprint) -> Comparison {
    match counterpart {
        None => Comparison::SignatureChanged,
        Some(old) if old.signature_hash != unit.signature_hash => Comparison::SignatureChanged,
        Some(old) if old.body_hash != unit.body_hash => Comparison::BodyChanged,
        Some(_) => Comparison::Unchanged,
    }
}

pub fn compare_partitions(
    previous: &[UnitFingerprint],
    current: &[UnitFingerprint],
) -> PartitionReport {
    let mut report = PartitionReport {
        units: current.to_vec(),
        signature_invalidated: previous.len() != current.len(),
        unchanged_count: 0,
        affected_count: 0,
    };
    let mut seen: Vec<(&str, NodeKind)> = Vec::new();
    for unit in current {
        let ordinal = seen
            .iter()
            .filter(|(name, kind)| *name == unit.name && *kind == unit.kind)
            .count();
        seen.push((unit.name.as_str(), unit.kind));
        let counterpart = previous
            .iter()
            .filter(|candidate| candidate.name == unit.name && candidate.kind == unit.kind)
            .nth(ordinal);
        match compare_unit(counterpart, unit) {
            Comparison::Unchanged => {
                report.unchanged_count = report.unchanged_count.saturating_add(1);
            }
            Comparison::BodyChanged => {
                report.affected_count = report.affected_count.saturating_add(1);
            }
            Comparison::SignatureChanged => {
                report.signature_invalidated = true;
                report.affected_count = report.affected_count.saturating_add(1);
            }
        }
    }
    report
}

fn compute_unit_fingerprint(declaration: &UnitDeclaration, source: &SourceText) -> UnitFingerprint {
    let mut signature_hasher = DefaultHasher::new();
    declaration.name.hash(&mut signature_hasher);
    format!("{:?}", declaration.kind).hash(&mut signature_hasher);
    for parameter in &declaration.parameters {
        parameter.name.hash(&mut signature_hasher);
        parameter.type_name.hash(&mut signature_hasher);
        parameter.by_reference.hash(&mut signature_hasher);
    }
    let signature_hash = signature_hasher.finish();

    let mut header_ending = declaration.span.start;
    for parameter in &declaration.parameters {
        if parameter.span.ending > header_ending {
            header_ending = parameter.span.ending;
        }
    }
    let body_span = Span::new(header_ending, declaration.span.ending);
    let body_hash = hash_span(source, body_span);

    UnitFingerprint {
        name: declaration.name.clone(),
        kind: map_unit_kind(declaration.kind),
        span: declaration.span,
        signature_hash,
        body_hash,
    }
}

fn map_unit_kind(kind: UnitKind) -> NodeKind {
    match kind {
        UnitKind::Program => NodeKind::AlgorithmUnit,
        UnitKind::Procedure | UnitKind::Function => NodeKind::Subprogram,
        UnitKind::Class => NodeKind::ClassUnit,
    }
}

fn hash_span(source: &SourceText, span: Span) -> u64 {
    let mut hasher = DefaultHasher::new();
    if let Some(slice) = source.slice(span) {
        slice.hash(&mut hasher);
    }
    hasher.finish()
}
