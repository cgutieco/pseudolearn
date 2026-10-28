#![forbid(unsafe_code)]

use crate::columns::InstructionColumns;
use crate::identities::{BlockId, InstructionId, ValueId, VariableId};
use crate::types::IrType;
use pseudolearn_source::SourceId;

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
    pub methods: Vec<(String, String)>,
    pub dense_integers: bool,
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
    pub visibility: Option<crate::IrSpan>,
    pub function: String,
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
            visibility: None,
            function: String::new(),
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
    pub suspendible: bool,
    pub name: String,
    pub parameters: Vec<(ValueId, IrType)>,
    pub return_type: IrType,
    pub blocks: Vec<Block>,
    pub columns: InstructionColumns,
    pub declaration_span: Option<crate::IrSpan>,
}

impl Function {
    pub fn new(name: String, return_type: IrType) -> Self {
        Self {
            suspendible: false,
            name,
            parameters: Vec::new(),
            return_type,
            blocks: Vec::new(),
            columns: InstructionColumns::new(),
            declaration_span: None,
        }
    }

    pub fn block(&self, identifier: BlockId) -> Option<&Block> {
        self.blocks
            .iter()
            .find(|block| block.identifier == identifier)
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct SourceProfile {
    pub source_id: SourceId,
    pub vocabulary: String,
}

#[derive(Clone, Debug, PartialEq)]
pub struct Module {
    pub name: String,
    pub vocabulary: String,
    pub profiles: Vec<SourceProfile>,
    pub classes: Vec<ClassDeclaration>,
    pub functions: Vec<Function>,
    pub origins: OriginTable,
}

impl Module {
    pub fn vocabularies(&self) -> Vec<&str> {
        let mut found: Vec<&str> = std::iter::once(self.vocabulary.as_str())
            .chain(
                self.profiles
                    .iter()
                    .map(|profile| profile.vocabulary.as_str()),
            )
            .collect();
        found.sort_unstable();
        found.dedup();
        found
    }

    pub fn vocabulary_index_of(&self, span: Option<crate::span::IrSpan>) -> usize {
        let source_id = span.map_or(SourceId::STANDALONE, |found| found.source_id);
        self.vocabulary_index(source_id)
    }

    pub fn vocabulary_index(&self, source_id: SourceId) -> usize {
        let wanted = self.vocabulary_for(source_id);
        self.vocabularies()
            .iter()
            .position(|vocabulary| *vocabulary == wanted)
            .unwrap_or(0)
    }

    pub fn vocabulary_for(&self, source_id: SourceId) -> &str {
        self.profiles
            .iter()
            .find(|profile| profile.source_id == source_id)
            .map_or(self.vocabulary.as_str(), |profile| {
                profile.vocabulary.as_str()
            })
    }

    pub fn new(name: String, vocabulary: String) -> Self {
        Self {
            name,
            vocabulary,
            profiles: Vec::new(),
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
