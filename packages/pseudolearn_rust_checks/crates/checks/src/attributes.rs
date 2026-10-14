use pseudolearn_check_model::{Violation, violation};
use pseudolearn_check_source::loading::SourceFile;
use syn::visit::Visit;

struct AttributeVisitor<'source> {
    source: &'source SourceFile,
    violations: Vec<Violation>,
}

impl<'syntax> Visit<'syntax> for AttributeVisitor<'_> {
    fn visit_attribute(&mut self, attribute: &'syntax syn::Attribute) {
        inspect_meta(&attribute.meta, self.source, &mut self.violations);
        syn::visit::visit_attribute(self, attribute);
    }
}

fn inspect_meta(meta: &syn::Meta, source: &SourceFile, violations: &mut Vec<Violation>) {
    use syn::spanned::Spanned;
    let path = meta.path();
    if path.is_ident("allow") || path.is_ident("expect") {
        violations.push(violation(
            &source.relative,
            meta.span().start().line,
            "QUALITY-NO-COMMENTS",
            "Lint suppression attribute is forbidden",
        ));
    }
    let syn::Meta::List(list) = meta else {
        return;
    };
    if !list.path.is_ident("cfg_attr") {
        return;
    }
    let parser = syn::punctuated::Punctuated::<syn::Meta, syn::Token![,]>::parse_terminated;
    if let Ok(nested) = syn::parse::Parser::parse2(parser, list.tokens.clone()) {
        for attribute in nested.iter().skip(1) {
            inspect_meta(attribute, source, violations);
        }
    }
}

pub fn check(source: &SourceFile) -> Vec<Violation> {
    let mut visitor = AttributeVisitor {
        source,
        violations: Vec::new(),
    };
    visitor.visit_file(&source.syntax);
    visitor.violations
}
