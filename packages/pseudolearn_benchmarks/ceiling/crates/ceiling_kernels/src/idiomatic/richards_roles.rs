use super::richards::{HANDLER_A, HANDLER_B, Role, Scheduler, WORK};

impl Scheduler {
    pub(super) fn handler(&mut self, identity: usize, message: Option<usize>) -> Option<usize> {
        let Some(Some(Role::Handler {
            mut work,
            mut device,
        })) = self
            .tasks
            .get(identity)
            .map(|task| task.map(|task| task.role))
        else {
            return Some(identity);
        };
        if let Some(packet) = message {
            if self
                .packets
                .get(packet)
                .is_some_and(|value| value.kind == WORK)
            {
                work = Some(self.append(packet, work));
            } else {
                device = Some(self.append(packet, device));
            }
        }
        let outcome = self.dispatch_work(identity, &mut work, &mut device);
        if let Some(Some(task)) = self.tasks.get_mut(identity) {
            task.role = Role::Handler { work, device };
        }
        outcome
    }

    fn dispatch_work(
        &mut self,
        identity: usize,
        work: &mut Option<usize>,
        device: &mut Option<usize>,
    ) -> Option<usize> {
        let Some(current) = *work else {
            return self.wait(identity);
        };
        let count = self.packets.get(current).map_or(0, |value| value.datum);
        if count >= 4 {
            *work = self.link_of(current);
            return self.queue(identity, current);
        }
        let Some(target) = *device else {
            return self.wait(identity);
        };
        *device = self.link_of(target);
        let slot = usize::try_from(count).unwrap_or_default();
        let value = self
            .packets
            .get(current)
            .and_then(|packet| packet.payload.get(slot).copied())
            .unwrap_or_default();
        if let Some(packet) = self.packets.get_mut(target) {
            packet.datum = value;
        }
        if let Some(packet) = self.packets.get_mut(current) {
            packet.datum = count.wrapping_add(1);
        }
        self.queue(identity, target)
    }

    pub(super) fn worker(&mut self, identity: usize, message: Option<usize>) -> Option<usize> {
        let Some(packet) = message else {
            return self.wait(identity);
        };
        let Some(Some(Role::Worker {
            destination,
            mut count,
        })) = self
            .tasks
            .get(identity)
            .map(|task| task.map(|task| task.role))
        else {
            return Some(identity);
        };
        let target = if destination == HANDLER_A {
            HANDLER_B
        } else {
            HANDLER_A
        };
        let payload = payload(&mut count);
        if let Some(value) = self.packets.get_mut(packet) {
            value.identity = target;
            value.datum = 0;
            value.payload = payload;
        }
        if let Some(Some(task)) = self.tasks.get_mut(identity) {
            task.role = Role::Worker {
                destination: target,
                count,
            };
        }
        self.queue(identity, packet)
    }
}

fn payload(count: &mut i64) -> [i64; 4] {
    std::array::from_fn(|_| {
        *count = if *count >= 26 {
            1
        } else {
            count.wrapping_add(1)
        };
        64_i64.wrapping_add(*count)
    })
}
