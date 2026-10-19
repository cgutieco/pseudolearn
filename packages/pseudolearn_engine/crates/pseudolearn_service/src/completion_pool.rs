use crate::completion_types::{CompletionEntry, CompletionKind};
use pseudolearn_lexicon::{Profile, fold_text};

pub struct Ranked {
    pub tier: u8,
    pub exempt_from_prefix: bool,
    pub entry: CompletionEntry,
}

#[derive(Default)]
pub struct CandidatePool {
    items: Vec<Ranked>,
}

pub fn plain_entry(label: String, kind: CompletionKind, detail: Option<String>) -> CompletionEntry {
    CompletionEntry {
        label,
        kind,
        detail,
        insert_text: None,
        bilingual_origin: None,
    }
}

impl CandidatePool {
    pub fn add(&mut self, tier: u8, entry: CompletionEntry) {
        self.items.push(Ranked {
            tier,
            exempt_from_prefix: false,
            entry,
        });
    }

    pub fn add_hint(&mut self, tier: u8, entry: CompletionEntry) {
        self.items.push(Ranked {
            tier,
            exempt_from_prefix: true,
            entry,
        });
    }

    pub fn finish(self, prefix: &str, profile: Profile) -> Vec<CompletionEntry> {
        let wanted = profile.fold_word(prefix);
        let mut kept: Vec<(u8, bool, String, CompletionEntry)> = self
            .items
            .into_iter()
            .filter_map(|ranked| {
                let folded = profile.fold_word(&ranked.entry.label);
                if !ranked.exempt_from_prefix && !folded.starts_with(&wanted) {
                    return None;
                }
                let exact = folded == wanted;
                Some((ranked.tier, !exact, folded, ranked.entry))
            })
            .collect();
        kept.sort_by(|left, right| {
            (left.0, left.1, &left.2, &left.3.label).cmp(&(
                right.0,
                right.1,
                &right.2,
                &right.3.label,
            ))
        });
        let mut seen: Vec<String> = Vec::new();
        let mut result = Vec::new();
        for (_, _, _, entry) in kept {
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
