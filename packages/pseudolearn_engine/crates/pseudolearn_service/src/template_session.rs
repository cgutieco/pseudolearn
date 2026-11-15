use crate::insertion::{Insertion, StopRange, TextChange};
use crate::template_model::StopRole;
use crate::typing_plan::shift_of;

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TemplateSession {
    stops: Vec<StopRange>,
    active: usize,
    final_offset: usize,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum StopDirection {
    Next,
    Previous,
    Exit,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum StopNavigation {
    Selected {
        index: u8,
        start: usize,
        end: usize,
        role: StopRole,
    },
    Exited {
        caret: usize,
    },
}

impl TemplateSession {
    pub fn from_insertion(insertion: &Insertion) -> Option<TemplateSession> {
        if insertion.stops.is_empty() {
            return None;
        }
        Some(TemplateSession {
            stops: insertion.stops.clone(),
            active: 0,
            final_offset: insertion.final_offset,
        })
    }

    pub fn navigate(&mut self, direction: StopDirection) -> StopNavigation {
        match direction {
            StopDirection::Exit => self.exit(),
            StopDirection::Previous => {
                self.active = self.active.saturating_sub(1);
                self.selection()
            }
            StopDirection::Next if self.active.saturating_add(1) >= self.stops.len() => self.exit(),
            StopDirection::Next => {
                self.active = self.active.saturating_add(1);
                self.selection()
            }
        }
    }

    fn exit(&self) -> StopNavigation {
        StopNavigation::Exited {
            caret: self.final_offset,
        }
    }

    fn selection(&self) -> StopNavigation {
        let stop = self.stops.get(self.active).or_else(|| self.stops.first());
        match stop {
            Some(found) => StopNavigation::Selected {
                index: found.index,
                start: found.start,
                end: found.end,
                role: found.role,
            },
            None => self.exit(),
        }
    }

    pub fn follow(&mut self, change: &TextChange) -> bool {
        let inside = self.stops.iter().any(|stop| contains(stop, change));
        if !inside {
            return false;
        }
        let shift = shift_of(change);
        for stop in &mut self.stops {
            move_range(stop, change, shift);
        }
        if change.end_utf8 <= self.final_offset {
            self.final_offset = self.final_offset.saturating_add_signed(shift);
        }
        true
    }
}

fn contains(stop: &StopRange, change: &TextChange) -> bool {
    change.start_utf8 >= stop.start && change.end_utf8 <= stop.end
}

fn move_range(stop: &mut StopRange, change: &TextChange, shift: isize) {
    if contains(stop, change) {
        stop.end = stop.end.saturating_add_signed(shift);
    } else if stop.start >= change.end_utf8 {
        stop.start = stop.start.saturating_add_signed(shift);
        stop.end = stop.end.saturating_add_signed(shift);
    }
}
