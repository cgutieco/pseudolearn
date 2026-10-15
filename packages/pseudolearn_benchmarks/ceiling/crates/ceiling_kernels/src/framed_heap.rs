use crate::framed_direct::FramedDirect;
use crate::immediate_arithmetic::ImmediateArithmetic;
use crate::machine::{Handle, Heap, Outcome, Shape};

impl ImmediateArithmetic for FramedDirect {}

impl Heap for FramedDirect {
    fn array(&mut self, length: i64) -> Outcome<Handle> {
        self.heap.array(length)
    }

    fn read(&mut self, array: Handle, index: i64) -> Outcome<i64> {
        self.heap.read(array, index)
    }

    fn write(&mut self, array: Handle, index: i64, value: i64) -> Outcome<()> {
        self.heap.write(array, index, value)
    }

    fn read_link(&mut self, array: Handle, index: i64) -> Outcome<Handle> {
        self.heap.read_link(array, index)
    }

    fn write_link(&mut self, array: Handle, index: i64, target: Handle) -> Outcome<()> {
        self.heap.write_link(array, index, target)
    }

    fn object(&mut self, shape: Shape) -> Outcome<Handle> {
        self.heap.object(shape)
    }

    fn field(&mut self, object: Handle, slot: u8) -> Outcome<i64> {
        self.heap.field(object, slot)
    }

    fn set_field(&mut self, object: Handle, slot: u8, value: i64) -> Outcome<()> {
        self.heap.set_field(object, slot, value)
    }

    fn link(&mut self, object: Handle, slot: u8) -> Outcome<Handle> {
        self.heap.link(object, slot)
    }

    fn set_link(&mut self, object: Handle, slot: u8, target: Handle) -> Outcome<()> {
        self.heap.set_link(object, slot, target)
    }
}
