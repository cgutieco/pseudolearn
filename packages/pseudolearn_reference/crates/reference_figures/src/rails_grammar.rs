#[derive(Clone, Debug, PartialEq)]
pub enum RailNode {
    Terminal(String),
    Nonterminal(String),
    Sequence(Vec<RailNode>),
    Choice(Vec<RailNode>),
    Optional(Box<RailNode>),
    Repeat(Box<RailNode>),
}

const HIDDEN: [&str; 6] = [
    "line",
    "trivia",
    "endOfLine",
    "endOfFile",
    "whitespace",
    "comment",
];

pub fn parse(rule: &str) -> Result<RailNode, String> {
    let symbols = symbols(rule);
    let mut parser = Parser { symbols, cursor: 0 };
    let tree = parser.choice()?;
    if parser.cursor < parser.symbols.len() {
        return Err(format!("unexpected symbol in rule `{rule}`"));
    }
    Ok(simplify(tree).unwrap_or(RailNode::Sequence(Vec::new())))
}

fn symbols(rule: &str) -> Vec<String> {
    let spaced: String = rule
        .chars()
        .flat_map(|character| match character {
            '(' | ')' | '[' | ']' | '{' | '}' | ',' | '|' => vec![' ', character, ' '],
            other => vec![other],
        })
        .collect();
    spaced.split_whitespace().map(str::to_owned).collect()
}

struct Parser {
    symbols: Vec<String>,
    cursor: usize,
}

impl Parser {
    fn peek(&self) -> Option<&str> {
        self.symbols.get(self.cursor).map(String::as_str)
    }

    fn advance(&mut self) -> Option<String> {
        let symbol = self.symbols.get(self.cursor).cloned();
        self.cursor = self.cursor.saturating_add(1);
        symbol
    }

    fn choice(&mut self) -> Result<RailNode, String> {
        let mut options = vec![self.sequence()?];
        while self.peek() == Some("|") {
            self.advance();
            options.push(self.sequence()?);
        }
        Ok(single_or(options, RailNode::Choice))
    }

    fn sequence(&mut self) -> Result<RailNode, String> {
        let mut items = vec![self.atom()?];
        while self.peek() == Some(",") {
            self.advance();
            items.push(self.atom()?);
        }
        Ok(single_or(items, RailNode::Sequence))
    }

    fn atom(&mut self) -> Result<RailNode, String> {
        let symbol = self
            .advance()
            .ok_or_else(|| "rule ends too early".to_owned())?;
        let closing = match symbol.as_str() {
            "(" => ")",
            "[" => "]",
            "{" => "}",
            _ => return Ok(leaf(&symbol)),
        };
        let inner = self.choice()?;
        if self.advance().as_deref() != Some(closing) {
            return Err(format!("expected `{closing}`"));
        }
        Ok(match closing {
            "]" => RailNode::Optional(Box::new(inner)),
            "}" => RailNode::Repeat(Box::new(inner)),
            _ => inner,
        })
    }
}

fn leaf(symbol: &str) -> RailNode {
    match symbol.strip_prefix('@') {
        Some(identity) => RailNode::Terminal(identity.to_owned()),
        None if symbol == "terminator" => {
            RailNode::Optional(Box::new(RailNode::Terminal("semicolon".to_owned())))
        }
        None => RailNode::Nonterminal(symbol.to_owned()),
    }
}

fn single_or(mut nodes: Vec<RailNode>, build: fn(Vec<RailNode>) -> RailNode) -> RailNode {
    if nodes.len() == 1
        && let Some(node) = nodes.pop()
    {
        return node;
    }
    build(nodes)
}

fn simplify(node: RailNode) -> Option<RailNode> {
    match node {
        RailNode::Nonterminal(name) if HIDDEN.contains(&name.as_str()) => None,
        RailNode::Sequence(items) => {
            let kept: Vec<RailNode> = items.into_iter().filter_map(simplify).collect();
            (!kept.is_empty()).then(|| single_or(kept, RailNode::Sequence))
        }
        RailNode::Choice(options) => {
            let kept: Vec<RailNode> = options.into_iter().filter_map(simplify).collect();
            (!kept.is_empty()).then(|| single_or(kept, RailNode::Choice))
        }
        RailNode::Optional(inner) => {
            simplify(*inner).map(|inner| RailNode::Optional(Box::new(inner)))
        }
        RailNode::Repeat(inner) => simplify(*inner).map(|inner| RailNode::Repeat(Box::new(inner))),
        leaf => Some(leaf),
    }
}

pub fn apply_contextual(node: RailNode, contextual: &[Option<String>]) -> RailNode {
    let mut remaining = contextual.iter();
    replace_identifiers(node, &mut remaining)
}

fn replace_identifiers<'list>(
    node: RailNode,
    remaining: &mut impl Iterator<Item = &'list Option<String>>,
) -> RailNode {
    match node {
        RailNode::Nonterminal(name) if name == "identifier" => match remaining.next() {
            Some(Some(identity)) => RailNode::Terminal(identity.clone()),
            _ => RailNode::Nonterminal(name),
        },
        RailNode::Sequence(items) => RailNode::Sequence(
            items
                .into_iter()
                .map(|member| replace_identifiers(member, remaining))
                .collect(),
        ),
        RailNode::Choice(options) => RailNode::Choice(
            options
                .into_iter()
                .map(|option| replace_identifiers(option, remaining))
                .collect(),
        ),
        RailNode::Optional(inner) => {
            RailNode::Optional(Box::new(replace_identifiers(*inner, remaining)))
        }
        RailNode::Repeat(inner) => {
            RailNode::Repeat(Box::new(replace_identifiers(*inner, remaining)))
        }
        leaf => leaf,
    }
}
