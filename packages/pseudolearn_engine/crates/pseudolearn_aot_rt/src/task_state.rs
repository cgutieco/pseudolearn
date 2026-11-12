use crate::cells::CellSlot;
use crate::task_baton::Baton;
use crate::task_values::TaskValue;
use pseudolearn_runtime::{
    ChannelReply, Handle, TaskAgenda, TaskChannelId, TaskChannels, TaskFailures, TaskId,
    TaskQuantum, TaskScopeId,
};
use std::collections::BTreeMap;
use std::sync::Arc;

pub type TaskDispatcher = extern "C" fn(*mut crate::context::AotRuntimeContext, u32, *const u64);

#[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
pub(crate) struct Landing {
    pub(crate) depth: u32,
    pub(crate) index: u32,
    pub(crate) root_top: u32,
    pub(crate) cells: usize,
}

pub(crate) struct SuspendedFrames {
    pub(crate) roots: Vec<u32>,
    pub(crate) root_top: u32,
    pub(crate) cells: Vec<CellSlot>,
    pub(crate) site: u32,
}

#[derive(Clone)]
pub(crate) struct AwaitedEffect {
    pub(crate) sequence: u64,
    pub(crate) task: TaskId,
    pub(crate) request: pseudolearn_runtime::HostEffectRequest,
}

impl AwaitedEffect {
    pub(crate) fn abandoned(&self) -> pseudolearn_runtime::AbandonedEffect {
        pseudolearn_runtime::AbandonedEffect {
            vm_sequence: self.sequence,
            task: self.task.0,
            request: self.request.clone(),
        }
    }
}

pub(crate) struct PendingStart {
    pub(crate) function: u32,
    pub(crate) arguments: Vec<TaskValue>,
}

pub(crate) enum Wakeup {
    Continue,
    Land(Landing),
    Terminate(u32),
}

pub(crate) struct AotTasks {
    pub(crate) baton: Arc<Baton>,
    pub(crate) dispatcher: Option<TaskDispatcher>,
    pub(crate) agenda: TaskAgenda,
    pub(crate) current: TaskId,
    pub(crate) quantum: TaskQuantum,
    pub(crate) budget: i64,
    pub(crate) pending_starts: BTreeMap<TaskId, PendingStart>,
    pub(crate) task_storage: BTreeMap<TaskId, Handle>,
    pub(crate) suspended: BTreeMap<TaskId, SuspendedFrames>,
    pub(crate) wakeups: BTreeMap<TaskId, Wakeup>,
    pub(crate) cancel_points: BTreeMap<TaskId, BTreeMap<u32, Landing>>,
    pub(crate) cleanup_depths: BTreeMap<TaskId, u32>,
    pub(crate) pending_landings: BTreeMap<TaskId, Landing>,
    pub(crate) scope_resumes: BTreeMap<TaskScopeId, Landing>,
    pub(crate) aborted_scopes: BTreeMap<TaskId, TaskScopeId>,
    pub(crate) scope_parents: BTreeMap<TaskScopeId, Option<TaskScopeId>>,
    pub(crate) scope_stacks: BTreeMap<TaskId, Vec<TaskScopeId>>,
    pub(crate) outcomes: BTreeMap<TaskId, (bool, Vec<TaskValue>)>,
    pub(crate) failures: BTreeMap<TaskScopeId, TaskFailures<Vec<TaskValue>>>,
    pub(crate) results: BTreeMap<TaskId, Option<TaskValue>>,
    pub(crate) task_values: BTreeMap<TaskId, Vec<TaskValue>>,
    pub(crate) transport_values: BTreeMap<TaskId, Option<Vec<TaskValue>>>,
    pub(crate) channels: TaskChannels<Vec<TaskValue>>,
    pub(crate) channel_storage: BTreeMap<TaskChannelId, Handle>,
    pub(crate) channel_replies: BTreeMap<TaskId, ChannelReply<Vec<TaskValue>>>,
    pub(crate) channel_capacity_limit: usize,
    pub(crate) termination: Option<u32>,
    pub(crate) pending_effects: BTreeMap<TaskId, AwaitedEffect>,
    pub(crate) abandoned_effects: Vec<AwaitedEffect>,
    pub(crate) delivering: BTreeMap<TaskId, u64>,
    pub(crate) vm_sequence: u64,
    pub(crate) pending_network: u64,
    pub(crate) limit_rejected: std::collections::BTreeSet<u64>,
    pub(crate) delivery_order: Vec<u64>,
}

impl AotTasks {
    pub(crate) fn new(dispatcher: TaskDispatcher, task_limit: u64, capacity: usize) -> Self {
        let (mut agenda, current) = TaskAgenda::with_running_root();
        agenda.set_task_limit(task_limit);
        Self {
            baton: Default::default(),
            dispatcher: Some(dispatcher),
            agenda,
            current,
            quantum: Default::default(),
            budget: 0,
            pending_starts: Default::default(),
            task_storage: Default::default(),
            suspended: Default::default(),
            wakeups: Default::default(),
            cancel_points: Default::default(),
            cleanup_depths: Default::default(),
            pending_landings: Default::default(),
            scope_resumes: Default::default(),
            aborted_scopes: Default::default(),
            scope_parents: Default::default(),
            scope_stacks: Default::default(),
            outcomes: Default::default(),
            failures: Default::default(),
            results: Default::default(),
            task_values: Default::default(),
            transport_values: Default::default(),
            channels: Default::default(),
            channel_storage: Default::default(),
            channel_replies: Default::default(),
            channel_capacity_limit: capacity,
            termination: None,
            vm_sequence: 0,
            pending_network: 0,
            limit_rejected: Default::default(),
            pending_effects: Default::default(),
            abandoned_effects: Default::default(),
            delivery_order: Default::default(),
            delivering: Default::default(),
        }
    }

    pub(crate) fn forget_channel_waits(&mut self, task: TaskId) {
        self.channels.cancel(task);
        self.channel_replies.remove(&task);
    }
}
