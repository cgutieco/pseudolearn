use crate::block_layout::{BlockLayout, LineRole};
use crate::identifier_roles::IdentifierRoles;
use crate::line_renderer::{RenderContext, render_line};
use crate::source_lines::{SourceLine, split_lines};
use pseudolearn_lexicon::{KeywordKind, Profile};
use pseudolearn_semantic::SemanticOptions;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{SyntaxTree, TokenKind, parse_source};

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct FormatOptions {
    pub profile: Profile,
    pub strict: bool,
    pub indent_size: usize,
}

impl Default for FormatOptions {
    fn default() -> Self {
        Self {
            profile: Profile::Spanish,
            strict: true,
            indent_size: 2,
        }
    }
}

pub fn format_source(text: &str, options: FormatOptions) -> String {
    format_checked(text, options).unwrap_or_else(|| text.to_owned())
}

pub fn format_checked(text: &str, options: FormatOptions) -> Option<String> {
    if text.trim().is_empty() {
        return Some(String::new());
    }
    let source = SourceText::new(text.to_owned());
    let (tree, diagnostics) = parse_source(&source, options.profile);
    if !diagnostics.is_empty() {
        return None;
    }
    let roles = IdentifierRoles::build(
        &tree,
        &source,
        SemanticOptions {
            profile: options.profile,
            strict: options.strict,
        },
    );
    let context = RenderContext {
        tree: &tree,
        source: &source,
        profile: options.profile,
        roles: &roles,
        strict: options.strict,
    };
    Some(layout_lines(&context, options.indent_size))
}

#[derive(Clone, Copy, PartialEq, Eq)]
enum EmittedKind {
    Blank,
    Comment,
    Code,
}

struct Emitter<'emit> {
    context: &'emit RenderContext<'emit>,
    layout: BlockLayout,
    indent_size: usize,
    lines: Vec<String>,
    last: Option<EmittedKind>,
    unit_just_closed: bool,
}

impl Emitter<'_> {
    fn push(&mut self, line: String, kind: EmittedKind) {
        self.lines.push(line);
        self.last = Some(kind);
    }

    fn push_blank_if_allowed(&mut self) {
        if matches!(
            self.last,
            None | Some(EmittedKind::Blank | EmittedKind::Comment)
        ) {
            return;
        }
        self.push(String::new(), EmittedKind::Blank);
    }

    fn separate_units(&mut self) {
        if self.unit_just_closed && self.last != Some(EmittedKind::Blank) {
            self.push(String::new(), EmittedKind::Blank);
        }
        self.unit_just_closed = false;
    }

    fn indentation(&self, level: usize) -> String {
        " ".repeat(level.saturating_mul(self.indent_size))
    }

    fn emit_comment_line(&mut self, line: &SourceLine) {
        self.separate_units();
        let indent = self.indentation(self.layout.depth());
        let rendered = render_line(self.context, line, false);
        self.push(format!("{indent}{rendered}"), EmittedKind::Comment);
    }

    fn emit_code_line(&mut self, line: &SourceLine) {
        let Some(first) = line.first_code_token() else {
            return;
        };
        self.separate_units();
        let role = self.layout.role_of(self.context.tree, first);
        let had_open_blocks = self.layout.open_depth() > 0;
        if role == LineRole::Closer {
            self.layout.pop_leading_closer();
        }
        let level = self.layout.indent_for(role);
        let simple = is_simple_statement(self.context.tree, line, role);
        let rendered = render_line(self.context, line, simple);
        let indent = self.indentation(level);
        self.push(format!("{indent}{rendered}"), EmittedKind::Code);
        apply_line_keywords(self.context.tree, &mut self.layout, line, role);
        self.unit_just_closed =
            self.layout.open_depth() == 0 && (had_open_blocks || role != LineRole::Plain);
    }

    fn finish(mut self) -> String {
        while self.last == Some(EmittedKind::Blank) {
            self.lines.pop();
            self.last = self.lines.last().map(|_| EmittedKind::Code);
        }
        if self.lines.is_empty() {
            return String::new();
        }
        let mut text = self.lines.join("\n");
        text.push('\n');
        text
    }
}

fn layout_lines(context: &RenderContext<'_>, indent_size: usize) -> String {
    let mut emitter = Emitter {
        context,
        layout: BlockLayout::new(context.tree),
        indent_size,
        lines: Vec::new(),
        last: None,
        unit_just_closed: false,
    };
    for line in split_lines(&context.tree.tokens) {
        if line.is_blank() {
            emitter.push_blank_if_allowed();
        } else if line.is_comment_only() {
            emitter.emit_comment_line(&line);
        } else {
            emitter.emit_code_line(&line);
        }
    }
    emitter.finish()
}

fn apply_line_keywords(
    tree: &SyntaxTree,
    layout: &mut BlockLayout,
    line: &SourceLine,
    role: LineRole,
) {
    let skip = usize::from(role == LineRole::Closer);
    for index in line.code_tokens.iter().skip(skip) {
        layout.apply_token(tree, *index);
    }
}

fn is_simple_statement(tree: &SyntaxTree, line: &SourceLine, role: LineRole) -> bool {
    if role != LineRole::Plain {
        return false;
    }
    let Some(first) = line.first_code_token() else {
        return false;
    };
    match tree.tokens.kind(first) {
        Some(TokenKind::Identifier) => !tree.nodes.iter().any(|node| {
            node.first_token == u32::try_from(first).unwrap_or(u32::MAX)
                && matches!(
                    node.kind,
                    pseudolearn_syntax::NodeKind::InterfaceUnit
                        | pseudolearn_syntax::NodeKind::DeferStatement
                )
        }),
        Some(TokenKind::Keyword(kind)) => starts_simple_statement(tree, line, kind),
        _ => false,
    }
}

fn starts_simple_statement(tree: &SyntaxTree, line: &SourceLine, kind: KeywordKind) -> bool {
    match kind {
        KeywordKind::Declare
        | KeywordKind::Dimension
        | KeywordKind::Write
        | KeywordKind::Read
        | KeywordKind::ReturnKeyword
        | KeywordKind::ThisObject
        | KeywordKind::SuperClass => true,
        KeywordKind::PublicVisibility | KeywordKind::PrivateVisibility => {
            line.code_tokens.get(1).is_some_and(|second| {
                matches!(
                    tree.tokens.kind(*second),
                    Some(TokenKind::Keyword(
                        KeywordKind::Declare | KeywordKind::Dimension
                    ))
                )
            })
        }
        _ => false,
    }
}
