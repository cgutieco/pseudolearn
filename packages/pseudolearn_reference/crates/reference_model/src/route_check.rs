use crate::{ExerciseKind, LapSource};

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct RunRecord {
    pub inputs: Vec<String>,
    pub expected: Option<String>,
    pub hidden: bool,
    pub output: String,
    pub termination: String,
}

impl RunRecord {
    pub fn completed(&self) -> bool {
        self.termination == "completed"
    }
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct RoleRuns {
    pub role: String,
    pub id: String,
    pub cases: Vec<RunRecord>,
    pub breakers: Vec<RunRecord>,
    pub solution: Vec<RunRecord>,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct LapCheck {
    pub expected: Vec<LapSource>,
    pub observed: Vec<Vec<String>>,
    pub termination: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ExerciseCheck {
    pub location: String,
    pub kind: ExerciseKind,
    pub roles: Vec<RoleRuns>,
    pub laps: Option<LapCheck>,
    pub structural: bool,
}

impl ExerciseCheck {
    pub fn role(&self, name: &str) -> Option<&RoleRuns> {
        self.roles.iter().find(|runs| runs.role == name)
    }

    pub fn roles_named<'check>(
        &'check self,
        name: &'check str,
    ) -> impl Iterator<Item = &'check RoleRuns> + 'check {
        self.roles.iter().filter(move |runs| runs.role == name)
    }
}
