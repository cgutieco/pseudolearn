use crate::identities::TypeId;
use crate::session::AnalysisSession;
use crate::types::Type;

pub(crate) fn text_vector(session: &mut AnalysisSession<'_>, node: usize) -> TypeId {
    let text = session.module.types.intern(Type::String);
    let class = session
        .module
        .collections
        .values()
        .find(|collection| collection.key.is_none() && collection.value == text)
        .map(|collection| collection.class)
        .unwrap_or_else(|| crate::collection_types::register(session, node, (None, text)));
    session.module.types.intern(Type::Object(class))
}
