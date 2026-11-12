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
    TaskSpawned = 9,
    TaskSuspended = 10,
    TaskReady = 11,
    TaskResumed = 12,
    TaskCompleted = 13,
    TaskCancelRequested = 14,
    ScopeJoined = 15,
    ChannelCreated = 16,
    ChannelSent = 17,
    ChannelReceived = 18,
    ChannelClosed = 19,
    EffectDelivered = 20,
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
            Self::TaskSpawned => "task_spawned",
            Self::TaskSuspended => "task_suspended",
            Self::TaskReady => "task_ready",
            Self::TaskResumed => "task_resumed",
            Self::TaskCompleted => "task_completed",
            Self::TaskCancelRequested => "task_cancel_requested",
            Self::ScopeJoined => "scope_joined",
            Self::ChannelCreated => "channel_created",
            Self::ChannelSent => "channel_sent",
            Self::ChannelReceived => "channel_received",
            Self::ChannelClosed => "channel_closed",
            Self::EffectDelivered => "effect_delivered",
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
            Self::TaskSpawned => 9,
            Self::TaskSuspended => 10,
            Self::TaskReady => 11,
            Self::TaskResumed => 12,
            Self::TaskCompleted => 13,
            Self::TaskCancelRequested => 14,
            Self::ScopeJoined => 15,
            Self::ChannelCreated => 16,
            Self::ChannelSent => 17,
            Self::ChannelReceived => 18,
            Self::ChannelClosed => 19,
            Self::EffectDelivered => 20,
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
            9 => Some(Self::TaskSpawned),
            10 => Some(Self::TaskSuspended),
            11 => Some(Self::TaskReady),
            12 => Some(Self::TaskResumed),
            13 => Some(Self::TaskCompleted),
            14 => Some(Self::TaskCancelRequested),
            15 => Some(Self::ScopeJoined),
            16 => Some(Self::ChannelCreated),
            17 => Some(Self::ChannelSent),
            18 => Some(Self::ChannelReceived),
            19 => Some(Self::ChannelClosed),
            20 => Some(Self::EffectDelivered),
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
            "task_spawned" => Some(Self::TaskSpawned),
            "task_suspended" => Some(Self::TaskSuspended),
            "task_ready" => Some(Self::TaskReady),
            "task_resumed" => Some(Self::TaskResumed),
            "task_completed" => Some(Self::TaskCompleted),
            "task_cancel_requested" => Some(Self::TaskCancelRequested),
            "scope_joined" => Some(Self::ScopeJoined),
            "channel_created" => Some(Self::ChannelCreated),
            "channel_sent" => Some(Self::ChannelSent),
            "channel_received" => Some(Self::ChannelReceived),
            "channel_closed" => Some(Self::ChannelClosed),
            "effect_delivered" => Some(Self::EffectDelivered),
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
    Fields(Vec<(&'static str, EventField)>),
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum EventField {
    Number(u64),
    Text(String),
    Flag(bool),
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
            Self::Fields(fields) => format_fields(fields, &mut out),
        }
        out
    }
}

fn format_fields(fields: &[(&'static str, EventField)], out: &mut String) {
    let mut ordered: Vec<_> = fields.iter().collect();
    ordered.sort_by_key(|(name, _)| *name);
    out.push('{');
    for (position, (name, field)) in ordered.into_iter().enumerate() {
        if position > 0 {
            out.push(',');
        }
        out.push('"');
        out.push_str(name);
        out.push_str("\":");
        match field {
            EventField::Number(number) => out.push_str(&number.to_string()),
            EventField::Flag(flag) => out.push_str(if *flag { "true" } else { "false" }),
            EventField::Text(text) => {
                out.push('"');
                escape_json_str(text, out);
                out.push('"');
            }
        }
    }
    out.push('}');
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
    pub span: Option<pseudolearn_bytecode::SourceSpan>,
    pub payload: Option<EventPayload>,
}

#[derive(Clone, Debug, Default, PartialEq)]
pub struct ChangeBuffer {
    pub modified_scalars: Vec<(u16, u64)>,
    pub modified_references: Vec<(u16, u32)>,
    pub modified_object_fields: Vec<(u32, usize, u64)>,
}

impl ChangeBuffer {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn clear(&mut self) {
        self.modified_scalars.clear();
        self.modified_references.clear();
        self.modified_object_fields.clear();
    }

    pub fn record_scalar(&mut self, register: u16, value: u64) {
        self.modified_scalars.push((register, value));
    }

    pub fn record_reference(&mut self, register: u16, handle: u32) {
        self.modified_references.push((register, handle));
    }

    pub fn record_object_field(&mut self, handle: u32, offset: usize, value: u64) {
        self.modified_object_fields.push((handle, offset, value));
    }
}
