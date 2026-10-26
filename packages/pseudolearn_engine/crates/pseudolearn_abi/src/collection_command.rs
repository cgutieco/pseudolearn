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
            _ => None,
        }
    }
}
