use super::{Arguments, number};
use crate::Fault;
use crate::machine::Machine;
use pseudolearn_diagnostics::DiagnosticArgument;
use pseudolearn_runtime::{self as runtime, Handle};

impl Machine<'_> {
    pub(super) fn text_effect_arguments(&self, fault: Fault, site: u32, arguments: &mut Arguments) {
        if fault != "stringPositionOutOfRange" {
            return;
        }
        let Some(site) = usize::try_from(site)
            .ok()
            .and_then(|site| self.current.effect_sites.get(site))
        else {
            return;
        };
        let text = site
            .arguments
            .first()
            .and_then(|register| self.reference(*register).ok())
            .and_then(|handle| runtime::text_length(&self.heap, Handle(handle)).ok());
        let scalar = |index: usize| {
            site.arguments
                .get(index)
                .and_then(|register| self.scalar(*register).ok())
                .map(crate::evaluate::integer_of)
        };
        let (Some(length), Some(start)) = (text, scalar(1)) else {
            return;
        };
        arguments.insert("length", DiagnosticArgument::Number(length.into()));
        let end = scalar(2).and_then(|count| start.checked_add(count));
        number(arguments, "position", end.unwrap_or(start));
    }
}
