#![forbid(unsafe_code)]

use crate::types::lower_type;
use pseudolearn_ir::{ClassDeclaration, FieldDeclaration};
use pseudolearn_semantic::hir::HirModule;

pub fn lower_classes(module: &HirModule) -> Vec<ClassDeclaration> {
    let mut classes = Vec::new();
    for (class_index, class_definition) in module.classes.iter().enumerate() {
        let superclass = class_definition.superclass.and_then(|superclass_id| {
            usize::try_from(superclass_id.0)
                .ok()
                .and_then(|index| module.classes.get(index))
                .map(|super_declaration| super_declaration.name.clone())
        });
        let mut fields = Vec::new();
        for field_definition in &class_definition.fields {
            fields.push(FieldDeclaration {
                name: field_definition.name.clone(),
                field_type: lower_type(field_definition.type_id, module),
            });
        }
        classes.push(ClassDeclaration {
            dense_integers: crate::class_density::dense(class_index, module),
            methods: class_definition
                .methods
                .iter()
                .filter_map(|identity| {
                    let function = module.functions.get(usize::try_from(identity.0).ok()?)?;
                    Some((
                        function.name.clone(),
                        crate::functions::function_name(function, module),
                    ))
                })
                .collect(),
            name: class_definition.name.clone(),
            superclass,
            fields,
        });
    }
    classes
}
