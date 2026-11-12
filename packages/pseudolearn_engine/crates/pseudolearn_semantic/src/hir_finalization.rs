use crate::expression_model::HirExpression;
use crate::hir::HirModule;
use crate::types::Type;

pub(crate) fn finalize(module: &mut HirModule) {
    let never = module.types.intern(Type::Never);
    for (index, kind) in module.expressions.types.iter_mut().enumerate() {
        if module.types.get(*kind) != Type::Unknown {
            continue;
        }
        let local = module
            .expressions
            .kinds
            .get(index)
            .and_then(|expression| match expression {
                HirExpression::Local(local) => Some(*local),
                _ => None,
            });
        let Some(local) = local else {
            *kind = never;
            continue;
        };
        let inferred = usize::try_from(local.0)
            .ok()
            .and_then(|index| module.locals.get(index))
            .map(|local| local.type_id);
        if let Some(inferred) =
            inferred.filter(|inferred| module.types.get(*inferred) != Type::Unknown)
        {
            *kind = inferred;
        } else {
            if let Some(expression) = module.expressions.kinds.get_mut(index) {
                *expression = HirExpression::Uninitialized(local);
            }
            *kind = never;
        }
    }
    for local in &mut module.locals {
        if module.types.get(local.type_id) == Type::Unknown {
            local.type_id = never;
        }
    }
}
