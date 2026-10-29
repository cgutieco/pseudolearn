#![forbid(unsafe_code)]

pub const JSON_BLOCK_SHAPE_TAG: u32 = u32::MAX - 5;
pub const JSON_VIEW_SHAPE_TAG: u32 = u32::MAX - 4;
pub const JSON_NODE_WORDS: usize = 8;
pub const JSON_BLOCK_HEADER_WORDS: usize = 2;
pub const JSON_BLOCK_NODE_COUNT_WORD_OFFSET: usize = 2;
pub const JSON_BLOCK_TEXT_LENGTH_WORD_OFFSET: usize = 3;
pub const JSON_VIEW_BLOCK_WORD_OFFSET: usize = 2;
pub const JSON_VIEW_NODE_WORD_OFFSET: usize = 3;
pub const JSON_NODE_KIND_WORD_OFFSET: usize = 0;
pub const JSON_NODE_FIRST_CHILD_WORD_OFFSET: usize = 1;
pub const JSON_NODE_CHILD_COUNT_WORD_OFFSET: usize = 2;
pub const JSON_NODE_NEXT_SIBLING_WORD_OFFSET: usize = 3;
pub const JSON_NODE_NAME_OFFSET_WORD_OFFSET: usize = 4;
pub const JSON_NODE_NAME_LENGTH_WORD_OFFSET: usize = 5;
pub const JSON_NODE_VALUE_OFFSET_WORD_OFFSET: usize = 6;
pub const JSON_NODE_VALUE_LENGTH_WORD_OFFSET: usize = 7;
pub const JSON_NODE_WORD_OFFSETS: [usize; JSON_NODE_WORDS] = [
    JSON_NODE_KIND_WORD_OFFSET,
    JSON_NODE_FIRST_CHILD_WORD_OFFSET,
    JSON_NODE_CHILD_COUNT_WORD_OFFSET,
    JSON_NODE_NEXT_SIBLING_WORD_OFFSET,
    JSON_NODE_NAME_OFFSET_WORD_OFFSET,
    JSON_NODE_NAME_LENGTH_WORD_OFFSET,
    JSON_NODE_VALUE_OFFSET_WORD_OFFSET,
    JSON_NODE_VALUE_LENGTH_WORD_OFFSET,
];

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
#[repr(u8)]
pub enum JsonNodeKind {
    Null = 0,
    Boolean = 1,
    Number = 2,
    String = 3,
    Array = 4,
    Object = 5,
}

impl JsonNodeKind {
    pub const fn tag(self) -> u8 {
        match self {
            Self::Null => 0,
            Self::Boolean => 1,
            Self::Number => 2,
            Self::String => 3,
            Self::Array => 4,
            Self::Object => 5,
        }
    }
}
