#![forbid(unsafe_code)]

use pseudolearn_abi::bytes_cell_count;

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct BytesBuffer {
    octets: Vec<u8>,
}

impl BytesBuffer {
    pub fn new() -> Self {
        Self { octets: Vec::new() }
    }

    pub fn from_vec(octets: Vec<u8>) -> Self {
        Self { octets }
    }

    pub fn byte_count(&self) -> usize {
        self.octets.len()
    }

    pub fn is_empty(&self) -> bool {
        self.octets.is_empty()
    }

    pub fn as_slice(&self) -> &[u8] {
        &self.octets
    }

    pub fn as_mut_slice(&mut self) -> &mut [u8] {
        &mut self.octets
    }

    pub(crate) fn get_byte(&self, index: usize) -> Option<u8> {
        self.octets.get(index).copied()
    }

    pub(crate) fn set_byte(&mut self, index: usize, value: u8) -> bool {
        if let Some(slot) = self.octets.get_mut(index) {
            *slot = value;
            true
        } else {
            false
        }
    }

    pub(crate) fn push_byte(&mut self, value: u8) {
        self.octets.push(value);
    }

    pub fn cells(&self) -> usize {
        bytes_cell_count(self.octets.len())
    }
}
