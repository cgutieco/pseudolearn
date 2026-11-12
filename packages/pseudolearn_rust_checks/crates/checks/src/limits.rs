use pseudolearn_check_model::{Limits, Violation, violation};
use pseudolearn_check_source::loading::SourceFile;
use syn::{spanned::Spanned, visit::Visit};

struct LimitVisitor<'source> {
    source: &'source SourceFile,
    rules: &'source Limits,
    violations: Vec<Violation>,
    depth: usize,
    public_methods: std::collections::BTreeMap<String, usize>,
}

impl LimitVisitor<'_> {
    fn inspect_function(&mut self, signature: &syn::Signature, body: &syn::Block) {
        let length = body
            .span()
            .end()
            .line
            .saturating_sub(signature.span().start().line)
            .saturating_add(1);
        if length > self.rules.function_lines {
            self.violations.push(violation(
                &self.source.relative,
                signature.span().start().line,
                "SIZE-FUNCTION",
                &format!("Measured {length}, maximum {}", self.rules.function_lines),
            ));
        }
        if signature.inputs.len() > self.rules.positional_parameters {
            self.violations.push(violation(
                &self.source.relative,
                signature.span().start().line,
                "SIZE-PARAMETERS",
                "Too many function parameters",
            ));
        }
    }
}

impl<'syntax> Visit<'syntax> for LimitVisitor<'_> {
    fn visit_item_fn(&mut self, function: &'syntax syn::ItemFn) {
        self.inspect_function(&function.sig, &function.block);
        syn::visit::visit_item_fn(self, function);
    }

    fn visit_impl_item_fn(&mut self, function: &'syntax syn::ImplItemFn) {
        self.inspect_function(&function.sig, &function.block);
        syn::visit::visit_impl_item_fn(self, function);
    }

    fn visit_trait_item_fn(&mut self, function: &'syntax syn::TraitItemFn) {
        if let Some(body) = &function.default {
            self.inspect_function(&function.sig, body);
        }
        syn::visit::visit_trait_item_fn(self, function);
    }

    fn visit_item_impl(&mut self, implementation: &'syntax syn::ItemImpl) {
        let count = implementation
            .items
            .iter()
            .filter(|member| {
                matches!(member, syn::ImplItem::Fn(function)
                if matches!(function.vis, syn::Visibility::Public(_)))
            })
            .count();
        if let syn::Type::Path(target) = implementation.self_ty.as_ref()
            && let Some(segment) = target.path.segments.last()
        {
            let total = self
                .public_methods
                .entry(segment.ident.to_string())
                .or_default();
            *total = total.saturating_add(count);
        }
        syn::visit::visit_item_impl(self, implementation);
    }

    fn visit_expr(&mut self, expression: &'syntax syn::Expr) {
        let is_control = matches!(
            expression,
            syn::Expr::If(_)
                | syn::Expr::Match(_)
                | syn::Expr::ForLoop(_)
                | syn::Expr::While(_)
                | syn::Expr::Loop(_)
        );
        if is_control {
            self.depth = self.depth.saturating_add(1);
            if self.depth > self.rules.nesting_depth {
                self.violations.push(violation(
                    &self.source.relative,
                    expression.span().start().line,
                    "SIZE-NESTING",
                    "Control nesting exceeds maximum",
                ));
            }
        }
        syn::visit::visit_expr(self, expression);
        if is_control {
            self.depth = self.depth.saturating_sub(1);
        }
    }
}

pub fn check(source: &SourceFile, rules: &Limits) -> Vec<Violation> {
    if source.is_test {
        return Vec::new();
    }
    let mut visitor = LimitVisitor {
        source,
        rules,
        violations: Vec::new(),
        depth: 0,
        public_methods: std::collections::BTreeMap::new(),
    };
    if source.text.lines().count() > rules.file_lines {
        visitor.violations.push(violation(
            &source.relative,
            1,
            "SIZE-FILE",
            "File exceeds maximum lines",
        ));
    }
    visitor.visit_file(&source.syntax);
    for (name, count) in visitor.public_methods {
        if count > rules.public_methods_per_class {
            visitor.violations.push(violation(
                &source.relative,
                1,
                "SIZE-METHODS",
                &format!("Too many public methods on {name}"),
            ));
        }
    }
    visitor.violations
}
