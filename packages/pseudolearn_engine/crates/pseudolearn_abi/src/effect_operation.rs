#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum EffectValueKind {
    Integer,
    Real,
    Boolean,
    Text,
    Bytes,
    TextList,
    JsonValue,
    JsonResult,
    JsonKind,
    OptionalBoolean,
    OptionalInteger,
    OptionalReal,
    OptionalText,
    OptionalJsonValue,
    Console,
    Arguments,
    Directory,
    File,
    Clock,
    Timer,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct EffectOperation {
    pub id: u32,
    pub identity: &'static str,
    pub family: &'static str,
    pub receiver: Option<EffectValueKind>,
    pub spanish: &'static str,
    pub english: &'static str,
    pub parameters: &'static [EffectValueKind],
    pub result: EffectValueKind,
    pub effect: bool,
    pub fallible: bool,
}

include!(concat!(env!("OUT_DIR"), "/effect_operations.rs"));

pub fn find_effect_operation(
    name: &str,
    spanish: bool,
    receiver: Option<EffectValueKind>,
) -> Option<&'static EffectOperation> {
    EFFECT_OPERATIONS.iter().find(|operation| {
        operation.receiver == receiver
            && name.eq_ignore_ascii_case(if spanish {
                operation.spanish
            } else {
                operation.english
            })
    })
}

impl EffectOperation {
    pub fn result_cell_count(&self) -> usize {
        match self.result {
            EffectValueKind::OptionalBoolean
            | EffectValueKind::OptionalInteger
            | EffectValueKind::OptionalReal => 2,
            EffectValueKind::OptionalText | EffectValueKind::OptionalJsonValue => 1,
            EffectValueKind::JsonResult => 5,
            _ if self.fallible => 3,
            _ => 1,
        }
    }

    pub fn is_scalar(kind: EffectValueKind) -> bool {
        matches!(
            kind,
            EffectValueKind::Integer
                | EffectValueKind::Real
                | EffectValueKind::Boolean
                | EffectValueKind::JsonKind
        )
    }

    pub fn capability_family(&self) -> &'static str {
        match self.receiver {
            Some(EffectValueKind::Directory | EffectValueKind::File) => "filesystem",
            Some(EffectValueKind::Clock) => "clock",
            Some(EffectValueKind::Console) => "console",
            Some(EffectValueKind::Arguments) => "arguments",
            Some(EffectValueKind::Timer) => "timer",
            _ => match self.identity.strip_prefix("request_") {
                Some("directory") => "filesystem",
                Some(requested) => requested,
                None if !self.family.is_empty() => self.family,
                None => "host",
            },
        }
    }
}

pub fn effect_operation(identity: &str) -> Option<&'static EffectOperation> {
    EFFECT_OPERATIONS
        .iter()
        .find(|operation| operation.identity == identity)
}
