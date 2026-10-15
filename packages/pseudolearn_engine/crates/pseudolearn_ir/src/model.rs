#![forbid(unsafe_code)]

use crate::columns::InstructionColumns;
use crate::identities::{BlockId, InstructionId, ValueId, VariableId};
use crate::types::IrType;

#[derive(Clone, Debug, PartialEq)]
pub struct FieldDeclaration {
    pub name: String,
    pub field_type: IrType,
}

#[derive(Clone, Debug, PartialEq)]
pub struct ClassDeclaration {
    pub name: String,
    pub superclass: Option<String>,
    pub fields: Vec<FieldDeclaration>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct Block {
    pub identifier: BlockId,
    pub parameters: Vec<(ValueId, IrType)>,
    pub mass: u32,
    pub instructions: Vec<InstructionId>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct OriginEntry {
    pub value: ValueId,
    pub variable: VariableId,
    pub name: String,
}

#[derive(Clone, Debug, Default, PartialEq)]
pub struct OriginTable {
    pub entries: Vec<OriginEntry>,
}

impl OriginTable {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn record(&mut self, value: ValueId, variable: VariableId, name: String) {
        self.entries.push(OriginEntry {
            value,
            variable,
            name,
        });
    }

    pub fn lookup(&self, value: ValueId) -> Option<&OriginEntry> {
        self.entries.iter().find(|entry| entry.value == value)
    }
}

#[derive(Clone, Debug, PartialEq)]
pub struct Function {
    pub name: String,
    pub parameters: Vec<(ValueId, IrType)>,
    pub return_type: IrType,
    pub blocks: Vec<Block>,
    pub columns: InstructionColumns,
}

impl Function {
    pub fn new(name: String, return_type: IrType) -> Self {
        Self {
            name,
            parameters: Vec::new(),
            return_type,
            blocks: Vec::new(),
            columns: InstructionColumns::new(),
        }
    }

    pub fn block(&self, identifier: BlockId) -> Option<&Block> {
        self.blocks
            .iter()
            .find(|block| block.identifier == identifier)
    }
}

#[derive(Clone, Debug, PartialEq)]
pub struct Module {
    pub name: String,
    pub vocabulary: String,
    pub classes: Vec<ClassDeclaration>,
    pub functions: Vec<Function>,
    pub origins: OriginTable,
}

impl Module {
    pub fn new(name: String, vocabulary: String) -> Self {
        Self {
            name,
            vocabulary,
            classes: Vec::new(),
            functions: Vec::new(),
            origins: OriginTable::new(),
        }
    }

    pub fn find_class(&self, name: &str) -> Option<&ClassDeclaration> {
        self.classes
            .iter()
            .find(|declaration| declaration.name == name)
    }

    pub fn find_function(&self, name: &str) -> Option<&Function> {
        let clean_query = name.trim_start_matches('@');
        self.functions.iter().find(|function| {
            function.name == name || function.name.trim_start_matches('@') == clean_query
        })
    }
}
