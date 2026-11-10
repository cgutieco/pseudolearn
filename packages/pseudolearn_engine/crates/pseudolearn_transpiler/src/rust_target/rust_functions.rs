use super::{FunctionScope, RustEmitter};
use crate::code_lines::CodeLines;
use crate::identifier_spelling::{rust_value_name, unique_spelling};
use pseudolearn_semantic::hir::{FunctionKind, HirFunction};
use pseudolearn_semantic::{FunctionId, LocalId, Passing, Type};

impl RustEmitter<'_, '_> {
    pub(crate) fn functions(&mut self, lines: &mut CodeLines) {
        let mut entry = None;
        for (index, function) in self.view.module.functions.iter().enumerate() {
            let identifier = FunctionId(u32::try_from(index).unwrap_or(u32::MAX));
            if function.kind == FunctionKind::Main {
                entry = Some((identifier, function));
            } else if self.is_free_function(identifier, function) {
                self.free_function(identifier, function, lines);
            }
        }
        if let Some((_, function)) = entry {
            self.entry_function(function, lines);
        }
    }

    pub(crate) fn uses_tasks(&self) -> bool {
        self.view.module.statements.kinds.iter().any(|statement| {
            matches!(
                statement,
                pseudolearn_semantic::HirStatement::TaskScope { .. }
                    | pseudolearn_semantic::HirStatement::Select(_)
            )
        }) || self
            .view
            .module
            .expressions
            .kinds
            .iter()
            .any(|expression| matches!(expression, pseudolearn_semantic::HirExpression::Channel(_)))
            || self
                .view
                .module
                .functions
                .iter()
                .any(|function| function.suspendible && function.kind != FunctionKind::Main)
    }

    pub(crate) fn is_free_function(&self, identifier: FunctionId, function: &HirFunction) -> bool {
        function.owner.is_none()
            && matches!(
                function.kind,
                FunctionKind::Procedure | FunctionKind::Function
            )
            && !self.view.module.closures.contains_key(&identifier)
    }

    pub(crate) fn function_name(&self, identifier: FunctionId) -> String {
        let name = self.view.function(identifier).map_or_else(
            || format!("function{}", identifier.0),
            |entry| rust_value_name(&entry.name),
        );
        self.names.routine(name)
    }

    pub(crate) fn local_name(&self, identifier: LocalId) -> String {
        unique_spelling(
            rust_value_name,
            self.view.scope_local_names(identifier).into_iter(),
            &self.view.local_name(identifier).replace('$', ""),
        )
    }

    pub(crate) fn is_reference_parameter(&self, identifier: LocalId) -> bool {
        self.view.local(identifier).is_some_and(|local| {
            local.parameter
                && (local.passing == Passing::Reference
                    || matches!(self.view.representation(local.type_id), Type::Array { .. }))
        })
    }

    pub(crate) fn parameter_list(&mut self, function: &HirFunction) -> Vec<String> {
        let environment = self
            .view
            .module
            .closures
            .values()
            .map(|closure| closure.environment)
            .collect::<Vec<_>>();
        function
            .parameters
            .iter()
            .filter(|parameter| !environment.contains(parameter))
            .filter_map(|parameter| {
                let local = self.view.local(*parameter)?;
                let type_text = self.type_text(local.type_id, local.span);
                let name = self.local_name(*parameter);
                Some(if self.is_reference_parameter(*parameter) {
                    format!("{name}: &mut {type_text}")
                } else if self.mutation.needs_mutable(*parameter, true) {
                    format!("mut {name}: {type_text}")
                } else {
                    format!("{name}: {type_text}")
                })
            })
            .collect()
    }

    pub(crate) fn result_suffix(&mut self, function: &HirFunction) -> String {
        let result = self.type_text(function.result, function.span);
        if result == "()" {
            String::new()
        } else {
            format!(" -> {result}")
        }
    }

    pub(crate) fn enter_function(&mut self, function: &HirFunction) {
        self.scope = FunctionScope {
            owner: function.owner,
            ..FunctionScope::default()
        };
        self.scope
            .declared
            .extend(function.parameters.iter().copied());
    }

    pub(crate) fn free_function(
        &mut self,
        identifier: FunctionId,
        function: &HirFunction,
        lines: &mut CodeLines,
    ) {
        self.enter_function(function);
        let parameters = self.parameter_list(function).join(", ");
        let result = self.result_suffix(function);
        let keyword = if function.suspendible {
            "async fn"
        } else {
            "fn"
        };
        let name = self.function_name(identifier);
        let previous = lines.attributed(function.span);
        lines.open(&format!("{keyword} {name}({parameters}){result} {{"));
        self.statements(&function.body, lines);
        lines.close("}");
        lines.restore(previous);
        lines.blank();
    }

    pub(crate) fn entry_function(&mut self, function: &HirFunction, lines: &mut CodeLines) {
        self.enter_function(function);
        let previous = lines.attributed(function.span);
        if self.uses_tasks() {
            self.require("tasks");
            lines.open("fn main() {");
            lines.line("run_tasks(algorithm());");
            lines.close("}");
            lines.blank();
            lines.open("async fn algorithm() {");
        } else {
            lines.open("fn main() {");
        }
        self.statements(&function.body, lines);
        lines.close("}");
        lines.restore(previous);
        lines.blank();
    }
}
