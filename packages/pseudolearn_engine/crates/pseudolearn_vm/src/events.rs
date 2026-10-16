#![forbid(unsafe_code)]

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
#[repr(u8)]
pub enum TraceClass {
    StatementEntered = 0,
    StatementExited = 1,
    Decision = 2,
    Call = 3,
    Return = 4,
    Output = 5,
    InputRequested = 6,
    InputReceived = 7,
    Failure = 8,
}

impl TraceClass {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::StatementEntered => "statement_entered",
            Self::StatementExited => "statement_exited",
            Self::Decision => "decision",
            Self::Call => "call",
            Self::Return => "return",
            Self::Output => "output",
            Self::InputRequested => "input_requested",
            Self::InputReceived => "input_received",
            Self::Failure => "failure",
        }
    }

    pub const fn to_u8(self) -> u8 {
        match self {
            Self::StatementEntered => 0,
            Self::StatementExited => 1,
            Self::Decision => 2,
            Self::Call => 3,
            Self::Return => 4,
            Self::Output => 5,
            Self::InputRequested => 6,
            Self::InputReceived => 7,
            Self::Failure => 8,
        }
    }

    pub fn from_u8(value: u8) -> Option<Self> {
        match value {
            0 => Some(Self::StatementEntered),
            1 => Some(Self::StatementExited),
            2 => Some(Self::Decision),
            3 => Some(Self::Call),
            4 => Some(Self::Return),
            5 => Some(Self::Output),
            6 => Some(Self::InputRequested),
            7 => Some(Self::InputReceived),
            8 => Some(Self::Failure),
            _ => None,
        }
    }

    pub fn from_name(name: &str) -> Option<Self> {
        match name {
            "statement_entered" => Some(Self::StatementEntered),
            "statement_exited" => Some(Self::StatementExited),
            "decision" => Some(Self::Decision),
            "call" => Some(Self::Call),
            "return" => Some(Self::Return),
            "output" => Some(Self::Output),
            "input_requested" => Some(Self::InputRequested),
            "input_received" => Some(Self::InputReceived),
            "failure" => Some(Self::Failure),
            _ => None,
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum EventPayload {
    Decision { rama: String, indice: Option<u64> },
    Call { nombre: String },
    Return { nombre: String },
    Output { texto: String },
    InputReceived { texto: String },
    Failure { codigo: String },
}

impl EventPayload {
    pub fn to_canonical_json(&self) -> String {
        let mut out = String::new();
        match self {
            Self::Decision { rama, indice: None } => format_field("rama", rama, &mut out),
            Self::Decision {
                rama,
                indice: Some(index),
            } => {
                out.push_str("{\"indice\":");
                out.push_str(&index.to_string());
                out.push_str(",\"rama\":\"");
                escape_json_str(rama, &mut out);
                out.push_str("\"}");
            }
            Self::Call { nombre } => format_field("nombre", nombre, &mut out),
            Self::Return { nombre } => format_field("nombre", nombre, &mut out),
            Self::Output { texto } => format_field("texto", texto, &mut out),
            Self::InputReceived { texto } => format_field("texto", texto, &mut out),
            Self::Failure { codigo } => format_field("codigo", codigo, &mut out),
        }
        out
    }
}

fn format_field(key: &str, text: &str, out: &mut String) {
    out.push_str("{\"");
    out.push_str(key);
    out.push_str("\":\"");
    escape_json_str(text, out);
    out.push_str("\"}");
}

fn escape_json_str(input: &str, out: &mut String) {
    for character in input.chars() {
        match character {
            '"' => out.push_str("\\\""),
            '\\' => out.push_str("\\\\"),
            '\n' => out.push_str("\\n"),
            '\r' => out.push_str("\\r"),
            '\t' => out.push_str("\\t"),
            other if u32::from(other) < 32 => out.push_str(&format!("\\u{:04x}", u32::from(other))),
            other => out.push(other),
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct TraceEvent {
    pub class: TraceClass,
    pub line: u32,
    pub depth: u32,
    pub payload: Option<EventPayload>,
}

#[derive(Clone, Debug, Default, PartialEq)]
pub struct ChangeBuffer {
    pub modified_scalars: Vec<(u16, u64)>,
    pub modified_references: Vec<(u16, u32)>,
}

impl ChangeBuffer {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn clear(&mut self) {
        self.modified_scalars.clear();
        self.modified_references.clear();
    }

    pub fn record_scalar(&mut self, register: u16, value: u64) {
        self.modified_scalars.push((register, value));
    }

    pub fn record_reference(&mut self, register: u16, handle: u32) {
        self.modified_references.push((register, handle));
    }
}
