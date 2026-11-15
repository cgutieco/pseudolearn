use pseudolearn_source::Span;

#[derive(Clone, Copy, Debug, Default, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub struct TemplateId(pub u32);

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum TemplateKind {
    Subprogram,
    Record,
    Class,
    Interface,
    Variant,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct HirTypeParameter {
    pub name: String,
    pub constraint: Option<String>,
    pub span: Span,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct HirTemplate {
    pub name: String,
    pub kind: TemplateKind,
    pub header: String,
    pub span: Span,
    pub parameters: Vec<HirTypeParameter>,
}
