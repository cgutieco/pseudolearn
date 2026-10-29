pub const CAPABILITY_SHAPE_TAG: u32 = u32::MAX - 7;
pub const CAPABILITY_SLOT_OFFSET: usize = 2;
pub const CAPABILITY_GENERATION_OFFSET: usize = 3;
pub const CAPABILITY_RIGHTS_OFFSET: usize = 4;
pub const CAPABILITY_KIND_OFFSET: usize = 5;
pub const CAPABILITY_HEADER_WORDS: usize = 6;

#[derive(Clone, Copy, Debug, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub enum CapabilityKind {
    Console,
    Arguments,
    Directory,
    File,
    Clock,
    Timer,
    Network,
}

impl CapabilityKind {
    pub const ALL: [Self; 7] = [
        Self::Console,
        Self::Arguments,
        Self::Directory,
        Self::File,
        Self::Clock,
        Self::Timer,
        Self::Network,
    ];

    pub fn as_str(self) -> &'static str {
        match self {
            Self::Console => "console",
            Self::Arguments => "arguments",
            Self::Directory => "directory",
            Self::File => "file",
            Self::Clock => "clock",
            Self::Timer => "timer",
            Self::Network => "network",
        }
    }

    pub fn from_tag(tag: u32) -> Option<Self> {
        match tag {
            0 => Some(Self::Console),
            1 => Some(Self::Arguments),
            2 => Some(Self::Directory),
            3 => Some(Self::File),
            4 => Some(Self::Clock),
            5 => Some(Self::Timer),
            6 => Some(Self::Network),
            _ => None,
        }
    }

    pub fn to_tag(self) -> u32 {
        match self {
            Self::Console => 0,
            Self::Arguments => 1,
            Self::Directory => 2,
            Self::File => 3,
            Self::Clock => 4,
            Self::Timer => 5,
            Self::Network => 6,
        }
    }
}
