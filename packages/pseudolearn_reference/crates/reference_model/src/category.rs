use serde::{Deserialize, Serialize};

#[derive(Clone, Copy, Debug, Deserialize, Eq, Hash, Ord, PartialEq, PartialOrd, Serialize)]
#[serde(rename_all = "camelCase")]
pub enum TokenCategory {
    KeywordStructured,
    KeywordProcedural,
    KeywordOop,
    Identifier,
    Type,
    LiteralNumber,
    LiteralString,
    LiteralBoolean,
    Operator,
    Punctuation,
    Comment,
}
