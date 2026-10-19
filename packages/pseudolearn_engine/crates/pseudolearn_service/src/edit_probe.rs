use crate::document_session::{DocumentSession, TextEdit};
use crate::navigation::Range;
use crate::node_identity::{SyntaxNodeId, compute_node_identities};
use crate::positions::{offset_at, position_at};
use pseudolearn_lexicon::Profile;
use pseudolearn_source::{SourceText, Span};
use pseudolearn_syntax::parse_source;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum IdentityCheck {
    NeighbourUnits,
    PreviousStatements,
    SemanticNodes,
}

pub struct SeededRandom {
    state: u64,
}

impl SeededRandom {
    pub fn new(seed: u64) -> Self {
        Self {
            state: seed
                .wrapping_mul(6364136223846793005)
                .wrapping_add(1442695040888963407)
                | 1,
        }
    }

    pub fn next_below(&mut self, bound: usize) -> usize {
        self.state ^= self.state.wrapping_shl(13);
        self.state ^= self.state.wrapping_shr(7);
        self.state ^= self.state.wrapping_shl(17);
        let wide = u128::from(self.state);
        let limit = u128::try_from(bound.max(1)).unwrap_or(1);
        usize::try_from(wide.checked_rem(limit).unwrap_or(0)).unwrap_or(0)
    }
}

const SNIPPETS: &[&str] = &[
    "x",
    " ",
    "\n",
    "; ",
    "// nota\n",
    "Si ",
    "1",
    ")",
    "\"",
    "Fin",
];

pub fn random_edit(text: &str, random: &mut SeededRandom) -> TextEdit {
    let boundaries: Vec<usize> = text
        .char_indices()
        .map(|(index, _)| index)
        .chain(std::iter::once(text.len()))
        .collect();
    let start_slot = random.next_below(boundaries.len());
    let start = boundaries.get(start_slot).copied().unwrap_or(0);
    let removed = random.next_below(4);
    let ending_slot = start_slot
        .saturating_add(removed)
        .min(boundaries.len().saturating_sub(1));
    let ending = boundaries.get(ending_slot).copied().unwrap_or(start);
    let snippet = SNIPPETS
        .get(random.next_below(SNIPPETS.len()))
        .copied()
        .unwrap_or("");
    TextEdit {
        range: Range {
            start: position_at(text, start),
            end: position_at(text, ending),
        },
        new_text: snippet.to_owned(),
    }
}

#[derive(Clone, Copy, Debug)]
pub struct IncrementalProbe {
    pub profile: Profile,
    pub strict: bool,
    pub seed: u64,
    pub steps: usize,
}

pub fn incremental_matches_cold(text: &str, probe: IncrementalProbe) -> bool {
    let mut session = DocumentSession::new(text.to_owned(), probe.profile, probe.strict);
    let mut random = SeededRandom::new(probe.seed);
    for _ in 0..probe.steps {
        let edit = random_edit(session.text(), &mut random);
        session.apply_text_edits(&[edit]);
        if !session.matches_cold_analysis() {
            return false;
        }
    }
    true
}

pub fn unit_local_edit(text: &str, profile: Profile, seed: u64) -> Option<TextEdit> {
    let source = SourceText::new(text.to_owned());
    let (tree, diagnostics) = parse_source(&source, profile);
    if !diagnostics.is_empty() {
        return None;
    }
    let units: Vec<Span> = compute_node_identities(&tree, &source)
        .into_iter()
        .filter(|(id, _)| id.structural_path.len() == 1)
        .map(|(_, span)| span)
        .collect();
    let mut random = SeededRandom::new(seed);
    let unit = units.get(random.next_below(units.len()))?;
    let start = usize::try_from(unit.start).ok()?;
    let header_end = text
        .get(start..)?
        .find('\n')?
        .saturating_add(start)
        .saturating_add(1);
    let insertion = ["// nota\n", "\n", "Escribir 1;\n"];
    let snippet = insertion.get(random.next_below(insertion.len()))?;
    let caret = position_at(text, header_end);
    Some(TextEdit {
        range: Range {
            start: caret,
            end: caret,
        },
        new_text: (*snippet).to_owned(),
    })
}

type UnitKey = (String, String, Option<u32>);

fn edited_unit(before: &[(SyntaxNodeId, Span)], edit_start: u32) -> Option<UnitKey> {
    before
        .iter()
        .find(|(id, span)| {
            id.structural_path.len() == 1 && span.start <= edit_start && edit_start <= span.ending
        })
        .map(|(id, _)| {
            (
                id.unit_name.clone(),
                id.unit_kind.clone(),
                id.structural_path.first().copied(),
            )
        })
}

fn belongs_to(id: &SyntaxNodeId, unit: &UnitKey) -> bool {
    id.unit_name == unit.0
        && id.unit_kind == unit.1
        && id.structural_path.first().copied() == unit.2
}

pub fn identity_stable(
    text: &str,
    edit: &TextEdit,
    check: IdentityCheck,
    profile: Profile,
) -> bool {
    let source = SourceText::new(text.to_owned());
    let (tree, _) = parse_source(&source, profile);
    let before = compute_node_identities(&tree, &source);
    let edit_start = u32::try_from(offset_at(text, edit.range.start)).unwrap_or(u32::MAX);
    let mut session = DocumentSession::new(text.to_owned(), profile, true);
    session.apply_text_edits(std::slice::from_ref(edit));
    let after: Vec<SyntaxNodeId> = compute_node_identities(&session.tree, &session.source)
        .into_iter()
        .map(|(id, _)| id)
        .collect();
    match check {
        IdentityCheck::SemanticNodes => {
            before.len() == after.len() && before.iter().all(|(id, _)| after.contains(id))
        }
        IdentityCheck::PreviousStatements => before
            .iter()
            .filter(|(_, span)| span.ending <= edit_start)
            .all(|(id, _)| after.contains(id)),
        IdentityCheck::NeighbourUnits => {
            let edited = edited_unit(&before, edit_start);
            before
                .iter()
                .filter(|(id, _)| edited.as_ref().is_none_or(|unit| !belongs_to(id, unit)))
                .all(|(id, _)| after.contains(id))
        }
    }
}
