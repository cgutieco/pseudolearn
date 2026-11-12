use super::PythonEmitter;
use crate::code_lines::CodeLines;
use crate::identifier_spelling::{python_type_name, python_value_name};
use pseudolearn_semantic::ClassId;
use pseudolearn_semantic::hir::{FunctionKind, HirClass, HirField};

impl<'module> PythonEmitter<'_, 'module> {
    pub(crate) fn class_name(&self, class: ClassId) -> String {
        if let Some(spelled) = self.names.class(class) {
            return spelled.to_owned();
        }
        self.view.class(class).map_or_else(
            || format!("Class{}", class.0),
            |entry| python_type_name(&entry.name),
        )
    }

    pub(crate) fn classes(&mut self, lines: &mut CodeLines) {
        let mut order: Vec<ClassId> = Vec::new();
        for index in 0..self.view.module.classes.len() {
            let identifier = ClassId(u32::try_from(index).unwrap_or(u32::MAX));
            self.order_class(identifier, &mut order);
        }
        for identifier in order {
            if let (true, Some(class)) = (
                self.view.is_emitted_class(identifier),
                self.view.class(identifier),
            ) {
                self.class_definition(identifier, class, lines);
            }
        }
    }

    pub(crate) fn order_class(&self, class: ClassId, order: &mut Vec<ClassId>) {
        if order.contains(&class) {
            return;
        }
        if let Some(parent) = self.view.class(class).and_then(|entry| entry.superclass)
            && parent != class
        {
            self.order_class(parent, order);
        }
        order.push(class);
    }

    pub(crate) fn own_fields(&self, class: ClassId, entry: &'module HirClass) -> Vec<HirField> {
        let leaves = self
            .view
            .module
            .class_record_fields
            .iter()
            .flat_map(|entry| entry.leaves.iter().copied())
            .collect::<Vec<_>>();
        entry
            .fields
            .iter()
            .filter(|field| field.owner == class && !leaves.contains(&field.id))
            .cloned()
            .chain(
                self.view
                    .module
                    .class_record_fields
                    .iter()
                    .filter(|entry| entry.field.owner == class)
                    .map(|entry| entry.field.clone()),
            )
            .collect()
    }

    pub(crate) fn class_definition(
        &mut self,
        class: ClassId,
        entry: &'module HirClass,
        lines: &mut CodeLines,
    ) {
        let name = self.class_name(class);
        let parent = entry
            .superclass
            .map(|parent| format!("({})", self.class_name(parent)))
            .unwrap_or_default();
        let previous = lines.attributed(entry.span);
        lines.open(&format!("class {name}{parent}:"));
        let defaults = self.defaults_method(class, entry, lines);
        self.initializer((class, entry), &defaults, lines);
        self.methods(entry, lines);
        lines.dedent();
        lines.restore(previous);
        lines.blank();
        lines.blank();
    }

    pub(crate) fn defaults_method(
        &mut self,
        class: ClassId,
        entry: &'module HirClass,
        lines: &mut CodeLines,
    ) -> String {
        let defaults = format!("_defaults_{}", python_value_name(&self.class_name(class)));
        lines.open(&format!("def {defaults}(self):"));
        let fields = self.own_fields(class, entry);
        if fields.is_empty() {
            lines.line("pass");
        }
        for field in &fields {
            lines.line(&format!(
                "self.{} = {}",
                self.names.field(&field.name),
                self.default_value(field.type_id)
            ));
        }
        lines.dedent();
        lines.blank();
        defaults
    }

    pub(crate) fn methods(&mut self, entry: &'module HirClass, lines: &mut CodeLines) {
        for method in &entry.methods {
            let Some(function) = self.view.function(*method) else {
                continue;
            };
            if Some(*method) == entry.constructor || function.kind != FunctionKind::Method {
                continue;
            }
            lines.blank();
            self.function_definition((*method, function), "self", lines);
        }
    }

    pub(crate) fn lineage(&self, class: ClassId) -> Vec<ClassId> {
        let mut chain = Vec::new();
        let mut current = Some(class);
        while let Some(found) = current {
            if chain.contains(&found) {
                break;
            }
            chain.push(found);
            current = self.view.class(found).and_then(|parent| parent.superclass);
        }
        chain
    }

    pub(crate) fn initializer(
        &mut self,
        (class, entry): (ClassId, &'module HirClass),
        defaults: &str,
        lines: &mut CodeLines,
    ) {
        let Some((constructor, function)) = entry.constructor.and_then(|identifier| {
            self.view
                .function(identifier)
                .map(|function| (identifier, function))
        }) else {
            if entry.superclass.is_some() {
                lines.open("def __init__(self, *arguments):");
                lines.line("super().__init__(*arguments)");
            } else {
                lines.open("def __init__(self):");
            }
            lines.line(&format!("self.{defaults}()"));
            lines.dedent();
            let _ = class;
            return;
        };
        self.enter_function(constructor, function);
        let mut parameters = vec!["self".to_owned()];
        parameters.extend(self.visible_parameters(function));
        lines.open(&format!("def __init__({}):", parameters.join(", ")));
        for ancestor in self.lineage(class).iter().rev() {
            let ancestor_name = self
                .view
                .class(*ancestor)
                .map(|parent| python_value_name(&parent.name))
                .unwrap_or_default();
            lines.line(&format!("self._defaults_{ancestor_name}()"));
        }
        self.function_body(function, lines);
        lines.dedent();
    }
}
