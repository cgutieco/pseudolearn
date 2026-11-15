use super::{Flow, Machine};
use crate::load::TaskSite;
use crate::{Fault, RuntimeValue, evaluate::INVALID_BYTECODE};
use pseudolearn_runtime::{Handle, TaskId, TaskScopeId};

impl Machine<'_> {
    pub(super) fn deliver_task_result(
        &mut self,
        task: TaskId,
        (destination, aggregate): (pseudolearn_bytecode::Register, bool),
    ) -> Result<Flow, Fault> {
        let values = self.tasks.task_values.get(&task).cloned();
        if let Some(values) = values {
            let current = self.tasks.current;
            self.tasks.transport_values.insert(current, Some(values));
        }
        let value = self
            .tasks
            .results
            .get(&task)
            .copied()
            .flatten()
            .unwrap_or(RuntimeValue::Scalar(0));
        self.store_task_result(
            destination,
            if aggregate {
                RuntimeValue::Scalar(0)
            } else {
                value
            },
        )?;
        Ok(Flow::Continue)
    }

    fn store_task_result(
        &mut self,
        destination: pseudolearn_bytecode::Register,
        value: RuntimeValue,
    ) -> Result<(), Fault> {
        match (destination.class, value) {
            (pseudolearn_bytecode::RegisterClass::Scalar, RuntimeValue::Scalar(word)) => {
                self.set_scalar(destination.index, word)
            }
            (pseudolearn_bytecode::RegisterClass::Reference, RuntimeValue::Reference(handle)) => {
                self.set_reference(destination.index, handle)
            }
            _ => Err(INVALID_BYTECODE),
        }
    }

    pub(crate) fn task_outcome(&mut self, site: u32) -> Result<Flow, Fault> {
        let TaskSite::Outcome { failure, values } = self.task_site(site)? else {
            return Err(INVALID_BYTECODE);
        };
        let values = values
            .into_iter()
            .map(|register| self.channel_argument(register))
            .collect::<Result<Vec<_>, _>>()?;
        self.tasks
            .outcomes
            .insert(self.tasks.current, (failure, values));
        Ok(Flow::Continue)
    }

    pub(super) fn task_site(&self, site: u32) -> Result<TaskSite, Fault> {
        self.current
            .task_sites
            .get(usize::try_from(site).map_err(|_| INVALID_BYTECODE)?)
            .cloned()
            .ok_or(INVALID_BYTECODE)
    }

    pub(crate) fn task_scope_result(&mut self, site: u32) -> Result<Flow, Fault> {
        let TaskSite::ScopeResult {
            scope,
            destination,
            layout,
        } = self.task_site(site)?
        else {
            return Err(INVALID_BYTECODE);
        };
        let scope = TaskScopeId(self.scalar(scope.index)?);
        let roots = self.memory_roots()?;
        let failure = self
            .tasks
            .failures
            .remove(&scope)
            .and_then(pseudolearn_runtime::TaskFailures::finish);
        let Some(failure) = failure else {
            self.tasks.transport_values.insert(self.tasks.current, None);
            self.set_scalar(destination.index, 0)?;
            return Ok(Flow::Continue);
        };
        let vector = self.associated_errors(layout, failure.associated, roots)?;
        let mut payload = failure.first;
        payload.push(RuntimeValue::Reference(vector.0));
        payload.push(RuntimeValue::Scalar(failure.cancelled));
        self.tasks
            .transport_values
            .insert(self.tasks.current, Some(payload));
        self.set_scalar(destination.index, 1)?;
        Ok(Flow::Continue)
    }
    fn associated_errors(
        &mut self,
        layout: pseudolearn_runtime::VectorLayout,
        associated: Vec<Vec<RuntimeValue>>,
        roots: Vec<Handle>,
    ) -> Result<Handle, Fault> {
        let vector = pseudolearn_runtime::new_vector(&mut self.heap, layout, &roots)
            .map_err(super::memory::memory_fault)?;
        let mut roots = roots;
        roots.push(vector);
        for (index, error) in associated.into_iter().enumerate() {
            let mut words = pseudolearn_runtime::CollectionWords::default();
            for value in error {
                match value {
                    RuntimeValue::Scalar(word) => words.scalars.push(word),
                    RuntimeValue::Reference(handle) => words.references.push(Handle(handle)),
                }
            }
            pseudolearn_runtime::vector_insert(
                &mut self.heap,
                vector,
                (i64::try_from(index).map_err(|_| INVALID_BYTECODE)?, words),
                &roots,
            )
            .map_err(super::memory::memory_fault)?;
        }
        Ok(vector)
    }
}
