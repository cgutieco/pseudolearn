use crate::identifier_roles::IdentifierRoles;
use crate::spelling::{boolean_spelling, builtin_spelling, keyword_spelling};
use pseudolearn_lexicon::{Profile, find_builtin, find_keyword, is_compound_prefix};
use pseudolearn_semantic::SemanticOptions;
use pseudolearn_source::{SourceText, Span};
use pseudolearn_syntax::{SyntaxTree, TokenKind, parse_source};
use std::collections::BTreeSet;

pub const COLLISION_DIAGNOSTIC: &str = "reservedLexemeUsedAsName";

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum TranslationError {
    Collision {
        identifier: String,
        diagnostic: String,
        span: Span,
    },
    ParseFailure(String),
}

pub fn translate_source(
    text: &str,
    target_profile: Profile,
    strict: bool,
) -> Result<String, TranslationError> {
    let source_profile = opposite(target_profile);
    let source = SourceText::new(text.to_owned());
    let (tree, diagnostics) = parse_source(&source, source_profile);
    if let Some(first) = diagnostics.first() {
        return Err(TranslationError::ParseFailure(format!("{:?}", first.code)));
    }
    let roles = IdentifierRoles::build(
        &tree,
        &source,
        SemanticOptions {
            profile: source_profile,
            strict,
        },
    );
    let plan = TranslationPlan {
        tree: &tree,
        source: &source,
        roles: &roles,
        source_profile,
        target_profile,
    };
    plan.render()
}

fn opposite(profile: Profile) -> Profile {
    match profile {
        Profile::Spanish => Profile::English,
        Profile::English => Profile::Spanish,
    }
}

struct TranslationPlan<'plan> {
    tree: &'plan SyntaxTree,
    source: &'plan SourceText,
    roles: &'plan IdentifierRoles,
    source_profile: Profile,
    target_profile: Profile,
}

#[derive(Default)]
struct Collected {
    produced: BTreeSet<String>,
    user_names: Vec<(String, Span)>,
}

impl TranslationPlan<'_> {
    fn render(&self) -> Result<String, TranslationError> {
        let mut rendered = String::new();
        if self.source.bom_prefix_length() > 0 {
            rendered.push('\u{FEFF}');
        }
        let mut collected = Collected::default();
        for index in 0..self.tree.tokens.token_count() {
            rendered.push_str(&self.translate_token(index, &mut collected));
        }
        self.reject_collisions(&collected)?;
        Ok(rendered)
    }

    fn translate_token(&self, index: usize, collected: &mut Collected) -> String {
        let original = self
            .tree
            .tokens
            .text(self.source.as_str(), index)
            .unwrap_or("");
        match self.tree.tokens.kind(index) {
            Some(TokenKind::EndOfFile) | None => String::new(),
            Some(TokenKind::Keyword(keyword)) => keyword_spelling(keyword, self.target_profile),
            Some(TokenKind::BooleanLiteral(value)) => boolean_spelling(value, self.target_profile),
            Some(TokenKind::Identifier) => self.translate_identifier(index, original, collected),
            Some(_) => original.to_owned(),
        }
    }

    fn translate_identifier(
        &self,
        index: usize,
        original: &str,
        collected: &mut Collected,
    ) -> String {
        if !self.roles.is_user_name(self.tree, self.source, index)
            && let Some(builtin) = find_builtin(original, self.source_profile)
        {
            let spelled = builtin_spelling(builtin, self.target_profile);
            collected
                .produced
                .insert(self.target_profile.fold_word(&spelled));
            return spelled;
        }
        if let Some(span) = self.tree.tokens.span(index) {
            collected.user_names.push((original.to_owned(), span));
        }
        original.to_owned()
    }

    fn reject_collisions(&self, collected: &Collected) -> Result<(), TranslationError> {
        for (name, span) in &collected.user_names {
            let folded = self.target_profile.fold_word(name);
            let reserved = find_keyword(name, self.target_profile).is_some()
                || is_compound_prefix(name)
                || collected.produced.contains(&folded);
            if reserved {
                return Err(TranslationError::Collision {
                    identifier: name.clone(),
                    diagnostic: COLLISION_DIAGNOSTIC.to_owned(),
                    span: *span,
                });
            }
        }
        Ok(())
    }
}
