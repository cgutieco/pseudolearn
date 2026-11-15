#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum TaskState {
    Ready,
    Running,
    Waiting,
    CancelRequested,
    Cleaning,
    Completed,
    Failed,
    Cancelled,
}

impl TaskState {
    pub fn is_terminal(self) -> bool {
        matches!(self, Self::Completed | Self::Failed | Self::Cancelled)
    }

    pub fn can_request_cancellation(self) -> bool {
        matches!(self, Self::Ready | Self::Waiting)
    }
}
