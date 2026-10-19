use crate::cursor_context::CursorContext;
use pseudolearn_lexicon::{KeywordKind, Profile};
use pseudolearn_semantic::ServiceAnalysis;

pub struct SourceScope<'scope> {
    pub analysis: Option<&'scope ServiceAnalysis>,
    pub context: &'scope CursorContext,
    pub profile: Profile,
    pub offset: usize,
}

impl SourceScope<'_> {
    pub fn inside_method(&self) -> bool {
        self.context.open_blocks.contains(&KeywordKind::Method)
    }

    pub fn label(&self, spanish: &str, english: &str) -> String {
        match self.profile {
            Profile::Spanish => spanish.to_owned(),
            Profile::English => english.to_owned(),
        }
    }
}
