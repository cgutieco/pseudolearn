use super::{PythonEmitter, PythonScope};
use crate::code_lines::CodeLines;
use crate::identifier_spelling::{python_value_name, unique_spelling};
use pseudolearn_semantic::hir::{FunctionKind, HirFunction};
use pseudolearn_semantic::{FunctionId, HirExpression, HirStatement, LocalId, Passing, Type};

impl<'module> PythonEmitter<'_, 'module> {
    pub(crate) fn functions(&mut self, lines: &mut CodeLines) {
        let mut entry = None;
        for (index, function) in self.view.module.functions.iter().enumerate() {
            let identifier = FunctionId(u32::try_from(index).unwrap_or(u32::MAX));
            if function.kind == FunctionKind::Main {
                entry = Some((identifier, function));
            } else if function.owner.is_none()
                && matches!(
                    function.kind,
                    FunctionKind::Procedure | FunctionKind::Function
                )
                && !self.view.module.closures.contains_key(&identifier)
            {
                self.function_definition((identifier, function), "", lines);
                lines.blank();
            }
        }
        if let Some((identifier, function)) = entry {
            let tasks = self.uses_tasks();
            let keyword = if tasks { "async def" } else { "def" };
            self.enter_function(identifier, function);
            self.scope.asynchronous = tasks;
            let previous = lines.attributed(function.span);
            lines.open(&format!("{keyword} main():"));
            self.body(&function.body, lines);
            lines.dedent();
            lines.restore(previous);
            lines.blank();
            lines.blank();
            if tasks {
                lines.line("asyncio.run(main())");
            } else {
                lines.line("main()");
            }
            if crate::effect_functions::sets_exit_code(self.view.module) {
                lines.line("sys.exit(EXIT_CODE[0])");
            }
        }
    }

    pub(crate) fn uses_tasks(&self) -> bool {
        self.view.module.statements.kinds.iter().any(|statement| {
            matches!(
                statement,
                HirStatement::TaskScope { .. } | HirStatement::Select(_)
            )
        }) || self
            .view
            .module
            .expressions
            .kinds
            .iter()
            .any(|expression| matches!(expression, HirExpression::Channel(_)))
            || self
                .view
                .module
                .functions
                .iter()
                .any(|function| function.suspendible && function.kind != FunctionKind::Main)
    }

    pub(crate) fn function_name(&self, identifier: FunctionId) -> String {
        let name = self.view.function(identifier).map_or_else(
            || format!("function{}", identifier.0),
            |entry| python_value_name(&entry.name),
        );
        self.names.routine(name)
    }

    pub(crate) fn local_name(&self, identifier: LocalId) -> String {
        let resolved = self
            .scope
            .aliases
            .get(&identifier)
            .copied()
            .unwrap_or(identifier);
        unique_spelling(
            python_value_name,
            self.view.scope_local_names(resolved).into_iter(),
            &self.view.local_name(resolved).replace('$', ""),
        )
    }

    pub(crate) fn write_backs(&self, function: FunctionId) -> Vec<LocalId> {
        self.view.function(function).map_or_else(Vec::new, |entry| {
            entry
                .parameters
                .iter()
                .copied()
                .filter(|parameter| {
                    self.view.local(*parameter).is_some_and(|local| {
                        local.passing == Passing::Reference
                            && !matches!(
                                self.view.representation(local.type_id),
                                Type::Array { .. }
                            )
                    })
                })
                .collect()
        })
    }

    pub(crate) fn enter_function(&mut self, identifier: FunctionId, function: &HirFunction) {
        self.scope = PythonScope {
            reference_parameters: self.write_backs(identifier),
            asynchronous: function.suspendible && function.kind != FunctionKind::Main,
            ..PythonScope::default()
        };
        self.scope
            .declared
            .extend(function.parameters.iter().copied());
    }

    pub(crate) fn visible_parameters(&self, function: &HirFunction) -> Vec<String> {
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
            .map(|parameter| self.local_name(*parameter))
            .collect()
    }

    pub(crate) fn function_definition(
        &mut self,
        (identifier, function): (FunctionId, &'module HirFunction),
        receiver: &str,
        lines: &mut CodeLines,
    ) {
        self.enter_function(identifier, function);
        let mut parameters = self.visible_parameters(function);
        if !receiver.is_empty() {
            parameters.insert(0, receiver.to_owned());
        }
        let keyword = if function.suspendible {
            "async def"
        } else {
            "def"
        };
        let name = if function.kind == FunctionKind::Constructor {
            "__init__".to_owned()
        } else {
            self.function_name(identifier)
        };
        let previous = lines.attributed(function.span);
        lines.open(&format!("{keyword} {name}({}):", parameters.join(", ")));
        self.function_body(function, lines);
        lines.dedent();
        lines.restore(previous);
    }

    pub(crate) fn function_body(&mut self, function: &HirFunction, lines: &mut CodeLines) {
        let propagates = self.propagates(function);
        if propagates {
            self.require("propagation");
            lines.open("try:");
        }
        self.body(&function.body, lines);
        if !self.scope.reference_parameters.is_empty() && !self.ends_in_return(&function.body) {
            let tail = self.write_back_tuple(None);
            lines.line(&format!("return {tail}"));
        }
        if propagates {
            lines.dedent();
            lines.open("except Propagation as stop:");
            let tail = self.write_back_tuple(Some("stop.result".to_owned()));
            lines.line(&format!("return {tail}"));
            lines.dedent();
        }
    }

    pub(crate) fn ends_in_return(&self, body: &[pseudolearn_semantic::StatementId]) -> bool {
        body.last()
            .is_some_and(|last| matches!(self.view.statement(*last), Some(HirStatement::Return(_))))
    }

    pub(crate) fn write_back_tuple(&self, value: Option<String>) -> String {
        let mut parts: Vec<String> = value.into_iter().collect();
        parts.extend(
            self.scope
                .reference_parameters
                .iter()
                .map(|parameter| self.local_name(*parameter)),
        );
        match parts.as_slice() {
            [single] => single.clone(),
            many => many.join(", "),
        }
    }

    pub(crate) fn propagates(&self, function: &HirFunction) -> bool {
        let start = function.span.start;
        let ending = function.span.ending;
        self.view
            .module
            .expressions
            .kinds
            .iter()
            .enumerate()
            .any(|(index, kind)| {
                matches!(kind, HirExpression::Propagate { .. })
                    && self
                        .view
                        .module
                        .expressions
                        .spans
                        .get(index)
                        .is_some_and(|span| span.start >= start && span.ending <= ending)
            })
    }
}
