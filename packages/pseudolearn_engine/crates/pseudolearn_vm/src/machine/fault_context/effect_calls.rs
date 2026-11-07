use super::Arguments;
use crate::Fault;
use crate::machine::Machine;

mod bytes_effects;
mod text_effects;

impl Machine<'_> {
    pub(super) fn effect_call_arguments(&self, fault: Fault, site: u32, arguments: &mut Arguments) {
        self.text_effect_arguments(fault, site, arguments);
        self.bytes_effect_arguments(fault, site, arguments);
    }
}
