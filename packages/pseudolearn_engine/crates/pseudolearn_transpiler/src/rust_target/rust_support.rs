use super::RustEmitter;
use super::rust_effect_catalog::{EFFECT_ORDER, SHARED_SUPPORT};
use super::rust_support_catalog::{dependencies, source};
use crate::code_lines::CodeLines;

const ORDER: &[&str] = &[
    "tasks",
    "channel",
    "select",
    "dictionary",
    "collection_text",
    "real_text",
    "boolean_text",
    "divide",
    "integer_power",
    "real_power",
    "counted_range",
    "read_line",
    "read_integer",
    "read_real",
    "read_text",
    "read_character",
    "read_boolean",
    "round_half_away",
    "truncate",
    "text_position",
    "substring",
    "character_at",
    "character_from_code",
    "text_to_integer",
    "text_to_real",
    "random",
    "random_seed",
    "snapshot",
    "finite",
    "replace_all",
    "split_text",
];

impl RustEmitter<'_, '_> {
    pub(crate) fn write_uses(&mut self, lines: &mut CodeLines) {
        self.support.close_over(dependencies);
        let tasks = self.support.contains("tasks") || self.support.contains("channel");
        let shared = tasks
            || self.uses.contains("rc")
            || ["dictionary", "split_text"]
                .iter()
                .chain(SHARED_SUPPORT)
                .any(|name| self.support.contains(name));
        let mut uses = Vec::new();
        if shared || self.support.contains("random") {
            uses.push("use std::cell::RefCell;");
        }
        if tasks {
            uses.push("use std::collections::VecDeque;");
            uses.push("use std::future::Future;");
            uses.push("use std::pin::Pin;");
        }
        if shared {
            uses.push("use std::rc::Rc;");
        }
        if tasks {
            uses.push("use std::sync::Arc;");
            uses.push("use std::task::{Context, Poll, Wake, Waker};");
        }
        if self.support.contains("read_line") {
            uses.push("use std::io::Write;");
        }
        for text in &uses {
            lines.line(text);
        }
        if !uses.is_empty() {
            lines.blank();
        }
    }

    pub(crate) fn write_support(&self, lines: &mut CodeLines) {
        for name in ORDER.iter().chain(EFFECT_ORDER) {
            if !self.support.contains(name) {
                continue;
            }
            lines.blank();
            let text = source(name, self.request);
            for line in text.lines() {
                lines.line(line);
            }
            if *name == "snapshot" {
                self.write_snapshot_implementations(lines);
            }
        }
    }
}
