use super::RustEmitter;
use crate::code_lines::CodeLines;
use pseudolearn_semantic::StatementId;

impl RustEmitter<'_, '_> {
    pub(crate) fn loop_body(&mut self, statements: &[StatementId], lines: &mut CodeLines) {
        self.scope.cleanups.push(super::CleanupFrame {
            loop_boundary: true,
            bodies: Vec::new(),
        });
        self.statements(statements, lines);
        self.scope.cleanups.pop();
    }

    pub(crate) fn run_cleanups(&mut self, frames: Vec<super::CleanupFrame>, lines: &mut CodeLines) {
        for frame in frames {
            for body in frame.bodies.iter().rev() {
                self.statements(body, lines);
            }
        }
    }

    pub(crate) fn cleanup_text(&mut self) -> Option<String> {
        let mut lines = CodeLines::default();
        if self.exit_cleanups(false, &mut lines) {
            Some(lines.inline_text())
        } else {
            None
        }
    }

    pub(crate) fn pending_cleanups(&self, until_loop: bool) -> Vec<super::CleanupFrame> {
        let mut frames = Vec::new();
        for frame in self.scope.cleanups.iter().rev() {
            if until_loop && frame.loop_boundary {
                break;
            }
            frames.push(super::CleanupFrame {
                loop_boundary: false,
                bodies: frame.bodies.clone(),
            });
        }
        frames
    }

    pub(crate) fn exit_cleanups(&mut self, until_loop: bool, lines: &mut CodeLines) -> bool {
        let frames = self.pending_cleanups(until_loop);
        if frames.iter().all(|frame| frame.bodies.is_empty()) {
            return false;
        }
        let saved = std::mem::take(&mut self.scope.cleanups);
        self.run_cleanups(frames, lines);
        self.scope.cleanups = saved;
        true
    }
}
