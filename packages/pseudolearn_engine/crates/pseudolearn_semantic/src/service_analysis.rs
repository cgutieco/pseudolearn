use crate::expression_model::HirExpression;
use crate::hir::{FunctionKind, HirClass, HirFunction, HirModule};
use crate::identities::{ClassId, FunctionId, LocalId, TypeId};
pub use crate::service_model::*;
use crate::session::{AnalysisSession, SemanticOptions};
use pseudolearn_source::{SourceText, Span};
use pseudolearn_syntax::SyntaxTree;

impl ServiceAnalysis {
    pub fn symbol_at_byte_offset(&self, offset: usize) -> Option<&ServiceSymbol> {
        let reference = innermost_reference(&self.occurrences, offset)?;
        match reference.target {
            ServiceSymbolTarget::Local(local_id) => {
                let index = usize::try_from(local_id.0).ok()?;
                self.symbols.get(index)
            }
            ServiceSymbolTarget::Function(function_id) => {
                let index = usize::try_from(function_id.0).ok()?;
                self.symbols
                    .iter()
                    .find(|symbol| symbol.identifier == index)
            }
            ServiceSymbolTarget::Class(class_id) => {
                let index = usize::try_from(class_id.0).ok()?;
                self.symbols
                    .iter()
                    .find(|symbol| symbol.identifier == index)
            }
            _ => None,
        }
    }

    pub fn definition_span_at_byte_offset(&self, offset: usize) -> Option<Span> {
        let reference = innermost_reference(&self.occurrences, offset)?;
        find_definition_span(&self.module, reference.target)
    }

    pub fn references_at_byte_offset(&self, offset: usize) -> Vec<ServiceReference> {
        let Some(reference) = innermost_reference(&self.occurrences, offset) else {
            return Vec::new();
        };
        let target = reference.target;
        self.occurrences
            .iter()
            .filter(|candidate| candidate.target == target)
            .cloned()
            .collect()
    }

    pub fn visible_symbols_at_span(&self, span: Span) -> Vec<&ServiceSymbol> {
        let containing = self
            .module
            .functions
            .iter()
            .find(|func| func.span.start <= span.start && func.span.ending >= span.ending);
        let scope_id = containing.and_then(|func| {
            self.module
                .functions
                .iter()
                .position(|candidate| candidate.syntax == func.syntax)
                .and_then(|index| u32::try_from(index).ok())
                .map(FunctionId)
        });
        self.symbols
            .iter()
            .filter(|symbol| match symbol.category {
                ServiceSymbolCategory::Variable | ServiceSymbolCategory::Parameter => {
                    scope_id.is_some_and(|_| symbol.span.start <= span.start)
                }
                _ => true,
            })
            .collect()
    }

    pub fn expression_type_at_span(&self, span: Span) -> Option<TypeId> {
        self.expression_types
            .iter()
            .find(|(candidate, _)| *candidate == span)
            .map(|(_, type_id)| *type_id)
    }

    pub fn class_by_name(&self, name: &str) -> Option<&HirClass> {
        self.module
            .classes
            .iter()
            .find(|class| class.name.eq_ignore_ascii_case(name))
    }

    pub fn function_by_name(&self, name: &str) -> Option<&HirFunction> {
        self.module
            .functions
            .iter()
            .find(|func| func.name.eq_ignore_ascii_case(name))
    }
}

fn contains_offset(span: Span, offset: usize) -> bool {
    let start = usize::try_from(span.start).unwrap_or(usize::MAX);
    let ending = usize::try_from(span.ending).unwrap_or(0);
    offset >= start && offset <= ending
}

fn innermost_reference(
    occurrences: &[ServiceReference],
    offset: usize,
) -> Option<&ServiceReference> {
    occurrences
        .iter()
        .filter(|occurrence| contains_offset(occurrence.span, offset))
        .min_by_key(|occurrence| occurrence.span.ending.saturating_sub(occurrence.span.start))
}

fn find_definition_span(module: &HirModule, target: ServiceSymbolTarget) -> Option<Span> {
    match target {
        ServiceSymbolTarget::Local(local_id) => {
            let index = usize::try_from(local_id.0).ok()?;
            module.locals.get(index).map(|local| local.span)
        }
        ServiceSymbolTarget::Function(function_id) => {
            let index = usize::try_from(function_id.0).ok()?;
            module.functions.get(index).map(|func| func.span)
        }
        ServiceSymbolTarget::Class(class_id) => {
            let index = usize::try_from(class_id.0).ok()?;
            module.classes.get(index).map(|class| class.span)
        }
        ServiceSymbolTarget::Field(field_id) => {
            for class in &module.classes {
                if let Some(field) = class.fields.iter().find(|field| field.id == field_id) {
                    return Some(field.span);
                }
            }
            None
        }
        ServiceSymbolTarget::Builtin(_) => None,
    }
}

pub fn analyze_for_service(
    tree: &SyntaxTree,
    source: &SourceText,
    options: SemanticOptions,
) -> ServiceAnalysis {
    let mut session = AnalysisSession::new(tree, source, options);
    crate::unit_resolver::register(&mut session);
    crate::hierarchy::check(&mut session);
    crate::flow::bodies(&mut session);
    let mut symbols = Vec::new();
    let mut occurrences = Vec::new();
    collect_symbols(
        &session.module,
        &session.inferred,
        &mut symbols,
        &mut occurrences,
    );
    collect_expression_occurrences(&session.module, &mut occurrences);
    let expression_types = session
        .module
        .expressions
        .spans
        .iter()
        .copied()
        .zip(session.module.expressions.types.iter().copied())
        .collect();
    ServiceAnalysis {
        module: session.module,
        diagnostics: session.diagnostics,
        symbols,
        occurrences,
        expression_types,
    }
}

fn collect_symbols(
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
    }
}

fn collect_expression_occurrences(module: &HirModule, occurrences: &mut Vec<ServiceReference>) {
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
