use pseudolearn_semantic::hir::HirModule;

pub(crate) fn polymorphic(function: u32, module: &HirModule) -> bool {
    let Some(target) = usize::try_from(function)
        .ok()
        .and_then(|index| module.functions.get(index))
    else {
        return true;
    };
    let Some(owner) = target.owner else {
        return false;
    };
    let mut implementations = std::collections::BTreeSet::new();
    for (index, class) in module.classes.iter().enumerate() {
        if !descendant(index, owner.0, module) {
            continue;
        }
        for identity in &class.virtual_slots {
            let method = usize::try_from(identity.0)
                .ok()
                .and_then(|index| module.functions.get(index));
            if method.is_some_and(|method| method.name == target.name) {
                implementations.insert(identity.0);
            }
        }
    }
    implementations.len() > 1
}

fn descendant(index: usize, owner: u32, module: &HirModule) -> bool {
    let mut current = Some(index);
    for _ in 0..module.classes.len() {
        let Some(index) = current else {
            return false;
        };
        if u32::try_from(index).ok() == Some(owner) {
            return true;
        }
        current = module
            .classes
            .get(index)
            .and_then(|class| class.superclass)
            .and_then(|parent| usize::try_from(parent.0).ok());
    }
    false
}
