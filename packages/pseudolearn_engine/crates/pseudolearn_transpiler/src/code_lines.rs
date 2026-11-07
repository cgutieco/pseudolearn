use crate::outcome::Transpilation;
use pseudolearn_source::Span;

const INDENTATION: &str = "    ";

#[derive(Default)]
pub(crate) struct CodeLines {
    lines: Vec<(String, Option<Span>)>,
    depth: usize,
    origin: Option<Span>,
}

impl CodeLines {
    pub(crate) fn line(&mut self, text: &str) {
        let indented = if text.is_empty() {
            String::new()
        } else {
            format!("{}{text}", INDENTATION.repeat(self.depth))
        };
        self.lines.push((indented, self.origin));
    }

    pub(crate) fn open(&mut self, text: &str) {
        self.line(text);
        self.depth = self.depth.saturating_add(1);
    }

    pub(crate) fn close(&mut self, text: &str) {
        self.depth = self.depth.saturating_sub(1);
        self.line(text);
    }

    pub(crate) fn dedent(&mut self) {
        self.depth = self.depth.saturating_sub(1);
    }

    pub(crate) fn blank(&mut self) {
        if self.lines.last().is_some_and(|(text, _)| !text.is_empty()) {
            self.lines.push((String::new(), None));
        }
    }

    pub(crate) fn attributed(&mut self, origin: Span) -> Option<Span> {
        self.origin.replace(origin)
    }

    pub(crate) fn restore(&mut self, previous: Option<Span>) {
        self.origin = previous;
    }

    pub(crate) fn append(&mut self, other: CodeLines) {
        for (text, origin) in other.lines {
            let indented = if text.is_empty() {
                text
            } else {
                format!("{}{text}", INDENTATION.repeat(self.depth))
            };
            self.lines.push((indented, origin));
        }
    }

    pub(crate) fn is_empty(&self) -> bool {
        self.lines.iter().all(|(text, _)| text.is_empty())
    }

    pub(crate) fn inline_text(&self) -> String {
        self.lines
            .iter()
            .map(|(text, _)| text.trim())
            .filter(|text| !text.is_empty())
            .collect::<Vec<_>>()
            .join(" ")
    }

    pub(crate) fn finish(mut self) -> Transpilation {
        while self.lines.last().is_some_and(|(text, _)| text.is_empty()) {
            self.lines.pop();
        }
        let code = self
            .lines
            .iter()
            .map(|(text, _)| text.as_str())
            .collect::<Vec<_>>()
            .join("\n");
        Transpilation {
            code: format!("{code}\n"),
            line_origins: self.lines.into_iter().map(|(_, origin)| origin).collect(),
        }
    }
}
