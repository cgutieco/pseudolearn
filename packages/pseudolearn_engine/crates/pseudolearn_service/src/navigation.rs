use crate::positions::{offset_at, position_at};
use crate::symbol_index::SymbolIndex;
use pseudolearn_semantic::hir::FunctionKind;
use pseudolearn_semantic::{ClassId, FunctionId, ServiceAnalysis, ServiceSymbolTarget};
use pseudolearn_source::{SourceText, Span};
use serde::{Deserialize, Serialize};

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct Position {
    pub line: u32,
    pub column: u32,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct Range {
    pub start: Position,
    pub end: Position,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub enum HighlightKind {
    Read,
    Write,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct DocumentHighlight {
    pub range: Range,
    pub kind: HighlightKind,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum SymbolCategory {
    Class,
    Method,
    Function,
    Field,
    Variable,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct DocumentSymbolEntry {
    pub name: String,
    pub category: SymbolCategory,
    pub range: Range,
    pub container: Option<String>,
}

pub fn byte_offset_at_position(source: &SourceText, position: Position) -> usize {
    offset_at(source.as_str(), position)
}

pub fn span_to_range(source: &SourceText, span: Span) -> Range {
    let text = source.as_str();
    Range {
        start: position_at(text, usize::try_from(span.start).unwrap_or(0)),
        end: position_at(text, usize::try_from(span.ending).unwrap_or(0)),
    }
}

pub fn find_definition(
    index: &SymbolIndex,
    source: &SourceText,
    position: Position,
) -> Option<Range> {
    let offset = byte_offset_at_position(source, position);
    let target = index.at_offset(offset)?.target;
    let declaration = index.declaration_of(target)?;
    Some(span_to_range(source, declaration.span))
}

pub fn find_references(index: &SymbolIndex, source: &SourceText, position: Position) -> Vec<Range> {
    let offset = byte_offset_at_position(source, position);
    let Some(found) = index.at_offset(offset) else {
        return Vec::new();
    };
    index
        .occurrences_of(found.target)
        .into_iter()
        .map(|entry| span_to_range(source, entry.span))
        .collect()
}

pub fn document_highlights(
    index: &SymbolIndex,
    source: &SourceText,
    position: Position,
) -> Vec<DocumentHighlight> {
    let offset = byte_offset_at_position(source, position);
    let Some(found) = index.at_offset(offset) else {
        return Vec::new();
    };
    index
        .occurrences_of(found.target)
        .into_iter()
        .map(|entry| DocumentHighlight {
            range: span_to_range(source, entry.span),
            kind: if entry.is_write || entry.is_declaration {
                HighlightKind::Write
            } else {
                HighlightKind::Read
            },
        })
        .collect()
}

struct SymbolCollector<'collect> {
    index: &'collect SymbolIndex,
    source: &'collect SourceText,
    symbols: Vec<DocumentSymbolEntry>,
}

impl SymbolCollector<'_> {
    fn push(
        &mut self,
        target: ServiceSymbolTarget,
        label: (&str, SymbolCategory),
        container: Option<String>,
    ) {
        let (name, category) = label;
        let Some(declaration) = self.index.declaration_of(target) else {
            return;
        };
        self.symbols.push(DocumentSymbolEntry {
            name: name.to_owned(),
            category,
            range: span_to_range(self.source, declaration.span),
            container,
        });
    }
}

pub fn document_symbols(
    analysis: &ServiceAnalysis,
    index: &SymbolIndex,
    source: &SourceText,
) -> Vec<DocumentSymbolEntry> {
    let mut collector = SymbolCollector {
        index,
        source,
        symbols: Vec::new(),
    };
    class_symbols(analysis, &mut collector);
    function_symbols(analysis, &mut collector);
    let mut symbols = collector.symbols;
    symbols.sort_by_key(|entry| (entry.range.start.line, entry.range.start.column));
    symbols
}

fn class_symbols(analysis: &ServiceAnalysis, collector: &mut SymbolCollector<'_>) {
    for (slot, class) in analysis.module.classes.iter().enumerate() {
        let identity = ClassId(u32::try_from(slot).unwrap_or(u32::MAX));
        collector.push(
            ServiceSymbolTarget::Class(identity),
            (&class.name, SymbolCategory::Class),
            None,
        );
        for field in &class.fields {
            collector.push(
                ServiceSymbolTarget::Field(field.id),
                (&field.name, SymbolCategory::Field),
                Some(class.name.clone()),
            );
        }
    }
}

fn function_symbols(analysis: &ServiceAnalysis, collector: &mut SymbolCollector<'_>) {
    for (slot, function) in analysis.module.functions.iter().enumerate() {
        let identity = FunctionId(u32::try_from(slot).unwrap_or(u32::MAX));
        let owner = function
            .owner
            .and_then(|class| usize::try_from(class.0).ok())
            .and_then(|class| analysis.module.classes.get(class))
            .map(|class| class.name.clone());
        let category = match function.kind {
            FunctionKind::Method | FunctionKind::Constructor => SymbolCategory::Method,
            _ => SymbolCategory::Function,
        };
        collector.push(
            ServiceSymbolTarget::Function(identity),
            (&function.name, category),
            owner,
        );
    }
}
