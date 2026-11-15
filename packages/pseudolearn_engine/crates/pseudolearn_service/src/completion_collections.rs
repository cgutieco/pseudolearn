use crate::completion_pool::{CandidatePool, plain_entry};
use crate::completion_types::{CompletionAction, CompletionKind};
use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::ServiceAnalysis;

pub(crate) fn add(
    analysis: &ServiceAnalysis,
    class: usize,
    profile: Profile,
    pool: &mut CandidatePool,
) -> bool {
    let Some(model) = u32::try_from(class).ok().and_then(|class| {
        analysis
            .module
            .collections
            .get(&pseudolearn_semantic::identities::ClassId(class))
    }) else {
        return false;
    };
    let identities = identities(model.key.is_some());
    for (identity, parameters) in identities {
        if let Some(label) = pseudolearn_syntax::contextual_spelling(identity, profile.as_str()) {
            let mut entry = plain_entry(label.to_owned(), CompletionKind::Method, None);
            entry.action = CompletionAction::Call {
                parameters: parameters
                    .iter()
                    .map(|parameter| (*parameter).to_owned())
                    .collect(),
            };
            pool.add(1, entry);
        }
    }
    true
}

fn identities(dictionary: bool) -> &'static [(&'static str, &'static [&'static str])] {
    if dictionary {
        &[
            ("collectionLength", &[]),
            ("dictionaryFind", &["key"]),
            ("collectionRemove", &["key"]),
            ("dictionaryKeys", &[]),
        ]
    } else {
        &[
            ("collectionLength", &[]),
            ("vectorAppend", &["value"]),
            ("vectorInsert", &["position", "value"]),
            ("collectionRemove", &["position"]),
            ("vectorSort", &[]),
            ("vectorReverse", &[]),
            ("vectorIndexOf", &["value"]),
            ("vectorContains", &["value"]),
        ]
    }
}
