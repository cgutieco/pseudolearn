use crate::Inline;

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct FigurePanelSource {
    pub zone: String,
    pub from_step: usize,
    pub text: Vec<Inline>,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct FigureStepSource {
    pub text: Vec<Inline>,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct FigureSource {
    pub id: String,
    pub caption: Vec<Inline>,
    pub steps: Vec<FigureStepSource>,
    pub panels: Vec<FigurePanelSource>,
}
