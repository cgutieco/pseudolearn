use super::memory::memory_fault;
use super::{Flow, Machine};
use crate::Fault;
use crate::load::memory::CollectionOperation;
use pseudolearn_library::CollectionRequest;

impl Machine<'_> {
    pub(super) fn collection_operation(
        &mut self,
        operation: &CollectionOperation,
    ) -> Result<Flow, Fault> {
        let arguments = operation
            .sources
            .iter()
            .map(|source| self.read_value(source.source))
            .collect::<Result<Vec<_>, _>>()?;
        let cells = u64::from(operation.layout.scalar_words)
            .checked_add(u64::from(operation.layout.reference_words))
            .ok_or("resourceLimit")?
            .saturating_add(2);
        let allocating = matches!(
            operation.command,
            pseudolearn_runtime::CollectionCommand::New
                | pseudolearn_runtime::CollectionCommand::Store
                | pseudolearn_runtime::CollectionCommand::Insert
                | pseudolearn_runtime::CollectionCommand::Remove
        );
        let roots = if allocating {
            self.collection_roots(cells)?
        } else {
            Vec::new()
        };
        let request = CollectionRequest {
            command: operation.command,
            layout: operation.layout,
            key: operation.key,
            leaf: operation.leaf,
            arguments: &arguments,
        };
        let result = pseudolearn_library::collection_operation(&mut self.heap, &request, &roots)
            .map_err(memory_fault)?;
        if let Some(destination) = operation.destination {
            self.write_result(destination, result)?;
        }
        Ok(Flow::Continue)
    }
}
