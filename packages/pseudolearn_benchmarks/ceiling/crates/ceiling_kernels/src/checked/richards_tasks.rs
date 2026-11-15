use super::richards::Scheduler;
use crate::checked::exclusive_or;
use crate::machine::{Handle, Machine, Outcome};

impl<Implementation: Machine> Scheduler<'_, Implementation> {
    pub(super) fn run_task(&mut self, identity: usize) -> Outcome<Option<usize>> {
        let task = self.task(identity)?;
        self.machine
            .enter(&[i64::try_from(identity).unwrap_or_default()], &[task])?;
        let mut message = self.null;
        if self.machine.field(task, 7)? != 0 && self.machine.field(task, 8)? != 0 {
            message = self.machine.link(task, 1)?;
            let next = self.machine.link(message, 0)?;
            self.machine.set_link(task, 1, next)?;
            self.machine
                .set_field(task, 7, i64::from(next != self.null))?;
            self.machine.set_field(task, 8, 0)?;
        }
        let result = match self.machine.field(task, 10)? {
            1 => self.idle(identity, task),
            2 => self.worker(identity, task, message),
            3 => self.handler(identity, task, message),
            _ => self.device(identity, task, message),
        };
        self.machine.leave();
        result
    }

    fn idle(&mut self, identity: usize, task: Handle) -> Outcome<Option<usize>> {
        let count = self.machine.field(task, 12)?;
        let remaining = self.machine.subtract(count, 1)?;
        self.machine.set_field(task, 12, remaining)?;
        if remaining == 0 {
            return self.hold(identity);
        }
        let control = self.machine.field(task, 11)?;
        let half = self.machine.quotient(control, 2)?;
        let even = self.machine.remainder(control, 2)? == 0;
        let next = if even {
            half
        } else {
            exclusive_or(self.machine, half, 53256)?
        };
        self.machine.set_field(task, 11, next)?;
        self.release(identity, if even { 5 } else { 6 })
    }

    fn device(&mut self, identity: usize, task: Handle, message: Handle) -> Outcome<Option<usize>> {
        if message == self.null {
            let stored = self.machine.link(task, 2)?;
            if stored == self.null {
                return self.wait(identity);
            }
            self.machine.set_link(task, 2, self.null)?;
            return self.queue(identity, stored);
        }
        self.machine.set_link(task, 2, message)?;
        self.hold(identity)
    }

    fn worker(&mut self, identity: usize, task: Handle, message: Handle) -> Outcome<Option<usize>> {
        if message == self.null {
            return self.wait(identity);
        }
        let destination = if self.machine.field(task, 13)? == 3 {
            4
        } else {
            3
        };
        self.machine.set_field(task, 13, destination)?;
        self.machine.set_field(message, 1, destination)?;
        self.machine.set_field(message, 3, 0)?;
        let mut count = self.machine.field(task, 12)?;
        for slot in 4..8 {
            count = self.machine.add(count, 1)?;
            if count > 26 {
                count = 1;
            }
            let value = self.machine.add(64, count)?;
            self.machine.set_field(message, slot, value)?;
        }
        self.machine.set_field(task, 12, count)?;
        self.queue(identity, message)
    }

    fn handler(
        &mut self,
        identity: usize,
        task: Handle,
        message: Handle,
    ) -> Outcome<Option<usize>> {
        if message != self.null {
            let slot = if self.machine.field(message, 2)? == 1001 {
                3
            } else {
                4
            };
            let old = self.machine.link(task, slot)?;
            let queue = self.append(message, old)?;
            self.machine.set_link(task, slot, queue)?;
        }
        let work = self.machine.link(task, 3)?;
        if work == self.null {
            return self.wait(identity);
        }
        let count = self.machine.field(work, 3)?;
        if count >= 4 {
            let next = self.machine.link(work, 0)?;
            self.machine.set_link(task, 3, next)?;
            return self.queue(identity, work);
        }
        self.dispatch_work(identity, task, (work, count))
    }

    fn dispatch_work(
        &mut self,
        identity: usize,
        task: Handle,
        work: (Handle, i64),
    ) -> Outcome<Option<usize>> {
        let device = self.machine.link(task, 4)?;
        if device == self.null {
            return self.wait(identity);
        }
        let next = self.machine.link(device, 0)?;
        self.machine.set_link(task, 4, next)?;
        let (work, count) = work;
        let slot = u8::try_from(count.wrapping_add(4)).unwrap_or_default();
        let value = self.machine.field(work, slot)?;
        self.machine.set_field(device, 3, value)?;
        let count = self.machine.add(count, 1)?;
        self.machine.set_field(work, 3, count)?;
        self.queue(identity, device)
    }
}
