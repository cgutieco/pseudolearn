#![forbid(unsafe_code)]

use crate::error::CodegenError;
use crate::type_mapping::kind_code;
use pseudolearn_aot_rt::{ClassDescriptor, InlineObjectImage, inline_object_image};
use pseudolearn_ir::{IrType, Module};
use std::collections::HashMap;

#[derive(Clone, Debug, Default)]
struct ClassShape {
    fields: Vec<(String, IrType)>,
    methods: HashMap<String, usize>,
    dense: bool,
    payload: Option<i64>,
}

#[derive(Debug, Default)]
pub(crate) struct ClassTable {
    names: Vec<String>,
    classes: Vec<ClassShape>,
    parents: Vec<Option<String>>,
}

impl ClassTable {
    pub(crate) fn build(module: &Module) -> Result<Self, CodegenError> {
        let mut classes = Vec::new();
        for index in 0..module.classes.len() {
            classes.push(resolve(module, index, module.classes.len())?);
        }
        Ok(Self {
            names: module
                .classes
                .iter()
                .map(|class| class.name.clone())
                .collect(),
            classes,
            parents: module
                .classes
                .iter()
                .map(|class| class.superclass.clone())
                .collect(),
        })
    }

    pub(crate) fn class_index(&self, name: &str) -> Option<usize> {
        self.names.iter().position(|candidate| candidate == name)
    }

    pub(crate) fn field(&self, class: &str, field: &str) -> Option<(usize, &IrType)> {
        let shape = self.classes.get(self.class_index(class)?)?;
        shape
            .fields
            .iter()
            .position(|(name, _)| name == field)
            .and_then(|index| Some((index, &shape.fields.get(index)?.1)))
    }

    pub(crate) fn targets(&self, method: &str) -> Vec<(usize, usize)> {
        self.classes
            .iter()
            .enumerate()
            .filter_map(|(class, shape)| Some((class, *shape.methods.get(method)?)))
            .collect()
    }

    pub(crate) fn object_image(&self, class: usize) -> Option<InlineObjectImage> {
        let shape = self.classes.get(class)?;
        let fields = shape
            .fields
            .iter()
            .map(|(_, field_type)| kind_code(field_type))
            .collect::<Option<Vec<_>>>()?;
        inline_object_image(u32::try_from(class).ok()?, &fields, shape.dense)
    }

    pub(crate) fn static_payload(&self, name: &str) -> Option<i64> {
        let root = self.class_index(name)?;
        let payload = self.classes.get(root)?.payload?;
        for (index, shape) in self.classes.iter().enumerate() {
            if descendant(self, index, root) && shape.payload != Some(payload) {
                return None;
            }
        }
        Some(payload)
    }

    pub(crate) fn descriptors(&self) -> Result<Vec<ClassDescriptor>, CodegenError> {
        self.classes
            .iter()
            .map(|shape| {
                let fields = shape
                    .fields
                    .iter()
                    .map(|(_, field_type)| kind_code(field_type))
                    .collect::<Option<Vec<_>>>()
                    .ok_or(CodegenError::InvalidModule("field without storage"))?;
                Ok(ClassDescriptor {
                    fields,
                    dense: shape.dense,
                })
            })
            .collect()
    }
}

fn resolve(module: &Module, index: usize, budget: usize) -> Result<ClassShape, CodegenError> {
    let declaration = module
        .classes
        .get(index)
        .ok_or(CodegenError::InvalidModule("unknown class"))?;
    let mut shape = match &declaration.superclass {
        Some(parent) if budget > 0 => {
            let position = module
                .classes
                .iter()
                .position(|candidate| &candidate.name == parent)
                .ok_or(CodegenError::InvalidModule("unknown superclass"))?;
            resolve(module, position, budget.saturating_sub(1))?
        }
        Some(_) => return Err(CodegenError::InvalidModule("cyclic class hierarchy")),
        None => ClassShape::default(),
    };
    shape.dense = declaration.dense_integers;
    shape.fields.extend(
        declaration
            .fields
            .iter()
            .map(|field| (field.name.clone(), field.field_type.clone())),
    );
    for (method, target) in &declaration.methods {
        let function = module
            .functions
            .iter()
            .position(|candidate| same_function(&candidate.name, target))
            .ok_or(CodegenError::InvalidModule("method without function"))?;
        shape.methods.insert(method.clone(), function);
    }
    shape.payload = pseudolearn_aot_rt::class_payload_offset(shape.fields.len(), shape.dense);
    Ok(shape)
}

pub(crate) fn same_function(left: &str, right: &str) -> bool {
    left.trim_start_matches('@') == right.trim_start_matches('@')
}

pub(crate) fn method_name(function_name: &str) -> Option<&str> {
    function_name.rsplit_once('.').map(|(_, method)| method)
}

fn descendant(table: &ClassTable, mut candidate: usize, root: usize) -> bool {
    for _ in 0..table.classes.len() {
        if candidate == root {
            return true;
        }
        let Some(parent) = table
            .parents
            .get(candidate)
            .and_then(Option::as_ref)
            .and_then(|name| table.class_index(name))
        else {
            return false;
        };
        candidate = parent;
    }
    false
}

#[cfg(test)]
#[path = "class_table_tests.rs"]
mod class_table_tests;
