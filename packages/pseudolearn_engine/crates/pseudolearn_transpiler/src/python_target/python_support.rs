use super::PythonEmitter;
use super::python_support_catalog::{dependencies, source};
use crate::code_lines::CodeLines;

const ORDER: &[&str] = &[
    "variants",
    "propagation",
    "tasks",
    "channel",
    "real_text",
    "boolean_text",
    "collection_text",
    "finite",
    "int_divide",
    "int_modulo",
    "int_power",
    "real_power",
    "counted_range",
    "index",
    "read_line",
    "read_integer",
    "read_real",
    "read_text",
    "read_character",
    "read_boolean",
    "round_half_away",
    "truncate",
    "floor",
    "ceiling",
    "random",
    "character_at",
    "character_from_code",
    "substring",
    "text_position",
    "replace_all",
    "split_text",
    "text_to_integer",
    "text_to_real",
    "dictionary_find",
    "dictionary_remove",
    "vector_index_of",
];

const IMPORTS: &[(&str, &str)] = &[
    ("asyncio", "import asyncio"),
    ("collections", "import collections"),
    ("copy", "import copy"),
    ("decimal", "import decimal"),
    ("functools", "import functools"),
    ("math", "import math"),
    ("re", "import re"),
    ("time", "import time"),
    ("dataclass", "from dataclasses import dataclass, field"),
    ("enum", "from enum import Enum"),
];

impl PythonEmitter<'_, '_> {
    pub(crate) fn write_imports(&mut self, lines: &mut CodeLines) {
        if self
            .view
            .module
            .expressions
            .kinds
            .iter()
            .any(|expression| self.uses_module(expression))
        {
            self.require("functools");
        }
        if self.uses_tasks() {
            self.require("tasks");
        }
        self.support.close_over(dependencies);
        let mut written = false;
        for (name, statement) in IMPORTS {
            if self.support.contains(name) {
                lines.line(statement);
                written = true;
            }
        }
        if written {
            lines.blank();
            lines.blank();
        }
    }

    pub(crate) fn write_support(&self, lines: &mut CodeLines) {
        for name in ORDER {
            if !self.support.contains(name) {
                continue;
            }
            for line in source(name, self.request).lines() {
                lines.line(line);
            }
            lines.blank();
            lines.blank();
        }
    }
}
