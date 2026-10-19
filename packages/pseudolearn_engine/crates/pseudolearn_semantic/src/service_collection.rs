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
        match kind {
            HirExpression::Local(local_id) => {
                occurrences.push(ServiceReference {
                    span,
                    target: ServiceSymbolTarget::Local(*local_id),
                    is_write: false,
                    is_declaration: false,
                });
            }
            HirExpression::Call { function, .. } | HirExpression::VirtualCall { function, .. } => {
                occurrences.push(ServiceReference {
                    span,
                    target: ServiceSymbolTarget::Function(*function),
                    is_write: false,
                    is_declaration: false,
                });
            }
            HirExpression::Field { field, .. } => {
                occurrences.push(ServiceReference {
                    span,
                    target: ServiceSymbolTarget::Field(*field),
                    is_write: false,
                    is_declaration: false,
                });
            }
            _ => {}
        }
    }
}
