use crate::{Lexer, TokenKind};
use pseudolearn_lexicon::find_keyword;

impl Lexer<'_> {
    pub(crate) fn match_compound_keyword(&mut self, word: &str, start_offset: u32) -> bool {
        let folded = if word.is_ascii() {
            std::borrow::Cow::Borrowed(word)
        } else {
            std::borrow::Cow::Owned(self.profile.fold_word(word))
        };
        if !pseudolearn_lexicon::keywords::is_compound_prefix(&folded) {
            return false;
        }
        let remainder = self.current_slice();
        let mut combined = word.to_owned();
        let mut consumed = 0_usize;
        for _ in 0..3 {
            let suffix = remainder.get(consumed..).unwrap_or("");
            let whitespace = suffix
                .bytes()
                .take_while(|byte| matches!(byte, b' ' | b'\t'))
                .count();
            if whitespace == 0 {
                break;
            }
            consumed = consumed.saturating_add(whitespace);
            let suffix = remainder.get(consumed..).unwrap_or("");
            let bytes = continuation_bytes(suffix);
            if bytes == 0 {
                break;
            }
            combined.push(' ');
            combined.push_str(suffix.get(..bytes).unwrap_or(""));
            consumed = consumed.saturating_add(bytes);
            if self.accept_compound(&combined, start_offset, consumed) {
                return true;
            }
        }
        false
    }

    fn accept_compound(&mut self, word: &str, start: u32, consumed: usize) -> bool {
        let Some(keyword) = find_keyword(word, self.profile) else {
            return false;
        };
        self.advance_by(consumed);
        self.tokens
            .push(TokenKind::Keyword(keyword), start, self.current_u32());
        true
    }
}

fn continuation_bytes(suffix: &str) -> usize {
    suffix
        .chars()
        .take_while(|character| {
            pseudolearn_source::IdentifierNormalizer::is_continuation(*character)
        })
        .map(char::len_utf8)
        .sum()
}
