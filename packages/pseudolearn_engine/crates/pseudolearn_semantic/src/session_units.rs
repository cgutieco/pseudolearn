use crate::identities::ClassId;
use crate::session::{AnalysisSession, SemanticOptions, UnitScope, UnitView};

impl<'syntax> AnalysisSession<'syntax> {
    pub(crate) fn for_units(
        units: Vec<UnitView<'syntax>>,
        options: SemanticOptions,
    ) -> Option<Self> {
        let first = *units.first()?;
        let options = SemanticOptions {
            profile: first.profile,
            ..options
        };
        let mut session = Self::new(first.tree, first.source, options);
        session.scopes = vec![UnitScope::default(); units.len()];
        session.units = units;
        Some(session)
    }

    pub(crate) fn switch_unit(&mut self, unit: usize) {
        let Some(view) = self.units.get(unit).copied() else {
            return;
        };
        if unit == self.unit {
            return;
        }
        let saved = UnitScope {
            functions: std::mem::take(&mut self.functions),
            classes: std::mem::take(&mut self.classes),
            modules: std::mem::take(&mut self.modules),
            declared: std::mem::take(&mut self.declared),
        };
        if let Some(slot) = self.scopes.get_mut(self.unit) {
            *slot = saved;
        }
        let loaded = self
            .scopes
            .get_mut(unit)
            .map(std::mem::take)
            .unwrap_or_default();
        self.functions = loaded.functions;
        self.classes = loaded.classes;
        self.modules = loaded.modules;
        self.declared = loaded.declared;
        self.unit = unit;
        self.tree = view.tree;
        self.source = view.source;
        self.options.profile = view.profile;
    }

    pub(crate) fn enter_function(&mut self, index: usize) {
        if let Some(unit) = self.module.units.functions.get(index).copied() {
            self.switch_unit(usize::try_from(unit).unwrap_or(0));
        }
    }

    pub(crate) fn enter_class_id(&mut self, class: ClassId) {
        self.enter_class(usize::try_from(class.0).unwrap_or(usize::MAX));
    }

    pub(crate) fn enter_class(&mut self, index: usize) {
        if let Some(unit) = self.module.units.classes.get(index).copied() {
            self.switch_unit(usize::try_from(unit).unwrap_or(0));
        }
    }

    pub(crate) fn link_name(&self, local: &str) -> String {
        match self.module.units.qualifiers.get(self.unit) {
            Some(qualifier) => format!("{qualifier}.{local}"),
            None => local.to_owned(),
        }
    }

    pub(crate) fn tag_function(&mut self) {
        if self.module.units.is_project() {
            self.module
                .units
                .functions
                .push(u32::try_from(self.unit).unwrap_or(u32::MAX));
        }
    }

    pub(crate) fn tag_class(&mut self) {
        if self.module.units.is_project() {
            self.module
                .units
                .classes
                .push(u32::try_from(self.unit).unwrap_or(u32::MAX));
        }
    }

    pub(crate) fn link_name_if(&self, qualify: bool, local: &str) -> String {
        if qualify {
            self.link_name(local)
        } else {
            local.to_owned()
        }
    }
}
