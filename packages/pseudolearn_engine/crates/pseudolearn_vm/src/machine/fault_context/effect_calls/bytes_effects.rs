use super::super::{Arguments, number};
use crate::Fault;
use crate::machine::Machine;
use pseudolearn_runtime::{self as runtime, Handle};

const BYTES_AT: &str = "bytes_at";

impl Machine<'_> {
    pub(super) fn bytes_effect_arguments(
        &self,
        fault: Fault,
        site: u32,
        arguments: &mut Arguments,
    ) {
        if fault != "arrayIndexOutOfRange" {
            return;
        }
        let Some(site) = usize::try_from(site)
            .ok()
            .and_then(|site| self.current.effect_sites.get(site))
            .filter(|site| site.operation == BYTES_AT)
        else {
            return;
        };
        let size = self
            .reference(site.capability)
            .ok()
            .and_then(|handle| runtime::bytes_length(&self.heap, Handle(handle)).ok())
            .and_then(|size| i64::try_from(size).ok());
        let index = site
            .arguments
            .first()
            .and_then(|register| self.scalar(*register).ok())
            .map(crate::evaluate::integer_of);
        if let (Some(size), Some(index)) = (size, index) {
            number(arguments, "index", index);
            number(arguments, "size", size);
        }
    }
}
