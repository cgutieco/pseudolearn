use crate::identities::{ClassId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_syntax::TokenKind;

pub(crate) fn resolve(session: &mut AnalysisSession<'_>, node: usize) -> TypeId {
    let kind = match session.token_kind(node) {
        Some(TokenKind::Keyword(KeywordKind::IntegerType)) => Type::Integer,
        Some(TokenKind::Keyword(KeywordKind::RealType)) => Type::Real,
        Some(TokenKind::Keyword(KeywordKind::BooleanType)) => Type::Boolean,
        Some(TokenKind::Keyword(KeywordKind::CharacterType)) => Type::Character,
        Some(TokenKind::Keyword(KeywordKind::StringType)) => Type::String,
        _ => class_type(session, node),
    };
    session.module.types.intern(kind)
}

fn class_type(session: &mut AnalysisSession<'_>, node: usize) -> Type {
    let name = session.name(node);
    if let Some(class) = session.classes.get(&name) {
        return Type::Object(*class);
    }
    if let Some(enumeration) = session.declared.enums.get(&name) {
        return Type::Enum(*enumeration);
    }
    if let Some(record) = session.declared.records.get(&name) {
        return Type::Record(*record);
    }
    session.named_report(DiagnosticCode::UndeclaredClass, node, &name);
    Type::Error
}

pub(crate) fn assignable(session: &AnalysisSession<'_>, target: &Type, source: &Type) -> bool {
    if target == source
        || matches!(target, Type::Error | Type::Unknown)
        || matches!(source, Type::Error | Type::Unknown)
    {
        return true;
    }
    if *target == Type::Real && *source == Type::Integer {
        return true;
    }
    if let (Type::Object(superclass), Type::Object(subclass)) = (target, source) {
        return subclass_of(session, *subclass, *superclass);
    }
    false
}

fn subclass_of(session: &AnalysisSession<'_>, mut class: ClassId, superclass: ClassId) -> bool {
    for _ in 0..session.module.classes.len() {
        if class == superclass {
            return true;
        }
        let next = usize::try_from(class.0)
            .ok()
            .and_then(|index| session.module.classes.get(index))
            .and_then(|class| class.superclass);
        let Some(next) = next else {
            break;
        };
        class = next;
    }
    false
}
