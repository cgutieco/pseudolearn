use pseudolearn_check_model::{Violation, violation};
use pseudolearn_check_source::{loading::SourceFile, tokens::comment_lines};
use syn::{spanned::Spanned, visit::Visit};

struct DocumentationVisitor<'source> {
    source: &'source SourceFile,
    violations: Vec<Violation>,
}

impl<'syntax> Visit<'syntax> for DocumentationVisitor<'_> {
    fn visit_meta(&mut self, meta: &'syntax syn::Meta) {
        if meta.path().is_ident("doc") {
            self.violations.push(violation(
                &self.source.relative,
                meta.span().start().line,
                "QUALITY-NO-COMMENTS",
                "Documentation attribute is forbidden",
            ));
        }
        syn::visit::visit_meta(self, meta);
        let syn::Meta::List(list) = meta else {
            return;
        };
        if !list.path.is_ident("cfg_attr") {
            return;
        }
        let parser = syn::punctuated::Punctuated::<syn::Meta, syn::Token![,]>::parse_terminated;
        if let Ok(nested) = syn::parse::Parser::parse2(parser, list.tokens.clone()) {
            for attribute in nested.iter().skip(1) {
                self.visit_meta(attribute);
            }
        }
    }
}

pub fn check(source: &SourceFile) -> Vec<Violation> {
    let mut visitor = DocumentationVisitor {
        source,
        violations: Vec::new(),
    };
    visitor.visit_file(&source.syntax);
    visitor
        .violations
        .extend(comment_lines(&source.text).into_iter().map(|line| {
            violation(
                &source.relative,
                line,
                "QUALITY-NO-COMMENTS",
                "Comment is forbidden",
            )
        }));
    visitor.violations
}
