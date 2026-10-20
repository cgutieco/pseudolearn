use crate::completion_keywords::{
    closing_keyword, follow_up_keywords, keyword_entry, structure_keywords,
};
use crate::completion_pool::{CandidatePool, Rank, keyed_entry, plain_entry};
use crate::completion_scope::SourceScope;
use crate::completion_symbols::{
    builtin_functions, class_names, enclosing_fields, local_variables, user_callables,
};
use crate::completion_types::CompletionKind;
use crate::spelling::{boolean_spelling, keyword_spelling};
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_semantic::types::Type;
use pseudolearn_syntax::TokenKind;

pub fn closing_candidates(scope: &SourceScope<'_>, pool: &mut CandidatePool) {
    let Some(innermost) = scope.context.open_blocks.last().copied() else {
        return;
    };
    pool.add(
        0,
        keyed_entry(
            keyword_spelling(closing_keyword(innermost), scope.profile),
            CompletionKind::Keyword,
            ("close_block", Vec::new()),
            Some(scope.label("Cerrar bloque", "Close block")),
        ),
    );
    if innermost == KeywordKind::IfKeyword {
        pool.add(1, keyword_entry(KeywordKind::ElseKeyword, scope.profile));
    }
    if innermost == KeywordKind::SwitchKeyword {
        pool.add(1, keyword_entry(KeywordKind::DefaultCase, scope.profile));
    }
}

pub fn statement_candidates(scope: &SourceScope<'_>, pool: &mut CandidatePool) {
    closing_candidates(scope, pool);
    let blocks = &scope.context.open_blocks;
    for kind in structure_keywords(blocks.last()) {
        pool.add(2, keyword_entry(*kind, scope.profile));
    }
    let returns_allowed = blocks
        .iter()
        .any(|block| matches!(block, KeywordKind::Subroutine | KeywordKind::Method));
    if returns_allowed {
        pool.add(2, keyword_entry(KeywordKind::ReturnKeyword, scope.profile));
    }
    if !blocks.is_empty() && blocks.last() != Some(&KeywordKind::ClassKeyword) {
        local_variables(scope, pool);
        user_callables(scope, pool, false);
    }
}

pub fn expression_candidates(scope: &SourceScope<'_>, pool: &mut CandidatePool) {
    if scope.context.previous == Some(TokenKind::Keyword(KeywordKind::NewInstance)) {
        class_names(scope, pool, 1);
        return;
    }
    follow_up_keywords(scope, pool);
    local_variables(scope, pool);
    enclosing_fields(scope, pool);
    user_callables(scope, pool, true);
    builtin_functions(scope, pool);
    for value in [true, false] {
        let rank = Rank {
            compat: scope.compatibility_of(Some(&Type::Boolean)),
            distance: 0,
        };
        pool.add_ranked(
            3,
            plain_entry(
                boolean_spelling(value, scope.profile),
                CompletionKind::Keyword,
                None,
            ),
            rank,
        );
    }
    pool.add(3, keyword_entry(KeywordKind::NewInstance, scope.profile));
    pool.add(3, keyword_entry(KeywordKind::Not, scope.profile));
    if scope.inside_method() {
        pool.add(3, keyword_entry(KeywordKind::ThisObject, scope.profile));
    }
    for operator in [
        KeywordKind::And,
        KeywordKind::Or,
        KeywordKind::Modulo,
        KeywordKind::IntegerDivide,
    ] {
        pool.add(4, keyword_entry(operator, scope.profile));
    }
}

pub fn type_candidates(scope: &SourceScope<'_>, pool: &mut CandidatePool) {
    for kind in [
        KeywordKind::IntegerType,
        KeywordKind::RealType,
        KeywordKind::BooleanType,
        KeywordKind::CharacterType,
        KeywordKind::StringType,
    ] {
        pool.add(
            1,
            keyed_entry(
                keyword_spelling(kind, scope.profile),
                CompletionKind::Type,
                ("primitive_type", Vec::new()),
                Some(scope.label("Tipo primitivo", "Primitive type")),
            ),
        );
    }
    class_names(scope, pool, 1);
}
