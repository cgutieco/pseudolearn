use pseudolearn_syntax::{TokenKind, Tokens};

#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct SourceLine {
    pub code_tokens: Vec<usize>,
    pub comment_tokens: Vec<usize>,
    pub order: Vec<usize>,
}

impl SourceLine {
    pub fn is_blank(&self) -> bool {
        self.order.is_empty()
    }

    pub fn is_comment_only(&self) -> bool {
        self.code_tokens.is_empty() && !self.comment_tokens.is_empty()
    }

    pub fn first_code_token(&self) -> Option<usize> {
        self.code_tokens.first().copied()
    }
}

pub fn split_lines(tokens: &Tokens) -> Vec<SourceLine> {
    let mut lines = Vec::new();
    let mut current = SourceLine::default();
    for index in 0..tokens.token_count() {
        match tokens.kind(index) {
            Some(TokenKind::Newline) => {
                lines.push(std::mem::take(&mut current));
            }
            Some(TokenKind::Whitespace | TokenKind::EndOfFile) | None => {}
            Some(TokenKind::Comment) => {
                current.comment_tokens.push(index);
                current.order.push(index);
            }
            Some(_) => {
                current.code_tokens.push(index);
                current.order.push(index);
            }
        }
    }
    lines.push(current);
    lines
}
