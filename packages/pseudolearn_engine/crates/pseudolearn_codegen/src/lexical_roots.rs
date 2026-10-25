use pseudolearn_ir::dominance::DominatorTree;
use pseudolearn_ir::{BlockId, Function, InstructionId, IrType, OriginEntry, ValueId, VariableId};
use std::collections::{BTreeMap, HashMap};

type Location = (BlockId, usize);

struct Scope<'program> {
    function: &'program Function,
    types: &'program HashMap<ValueId, IrType>,
    origins: &'program [OriginEntry],
    definitions: HashMap<ValueId, Location>,
    dominators: DominatorTree,
}

pub(crate) fn augment(
    function: &Function,
    types: &HashMap<ValueId, IrType>,
    origins: &[OriginEntry],
    roots: &mut HashMap<InstructionId, Vec<ValueId>>,
) {
    let scope = Scope {
        function,
        types,
        origins,
        definitions: definitions(function),
        dominators: DominatorTree::compute(function),
    };
    for block in &function.blocks {
        for (index, instruction) in block.instructions.iter().enumerate() {
            if let Some(live) = roots.get_mut(instruction) {
                live.extend(visible(
                    &scope,
                    (*instruction, (block.identifier, index.saturating_add(1))),
                ));
                live.sort();
                live.dedup();
            }
        }
    }
}

fn definitions(function: &Function) -> HashMap<ValueId, Location> {
    let mut definitions = HashMap::new();
    let Some(first) = function.blocks.first() else {
        return definitions;
    };
    for (value, _) in &function.parameters {
        definitions.insert(*value, (first.identifier, 0));
    }
    for block in &function.blocks {
        for (value, _) in &block.parameters {
            definitions.insert(*value, (block.identifier, 0));
        }
        for (index, instruction) in block.instructions.iter().enumerate() {
            if let Some(value) = function.columns.result(*instruction) {
                definitions.insert(value, (block.identifier, index.saturating_add(1)));
            }
        }
    }
    definitions
}

fn visible(scope: &Scope<'_>, (instruction, location): (InstructionId, Location)) -> Vec<ValueId> {
    let point = scope.function.columns.span(instruction);
    let mut selected = BTreeMap::<VariableId, (ValueId, Location)>::new();
    for origin in scope
        .origins
        .iter()
        .filter(|origin| origin.function == scope.function.name)
    {
        if !scope
            .types
            .get(&origin.value)
            .is_some_and(crate::type_mapping::is_heap_reference)
            || origin
                .visibility
                .is_some_and(|span| !point.is_some_and(|point| span.contains_start(point)))
        {
            continue;
        }
        let Some(definition) = scope.definitions.get(&origin.value).copied() else {
            continue;
        };
        if !dominates(scope, definition, location) {
            continue;
        }
        if selected
            .get(&origin.variable)
            .is_none_or(|(_, previous)| dominates(scope, *previous, definition))
        {
            selected.insert(origin.variable, (origin.value, definition));
        }
    }
    selected.values().map(|(value, _)| *value).collect()
}

fn dominates(scope: &Scope<'_>, definition: Location, usage: Location) -> bool {
    if definition.0 == usage.0 {
        definition.1 < usage.1
    } else {
        scope.dominators.dominates_block(definition.0, usage.0)
    }
}
