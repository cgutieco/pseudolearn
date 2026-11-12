use crate::{Inline, SourceBlock};

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct CaseSource {
    pub hidden: bool,
    pub inputs: Vec<String>,
    pub expected: Option<String>,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct ChoiceSource {
    pub correct: bool,
    pub text: Vec<Inline>,
    pub justification: Vec<Inline>,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct ElementSource {
    pub text: Vec<Inline>,
    pub category: String,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct LapSource {
    pub label: String,
    pub cells: Vec<String>,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct LapTable {
    pub mark: usize,
    pub start: Option<usize>,
    pub columns: Vec<String>,
    pub rows: Vec<LapSource>,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct AssertionSource {
    pub kind: String,
    pub fields: Vec<String>,
    pub requirement: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum RouteFence {
    SpecFigure {
        section: String,
        figure: String,
    },
    Laps(LapTable),
    Cases(Vec<CaseSource>),
    Breakers(Vec<CaseSource>),
    SolutionCases {
        minimum: usize,
        maximum: usize,
        cases: Vec<CaseSource>,
    },
    Steps(Vec<Vec<Inline>>),
    Categories(Vec<String>),
    Elements(Vec<ElementSource>),
    Choices(Vec<ChoiceSource>),
    Assertions(Vec<AssertionSource>),
}

impl RouteFence {
    pub fn name(&self) -> &'static str {
        match self {
            Self::SpecFigure { .. } => "figura-especificacion",
            Self::Laps(_) => "vueltas",
            Self::Cases(_) => "casos",
            Self::Breakers(_) => "rompe",
            Self::SolutionCases { .. } => "casos-solucion",
            Self::Steps(_) => "pasos",
            Self::Categories(_) => "categorias",
            Self::Elements(_) => "elementos",
            Self::Choices(_) => "opciones",
            Self::Assertions(_) => "aserciones",
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct RouteDocument<Header> {
    pub path: String,
    pub header: Header,
    pub title: Vec<Inline>,
    pub blocks: Vec<SourceBlock>,
}
