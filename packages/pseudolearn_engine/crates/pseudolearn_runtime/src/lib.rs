#![forbid(unsafe_code)]

pub use pseudolearn_abi::Handle;

mod arithmetic;
mod array;
mod cell;
mod error;
mod heap;
mod object;
mod random;
mod text;
mod value;

pub use array::{array_dimensions, new_array, read_element, write_element};
pub use cell::{MemoryCell, element_cell, field_cell, read_memory_cell, write_memory_cell};
pub use heap::{Heap, ObjectLayout};
pub use object::{
    copy_object, new_object, new_object_shared, object_class, read_field, write_field,
};
pub use random::RandomState;
pub use text::{
    TextCompaction, TextPart, compare_text, concat_parts, concat_text, new_text, text_character,
    text_content, text_length,
};
pub use value::{CollectionPolicy, MemoryError, MemoryOptions, ValueKind};

pub use arithmetic::{
    int_add, int_divide, int_modulo, int_multiply, int_negate, int_power, int_subtract, real_add,
    real_divide, real_multiply, real_subtract,
};
pub use error::ArithmeticError;
