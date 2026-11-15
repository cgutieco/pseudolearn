use crate::lexer::TokenKind;
use crate::model::SourceProfile;
use crate::parser::Parser;
use pseudolearn_source::SourceId;

pub(crate) fn parse_profiles(parser: &mut Parser) -> Result<Vec<SourceProfile>, String> {
    let mut profiles = Vec::new();
    while parser.peek() == &TokenKind::Word("profile".to_owned()) {
        let _ = parser.advance();
        let TokenKind::Integer(identifier) = parser.advance() else {
            return Err("Expected source identifier after 'profile'".to_owned());
        };
        let source_id = u32::try_from(identifier)
            .map(SourceId::new)
            .map_err(|_| "Source identifier out of range".to_owned())?;
        let vocabulary = parser.expect_word("")?;
        profiles.push(SourceProfile {
            source_id,
            vocabulary,
        });
    }
    Ok(profiles)
}
