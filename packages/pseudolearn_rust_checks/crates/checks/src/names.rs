use pseudolearn_check_model::{Names, Violation, violation};
use pseudolearn_check_source::loading::SourceFile;
use syn::visit::Visit;

struct NameVisitor<'source> {
    source: &'source SourceFile,
    rules: &'source Names,
    violations: Vec<Violation>,
    in_trait_implementation: bool,
}

impl NameVisitor<'_> {
    fn inspect(&mut self, identifier: &proc_macro2::Ident) {
        let name = identifier.to_string();
        let normalized = name.trim_start_matches("r#").trim_start_matches('_');
        let too_short = normalized.chars().count() < self.rules.minimum_length
            && !self
                .rules
                .permitted_short
                .iter()
                .any(|allowed| allowed == normalized);
        let components = split_components(normalized);
        let forbidden = components
            .iter()
            .any(|component| self.rules.forbidden_components.contains(component));
        if too_short || forbidden {
            self.violations.push(violation(
                &self.source.relative,
                identifier.span().start().line,
                "QUALITY-SEMANTIC-NAMES",
                &format!("Nonsemantic identifier: {name}"),
            ));
        }
    }
}

fn split_components(name: &str) -> Vec<String> {
    let mut normalized = String::new();
    for character in name.chars() {
        if character.is_uppercase() && !normalized.is_empty() {
            normalized.push('_');
        }
        normalized.extend(character.to_lowercase());
    }
    normalized
        .split('_')
        .filter(|part| !part.is_empty())
        .map(str::to_owned)
        .collect()
}

impl<'syntax> Visit<'syntax> for NameVisitor<'_> {
    fn visit_item_impl(&mut self, implementation: &'syntax syn::ItemImpl) {
        let previous = self.in_trait_implementation;
        self.in_trait_implementation = implementation.trait_.is_some();
        syn::visit::visit_item_impl(self, implementation);
        self.in_trait_implementation = previous;
    }

    fn visit_pat_ident(&mut self, binding: &'syntax syn::PatIdent) {
        self.inspect(&binding.ident);
        syn::visit::visit_pat_ident(self, binding);
    }

    fn visit_signature(&mut self, signature: &'syntax syn::Signature) {
        if !self.in_trait_implementation {
            self.inspect(&signature.ident);
        }
        syn::visit::visit_signature(self, signature);
    }

    fn visit_generic_param(&mut self, parameter: &'syntax syn::GenericParam) {
        match parameter {
            syn::GenericParam::Type(generic) => self.inspect(&generic.ident),
            syn::GenericParam::Const(generic) => self.inspect(&generic.ident),
            syn::GenericParam::Lifetime(generic) => self.inspect(&generic.lifetime.ident),
        }
        syn::visit::visit_generic_param(self, parameter);
    }

    fn visit_field(&mut self, field: &'syntax syn::Field) {
        if let Some(identifier) = &field.ident {
            self.inspect(identifier);
        }
        syn::visit::visit_field(self, field);
    }

    fn visit_item_struct(&mut self, declaration: &'syntax syn::ItemStruct) {
        self.inspect(&declaration.ident);
        syn::visit::visit_item_struct(self, declaration);
    }

    fn visit_item_enum(&mut self, declaration: &'syntax syn::ItemEnum) {
        self.inspect(&declaration.ident);
        syn::visit::visit_item_enum(self, declaration);
    }

    fn visit_item_type(&mut self, declaration: &'syntax syn::ItemType) {
        self.inspect(&declaration.ident);
        syn::visit::visit_item_type(self, declaration);
    }

    fn visit_item_const(&mut self, declaration: &'syntax syn::ItemConst) {
        self.inspect(&declaration.ident);
        syn::visit::visit_item_const(self, declaration);
    }
}

pub fn check(source: &SourceFile, rules: &Names) -> Vec<Violation> {
    let mut visitor = NameVisitor {
        source,
        rules,
        violations: Vec::new(),
        in_trait_implementation: false,
    };
    visitor.visit_file(&source.syntax);
    if source.path.file_stem().is_some_and(|name| {
        rules
            .forbidden_files
            .iter()
            .any(|forbidden| name == forbidden.as_str())
    }) {
        visitor.violations.push(violation(
            &source.relative,
            1,
            "QUALITY-SEMANTIC-NAMES",
            "Nonsemantic file name",
        ));
    }
    visitor.violations
}
