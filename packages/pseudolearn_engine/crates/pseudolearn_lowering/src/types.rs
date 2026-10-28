#![forbid(unsafe_code)]

use pseudolearn_ir::IrType;
use pseudolearn_semantic::hir::HirModule;
use pseudolearn_semantic::identities::TypeId;
use pseudolearn_semantic::types::Type;

pub fn lower_type(type_id: TypeId, module: &HirModule) -> IrType {
    match module.types.get(type_id) {
        Type::Integer => IrType::I64,
        Type::Real => IrType::F64,
        Type::Boolean => IrType::Bool,
        Type::Character => IrType::Char,
        Type::String => IrType::Str,
        Type::Enum(_) => IrType::I64,
        Type::Unit | Type::Never | Type::Record(_) => IrType::Unit,
        Type::Array { element, rank } => IrType::Array {
            element: Box::new(lower_type(element, module)),
            dimension_rank: rank,
        },
        Type::Task(payload) => lower_type(payload, module),
        Type::Object(class_id) => {
            let class_name = usize::try_from(class_id.0)
                .ok()
                .and_then(|index| module.classes.get(index))
                .map(|class_declaration| class_declaration.name.clone())
                .unwrap_or_else(|| "Object".to_owned());
            IrType::Object(class_name)
        }
        Type::Unknown | Type::Error => IrType::Unit,
    }
}
