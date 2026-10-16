#[derive(Clone, Debug, Eq, PartialEq)]
pub struct AliasDestination {
    pub frame_position: usize,
    pub target_name: String,
}

#[derive(Clone, Debug, PartialEq)]
pub enum VariableValue {
    Undefined,
    Integer(i64),
    Real(f64),
    Boolean(bool),
    Character(char),
    Text(String),
    ObjectReference {
        handle_word: u32,
        identity_ordinal: u64,
        class_identifier: u32,
    },
    ArrayReference {
        handle_word: u32,
        identity_ordinal: u64,
        dimensions: Vec<u64>,
    },
    NullReference,
}

pub fn format_real(number: f64) -> String {
    let representation = number.to_string();
    if representation.contains('.') || representation.contains('e') || representation.contains('E')
    {
        representation
    } else {
        format!("{representation}.0")
    }
}

#[derive(Clone, Debug, PartialEq)]
pub struct VariableView {
    pub name: String,
    pub variable_type: String,
    pub value: VariableValue,
    pub alias: Option<AliasDestination>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct FrameView {
    pub position: usize,
    pub function_name: String,
    pub variables: Vec<VariableView>,
    pub receiver_handle: Option<u32>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct StateSnapshot {
    pub event_index: usize,
    pub statement_index: u64,
    pub output_text: String,
    pub frames: Vec<FrameView>,
}
