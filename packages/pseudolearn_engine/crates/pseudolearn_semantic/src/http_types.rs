use crate::hir::HirEnum;
use crate::identities::{EnumId, TypeId};
use crate::session::AnalysisSession;
use crate::types::Type;

const HTTP_METHOD_ENUM: &str = "httpMethod";

pub(crate) fn resolve(session: &mut AnalysisSession<'_>, name: &str) -> Option<Type> {
    matches!(name, "MetodoHttp" | "HttpMethod").then(|| Type::Enum(ensure_enum(session)))
}

pub(crate) fn value_type(session: &mut AnalysisSession<'_>, _node: usize) -> TypeId {
    let enumeration = ensure_enum(session);
    session.module.types.intern(Type::Enum(enumeration))
}

pub(crate) fn builtin_enum(session: &mut AnalysisSession<'_>, name: &str) -> Option<EnumId> {
    matches!(name, "MetodoHttp" | "HttpMethod").then(|| ensure_enum(session))
}

fn ensure_enum(session: &mut AnalysisSession<'_>) -> EnumId {
    if let Some(enumeration) = session.module.builtin_enums.get(HTTP_METHOD_ENUM) {
        return *enumeration;
    }
    let enumeration = EnumId(u32::try_from(session.module.enums.len()).unwrap_or(u32::MAX));
    session.module.enums.push(HirEnum {
        name: format!("${HTTP_METHOD_ENUM}"),
        members: ["GET", "HEAD", "POST", "PUT", "PATCH", "DELETE"]
            .into_iter()
            .map(str::to_owned)
            .collect(),
        span: session.span(0),
    });
    session
        .module
        .builtin_enums
        .insert(HTTP_METHOD_ENUM.to_owned(), enumeration);
    enumeration
}
