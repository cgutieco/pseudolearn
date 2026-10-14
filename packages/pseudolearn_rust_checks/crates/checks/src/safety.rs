use pseudolearn_check_model::{Architecture, Violation, violation};
use pseudolearn_check_source::loading::{SourceFile, read_text};
use std::{collections::BTreeSet, path::Path};
use syn::{spanned::Spanned, visit::Visit};

struct UnsafeFinder {
    found: bool,
}

impl<'syntax> Visit<'syntax> for UnsafeFinder {
    fn visit_expr_unsafe(&mut self, _: &'syntax syn::ExprUnsafe) {
        self.found = true;
    }
}

struct FunctionVisitor<'source> {
    source: &'source SourceFile,
    function_names: BTreeSet<String>,
    unsafe_spans: Vec<proc_macro2::Span>,
    violations: Vec<Violation>,
    rows: BTreeSet<String>,
    permitted: bool,
    in_function: bool,
    maximum: usize,
}

impl FunctionVisitor<'_> {
    fn inspect(&mut self, signature: &syn::Signature, body: &syn::Block) {
        let mut finder = UnsafeFinder {
            found: matches!(signature.safety, syn::Safety::Unsafe(_)),
        };
        finder.visit_block(body);
        if !finder.found {
            return;
        }
        let name = signature.ident.to_string();
        self.function_names.insert(name.clone());
        let length = body
            .span()
            .end()
            .line
            .saturating_sub(signature.span().start().line)
            .saturating_add(1);
        if !self.permitted || length > self.maximum || !self.rows.contains(&name) {
            self.violations.push(violation(
                &self.source.relative,
                signature.span().start().line,
                "QUALITY-UNSAFE-INVARIANT",
                &format!("Unverified unsafe function: {name}"),
            ));
        }
    }
}

impl<'syntax> Visit<'syntax> for FunctionVisitor<'_> {
    fn visit_item_fn(&mut self, function: &'syntax syn::ItemFn) {
        self.inspect(&function.sig, &function.block);
        let previous = self.in_function;
        self.in_function = true;
        syn::visit::visit_item_fn(self, function);
        self.in_function = previous;
    }

    fn visit_impl_item_fn(&mut self, function: &'syntax syn::ImplItemFn) {
        self.inspect(&function.sig, &function.block);
        let previous = self.in_function;
        self.in_function = true;
        syn::visit::visit_impl_item_fn(self, function);
        self.in_function = previous;
    }

    fn visit_expr_unsafe(&mut self, expression: &'syntax syn::ExprUnsafe) {
        self.unsafe_spans.push(expression.span());
        if !self.permitted || !self.in_function {
            self.violations.push(violation(
                &self.source.relative,
                expression.span().start().line,
                "QUALITY-UNSAFE-INVARIANT",
                "Unsafe is forbidden in this crate",
            ));
        }
        syn::visit::visit_expr_unsafe(self, expression);
    }

    fn visit_item_impl(&mut self, implementation: &'syntax syn::ItemImpl) {
        if implementation.unsafety.is_some() {
            self.violations.push(violation(
                &self.source.relative,
                implementation.span().start().line,
                "QUALITY-UNSAFE-INVARIANT",
                "Unsafe impl requires a function invariant",
            ));
        }
        syn::visit::visit_item_impl(self, implementation);
    }
}

fn rows(root: &Path, path: &str) -> Result<BTreeSet<String>, String> {
    let text = read_text(&root.join(path).join("README.md"))?;
    let mut inside = false;
    let mut names = BTreeSet::new();
    for line in text.lines() {
        if line.starts_with('#') {
            inside = line.contains("Invariantes de `unsafe`");
        } else if inside && line.starts_with('|') {
            let cells: Vec<_> = line.split('|').map(str::trim).collect();
            names.extend(invariant_name(&cells));
        }
    }
    Ok(names)
}

pub fn check(
    source: &SourceFile,
    rules: &Architecture,
    root: &Path,
) -> Result<Vec<Violation>, String> {
    let layer = rules
        .layers
        .get(source.layer)
        .ok_or("Missing source layer")?;
    let mut visitor = FunctionVisitor {
        source,
        function_names: BTreeSet::new(),
        unsafe_spans: Vec::new(),
        violations: Vec::new(),
        rows: rows(root, &layer.path)?,
        permitted: layer.unsafe_allowed,
        in_function: false,
        maximum: rules.limits.unsafe_function_lines,
    };
    visitor.visit_file(&source.syntax);
    Ok(visitor.violations)
}

pub fn check_orphan_rows(
    sources: &[SourceFile],
    rules: &Architecture,
    root: &Path,
) -> Result<Vec<Violation>, String> {
    let mut violations = Vec::new();
    for (index, layer) in rules.layers.iter().enumerate() {
        let declared = rows(root, &layer.path)?;
        let mut implemented = BTreeSet::new();
        for source in sources.iter().filter(|source| source.layer == index) {
            let mut visitor = FunctionVisitor {
                source,
                function_names: BTreeSet::new(),
                unsafe_spans: Vec::new(),
                violations: Vec::new(),
                rows: declared.clone(),
                permitted: layer.unsafe_allowed,
                in_function: false,
                maximum: rules.limits.unsafe_function_lines,
            };
            visitor.visit_file(&source.syntax);
            implemented.extend(visitor.function_names);
        }
        for name in declared.difference(&implemented) {
            violations.push(violation(
                &format!("{}/README.md", layer.path),
                1,
                "QUALITY-UNSAFE-INVARIANT",
                &format!("Orphan invariant row: {name}"),
            ));
        }
    }
    Ok(violations)
}

fn invariant_name(cells: &[&str]) -> Option<String> {
    let name = cells.get(1).filter(|name| name.starts_with('`'))?;
    let invariant = cells.get(2).filter(|cell| !cell.is_empty())?;
    let guarantee = cells.get(3).filter(|cell| !cell.is_empty())?;
    if invariant.is_empty() || guarantee.is_empty() {
        return None;
    }
    Some(name.trim_matches('`').to_owned())
}
