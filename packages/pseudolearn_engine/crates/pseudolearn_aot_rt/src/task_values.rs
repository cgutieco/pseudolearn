use crate::trap::Trap;
use pseudolearn_runtime::Handle;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) enum TaskValue {
    Scalar(u64),
    Reference(u32),
}

impl TaskValue {
    pub(crate) fn word(self) -> u64 {
        match self {
            Self::Scalar(word) => word,
            Self::Reference(handle) => u64::from(handle),
        }
    }

    pub(crate) fn root(self) -> Option<Handle> {
        match self {
            Self::Reference(handle) if handle != 0 => Some(Handle(handle)),
            _ => None,
        }
    }
}

pub(crate) fn decode_packet(words: &[u64]) -> Result<Vec<TaskValue>, Trap> {
    let (count, rest) = words
        .split_first()
        .ok_or_else(|| Trap::named("internalFault"))?;
    let count = usize::try_from(*count).map_err(|_| Trap::named("internalFault"))?;
    let (kinds, values) = rest
        .split_at_checked(count)
        .ok_or_else(|| Trap::named("internalFault"))?;
    kinds
        .iter()
        .zip(values)
        .map(|(kind, word)| match kind {
            0 => Ok(TaskValue::Scalar(*word)),
            _ => u32::try_from(*word)
                .map(TaskValue::Reference)
                .map_err(|_| Trap::named("internalFault")),
        })
        .collect()
}

pub(crate) fn packet_length(words: &[u64]) -> Option<usize> {
    let count = usize::try_from(*words.first()?).ok()?;
    count.checked_mul(2)?.checked_add(1)
}
