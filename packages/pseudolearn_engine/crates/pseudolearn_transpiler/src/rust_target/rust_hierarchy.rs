use super::RustEmitter;
use crate::code_lines::CodeLines;
use crate::identifier_spelling::rust_value_name;
use pseudolearn_semantic::hir::{FunctionKind, HirClass, HirFunction};
use pseudolearn_semantic::{ClassId, FunctionId};

impl<'module> RustEmitter<'_, 'module> {
    pub(crate) fn ancestors(&self, class: ClassId) -> Vec<ClassId> {
        let mut chain = vec![class];
        let mut current = class;
        while let Some(parent) = self.view.class(current).and_then(|entry| entry.superclass) {
            if chain.contains(&parent) {
                break;
            }
            chain.push(parent);
            current = parent;
        }
        chain
    }

    pub(crate) fn own_methods(
        &self,
        class: &'module HirClass,
    ) -> Vec<(FunctionId, &'module HirFunction)> {
        class
            .methods
            .iter()
            .filter(|method| Some(**method) != class.constructor)
            .filter_map(|method| {
                self.view
                    .function(*method)
                    .map(|function| (*method, function))
            })
            .filter(|(_, function)| function.kind == FunctionKind::Method)
            .collect()
    }

    pub(crate) fn defining_class(
        &self,
        class: ClassId,
        name: &str,
    ) -> Option<(ClassId, FunctionId)> {
        self.ancestors(class).into_iter().find_map(|ancestor| {
            let entry = self.view.class(ancestor)?;
            self.own_methods(entry)
                .into_iter()
                .find(|(_, function)| function.name == name)
                .map(|(method, _)| (ancestor, method))
        })
    }

    pub(crate) fn introduced_methods(
        &self,
        class: ClassId,
    ) -> Vec<(FunctionId, &'module HirFunction)> {
        let Some(entry) = self.view.class(class) else {
            return Vec::new();
        };
        let parent = entry.superclass;
        self.own_methods(entry)
            .into_iter()
            .filter(|(_, function)| {
                parent.is_none_or(|parent| self.defining_class(parent, &function.name).is_none())
            })
            .collect()
    }

    pub(crate) fn method_function_name(&self, function: FunctionId) -> String {
        let Some(entry) = self.view.function(function) else {
            return format!("method{}", function.0);
        };
        let owner = entry
            .owner
            .map(|class| rust_value_name(&self.class_name(class)))
            .unwrap_or_default();
        if entry.kind == FunctionKind::Constructor {
            format!("{owner}_construct")
        } else {
            format!("{owner}_{}", rust_value_name(&entry.name))
        }
    }

    pub(crate) fn kind_trait(
        &mut self,
        class: ClassId,
        (kind, accessor): (&str, &str),
        lines: &mut CodeLines,
    ) {
        let name = self.class_name(class);
        let supertrait = self
            .view
            .class(class)
            .and_then(|entry| entry.superclass)
            .map(|parent| format!(": {}Kind", self.class_name(parent)))
            .unwrap_or_default();
        lines.open(&format!("trait {kind}{supertrait} {{"));
        lines.line(&format!("fn {accessor}(&self) -> &{name};"));
        lines.line(&format!("fn {accessor}_mut(&mut self) -> &mut {name};"));
        for (method, function) in self.introduced_methods(class) {
            let signature = self.method_signature(method, function);
            let call = self.forwarding_call(method, function);
            lines.open(&format!("{signature} {{"));
            lines.line(&call);
            lines.close("}");
        }
        lines.close("}");
        lines.blank();
    }

    pub(crate) fn hierarchy_class(
        &mut self,
        class: ClassId,
        entry: &'module HirClass,
        lines: &mut CodeLines,
    ) {
        let name = self.class_name(class);
        let kind = format!("{name}Kind");
        let accessor = rust_value_name(&name);
        lines.line("#[derive(Clone, Default)]");
        lines.open(&format!("struct {name} {{"));
        if let Some(parent) = entry.superclass {
            lines.line(&format!("base: {},", self.class_name(parent)));
        }
        self.class_fields(class, entry, lines);
        lines.close("}");
        lines.blank();
        self.kind_trait(class, (&kind, &accessor), lines);
        self.hierarchy_constructor(class, entry, lines);
        for (method, function) in self.own_methods(entry) {
            self.generic_method(class, (method, function), lines);
        }
        if let Some(constructor) = entry.constructor.and_then(|identifier| {
            self.view
                .function(identifier)
                .map(|function| (identifier, function))
        }) {
            self.generic_method(class, constructor, lines);
        }
        for ancestor in self.ancestors(class) {
            self.trait_implementation(class, ancestor, lines);
        }
    }

    pub(crate) fn method_signature(
        &mut self,
        method: FunctionId,
        function: &HirFunction,
    ) -> String {
        self.enter_function(function);
        let parameters = self.parameter_list(function);
        let result = self.result_suffix(function);
        let tail = if parameters.is_empty() {
            String::new()
        } else {
            format!(", {}", parameters.join(", "))
        };
        format!("fn {}(&mut self{tail}){result}", self.function_name(method))
    }

    pub(crate) fn forwarding_call(&self, method: FunctionId, function: &HirFunction) -> String {
        let mut arguments = vec!["self".to_owned()];
        arguments.extend(
            function
                .parameters
                .iter()
                .map(|parameter| self.local_name(*parameter)),
        );
        format!(
            "{}({})",
            self.method_function_name(method),
            arguments.join(", ")
        )
    }

    pub(crate) fn generic_method(
        &mut self,
        class: ClassId,
        (method, function): (FunctionId, &HirFunction),
        lines: &mut CodeLines,
    ) {
        if function.suspendible {
            self.block("suspendible_method", function.span);
            return;
        }
        self.enter_function(function);
        self.scope.generic_receiver = true;
        let parameters = self.parameter_list(function);
        let result = self.result_suffix(function);
        let tail = if parameters.is_empty() {
            String::new()
        } else {
            format!(", {}", parameters.join(", "))
        };
        let bound = format!("{}Kind", self.class_name(class));
        let previous = lines.attributed(function.span);
        lines.open(&format!(
            "fn {}<T: {bound} + ?Sized>(this: &mut T{tail}){result} {{",
            self.method_function_name(method)
        ));
        self.statements(&function.body, lines);
        lines.close("}");
        lines.restore(previous);
        lines.blank();
    }
}
