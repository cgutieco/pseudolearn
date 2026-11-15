use super::RustEmitter;
use crate::code_lines::CodeLines;
use pseudolearn_semantic::hir::{HirClass, HirField, HirFunction};
use pseudolearn_semantic::{ClassId, FunctionId};

impl<'module> RustEmitter<'_, 'module> {
    pub(crate) fn classes(&mut self, lines: &mut CodeLines) {
        for (index, class) in self.view.module.classes.iter().enumerate() {
            let identifier = ClassId(u32::try_from(index).unwrap_or(u32::MAX));
            if !self.view.is_emitted_class(identifier) {
                continue;
            }
            if self.is_polymorphic(identifier) {
                self.uses.insert("rc");
                self.hierarchy_class(identifier, class, lines);
                continue;
            }
            self.simple_class(identifier, class, lines);
        }
    }

    pub(crate) fn field_is_optional(&self, field: &HirField) -> bool {
        !self.has_default(field.type_id)
    }

    pub(crate) fn simple_class(
        &mut self,
        identifier: ClassId,
        class: &HirClass,
        lines: &mut CodeLines,
    ) {
        self.uses.insert("rc");
        let name = self.class_name(identifier);
        let previous = lines.attributed(class.span);
        lines.line("#[derive(Clone, Default)]");
        lines.open(&format!("struct {name} {{"));
        self.class_fields(identifier, class, lines);
        lines.close("}");
        lines.blank();
        lines.open(&format!("impl {name} {{"));
        self.constructor_function(&name, class, lines);
        for method in &class.methods {
            if Some(*method) != class.constructor {
                self.method(*method, lines);
            }
        }
        lines.close("}");
        lines.restore(previous);
        lines.blank();
    }

    pub(crate) fn class_fields(
        &mut self,
        identifier: ClassId,
        class: &HirClass,
        lines: &mut CodeLines,
    ) {
        let record_fields = self
            .view
            .module
            .class_record_fields
            .iter()
            .filter(|entry| entry.field.owner == identifier)
            .map(|entry| entry.field.clone())
            .collect::<Vec<_>>();
        let own_fields = class
            .fields
            .iter()
            .filter(|field| field.owner == identifier && !self.is_leaf_field(field.id))
            .cloned()
            .collect::<Vec<_>>();
        for field in own_fields.iter().chain(&record_fields) {
            let type_text = self.type_text(field.type_id, field.span);
            let stored = if self.field_is_optional(field) {
                format!("Option<{type_text}>")
            } else {
                type_text
            };
            lines.line(&format!("{}: {stored},", self.names.field(&field.name)));
        }
    }

    pub(crate) fn constructor_function(
        &mut self,
        name: &str,
        class: &HirClass,
        lines: &mut CodeLines,
    ) {
        let Some(constructor) = class.constructor.and_then(|identifier| {
            self.view
                .function(identifier)
                .map(|function| (identifier, function))
        }) else {
            lines.open(&format!("fn new() -> Rc<RefCell<{name}>> {{"));
            lines.line(&format!("Rc::new(RefCell::new({name}::default()))"));
            lines.close("}");
            return;
        };
        let (_, function) = constructor;
        self.enter_function(function);
        let parameters = self.parameter_list(function);
        let names = function
            .parameters
            .iter()
            .map(|parameter| self.local_name(*parameter))
            .collect::<Vec<_>>()
            .join(", ");
        lines.open(&format!(
            "fn new({}) -> Rc<RefCell<{name}>> {{",
            parameters.join(", ")
        ));
        lines.line(&format!(
            "let this = Rc::new(RefCell::new({name}::default()));"
        ));
        lines.line(&format!("this.borrow_mut().construct({names});"));
        lines.line("this");
        lines.close("}");
        lines.blank();
        self.construct_method(function, &parameters, lines);
    }

    pub(crate) fn construct_method(
        &mut self,
        function: &HirFunction,
        parameters: &[String],
        lines: &mut CodeLines,
    ) {
        lines.open(&format!(
            "fn construct(&mut self{}) {{",
            Self::leading_comma(parameters)
        ));
        self.statements(&function.body, lines);
        lines.close("}");
    }

    pub(crate) fn leading_comma(parameters: &[String]) -> String {
        if parameters.is_empty() {
            String::new()
        } else {
            format!(", {}", parameters.join(", "))
        }
    }

    pub(crate) fn method(&mut self, method: FunctionId, lines: &mut CodeLines) {
        let Some(function) = self.view.function(method) else {
            return;
        };
        self.enter_function(function);
        let parameters = self.parameter_list(function);
        let result = self.result_suffix(function);
        let keyword = if function.suspendible {
            "async fn"
        } else {
            "fn"
        };
        let name = self.function_name(method);
        lines.blank();
        let previous = lines.attributed(function.span);
        lines.open(&format!(
            "{keyword} {name}(&mut self{}){result} {{",
            Self::leading_comma(&parameters)
        ));
        self.statements(&function.body, lines);
        lines.close("}");
        lines.restore(previous);
    }

    pub(crate) fn is_optional_field_place(&self, place: &pseudolearn_semantic::HirPlace) -> bool {
        match place {
            pseudolearn_semantic::HirPlace::Field { field, .. } => self
                .field(*field)
                .is_some_and(|entry| self.field_is_optional(entry)),
            _ => false,
        }
    }
}
