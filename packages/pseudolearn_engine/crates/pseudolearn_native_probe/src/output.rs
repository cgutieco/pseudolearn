use std::cell::RefCell;
use std::io::{Result, Write};
use std::rc::Rc;

#[derive(Clone, Default)]
pub(crate) struct Output(Rc<RefCell<Vec<u8>>>);

impl Output {
    pub(crate) fn text(&self) -> Result<String> {
        String::from_utf8(self.0.borrow().clone()).map_err(std::io::Error::other)
    }
}

impl Write for Output {
    fn write(&mut self, bytes: &[u8]) -> Result<usize> {
        self.0.borrow_mut().extend_from_slice(bytes);
        Ok(bytes.len())
    }

    fn flush(&mut self) -> Result<()> {
        Ok(())
    }
}
