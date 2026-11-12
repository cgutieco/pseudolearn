use super::{Arguments, number};
use crate::Fault;
use crate::load::Source;
use crate::machine::Machine;
use pseudolearn_bytecode::RegisterClass;

impl Machine<'_> {
    pub(super) fn collection_arguments(
        &self,
        fault: Fault,
        operation: &crate::load::memory::CollectionOperation,
        arguments: &mut Arguments,
    ) {
        if fault != "arrayIndexOutOfRange" {
            return;
        }
        let Some(handle) = operation
            .sources
            .first()
            .and_then(|source| self.read_value(source.source).ok())
            .and_then(|word| u32::try_from(word).ok())
            .map(pseudolearn_runtime::Handle)
        else {
            return;
        };
        let Some(index) = operation
            .sources
            .get(1)
            .and_then(|source| self.read_value(source.source).ok())
        else {
            return;
        };
        if let Ok(size) = pseudolearn_runtime::collection_length(&self.heap, handle) {
            number(arguments, "index", crate::evaluate::integer_of(index));
            number(arguments, "size", i64::from(size));
        }
    }

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
