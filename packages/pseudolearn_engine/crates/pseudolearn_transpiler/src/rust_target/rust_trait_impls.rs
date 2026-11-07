use super::RustEmitter;
use crate::code_lines::CodeLines;
use crate::identifier_spelling::rust_value_name;
use pseudolearn_semantic::hir::{HirClass, HirFunction};
use pseudolearn_semantic::{ClassId, FunctionId};

impl<'module> RustEmitter<'_, 'module> {
    pub(crate) fn trait_implementation(
        &mut self,
        class: ClassId,
        ancestor: ClassId,
        lines: &mut CodeLines,
    ) {
        let name = self.class_name(class);
        let ancestor_name = self.class_name(ancestor);
        let accessor = rust_value_name(&ancestor_name);
        let depth = self
            .ancestors(class)
            .iter()
            .position(|found| *found == ancestor)
            .unwrap_or(0);
        lines.open(&format!("impl {ancestor_name}Kind for {name} {{"));
        self.accessors((&ancestor_name, &accessor), depth, lines);
        self.overrides(class, ancestor, lines);
        lines.close("}");
        lines.blank();
    }

    pub(crate) fn accessors(
        &self,
        (ancestor_name, accessor): (&str, &str),
        depth: usize,
        lines: &mut CodeLines,
    ) {
        let path = std::iter::repeat_n(".base", depth).collect::<String>();
        let (shared, exclusive) = if depth == 0 {
            ("self".to_owned(), "self".to_owned())
        } else {
            (format!("&self{path}"), format!("&mut self{path}"))
        };
        lines.line(&format!(
            "fn {accessor}(&self) -> &{ancestor_name} {{ {shared} }}"
        ));
        lines.line(&format!(
            "fn {accessor}_mut(&mut self) -> &mut {ancestor_name} {{ {exclusive} }}"
        ));
    }

    pub(crate) fn overrides(&mut self, class: ClassId, ancestor: ClassId, lines: &mut CodeLines) {
        for (method, function) in self.introduced_methods(ancestor) {
            let Some((definer, implementation)) = self.defining_class(class, &function.name) else {
                continue;
            };
            if definer == ancestor {
                continue;
            }
            let signature = self.method_signature(method, function);
            let call = self.forwarding_call(implementation, function);
            lines.open(&format!("{signature} {{"));
            lines.line(&call);
            lines.close("}");
        }
    }

    pub(crate) fn inherited_constructor(
        &mut self,
        name: &str,
        (identifier, function): (FunctionId, &HirFunction),
        lines: &mut CodeLines,
    ) {
        self.enter_function(function);
        let parameters = self.parameter_list(function).join(", ");
        let mut arguments = vec!["&mut *this.borrow_mut()".to_owned()];
        arguments.extend(
            function
                .parameters
                .iter()
                .map(|parameter| self.local_name(*parameter)),
        );
        lines.open(&format!("fn new({parameters}) -> Rc<RefCell<{name}>> {{"));
        lines.line(&format!(
            "let this = Rc::new(RefCell::new({name}::default()));"
        ));
        let call = self.method_function_name(identifier);
        lines.line(&format!("{call}({});", arguments.join(", ")));
        lines.line("this");
    }

    pub(crate) fn hierarchy_constructor(
        &mut self,
        class: ClassId,
        entry: &HirClass,
        lines: &mut CodeLines,
    ) {
        let name = self.class_name(class);
        let constructor = self
            .ancestors(class)
            .into_iter()
            .find_map(|ancestor| {
                self.view
                    .class(ancestor)
                    .and_then(|found| found.constructor)
            })
            .and_then(|identifier| {
                self.view
                    .function(identifier)
                    .map(|function| (identifier, function))
            });
        lines.open(&format!("impl {name} {{"));
        match constructor {
            Some(found) => self.inherited_constructor(&name, found, lines),
            None => {
                lines.open(&format!("fn new() -> Rc<RefCell<{name}>> {{"));
                lines.line(&format!("Rc::new(RefCell::new({name}::default()))"));
            }
        }
        lines.close("}");
        lines.close("}");
        lines.blank();
        let _ = entry;
    }
}
