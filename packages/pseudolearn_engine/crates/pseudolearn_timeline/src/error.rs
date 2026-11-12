use std::fmt;

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum TimelineError {
    PastHorizon {
        requested: usize,
        horizon: usize,
    },
    FutureEvent {
        requested: usize,
        latest: usize,
    },
    InvalidFrame {
        frame_position: usize,
        total_frames: usize,
    },
    InvalidObject {
        identity_ordinal: u64,
    },
    InvalidArray {
        identity_ordinal: u64,
    },
    SliceOutOfRange {
        start_index: usize,
        slice_length: usize,
        total_elements: usize,
    },
    ReplayFailure,
}

impl fmt::Display for TimelineError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::PastHorizon { requested, horizon } => {
                write!(formatter, "event {requested} is past horizon {horizon}")
            }
            Self::FutureEvent { requested, latest } => {
                write!(formatter, "event {requested} exceeds latest event {latest}")
            }
            Self::InvalidFrame {
                frame_position,
                total_frames,
            } => {
                write!(
                    formatter,
                    "frame {frame_position} invalid for depth {total_frames}"
                )
            }
            Self::InvalidObject { identity_ordinal } => {
                write!(
                    formatter,
                    "object with ordinal {identity_ordinal} not found"
                )
            }
            Self::InvalidArray { identity_ordinal } => {
                write!(formatter, "array with ordinal {identity_ordinal} not found")
            }
            Self::SliceOutOfRange {
                start_index,
                slice_length,
                total_elements,
            } => {
                write!(
                    formatter,
                    "slice ({start_index}, {slice_length}) exceeds length {total_elements}"
                )
            }
            Self::ReplayFailure => write!(formatter, "replay execution failed"),
        }
    }
}

impl std::error::Error for TimelineError {}
