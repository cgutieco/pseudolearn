#[derive(Clone, Copy, Debug, Eq, PartialEq)]
#[repr(u32)]
pub enum CollectionCommand {
    New,
    Length,
    Version,
    Check,
    Lookup,
    Load,
    Store,
    Insert,
    Remove,
    Next,
    Key,
    ArrayLength,
    Clone,
    Commit,
    Reverse,
    BeginSort,
}

impl CollectionCommand {
    pub fn code(self) -> u32 {
        match self {
            Self::New => 0,
            Self::Length => 1,
            Self::Version => 2,
            Self::Check => 3,
            Self::Lookup => 4,
            Self::Load => 5,
            Self::Store => 6,
            Self::Insert => 7,
            Self::Remove => 8,
            Self::Next => 9,
            Self::Key => 10,
            Self::ArrayLength => 11,
            Self::Clone => 12,
            Self::Commit => 13,
            Self::Reverse => 14,
            Self::BeginSort => 15,
        }
    }

    pub fn from_code(code: u32) -> Option<Self> {
        match code {
            0 => Some(Self::New),
            1 => Some(Self::Length),
            2 => Some(Self::Version),
            3 => Some(Self::Check),
            4 => Some(Self::Lookup),
            5 => Some(Self::Load),
            6 => Some(Self::Store),
            7 => Some(Self::Insert),
            8 => Some(Self::Remove),
            9 => Some(Self::Next),
            10 => Some(Self::Key),
            11 => Some(Self::ArrayLength),
            12 => Some(Self::Clone),
            13 => Some(Self::Commit),
            14 => Some(Self::Reverse),
            15 => Some(Self::BeginSort),
            _ => None,
        }
    }
}
