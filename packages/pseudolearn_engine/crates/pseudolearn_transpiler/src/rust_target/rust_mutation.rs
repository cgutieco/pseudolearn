use crate::module_view::ModuleView;
use pseudolearn_semantic::{ExpressionId, HirExpression, HirPlace, HirStatement, LocalId, Passing};
use std::collections::{BTreeMap, BTreeSet};

pub(crate) struct Mutation {
    writes: BTreeMap<LocalId, usize>,
    changed: BTreeSet<LocalId>,
}

impl Mutation {
    pub(crate) fn scan(view: &ModuleView<'_>) -> Self {
        let mut mutation = Mutation {
            writes: BTreeMap::new(),
            changed: BTreeSet::new(),
        };
        for statement in &view.module.statements.kinds {
            mutation.statement(view, statement);
        }
        for expression in &view.module.expressions.kinds {
            mutation.expression(view, expression);
        }
        mutation
    }

    pub(crate) fn needs_mutable(&self, local: LocalId, declared_with_value: bool) -> bool {
        let writes = self.writes.get(&local).copied().unwrap_or(0);
        let initial = usize::from(declared_with_value);
        self.changed.contains(&local) || writes > initial
    }

    fn statement(&mut self, view: &ModuleView<'_>, statement: &HirStatement) {
        match statement {
            HirStatement::Assign { destination, .. } => self.place(view, destination),
            HirStatement::Read(places) => {
                for place in places {
                    self.place(view, place);
                    if let HirPlace::Local(local) = place {
                        self.changed.insert(*local);
                    }
                }
            }
            HirStatement::Dimension(dimensions) => {
                for dimension in dimensions {
                    self.count(dimension.local);
                }
            }
            _ => {}
        }
    }

    fn count(&mut self, local: LocalId) {
        let entry = self.writes.entry(local).or_insert(0);
        *entry = entry.saturating_add(1);
    }

    fn place(&mut self, view: &ModuleView<'_>, place: &HirPlace) {
        match place {
            HirPlace::Local(local) => self.count(*local),
            HirPlace::WholeArray(local) | HirPlace::RecordField { local, .. } => {
                self.changed.insert(*local);
            }
            HirPlace::Element { array, .. } | HirPlace::ElementRange { array, .. } => {
                self.root(view, *array);
            }
            HirPlace::Field { .. } | HirPlace::FieldRange { .. } => {}
        }
    }

    fn root(&mut self, view: &ModuleView<'_>, expression: ExpressionId) {
        match view.expression(expression) {
            HirExpression::Local(local) => {
                self.changed.insert(*local);
            }
            HirExpression::Element { array, .. }
            | HirExpression::RecordField { record: array, .. } => {
                self.root(view, *array);
            }
            _ => {}
        }
    }

    fn expression(&mut self, view: &ModuleView<'_>, expression: &HirExpression) {
        let (function, arguments) = match expression {
            HirExpression::Call {
                function,
                arguments,
            }
            | HirExpression::VirtualCall {
                function,
                arguments,
                ..
            } => (*function, arguments),
            _ => return,
        };
        let parameters = view
            .function(function)
            .map(|entry| entry.parameters.clone())
            .unwrap_or_default();
        for (parameter, argument) in parameters.iter().zip(arguments) {
            let by_reference = view.local(*parameter).is_some_and(|local| {
                local.passing == Passing::Reference
                    || matches!(
                        view.representation(local.type_id),
                        pseudolearn_semantic::Type::Array { .. }
                    )
            });
            if by_reference {
                self.root(view, *argument);
            }
        }
    }
}
