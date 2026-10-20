use crate::completion_types::{CompletionAction, CompletionEntry, CompletionKind};
use pseudolearn_lexicon::{Profile, fold_text};

#[derive(Clone, Copy, Debug)]
pub struct Rank {
    pub compat: u8,
    pub distance: u32,
}

impl Rank {
    pub const NEUTRAL: Rank = Rank {
        compat: 2,
        distance: 0,
    };
}

pub struct Ranked {
    pub tier: u8,
    pub exempt_from_prefix: bool,
    pub rank: Rank,
    pub entry: CompletionEntry,
}

#[derive(Default)]
pub struct CandidatePool {
    items: Vec<Ranked>,
}

type SortKey = (u8, u8, u8, bool, u32, String, String);

pub fn plain_entry(label: String, kind: CompletionKind, detail: Option<String>) -> CompletionEntry {
    CompletionEntry {
        label,
        kind,
        detail,
        insert_text: None,
        bilingual_origin: None,
        detail_key: None,
        detail_arguments: Vec::new(),
        inline: false,
        action: CompletionAction::Plain,
    }
}

pub fn keyed_entry(
    label: String,
    kind: CompletionKind,
    key: (&str, Vec<String>),
    prose: Option<String>,
) -> CompletionEntry {
    let mut entry = plain_entry(label, kind, prose);
    entry.detail_key = Some(key.0.to_owned());
    entry.detail_arguments = key.1;
    entry
}

impl CandidatePool {
    pub fn add(&mut self, tier: u8, entry: CompletionEntry) {
        self.add_ranked(tier, entry, Rank::NEUTRAL);
    }

    pub fn add_ranked(&mut self, tier: u8, entry: CompletionEntry, rank: Rank) {
        self.items.push(Ranked {
            tier,
            exempt_from_prefix: false,
            rank,
            entry,
        });
    }

    pub fn add_hint(&mut self, tier: u8, entry: CompletionEntry) {
        self.items.push(Ranked {
            tier,
            exempt_from_prefix: true,
            rank: Rank::NEUTRAL,
            entry,
        });
    }

    pub fn finish(self, prefix: &str, profile: Profile) -> Vec<CompletionEntry> {
        let wanted = profile.fold_word(prefix);
        let mut kept: Vec<(SortKey, CompletionEntry)> = self
            .items
            .into_iter()
            .filter_map(|ranked| sort_key(&ranked, &wanted, profile).map(|key| (key, ranked.entry)))
            .collect();
        kept.sort_by(|left, right| left.0.cmp(&right.0));
        let mut seen: Vec<String> = Vec::new();
        let mut result = Vec::new();
        for (_, entry) in kept {
            let key = fold_text(&entry.label);
            if seen.contains(&key) {
                continue;
            }
            seen.push(key);
            result.push(entry);
        }
        result
    }
}

fn sort_key(ranked: &Ranked, wanted: &str, profile: Profile) -> Option<SortKey> {
    let folded = profile.fold_word(&ranked.entry.label);
    let level = if ranked.exempt_from_prefix || folded.starts_with(wanted) {
        0
    } else if initials_match(&ranked.entry.label, wanted, profile) {
        1
    } else {
        return None;
    };
    let not_exact = folded != wanted;
    Some((
        ranked.tier,
        level,
        ranked.rank.compat,
        not_exact,
        ranked.rank.distance,
        folded,
        ranked.entry.label.clone(),
    ))
}

fn initials_match(label: &str, wanted: &str, profile: Profile) -> bool {
    if wanted.chars().count() < 2 {
        return false;
    }
    let initials = segment_initials(label);
    initials.chars().count() >= 2 && profile.fold_word(&initials).starts_with(wanted)
}

fn segment_initials(label: &str) -> String {
    let mut initials = String::new();
    let mut previous_lower = false;
    let mut at_start = true;
    for glyph in label.chars() {
        if glyph == ' ' {
            at_start = true;
            previous_lower = false;
            continue;
        }
        if at_start || (previous_lower && glyph.is_uppercase()) {
            initials.push(glyph);
        }
        at_start = false;
        previous_lower = glyph.is_lowercase();
    }
    initials
}
