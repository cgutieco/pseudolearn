use crate::error::TimelineError;
use crate::inspect::{build_frame_view, build_single_object_view};
use crate::replay::{replay_machine_to_event, replay_to_event};
use crate::scheduler::{CostScheduler, SchedulerOptions};
use crate::store::CheckpointStore;
use crate::views::{FrameView, ObjectView, StateSnapshot, VariableValue, VariableView};
use pseudolearn_vm::{LoadedProgram, Machine, RunOptions, machine_statements_executed};

pub struct ExecutionTimeline<'program> {
    pub program: &'program LoadedProgram,
    pub options: RunOptions,
    pub scheduler: CostScheduler,
    pub store: CheckpointStore,
    latest_event: usize,
}

#[derive(Clone, Copy, Debug, PartialEq)]
pub struct ArraySliceRange {
    pub start_index: usize,
    pub slice_length: usize,
}

impl<'program> ExecutionTimeline<'program> {
    pub fn new(
        program: &'program LoadedProgram,
        options: RunOptions,
        scheduler_options: SchedulerOptions,
        max_checkpoints: usize,
    ) -> Self {
        Self {
            program,
            options,
            scheduler: CostScheduler::new(scheduler_options),
            store: CheckpointStore::new(max_checkpoints),
            latest_event: 0,
        }
    }

    pub fn record_step(
        &mut self,
        machine: &Machine,
        event_index: usize,
    ) -> Result<(), TimelineError> {
        if event_index.checked_add(1) != Some(pseudolearn_vm::machine_event_count(machine)) {
            return Err(TimelineError::ReplayFailure);
        }
        self.latest_event = event_index;
        let statements = machine_statements_executed(machine);
        if !self.store.has_checkpoints() || self.scheduler.should_checkpoint(statements) {
            self.store.record(machine, event_index)?;
            self.scheduler
                .record_checkpoint(statements, self.store.stats().live_words);
        }
        Ok(())
    }

    pub fn query_state(&mut self, event_index: usize) -> Result<StateSnapshot, TimelineError> {
        self.validate_event_boundaries(event_index)?;
        let (image, _) = self.store.image_at(event_index)?;
        replay_to_event(self.program, image, event_index, &self.options)
    }

    pub fn query_frames(&mut self, event_index: usize) -> Result<Vec<FrameView>, TimelineError> {
        let machine = self.machine_at(event_index)?;
        let mut frames = Vec::new();
        for position in 0..machine.active_frames_count() {
            let frame = machine
                .active_frame(position)
                .ok_or(TimelineError::ReplayFailure)?;
            frames.push(build_frame_view(&machine, position, &frame));
        }
        Ok(frames)
    }

    pub fn query_variables(
        &mut self,
        event_index: usize,
        frame_position: usize,
    ) -> Result<Vec<VariableView>, TimelineError> {
        let machine = self.machine_at(event_index)?;
        let frame = machine
            .active_frame(frame_position)
            .ok_or(TimelineError::InvalidFrame {
                frame_position,
                total_frames: machine.active_frames_count(),
            })?;
        Ok(build_frame_view(&machine, frame_position, &frame).variables)
    }

    pub fn query_object(
        &mut self,
        event_index: usize,
        identity_ordinal: u64,
    ) -> Result<ObjectView, TimelineError> {
        let machine = self.machine_at(event_index)?;
        let handle = crate::array_view::find_identity(&machine, identity_ordinal)
            .ok_or(TimelineError::InvalidObject { identity_ordinal })?;
        build_single_object_view(&machine, handle)
            .ok_or(TimelineError::InvalidObject { identity_ordinal })
    }

    pub fn query_array_slice(
        &mut self,
        event_index: usize,
        identity_ordinal: u64,
        slice_range: ArraySliceRange,
    ) -> Result<Vec<VariableValue>, TimelineError> {
        let machine = self.machine_at(event_index)?;
        crate::array_view::read_slice(&machine, identity_ordinal, slice_range)
    }

    fn machine_at(&self, event_index: usize) -> Result<Machine<'program>, TimelineError> {
        self.validate_event_boundaries(event_index)?;
        let (image, _) = self.store.image_at(event_index)?;
        replay_machine_to_event(self.program, image, event_index, &self.options)
    }

    fn validate_event_boundaries(&self, requested: usize) -> Result<(), TimelineError> {
        let horizon = self.store.stats().horizon;
        if requested < horizon {
            return Err(TimelineError::PastHorizon { requested, horizon });
        }
        if requested > self.latest_event {
            return Err(TimelineError::FutureEvent {
                requested,
                latest: self.latest_event,
            });
        }
        Ok(())
    }
}

pub fn timeline_horizon(timeline: &ExecutionTimeline<'_>) -> usize {
    timeline.store.stats().horizon
}

pub fn timeline_checkpoints_count(timeline: &ExecutionTimeline<'_>) -> usize {
    timeline.store.stats().checkpoints
}
