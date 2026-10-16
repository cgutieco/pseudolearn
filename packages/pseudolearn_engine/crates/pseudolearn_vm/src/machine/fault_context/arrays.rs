use super::{Arguments, number};
use crate::Fault;
use crate::load::Source;
use crate::machine::Machine;
use pseudolearn_bytecode::RegisterClass;

impl Machine<'_> {
    pub(super) fn array_arguments(
        &self,
        fault: Fault,
        location: (u16, &[Source]),
        arguments: &mut Arguments,
    ) {
        let (array, indices) = location;
        if fault == "arrayIndexOutOfRange" {
            self.index_arguments(array, indices, arguments);
        } else if fault == "uninitializedVariableRead" {
            self.variable_argument(array, RegisterClass::Reference, arguments);
        }
    }

    pub(super) fn array_creation_arguments(&self, sources: &[Source], arguments: &mut Arguments) {
        if let Ok(dimensions) = self.read_indices(sources)
            && let Some(size) = dimensions.into_iter().find(|size| *size < 0)
        {
            number(arguments, "size", size);
        }
    }
}
