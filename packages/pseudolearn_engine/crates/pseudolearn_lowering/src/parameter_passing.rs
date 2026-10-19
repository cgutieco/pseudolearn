use pseudolearn_semantic::hir::{HirLocal, HirModule, Passing};
use pseudolearn_semantic::types::Type;

pub(crate) fn requires_cell(local: &HirLocal, module: &HirModule) -> bool {
    local.passing == Passing::Reference
        && !matches!(module.types.get(local.type_id), Type::Array { .. })
}
