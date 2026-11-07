use reference_model::Inline;

pub fn parse_inline(text: &str) -> Result<Vec<Inline>, String> {
    let mut parser = InlineParser {
        rest: text,
        runs: Vec::new(),
        plain: String::new(),
    };
    while !parser.rest.is_empty() {
        parser.step()?;
    }
    parser.flush();
    Ok(parser.runs)
}

struct InlineParser<'text> {
    rest: &'text str,
    runs: Vec<Inline>,
    plain: String,
}

impl<'text> InlineParser<'text> {
    fn step(&mut self) -> Result<(), String> {
        if let Some(after) = self.rest.strip_prefix("**") {
            return self.delimited(after, "**", Inline::Strong);
        }
        if let Some(after) = self.rest.strip_prefix('`') {
            return self.delimited(after, "`", Inline::Code);
        }
        if let Some(after) = self.rest.strip_prefix('«') {
            return self.delimited(after, "»", Inline::Slot);
        }
        if let Some(after) = self.rest.strip_prefix("[[") {
            return self.term(after);
        }
        if let Some(after) = self.rest.strip_prefix('[') {
            return self.link(after);
        }
        if let Some(after) = self.rest.strip_prefix('*') {
            return self.delimited(after, "*", Inline::Emphasis);
        }
        self.advance_plain();
        Ok(())
    }

    fn advance_plain(&mut self) {
        let mut characters = self.rest.chars();
        if let Some(character) = characters.next() {
            self.plain.push(character);
        }
        self.rest = characters.as_str();
    }

    fn delimited(
        &mut self,
        after: &'text str,
        closing: &str,
        build: fn(String) -> Inline,
    ) -> Result<(), String> {
        let (inner, rest) = after
            .split_once(closing)
            .ok_or_else(|| format!("unclosed `{closing}` in inline text"))?;
        if inner.is_empty() {
            return Err(format!("empty `{closing}` span in inline text"));
        }
        self.flush();
        self.runs.push(build(inner.to_owned()));
        self.rest = rest;
        Ok(())
    }

    fn term(&mut self, after: &'text str) -> Result<(), String> {
        let (inner, rest) = after
            .split_once("]]")
            .ok_or_else(|| "unclosed glossary term".to_owned())?;
        let (term, text) = inner.split_once('|').unwrap_or((inner, inner));
        self.flush();
        self.runs.push(Inline::Term {
            term: term.trim().to_owned(),
            text: text.trim().to_owned(),
        });
        self.rest = rest;
        Ok(())
    }

    fn link(&mut self, after: &'text str) -> Result<(), String> {
        let Some((text, rest)) = after
            .split_once("](#")
            .filter(|(text, _)| !text.contains(['[', ']', '`']))
        else {
            self.plain.push('[');
            self.rest = after;
            return Ok(());
        };
        let (section, rest) = rest
            .split_once(')')
            .ok_or_else(|| "unclosed section link".to_owned())?;
        self.flush();
        self.runs.push(Inline::Link {
            section: section.to_owned(),
            text: text.to_owned(),
        });
        self.rest = rest;
        Ok(())
    }

    fn flush(&mut self) {
        if !self.plain.is_empty() {
            self.runs
                .push(Inline::Text(std::mem::take(&mut self.plain)));
        }
    }
}
