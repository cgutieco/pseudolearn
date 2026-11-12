use super::semantic_type;
use crate::ApiError;
use crate::execution_resource::usage;
use pseudolearn_bytecode::collection_metadata::CollectionType;
use pseudolearn_semantic::collection_model::HirCollection;
use pseudolearn_semantic::hir::HirModule;
use pseudolearn_semantic::identities::{ClassId, TypeId};

type CollectionValue = (TypeId, Vec<TypeId>, Vec<usize>);

pub(super) fn register(
    module: &mut HirModule,
    ordinal: u32,
    collection: CollectionType,
    schema: &pseudolearn_bytecode::BytecodeClass,
) -> Result<(), ApiError> {
    let (value, leaves, canonical) = value_model(module, &collection, schema)?;
    let key = collection
        .key
        .as_ref()
        .map(|kind| semantic_type(kind, module))
        .transpose()?;
    module.collections.insert(
        ClassId(ordinal),
        HirCollection {
            class: ClassId(ordinal),
            key,
            value,
            leaves,
            canonical,
        },
    );
    Ok(())
}

fn value_model(
    module: &mut HirModule,
    collection: &CollectionType,
    schema: &pseudolearn_bytecode::BytecodeClass,
) -> Result<CollectionValue, ApiError> {
    let record = schema
        .fields
        .iter()
        .any(|field| field.0.starts_with("$leaf:record:"));
    if collection.leaves.len() == 1 && !record {
        let leaf = collection
            .leaves
            .first()
            .ok_or_else(|| usage("missing inspection collection value"))?;
        let value = semantic_type(leaf, module)?;
        return Ok((value, vec![value], vec![0]));
    }
    record_value(module, schema)
}

fn record_value(
    module: &mut HirModule,
    schema: &pseudolearn_bytecode::BytecodeClass,
) -> Result<CollectionValue, ApiError> {
    let fields = record_fields(module, schema)?;
    let value = pseudolearn_semantic::inspection_expression::record_type(module, &fields)
        .map_err(|_| usage("invalid inspection collection record"))?;
    let pseudolearn_semantic::Type::Record(identity) = module.types.get(value) else {
        return Err(usage("missing inspection collection record"));
    };
    let model = module
        .records
        .get(usize::try_from(identity.0).map_err(|_| usage("invalid inspection record"))?)
        .ok_or_else(|| usage("missing inspection record"))?;
    let canonical = fields
        .iter()
        .map(|field| {
            model
                .leaf_names
                .iter()
                .position(|name| *name == field.0)
                .ok_or_else(|| usage("missing inspection record field"))
        })
        .collect::<Result<Vec<_>, _>>()?;
    Ok((value, model.leaf_types.clone(), canonical))
}

fn record_fields(
    module: &mut HirModule,
    schema: &pseudolearn_bytecode::BytecodeClass,
) -> Result<Vec<(String, TypeId)>, ApiError> {
    let mut fields = Vec::new();
    for (name, kind) in &schema.fields {
        if let Some(name) = name
            .strip_prefix("$leaf:record:")
            .or_else(|| name.strip_prefix("$leaf:"))
        {
            fields.push((name.to_owned(), semantic_type(kind, module)?));
        }
    }
    Ok(fields)
}
