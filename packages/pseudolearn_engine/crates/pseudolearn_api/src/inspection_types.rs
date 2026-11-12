use crate::ApiError;
use crate::execution_resource::usage;
use pseudolearn_bytecode::ValueType;
use pseudolearn_semantic::hir::{HirClass, HirField, HirModule};
use pseudolearn_semantic::identities::{ClassId, FieldId, TypeId};
use pseudolearn_semantic::types::Type;
use pseudolearn_source::Span;
use pseudolearn_vm::LoadedProgram;

#[path = "inspection_collections.rs"]
mod inspection_collections;

pub(super) fn class_environment(program: &LoadedProgram) -> Result<HirModule, ApiError> {
    let mut module = HirModule::default();
    let mut position = 0_u32;
    while let Some(class) = program.class_schema(position) {
        module.classes.push(HirClass {
            name: class.name.clone(),
            superclass: None,
            fields: Vec::new(),
            methods: Vec::new(),
            virtual_slots: Vec::new(),
            constructor: None,
            span: Span::default(),
            syntax: 0,
        });
        position = position
            .checked_add(1)
            .ok_or_else(|| usage("too many inspection classes"))?;
    }
    for class_index in 0..module.classes.len() {
        populate_fields(program, &mut module, class_index)?;
        populate_collection(program, &mut module, class_index)?;
    }
    Ok(module)
}

fn populate_fields(
    program: &LoadedProgram,
    module: &mut HirModule,
    index: usize,
) -> Result<(), ApiError> {
    let ordinal = u32::try_from(index).map_err(|_| usage("invalid inspection class"))?;
    let schema = program
        .class_schema(ordinal)
        .ok_or_else(|| usage("missing inspection class"))?;
    let first = module
        .classes
        .iter()
        .try_fold(0_usize, |count, class| {
            count.checked_add(class.fields.len())
        })
        .ok_or_else(|| usage("too many inspection fields"))?;
    let mut fields = Vec::new();
    for (position, field) in schema.fields.iter().enumerate() {
        fields.push(make_field(
            module,
            field,
            (first, position),
            ClassId(ordinal),
        )?);
    }
    module
        .classes
        .get_mut(index)
        .ok_or_else(|| usage("missing inspection class"))?
        .fields = fields;
    Ok(())
}

fn make_field(
    module: &mut HirModule,
    field: &(String, ValueType),
    positions: (usize, usize),
    owner: ClassId,
) -> Result<HirField, ApiError> {
    let ordinal = positions
        .0
        .checked_add(positions.1)
        .and_then(|value| u32::try_from(value).ok())
        .ok_or_else(|| usage("too many inspection fields"))?;
    Ok(HirField {
        id: FieldId(ordinal),
        name: field.0.clone(),
        type_id: semantic_type(&field.1, module)?,
        owner,
        private: false,
        span: Span::default(),
    })
}

pub(super) fn semantic_type(kind: &ValueType, module: &mut HirModule) -> Result<TypeId, ApiError> {
    let kind = match kind {
        ValueType::I64 => Type::Integer,
        ValueType::F64 => Type::Real,
        ValueType::Bool => Type::Boolean,
        ValueType::Char => Type::Character,
        ValueType::Str => Type::String,
        ValueType::Unit => Type::Unit,
        ValueType::Cell(inner) => return semantic_type(inner, module),
        ValueType::Array {
            element,
            dimension_rank,
        } => Type::Array {
            element: semantic_type(element, module)?,
            rank: *dimension_rank,
        },
        ValueType::Object(name) => {
            let index = module
                .classes
                .iter()
                .position(|class| class.name == *name)
                .ok_or_else(|| usage("unknown inspection object type"))?;
            Type::Object(ClassId(
                u32::try_from(index).map_err(|_| usage("invalid inspection class"))?,
            ))
        }
    };
    Ok(module.types.intern(kind))
}

fn populate_collection(
    program: &LoadedProgram,
    module: &mut HirModule,
    index: usize,
) -> Result<(), ApiError> {
    let ordinal = u32::try_from(index).map_err(|_| usage("invalid inspection collection"))?;
    let schema = program
        .class_schema(ordinal)
        .ok_or_else(|| usage("missing inspection collection"))?;
    let Some(collection) = pseudolearn_bytecode::collection_metadata::collection_fields(
        &schema.name,
        schema
            .fields
            .iter()
            .map(|(name, kind)| (name.as_str(), kind)),
    ) else {
        return Ok(());
    };
    inspection_collections::register(module, ordinal, collection, schema)
}
