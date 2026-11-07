use std::collections::BTreeMap;

pub struct FigureContext<'context> {
    pub id: &'context str,
    pub strings: &'context BTreeMap<String, String>,
    pub lexeme: &'context dyn Fn(&str) -> Option<String>,
    pub code: &'context dyn Fn(&str) -> String,
}

impl FigureContext<'_> {
    pub fn substitute(&self, text: &str) -> Result<String, String> {
        let mut rest = text;
        let mut result = String::new();
        while let Some((literal, after)) = rest.split_once("{{") {
            check_literal(literal)?;
            result.push_str(literal);
            let (inner, remaining) = after
                .split_once("}}")
                .ok_or_else(|| "unclosed `{{` placeholder".to_owned())?;
            result.push_str(&self.expand(inner)?);
            rest = remaining;
        }
        check_literal(rest)?;
        result.push_str(rest);
        Ok(result)
    }

    pub fn string(&self, key: &str) -> Result<String, String> {
        self.strings
            .get(key)
            .cloned()
            .ok_or_else(|| format!("figure `{}` has no string `{key}`", self.id))
    }

    fn expand(&self, inner: &str) -> Result<String, String> {
        let (kind, argument) = inner
            .split_once(':')
            .ok_or_else(|| format!("placeholder `{inner}` needs a kind"))?;
        match kind {
            "t" => self.string(argument),
            "lex" => (self.lexeme)(argument)
                .ok_or_else(|| format!("unknown lexeme identity `{argument}`")),
            "codigo" => Ok((self.code)(argument)),
            other => Err(format!("unknown placeholder kind `{other}`")),
        }
    }
}

fn check_literal(literal: &str) -> Result<(), String> {
    if literal.chars().any(char::is_alphabetic) {
        return Err(format!(
            "visible text `{}` must come from a string, a lexeme or a code fragment",
            literal.trim()
        ));
    }
    Ok(())
}
