#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct Handle(pub u32);

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Trap {
    IntegerOverflow,
    DivisionByZero,
    IndexOutOfRange,
    NonFiniteReal,
    NegativeSize,
    CellLimit,
    DepthLimit,
    InvalidHandle,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum RealOperation {
    Add,
    Subtract,
    Multiply,
    Divide,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Shape {
    pub links: u8,
    pub words: u8,
}

pub type Outcome<Value> = Result<Value, Trap>;

pub const CELL_LIMIT: u64 = 1 << 22;
pub const DEPTH_LIMIT: u32 = 100_000;

pub trait Arithmetic {
    fn add(&mut self, left: i64, right: i64) -> Outcome<i64>;
    fn subtract(&mut self, left: i64, right: i64) -> Outcome<i64>;
    fn multiply(&mut self, left: i64, right: i64) -> Outcome<i64>;
    fn quotient(&mut self, left: i64, right: i64) -> Outcome<i64>;
    fn remainder(&mut self, left: i64, right: i64) -> Outcome<i64>;
    fn real(&mut self, operation: RealOperation, left: f64, right: f64) -> Outcome<f64>;
    fn root(&mut self, value: f64) -> Outcome<f64>;
    fn settle(&mut self) -> Outcome<()>;
}

pub trait Heap {
    fn array(&mut self, length: i64) -> Outcome<Handle>;
    fn read(&mut self, array: Handle, index: i64) -> Outcome<i64>;
    fn write(&mut self, array: Handle, index: i64, value: i64) -> Outcome<()>;
    fn read_link(&mut self, array: Handle, index: i64) -> Outcome<Handle>;
    fn write_link(&mut self, array: Handle, index: i64, target: Handle) -> Outcome<()>;
    fn object(&mut self, shape: Shape) -> Outcome<Handle>;
    fn field(&mut self, object: Handle, slot: u8) -> Outcome<i64>;
    fn set_field(&mut self, object: Handle, slot: u8, value: i64) -> Outcome<()>;
    fn link(&mut self, object: Handle, slot: u8) -> Outcome<Handle>;
    fn set_link(&mut self, object: Handle, slot: u8, target: Handle) -> Outcome<()>;
}

pub trait Calls {
    fn retain(&mut self, _handle: Handle) {}
    fn enter(&mut self, words: &[i64], links: &[Handle]) -> Outcome<()>;
    fn word(&self, slot: usize) -> i64;
    fn handle(&self, slot: usize) -> Handle;
    fn leave(&mut self);
    fn tick(&mut self);
}

pub trait Machine: Arithmetic + Heap + Calls {}

impl<Implementation: Arithmetic + Heap + Calls> Machine for Implementation {}

pub fn word_from_real(value: f64) -> i64 {
    i64::from_ne_bytes(value.to_ne_bytes())
}

pub fn real_from_word(word: i64) -> f64 {
    f64::from_ne_bytes(word.to_ne_bytes())
}

pub fn word_from_handle(handle: Handle) -> i64 {
    i64::from(handle.0)
}

pub fn handle_from_word(word: i64) -> Outcome<Handle> {
    u32::try_from(word)
        .map(Handle)
        .map_err(|_| Trap::InvalidHandle)
}

pub fn finite(value: f64) -> Outcome<f64> {
    if value.is_finite() {
        Ok(value)
    } else {
        Err(Trap::NonFiniteReal)
    }
}

pub fn apply(operation: RealOperation, left: f64, right: f64) -> f64 {
    match operation {
        RealOperation::Add => left + right,
        RealOperation::Subtract => left - right,
        RealOperation::Multiply => left * right,
        RealOperation::Divide => left / right,
    }
}
