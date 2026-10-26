use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::{
    SemanticOptions, ServiceAnalysis, ServiceSymbolTarget, analyze_for_service,
};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{SyntaxTree, TokenKind};
use std::collections::BTreeSet;

pub struct IdentifierRoles {
    user_starts: BTreeSet<u32>,
    contextual: std::collections::BTreeMap<usize, &'static str>,
    global_names: BTreeSet<String>,
    profile: Profile,
}

impl IdentifierRoles {
    pub fn build(tree: &SyntaxTree, source: &SourceText, options: SemanticOptions) -> Self {
        let analysis = analyze_for_service(tree, source, options);
        let user_starts = analysis
            .occurrences
            .iter()
            .filter(|occurrence| !matches!(occurrence.target, ServiceSymbolTarget::Builtin(_)))
            .map(|occurrence| occurrence.span.start)
            .collect();
        Self {
            contextual: crate::contextual_tokens::collect(tree, source, &analysis, options.profile),
            user_starts,
            global_names: global_names(&analysis, options.profile),
            profile: options.profile,
        }
    }

    pub(crate) fn contextual_identity(&self, token: usize) -> Option<&'static str> {
        self.contextual.get(&token).copied()
    }

    pub fn is_user_name(&self, tree: &SyntaxTree, source: &SourceText, index: usize) -> bool {
        if is_member_access(tree, index) {
            return true;
        }
        let Some(span) = tree.tokens.span(index) else {
            return false;
        };
        if self.user_starts.contains(&span.start) {
            return true;
        }
        let text = tree.tokens.text(source.as_str(), index).unwrap_or("");
        self.global_names.contains(&self.profile.fold_word(text))
    }
}

fn global_names(analysis: &ServiceAnalysis, profile: Profile) -> BTreeSet<String> {
    let mut names = BTreeSet::new();
    for function in &analysis.module.functions {
        names.insert(profile.fold_word(&function.name));
    }
    for class in &analysis.module.classes {
        names.insert(profile.fold_word(&class.name));
        for field in &class.fields {
            names.insert(profile.fold_word(&field.name));
        }
    }
    names
}

fn is_member_access(tree: &SyntaxTree, index: usize) -> bool {
    let mut cursor = index;
    while cursor > 0 {
        cursor = cursor.saturating_sub(1);
        match tree.tokens.kind(cursor) {
            Some(TokenKind::Whitespace) => {}
            Some(TokenKind::Dot) => return true,
            _ => return false,
        }
    }
    false
}
