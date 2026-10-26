#![forbid(unsafe_code)]

pub const BYTES_SHAPE_TAG: u32 = u32::MAX - 8;
pub const BYTES_LENGTH_OFFSET: usize = 2;
pub const BYTES_DATA_OFFSET: usize = 3;
pub const BYTES_HEADER_WORDS: usize = 3;

pub fn bytes_cell_count(byte_count: usize) -> usize {
    1 + byte_count.div_ceil(8)
}
