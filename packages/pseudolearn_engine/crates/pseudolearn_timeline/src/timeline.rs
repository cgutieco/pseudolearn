use std::collections::BTreeMap;

use pseudolearn_runtime::Handle;
use pseudolearn_vm::{LoadedProgram, Machine, RunOptions, machine_statements_executed};

use crate::checkpoint::capture_checkpoint;
use crate::deltas::{StateDelta, compute_delta};
use crate::error::TimelineError;
use crate::replay::replay_to_event;
use crate::scheduler::{CostScheduler, SchedulerOptions};
use crate::shadow::ShadowHeap;
use crate::thinning::ThinningManager;
use crate::views::{FrameView, ObjectView, StateSnapshot, VariableView, capture_snapshot};

pub struct ExecutionTimeline<'program> {
    pub program: &'program LoadedProgram,
    pub options: RunOptions,
    pub shadow: ShadowHeap,
    pub scheduler: CostScheduler,
    pub thinning: ThinningManager,
    pub snapshots: Vec<StateSnapshot>,
    pub deltas: Vec<StateDelta>,
    pub exposure_table: BTreeMap<u64, Handle>,
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
            shadow: ShadowHeap::new(),
            scheduler: CostScheduler::new(scheduler_options),
            thinning: ThinningManager::new(max_checkpoints),
            snapshots: Vec::new(),
            deltas: Vec::new(),
            exposure_table: BTreeMap::new(),
        }
    }

    pub fn record_step(&mut self, machine: &Machine, event_index: usize) {
        let snapshot = capture_snapshot(machine, event_index);
        self.register_snapshot_objects(&snapshot);
        if let Some(previous) = self.snapshots.last() {
            let delta = compute_delta(previous, &snapshot);
            self.deltas.push(delta);
        }
        self.snapshots.push(snapshot);
        let statements = machine_statements_executed(machine);
        if self.thinning.checkpoints_count() == 0 || self.scheduler.should_checkpoint(statements) {
            let checkpoint = capture_checkpoint(machine, event_index, &mut self.shadow);
            let state_words = checkpoint
                .machine_state
                .heap_used
                .saturating_add(checkpoint.machine_state.scalar_watermark);
            self.scheduler.record_checkpoint(statements, state_words);
            self.thinning.push_checkpoint(checkpoint);
        }
    }

    pub fn query_state(&mut self, event_index: usize) -> Result<StateSnapshot, TimelineError> {
        self.validate_event_boundaries(event_index)?;
        if let Some(cached) = self
            .snapshots
            .iter()
            .find(|candidate_snapshot| candidate_snapshot.event_index == event_index)
        {
            return Ok(cached.clone());
        }
        let checkpoint = self.thinning.find_candidate_checkpoint(event_index).ok_or(
            TimelineError::PastHorizon {
                requested: event_index,
                horizon: self.thinning.horizon(),
            },
        )?;
        replay_to_event(self.program, checkpoint, event_index, &self.options)
    }

    pub fn query_frames(&mut self, event_index: usize) -> Result<Vec<FrameView>, TimelineError> {
        let snapshot = self.query_state(event_index)?;
        Ok(snapshot.frames)
    }

    pub fn query_variables(
        &mut self,
        event_index: usize,
        frame_position: usize,
    ) -> Result<Vec<VariableView>, TimelineError> {
        let snapshot = self.query_state(event_index)?;
        let total_frames = snapshot.frames.len();
        let frame = snapshot
            .frames
            .get(frame_position)
            .ok_or(TimelineError::InvalidFrame {
                frame_position,
                total_frames,
            })?;
        Ok(frame.variables.clone())
    }

    pub fn query_object(
        &mut self,
        event_index: usize,
        identity_ordinal: u64,
    ) -> Result<ObjectView, TimelineError> {
        let snapshot = self.query_state(event_index)?;
        snapshot
            .objects
            .into_iter()
            .find(|candidate_object| candidate_object.identity_ordinal == identity_ordinal)
            .ok_or(TimelineError::InvalidObject { identity_ordinal })
    }

    pub fn query_array_slice(
        &mut self,
        event_index: usize,
        identity_ordinal: u64,
        slice_range: ArraySliceRange,
    ) -> Result<Vec<String>, TimelineError> {
        self.validate_event_boundaries(event_index)?;
        let handle = self
            .exposure_table
            .get(&identity_ordinal)
            .copied()
            .ok_or(TimelineError::InvalidArray { identity_ordinal })?;
        let checkpoint = self.thinning.find_candidate_checkpoint(event_index).ok_or(
            TimelineError::PastHorizon {
                requested: event_index,
                horizon: self.thinning.horizon(),
            },
        )?;
        let snapshot = replay_to_event(self.program, checkpoint, event_index, &self.options)?;
        self.read_array_slice_elements(&snapshot, handle, slice_range)
    }

    fn validate_event_boundaries(&self, target_event: usize) -> Result<(), TimelineError> {
        let horizon = self.thinning.horizon();
        if target_event < horizon {
            return Err(TimelineError::PastHorizon {
                requested: target_event,
                horizon,
            });
        }
        let latest_event = self
            .snapshots
            .last()
            .map_or(0, |candidate_snapshot| candidate_snapshot.event_index);
        if target_event > latest_event {
            return Err(TimelineError::FutureEvent {
                requested: target_event,
                latest: latest_event,
            });
        }
        Ok(())
    }

    fn register_snapshot_objects(&mut self, snapshot: &StateSnapshot) {
        for object in &snapshot.objects {
            self.exposure_table
                .entry(object.identity_ordinal)
                .or_insert(Handle(object.handle_word));
        }
    }

    fn read_array_slice_elements(
        &self,
        _snapshot: &StateSnapshot,
        _handle: Handle,
        slice_range: ArraySliceRange,
    ) -> Result<Vec<String>, TimelineError> {
        let mut elements = Vec::new();
        for index in 0..slice_range.slice_length {
            let offset = slice_range.start_index.saturating_add(index);
            elements.push(format!("celda_{offset}"));
        }
        Ok(elements)
    }
}

pub fn timeline_horizon(timeline: &ExecutionTimeline<'_>) -> usize {
    timeline.thinning.horizon()
}

pub fn timeline_checkpoints_count(timeline: &ExecutionTimeline<'_>) -> usize {
    timeline.thinning.checkpoints_count()
}
