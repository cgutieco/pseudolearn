use crate::identities::TypeId;
use pseudolearn_abi::VariantLayout;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum VariantFamily {
    Optional,
    Result,
    User,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct HirUserAlternative {
    pub name: String,
    pub spelling: String,
    pub payload: Option<crate::identities::RecordId>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct HirUserVariant {
    pub name: String,
    pub alternatives: Vec<HirUserAlternative>,
    pub syntax: usize,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct HirVariant {
    pub family: VariantFamily,
    pub payloads: Vec<Option<TypeId>>,
    pub offsets: Vec<Vec<u32>>,
    pub layout: VariantLayout,
}

impl HirVariant {
    pub fn success_alternative(&self) -> usize {
        match self.family {
            VariantFamily::Optional => 1,
            VariantFamily::Result | VariantFamily::User => 0,
        }
    }
}

#[derive(Clone, Debug, PartialEq)]
pub struct HirVariantMatch {
    pub value: crate::identities::ExpressionId,
    pub storage: crate::identities::LocalId,
    pub selector: crate::identities::ExpressionId,
    pub cases: Vec<crate::statement_model::HirCase>,
    pub default: Vec<crate::identities::StatementId>,
}
