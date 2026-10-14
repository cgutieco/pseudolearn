use super::richards::{DEVICE_A, DEVICE_B, Role, Scheduler, Task};

impl Scheduler {
    fn task_at(&self, identity: usize) -> Option<Task> {
        self.tasks.get(identity).copied().flatten()
    }

    fn update(&mut self, identity: usize, change: impl FnOnce(&mut Task)) {
        if let Some(Some(task)) = self.tasks.get_mut(identity) {
            change(task);
        }
    }

    pub(super) fn schedule(&mut self) {
        let mut current = self.list;
        while let Some(identity) = current {
            let Some(task) = self.task_at(identity) else {
                return;
            };
            current = if task.holding || (!task.pending && task.waiting) {
                task.link
            } else {
                self.run_task(identity, task)
            };
        }
    }

    fn run_task(&mut self, identity: usize, task: Task) -> Option<usize> {
        let mut message = None;
        if task.pending && task.waiting && !task.holding {
            message = task.input;
            let next = task.input.and_then(|packet| self.link_of(packet));
            self.update(identity, |task| {
                task.input = next;
                task.pending = next.is_some();
                task.waiting = false;
                task.holding = false;
            });
        }
        match task.role {
            Role::Device { pending } => self.device(identity, message, pending),
            Role::Handler { .. } => self.handler(identity, message),
            Role::Idle { control, count } => self.idle(identity, control, count),
            Role::Worker { .. } => self.worker(identity, message),
        }
    }

    pub(super) fn wait(&mut self, identity: usize) -> Option<usize> {
        self.update(identity, |task| task.waiting = true);
        Some(identity)
    }

    pub(super) fn hold(&mut self, identity: usize) -> Option<usize> {
        self.holds = self.holds.wrapping_add(1);
        self.update(identity, |task| task.holding = true);
        self.task_at(identity).and_then(|task| task.link)
    }

    fn release(&mut self, identity: usize, target: usize) -> Option<usize> {
        self.update(target, |task| task.holding = false);
        let priority = |task: Option<Task>| task.map_or(0, |task| task.priority);
        if priority(self.task_at(target)) > priority(self.task_at(identity)) {
            Some(target)
        } else {
            Some(identity)
        }
    }

    pub(super) fn queue(&mut self, identity: usize, packet: usize) -> Option<usize> {
        let target = self.packets.get(packet).map_or(0, |value| value.identity);
        self.queued = self.queued.wrapping_add(1);
        self.set_link(packet, None);
        if let Some(value) = self.packets.get_mut(packet) {
            value.identity = identity;
        }
        let Some(task) = self.task_at(target) else {
            return Some(identity);
        };
        if let Some(input) = task.input {
            self.append(packet, Some(input));
            return Some(identity);
        }
        self.update(target, |task| {
            task.input = Some(packet);
            task.pending = true;
        });
        let previous = self.task_at(identity).map_or(0, |task| task.priority);
        Some(if task.priority > previous {
            target
        } else {
            identity
        })
    }

    fn device(
        &mut self,
        identity: usize,
        message: Option<usize>,
        pending: Option<usize>,
    ) -> Option<usize> {
        let Some(packet) = message else {
            let Some(stored) = pending else {
                return self.wait(identity);
            };
            self.update(identity, |task| task.role = Role::Device { pending: None });
            return self.queue(identity, stored);
        };
        self.update(identity, |task| {
            task.role = Role::Device {
                pending: Some(packet),
            }
        });
        self.hold(identity)
    }

    fn idle(&mut self, identity: usize, control: i64, count: i64) -> Option<usize> {
        let remaining = count.wrapping_sub(1);
        let half = control.wrapping_div(2);
        let even = control.wrapping_rem(2) == 0;
        let next = if even { half } else { half ^ 53256 };
        self.update(identity, |task| {
            task.role = Role::Idle {
                control: next,
                count: remaining,
            }
        });
        if remaining == 0 {
            return self.hold(identity);
        }
        self.release(identity, if even { DEVICE_A } else { DEVICE_B })
    }
}
