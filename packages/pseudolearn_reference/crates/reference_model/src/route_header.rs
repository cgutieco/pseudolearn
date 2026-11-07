use serde::{Deserialize, Serialize};

#[derive(Clone, Copy, Debug, Deserialize, Eq, Hash, Ord, PartialEq, PartialOrd, Serialize)]
pub enum LessonKind {
    #[serde(rename = "leccion")]
    Lesson,
    #[serde(rename = "apertura")]
    Opening,
    #[serde(rename = "proyecto")]
    Project,
}

#[derive(Clone, Copy, Debug, Deserialize, Eq, Hash, Ord, PartialEq, PartialOrd, Serialize)]
pub enum ExerciseKind {
    #[serde(rename = "predecir")]
    Predict,
    #[serde(rename = "rastrear")]
    Trace,
    #[serde(rename = "ordenar")]
    Order,
    #[serde(rename = "encontrar-error")]
    FindError,
    #[serde(rename = "romperlo")]
    Break,
    #[serde(rename = "disenar-pruebas")]
    DesignTests,
    #[serde(rename = "modificar")]
    Modify,
    #[serde(rename = "resolver")]
    Solve,
    #[serde(rename = "comparar")]
    Compare,
    #[serde(rename = "clasificar")]
    Classify,
    #[serde(rename = "explicar")]
    Explain,
}

impl ExerciseKind {
    pub fn runs_student_code(self) -> bool {
        matches!(self, Self::Solve | Self::Modify | Self::FindError)
    }

    pub fn writes_code(self) -> bool {
        matches!(
            self,
            Self::Solve
                | Self::Modify
                | Self::FindError
                | Self::DesignTests
                | Self::Order
                | Self::Break
        )
    }

    pub fn needs_hint_ladder(self) -> bool {
        matches!(
            self,
            Self::Solve | Self::Modify | Self::FindError | Self::Break | Self::DesignTests
        )
    }
}

#[derive(Clone, Copy, Debug, Deserialize, Eq, Hash, Ord, PartialEq, PartialOrd, Serialize)]
pub enum ExerciseLevel {
    #[serde(rename = "semilla")]
    Seed,
    #[serde(rename = "brote")]
    Sprout,
    #[serde(rename = "arbol")]
    Tree,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq)]
#[serde(deny_unknown_fields)]
pub struct LessonHeader {
    pub id: String,
    #[serde(rename = "numero")]
    pub number: String,
    #[serde(rename = "tipo")]
    pub kind: LessonKind,
    #[serde(rename = "titulo")]
    pub title: String,
    #[serde(rename = "duracion")]
    pub minutes: u32,
    #[serde(rename = "problema_breve")]
    pub brief_problem: String,
    #[serde(rename = "necesita", default)]
    pub needs: Vec<String>,
    #[serde(rename = "introduce", default)]
    pub introduces: Vec<String>,
    #[serde(rename = "usa", default)]
    pub uses: Vec<String>,
    #[serde(rename = "pieza", default)]
    pub piece: Option<u8>,
    #[serde(rename = "menciones_cotidianas", default)]
    pub everyday_mentions: Vec<String>,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq)]
#[serde(deny_unknown_fields)]
pub struct ExerciseHeader {
    pub id: String,
    #[serde(rename = "leccion")]
    pub lesson: String,
    #[serde(rename = "tipo")]
    pub kind: ExerciseKind,
    #[serde(rename = "nivel")]
    pub level: ExerciseLevel,
    #[serde(rename = "obligatorio", default)]
    pub required: bool,
    #[serde(rename = "titulo")]
    pub title: String,
}

#[derive(Clone, Debug, Default, Deserialize, Eq, PartialEq)]
#[serde(deny_unknown_fields)]
pub struct TermDefinition {
    #[serde(rename = "etiqueta")]
    pub label: String,
    #[serde(rename = "formas", default)]
    pub forms: Vec<String>,
    #[serde(rename = "estricto", default)]
    pub strict: bool,
    #[serde(rename = "receta", default)]
    pub recipe: bool,
}

pub type LessonDocument = crate::RouteDocument<LessonHeader>;
pub type ExerciseDocument = crate::RouteDocument<ExerciseHeader>;
