use crate::identifier_spelling::unique_spellings;
use crate::module_view::ModuleView;
use pseudolearn_semantic::ClassId;
use std::collections::{BTreeMap, BTreeSet};

pub(crate) struct MemberSpellings {
    fields: BTreeMap<String, String>,
    classes: BTreeMap<u32, String>,
    locals: BTreeSet<String>,
    value_spelling: fn(&str) -> String,
}

pub(crate) struct SpellingRules {
    pub(crate) value: fn(&str) -> String,
    pub(crate) type_name: fn(&str) -> String,
}

impl MemberSpellings {
    pub(crate) fn new(view: &ModuleView<'_>, rules: &SpellingRules) -> Self {
        let fields = unique_spellings(rules.value, view.field_names().into_iter())
            .into_iter()
            .collect();
        Self {
            fields,
            classes: class_spellings(view, rules.type_name),
            locals: local_spellings(view, rules.value),
            value_spelling: rules.value,
        }
    }

    pub(crate) fn field(&self, raw: &str) -> String {
        self.fields
            .get(raw)
            .cloned()
            .unwrap_or_else(|| (self.value_spelling)(raw))
    }

    pub(crate) fn field_path(&self, raw: &str) -> String {
        raw.split('.')
            .map(|segment| self.field(segment))
            .collect::<Vec<_>>()
            .join(".")
    }

    pub(crate) fn class(&self, class: ClassId) -> Option<&str> {
        self.classes.get(&class.0).map(String::as_str)
    }

    pub(crate) fn routine(&self, spelled: String) -> String {
        let mut candidate = spelled;
        while self.locals.contains(&candidate) {
            candidate.push_str("_routine");
        }
        candidate
    }
}

fn local_spellings(view: &ModuleView<'_>, spell: fn(&str) -> String) -> BTreeSet<String> {
    let mut scopes: BTreeMap<u32, Vec<String>> = BTreeMap::new();
    for local in &view.module.locals {
        scopes
            .entry(local.scope.0)
            .or_default()
            .push(local.name.replace('$', ""));
    }
    scopes
        .into_values()
        .flat_map(|names| unique_spellings(spell, names.into_iter()))
        .map(|(_, spelled)| spelled)
        .collect()
}

fn class_spellings(view: &ModuleView<'_>, spell: fn(&str) -> String) -> BTreeMap<u32, String> {
    let mut taken: BTreeSet<String> = view
        .declared_type_names()
        .iter()
        .map(|name| spell(name))
        .collect();
    let mut spellings = BTreeMap::new();
    for (index, class) in view.module.classes.iter().enumerate() {
        let Ok(identifier) = u32::try_from(index) else {
            continue;
        };
        if !view.is_emitted_class(ClassId(identifier)) {
            continue;
        }
        let base = spell(&class.name);
        let mut candidate = base.clone();
        let mut suffix = 2_u32;
        while taken.contains(&candidate) {
            candidate = format!("{base}{suffix}");
            suffix = suffix.saturating_add(1);
        }
        taken.insert(candidate.clone());
        spellings.insert(identifier, candidate);
    }
    spellings
}
