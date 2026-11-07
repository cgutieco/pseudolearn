use crate::fence_blocks::{FenceOutcome, interpret};
use crate::inline_parser::parse_inline;
use crate::line_kind::LineElement;
use reference_model::{CalloutKind, Inline, ProgramSource, RuleId, SourceBlock, Violation};
use std::collections::BTreeMap;

pub fn assemble(path: &str, elements: Vec<LineElement>) -> Result<Vec<SourceBlock>, Violation> {
    let mut assembler = Assembler {
        containers: vec![(None, Vec::new())],
        paragraph: Vec::new(),
        list: None,
        table: Vec::new(),
    };
    for element in elements {
        assembler
            .accept(element)
            .map_err(|detail| Violation::new(RuleId::Format, path, detail))?;
    }
    assembler
        .finish()
        .map_err(|detail| Violation::new(RuleId::Format, path, detail))
}

type Container = (
    Option<(CalloutKind, BTreeMap<String, String>)>,
    Vec<SourceBlock>,
);

struct Assembler {
    containers: Vec<Container>,
    paragraph: Vec<String>,
    list: Option<(bool, Vec<String>)>,
    table: Vec<Vec<String>>,
}

impl Assembler {
    fn accept(&mut self, element: LineElement) -> Result<(), String> {
        match element {
            LineElement::Text(line) => {
                self.flush_list()?;
                self.flush_table()?;
                self.paragraph.push(line);
            }
            LineElement::ListEntry { ordered, text } => self.accept_entry(ordered, text)?,
            LineElement::TableRow(cells) => {
                self.flush_paragraph()?;
                self.flush_list()?;
                self.table.push(cells);
            }
            LineElement::Blank => self.flush_all()?,
            structural => self.accept_structural(structural)?,
        }
        Ok(())
    }

    fn accept_entry(&mut self, ordered: bool, text: String) -> Result<(), String> {
        self.flush_paragraph()?;
        self.flush_table()?;
        if self.list.as_ref().is_some_and(|(kind, _)| *kind != ordered) {
            self.flush_list()?;
        }
        self.list
            .get_or_insert_with(|| (ordered, Vec::new()))
            .1
            .push(text);
        Ok(())
    }

    fn accept_structural(&mut self, element: LineElement) -> Result<(), String> {
        self.flush_all()?;
        match element {
            LineElement::Heading { id, phase, text } => {
                let text = parse_inline(&text)?;
                self.push(SourceBlock::Heading { id, phase, text });
            }
            LineElement::Fence { opening, body } => {
                self.accept_fence(interpret(&opening, body)?)?
            }
            LineElement::CalloutOpen { kind, attributes } => {
                self.containers.push((Some((kind, attributes)), Vec::new()))
            }
            LineElement::CalloutClose => self.close_callout()?,
            _ => {}
        }
        Ok(())
    }

    fn accept_fence(&mut self, outcome: FenceOutcome) -> Result<(), String> {
        if let FenceOutcome::Block(block) = outcome {
            self.push(*block);
            return Ok(());
        }
        let program = self
            .last_program()
            .ok_or_else(|| "a promise block must follow a program".to_owned())?;
        match outcome {
            FenceOutcome::Output(text) => program.promise.output = Some(text),
            FenceOutcome::Diagnostics(codes) => program.promise.diagnostics = Some(codes),
            FenceOutcome::Inputs(lines) => program.inputs = lines,
            FenceOutcome::Host(text) => program.host = Some(text),
            FenceOutcome::Block(_) => {}
        }
        Ok(())
    }

    fn last_program(&mut self) -> Option<&mut ProgramSource> {
        match self.containers.last_mut()?.1.last_mut()? {
            SourceBlock::Program(program) => Some(program),
            _ => None,
        }
    }

    fn close_callout(&mut self) -> Result<(), String> {
        if self.containers.len() < 2 {
            return Err("`:::` closes a box that was never opened".to_owned());
        }
        let Some((Some((kind, attributes)), blocks)) = self.containers.pop() else {
            return Err("`:::` closes a box that was never opened".to_owned());
        };
        self.push(SourceBlock::Callout {
            kind,
            attributes,
            blocks,
        });
        Ok(())
    }

    fn push(&mut self, block: SourceBlock) {
        if let Some((_, blocks)) = self.containers.last_mut() {
            blocks.push(block);
        }
    }

    fn flush_all(&mut self) -> Result<(), String> {
        self.flush_paragraph()?;
        self.flush_list()?;
        self.flush_table()
    }

    fn flush_paragraph(&mut self) -> Result<(), String> {
        if self.paragraph.is_empty() {
            return Ok(());
        }
        let text = std::mem::take(&mut self.paragraph).join(" ");
        self.push(SourceBlock::Paragraph(parse_inline(&text)?));
        Ok(())
    }

    fn flush_list(&mut self) -> Result<(), String> {
        let Some((ordered, entries)) = self.list.take() else {
            return Ok(());
        };
        let entries = entries
            .iter()
            .map(|entry| parse_inline(entry))
            .collect::<Result<Vec<Vec<Inline>>, String>>()?;
        self.push(SourceBlock::List { ordered, entries });
        Ok(())
    }

    fn flush_table(&mut self) -> Result<(), String> {
        if self.table.is_empty() {
            return Ok(());
        }
        let rows = std::mem::take(&mut self.table);
        self.push(crate::table_row::assemble_table(rows)?);
        Ok(())
    }

    fn finish(mut self) -> Result<Vec<SourceBlock>, String> {
        self.flush_all()?;
        if self.containers.len() != 1 {
            return Err("a box opened with `:::` is never closed".to_owned());
        }
        Ok(self
            .containers
            .pop()
            .map(|(_, blocks)| blocks)
            .unwrap_or_default())
    }
}
