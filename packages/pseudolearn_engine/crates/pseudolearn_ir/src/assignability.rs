use crate::{IrType, Module};

pub(crate) fn assignable(module: &Module, actual: &IrType, expected: &IrType) -> bool {
    if actual == expected {
        return true;
    }
    let (IrType::Object(actual), IrType::Object(expected)) = (actual, expected) else {
        return false;
    };
    let mut current = Some(actual.as_str());
    let mut remaining = module.classes.len().saturating_add(1);
    while let Some(name) = current {
        if name == expected {
            return true;
        }
        if remaining == 0 {
            return false;
        }
        remaining = remaining.saturating_sub(1);
        current = module
            .find_class(name)
            .and_then(|class| class.superclass.as_deref());
    }
    false
}
