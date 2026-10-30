use crate::expression_model::HirExpression;
use crate::hir::{FunctionKind, HirModule};
use crate::identities::{ClassId, FunctionId, LocalId};
use crate::service_model::*;
use pseudolearn_source::Span;

pub(crate) fn collect_symbols(
    module: &HirModule,
    inferred: &std::collections::BTreeSet<LocalId>,
    symbols: &mut Vec<ServiceSymbol>,
    occurrences: &mut Vec<ServiceReference>,
) {
    for (index, local) in module.locals.iter().enumerate() {
        let local_id = LocalId(u32::try_from(index).unwrap_or(u32::MAX));
        if internal_symbol(module, local_id) {
            continue;
        }
        let category = if local.parameter {
            ServiceSymbolCategory::Parameter
        } else {
            ServiceSymbolCategory::Variable
        };
        symbols.push(ServiceSymbol {
            identifier: index,
            name: local.name.clone(),
            category,
            type_id: local.type_id,
            span: local.span,
            is_inferred: inferred.contains(&local_id),
            owner_class: None,
            parameter_types: Vec::new(),
            return_type: None,
        });
        occurrences.push(ServiceReference {
            span: local.span,
            target: ServiceSymbolTarget::Local(local_id),
            is_write: true,
            is_declaration: true,
        });
    }
    collect_function_symbols(module, symbols, occurrences);
    collect_class_symbols(module, occurrences);
}

fn collect_function_symbols(
    module: &HirModule,
    symbols: &mut Vec<ServiceSymbol>,
    occurrences: &mut Vec<ServiceReference>,
) {
    for (index, function) in module.functions.iter().enumerate() {
        let function_id = FunctionId(u32::try_from(index).unwrap_or(u32::MAX));
        let category = match function.kind {
            FunctionKind::Method | FunctionKind::Constructor => ServiceSymbolCategory::Method,
            FunctionKind::Function => ServiceSymbolCategory::Function,
            _ => ServiceSymbolCategory::Procedure,
        };
        let parameter_types = function
            .parameters
            .iter()
            .filter_map(|parameter_id| {
                let position = usize::try_from(parameter_id.0).ok()?;
                let local = module.locals.get(position)?;
                Some((local.name.clone(), local.type_id, local.passing))
            })
            .collect();
        symbols.push(ServiceSymbol {
            identifier: index,
            name: function.name.clone(),
            category,
            type_id: function.result,
            span: function.span,
            is_inferred: false,
            owner_class: function.owner,
            parameter_types,
            return_type: Some(function.result),
        });
        occurrences.push(ServiceReference {
            span: function.span,
            target: ServiceSymbolTarget::Function(function_id),
            is_write: false,
            is_declaration: true,
        });
    }
}

fn collect_class_symbols(module: &HirModule, occurrences: &mut Vec<ServiceReference>) {
    for (index, class) in module.classes.iter().enumerate() {
        if module.collections.contains_key(&crate::identities::ClassId(
            u32::try_from(index).unwrap_or(u32::MAX),
        )) {
            continue;
        }
        let class_id = ClassId(u32::try_from(index).unwrap_or(u32::MAX));
        occurrences.push(ServiceReference {
            span: class.span,
            target: ServiceSymbolTarget::Class(class_id),
            is_write: false,
            is_declaration: true,
        });
        for field in &class.fields {
            occurrences.push(ServiceReference {
                span: field.span,
                target: ServiceSymbolTarget::Field(field.id),
                is_write: true,
                is_declaration: true,
            });
        }
    }
}

pub(crate) fn collect_expression_occurrences(
    module: &HirModule,
    occurrences: &mut Vec<ServiceReference>,
) {
    for (index, kind) in module.expressions.kinds.iter().enumerate() {
        let span = module
            .expressions
            .spans
            .get(index)
            .copied()
            .unwrap_or(Span::new(0, 0));
        if let Some(reference) = expression_reference(module, span, kind) {
            occurrences.push(reference);
        }
    }
}

fn expression_reference(
    module: &HirModule,
    span: Span,
    expression: &HirExpression,
) -> Option<ServiceReference> {
    let target = match expression {
        HirExpression::Local(local_id) if !internal_symbol(module, *local_id) => {
            ServiceSymbolTarget::Local(*local_id)
        }
        HirExpression::Call { function, .. }
        | HirExpression::VirtualCall { function, .. }
        | HirExpression::TaskSpawn { function, .. }
        | HirExpression::FunctionValue(function)
        | HirExpression::Captured { function, .. } => ServiceSymbolTarget::Function(*function),
        HirExpression::Field { field, .. } => ServiceSymbolTarget::Field(*field),
        HirExpression::New { class, .. } | HirExpression::This(class) => {
            ServiceSymbolTarget::Class(*class)
        }
        _ => return None,
    };
    Some(ServiceReference {
        span,
        target,
        is_write: false,
        is_declaration: false,
    })
}

fn internal_symbol(module: &HirModule, local: LocalId) -> bool {
    usize::try_from(local.0)
        .ok()
        .and_then(|index| module.locals.get(index))
        .is_some_and(|local| local.name.starts_with('$'))
        || module
            .record_locals
            .values()
            .any(|components| components.contains(&local))
}
