use crate::hir::{HirModule, HirRecord, HirRecordField};
use crate::identities::{LocalId, RecordId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::Diagnostic;
use pseudolearn_source::{IdentifierNormalizer, Span};
use std::collections::BTreeMap;

type TypedLeaves = Vec<(String, TypeId)>;
type CapturedLeaves = Vec<(String, LocalId, TypeId)>;

pub(super) fn register(session: &mut AnalysisSession<'_>) -> Result<(), Vec<Diagnostic>> {
    let mut groups: BTreeMap<String, CapturedLeaves> = BTreeMap::new();
    for (index, local) in session.module.locals.iter().enumerate() {
        let Some((name, path)) = local.name.split_once('.') else {
            continue;
        };
        let identity =
            LocalId(u32::try_from(index).map_err(|_| super::inspection_expression::rejection())?);
        groups
            .entry(name.to_owned())
            .or_default()
            .push((path.to_owned(), identity, local.type_id));
    }
    for (name, leaves) in groups {
        bind_record(session, &name, &leaves)?;
    }
    Ok(())
}

fn bind_record(
    session: &mut AnalysisSession<'_>,
    name: &str,
    leaves: &CapturedLeaves,
) -> Result<(), Vec<Diagnostic>> {
    let kinds = leaves
        .iter()
        .map(|(path, _, kind)| (path.clone(), *kind))
        .collect::<Vec<_>>();
    let kind = record_type(&mut session.module, &kinds)?;
    let Type::Record(record) = session.module.types.get(kind) else {
        return Err(super::inspection_expression::rejection());
    };
    let model = session
        .module
        .records
        .get(usize::try_from(record.0).map_err(|_| super::inspection_expression::rejection())?)
        .ok_or_else(super::inspection_expression::rejection)?;
    let values = model
        .leaf_names
        .iter()
        .map(|name| {
            leaves
                .iter()
                .find(|leaf| leaf.0 == *name)
                .map(|leaf| leaf.1)
                .ok_or_else(super::inspection_expression::rejection)
        })
        .collect::<Result<Vec<_>, _>>()?;
    let identity = super::inspection_expression::bind(session, name, kind)?;
    session.module.record_locals.insert(identity, values);
    session.bindings.insert(
        IdentifierNormalizer::normalize(name),
        crate::block_scopes::BindingTarget::Local(identity),
    );
    Ok(())
}

#[derive(Default)]
struct RecordProjection {
    fields: Vec<HirRecordField>,
    types: Vec<TypeId>,
    names: Vec<String>,
}

pub fn record_type(
    module: &mut HirModule,
    leaves: &[(String, TypeId)],
) -> Result<TypeId, Vec<Diagnostic>> {
    build_record(module, leaves, 0)
}

fn build_record(
    module: &mut HirModule,
    leaves: &[(String, TypeId)],
    depth: u32,
) -> Result<TypeId, Vec<Diagnostic>> {
    if depth > 64 {
        return Err(super::inspection_expression::rejection());
    }
    let mut groups: BTreeMap<String, TypedLeaves> = BTreeMap::new();
    for (path, kind) in leaves {
        let (name, remainder) = path.split_once('.').unwrap_or((path, ""));
        groups
            .entry(name.to_owned())
            .or_default()
            .push((remainder.to_owned(), *kind));
    }
    let mut projection = RecordProjection::default();
    for (name, children) in groups {
        append_field(module, &mut projection, (name, children), depth)?;
    }
    let identity = RecordId(
        u32::try_from(module.records.len())
            .map_err(|_| super::inspection_expression::rejection())?,
    );
    module.records.push(HirRecord {
        name: format!("inspection_record_{}", identity.0),
        fields: projection.fields,
        leaf_types: projection.types,
        leaf_names: projection.names,
        span: Span::default(),
        syntax: 0,
    });
    Ok(module.types.intern(Type::Record(identity)))
}

fn append_field(
    module: &mut HirModule,
    projection: &mut RecordProjection,
    field: (String, TypedLeaves),
    depth: u32,
) -> Result<(), Vec<Diagnostic>> {
    let (name, children) = field;
    let kind = field_type(module, &children, depth)?;
    let offset = u32::try_from(projection.types.len())
        .map_err(|_| super::inspection_expression::rejection())?;
    let width = append_leaves(module, projection, (&name, kind))?;
    projection.fields.push(HirRecordField {
        name,
        type_id: kind,
        offset,
        width,
    });
    Ok(())
}

fn append_leaves(
    module: &HirModule,
    projection: &mut RecordProjection,
    field: (&str, TypeId),
) -> Result<u32, Vec<Diagnostic>> {
    let (name, kind) = field;
    if let Type::Record(record) = module.types.get(kind) {
        let model = module
            .records
            .get(usize::try_from(record.0).map_err(|_| super::inspection_expression::rejection())?)
            .ok_or_else(super::inspection_expression::rejection)?;
        projection
            .names
            .extend(model.leaf_names.iter().map(|leaf| format!("{name}.{leaf}")));
        projection.types.extend_from_slice(&model.leaf_types);
        return u32::try_from(model.leaf_types.len())
            .map_err(|_| super::inspection_expression::rejection());
    }
    projection.names.push(name.to_owned());
    projection.types.push(kind);
    Ok(1)
}

fn field_type(
    module: &mut HirModule,
    children: &TypedLeaves,
    depth: u32,
) -> Result<TypeId, Vec<Diagnostic>> {
    if let Some((path, kind)) = children.first()
        && path.is_empty()
        && children.len() == 1
    {
        return Ok(*kind);
    }
    build_record(module, children, depth.saturating_add(1))
}
