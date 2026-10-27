#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum EffectValueKind {
    Integer,
    Boolean,
    Text,
    Bytes,
    TextList,
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

pub fn effect_operation(identity: &str) -> Option<&'static EffectOperation> {
    EFFECT_OPERATIONS
        .iter()
        .find(|operation| operation.identity == identity)
}
