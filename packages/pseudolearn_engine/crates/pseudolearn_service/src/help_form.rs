use crate::help_catalog::{FormLine, FormSegment, HelpPart, HelpSlot};
use pseudolearn_lexicon::Profile;

pub const INDENT_UNIT: &str = "  ";
pub const ELLIPSIS: &str = "...";

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum PartEntry {
    Word(&'static HelpPart),
    Slot(&'static HelpSlot),
}

pub fn slot_text(label: &str) -> String {
    format!("«{label}»")
}

pub fn form_text(form: &[FormLine], slots: &[HelpSlot]) -> String {
    form.iter()
        .map(|line| line_text(line, slots))
        .collect::<Vec<_>>()
        .join("\n")
}

fn line_text(line: &FormLine, slots: &[HelpSlot]) -> String {
    let mut text = INDENT_UNIT.repeat(usize::from(line.indent));
    for (position, piece) in line.pieces.iter().enumerate() {
        if position > 0 && !piece.joined {
            text.push(' ');
        }
        match piece.segment {
            FormSegment::Code { text: lexeme, .. } => text.push_str(lexeme),
            FormSegment::Slot(identity) => text.push_str(&slot_text(slot_label(slots, identity))),
            FormSegment::Ellipsis => text.push_str(ELLIPSIS),
        }
    }
    text
}

fn slot_label<'slot>(slots: &'slot [HelpSlot], identity: &'slot str) -> &'slot str {
    slots
        .iter()
        .find(|slot| slot.id == identity)
        .map_or(identity, |slot| slot.label)
}

pub fn part_entries(
    form: &[FormLine],
    parts: &'static [HelpPart],
    slots: &'static [HelpSlot],
) -> Vec<PartEntry> {
    let mut entries = Vec::with_capacity(parts.len().saturating_add(slots.len()));
    for piece in form.iter().flat_map(|line| line.pieces.iter()) {
        let entry = match piece.segment {
            FormSegment::Code { identity, .. } => parts
                .iter()
                .find(|part| part.identity == identity)
                .map(PartEntry::Word),
            FormSegment::Slot(identity) => slots
                .iter()
                .find(|slot| slot.id == identity)
                .map(PartEntry::Slot),
            FormSegment::Ellipsis => None,
        };
        if let Some(entry) = entry.filter(|entry| !entries.contains(entry)) {
            entries.push(entry);
        }
    }
    let remaining = parts
        .iter()
        .map(PartEntry::Word)
        .chain(slots.iter().map(PartEntry::Slot))
        .collect::<Vec<_>>();
    for entry in remaining {
        if !entries.contains(&entry) {
            entries.push(entry);
        }
    }
    entries
}

pub fn entry_name(entry: PartEntry, profile: Profile) -> String {
    match entry {
        PartEntry::Word(part) => part.lexeme(profile).to_owned(),
        PartEntry::Slot(slot) => slot_text(slot.label),
    }
}

pub fn entry_text(entry: PartEntry) -> &'static str {
    match entry {
        PartEntry::Word(part) => part.text,
        PartEntry::Slot(slot) => slot.text,
    }
}
