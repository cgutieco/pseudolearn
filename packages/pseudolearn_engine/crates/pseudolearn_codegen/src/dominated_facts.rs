#![forbid(unsafe_code)]

use crate::constant_folding::known_integer;
use crate::lowering::Lowering;
use cranelift_codegen::ir::Value;
use pseudolearn_ir::{BlockId, Function, Operation};
use std::collections::{HashMap, HashSet};

#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
pub(crate) enum Term {
    Constant(i64),
    Variable(Value),
}

#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
pub(crate) struct ArithmeticKey {
    operation: Operation,
    left: Term,
    right: Option<Term>,
}

#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
pub(crate) struct SlotKey {
    handle: Value,
    index: Term,
}

#[derive(Clone, Default)]
pub(crate) struct Facts {
    arithmetic: HashMap<ArithmeticKey, Value>,
    slots: HashSet<SlotKey>,
}

pub(crate) struct Scope {
    dominators: HashMap<BlockId, BlockId>,
    facts: Facts,
    facts_at_end: HashMap<BlockId, Facts>,
}

impl Scope {
    pub(crate) fn for_function(function: &Function) -> Self {
        Self {
            dominators: crate::dominators::immediate_dominators(function),
            facts: Facts::default(),
            facts_at_end: HashMap::new(),
        }
    }
}

pub(crate) fn enter_block(lowering: &mut Lowering<'_, '_>, block: BlockId) {
    let inherited = lowering
        .scope
        .dominators
        .get(&block)
        .filter(|dominator| **dominator != block)
        .and_then(|dominator| lowering.scope.facts_at_end.get(dominator))
        .cloned();
    lowering.scope.facts = inherited.unwrap_or_default();
}

pub(crate) fn leave_block(lowering: &mut Lowering<'_, '_>, block: BlockId) {
    let facts = std::mem::take(&mut lowering.scope.facts);
    lowering.scope.facts_at_end.insert(block, facts);
}

fn term_of(lowering: &Lowering<'_, '_>, value: Value) -> Term {
    match known_integer(lowering, value) {
        Some(number) => Term::Constant(number),
        None => Term::Variable(value),
    }
}

pub(crate) fn arithmetic_key(
    lowering: &Lowering<'_, '_>,
    operation: Operation,
    (left, right): (Value, Option<Value>),
) -> ArithmeticKey {
    ArithmeticKey {
        operation,
        left: term_of(lowering, left),
        right: right.map(|value| term_of(lowering, value)),
    }
}

pub(crate) fn recall_arithmetic(lowering: &Lowering<'_, '_>, key: &ArithmeticKey) -> Option<Value> {
    lowering.scope.facts.arithmetic.get(key).copied()
}

pub(crate) fn remember_arithmetic(
    lowering: &mut Lowering<'_, '_>,
    key: ArithmeticKey,
    result: Value,
) {
    lowering.scope.facts.arithmetic.insert(key, result);
}

pub(crate) fn slot_key(lowering: &Lowering<'_, '_>, handle: Value, index: Value) -> SlotKey {
    SlotKey {
        handle,
        index: term_of(lowering, index),
    }
}

pub(crate) fn slot_verified(lowering: &Lowering<'_, '_>, key: &SlotKey) -> bool {
    lowering.scope.facts.slots.contains(key)
}

pub(crate) fn remember_slot(lowering: &mut Lowering<'_, '_>, key: SlotKey) {
    lowering.scope.facts.slots.insert(key);
}
