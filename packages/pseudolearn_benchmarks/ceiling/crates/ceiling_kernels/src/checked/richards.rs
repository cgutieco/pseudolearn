use crate::machine::{Handle, Machine, Outcome, Shape, Trap};

pub(super) const PACKET: Shape = Shape { links: 1, words: 7 };
pub(super) const TASK: Shape = Shape { links: 6, words: 9 };

pub(super) struct Scheduler<'scope, Implementation: Machine> {
    pub(super) machine: &'scope mut Implementation,
    pub(super) tasks: [Handle; 7],
    pub(super) held: i64,
    pub(super) queued: i64,
    pub(super) null: Handle,
}

impl<Implementation: Machine> Scheduler<'_, Implementation> {
    pub(super) fn task(&self, identity: usize) -> Outcome<Handle> {
        self.tasks.get(identity).copied().ok_or(Trap::InvalidHandle)
    }

    fn packet(&mut self, queue: Handle, identity: i64, kind: i64) -> Outcome<Handle> {
        let packet = self.machine.object(PACKET)?;
        self.machine.set_link(packet, 0, queue)?;
        self.machine.set_field(packet, 1, identity)?;
        self.machine.set_field(packet, 2, kind)?;
        Ok(packet)
    }

    fn create_task(&mut self, identity: usize, setup: (i64, Handle), kind: i64) -> Outcome<()> {
        let task = self.machine.object(TASK)?;
        let (priority, queue) = setup;
        let previous = self.task(0)?;
        self.machine.set_link(task, 0, previous)?;
        self.machine.set_link(task, 1, queue)?;
        for slot in 2..6 {
            self.machine.set_link(task, slot, self.null)?;
        }
        for (slot, value) in [
            (6, priority),
            (7, i64::from(queue != self.null)),
            (8, i64::from(queue != self.null || kind == 4)),
            (9, 0),
            (10, kind),
            (11, 1),
            (12, 0),
            (13, 3),
        ] {
            self.machine.set_field(task, slot, value)?;
        }
        self.tasks
            .get_mut(identity)
            .ok_or(Trap::InvalidHandle)?
            .clone_from(&task);
        self.tasks
            .get_mut(0)
            .ok_or(Trap::InvalidHandle)?
            .clone_from(&task);
        Ok(())
    }

    pub(super) fn append(&mut self, packet: Handle, queue: Handle) -> Outcome<Handle> {
        self.machine.set_link(packet, 0, self.null)?;
        if queue == self.null {
            return Ok(packet);
        }
        let mut tail = queue;
        loop {
            let next = self.machine.link(tail, 0)?;
            if next == self.null {
                break;
            }
            tail = next;
        }
        self.machine.set_link(tail, 0, packet)?;
        Ok(queue)
    }

    pub(super) fn wait(&mut self, identity: usize) -> Outcome<Option<usize>> {
        let task = self.task(identity)?;
        self.machine.set_field(task, 8, 1)?;
        Ok(Some(identity))
    }

    pub(super) fn hold(&mut self, identity: usize) -> Outcome<Option<usize>> {
        self.held = self.machine.add(self.held, 1)?;
        let task = self.task(identity)?;
        self.machine.set_field(task, 9, 1)?;
        let next = self.machine.link(task, 0)?;
        Ok(self
            .tasks
            .iter()
            .position(|candidate| *candidate == next)
            .filter(|found| *found != 0))
    }

    pub(super) fn release(&mut self, identity: usize, target: usize) -> Outcome<Option<usize>> {
        let task = self.task(target)?;
        self.machine.set_field(task, 9, 0)?;
        let priority = self.machine.field(task, 6)?;
        let current = self.task(identity)?;
        let previous = self.machine.field(current, 6)?;
        Ok(Some(if priority > previous {
            target
        } else {
            identity
        }))
    }

    pub(super) fn queue(&mut self, identity: usize, packet: Handle) -> Outcome<Option<usize>> {
        let target = self.machine.field(packet, 1)?;
        let target = usize::try_from(target).map_err(|_| Trap::InvalidHandle)?;
        self.queued = self.machine.add(self.queued, 1)?;
        self.machine.set_link(packet, 0, self.null)?;
        self.machine.set_field(
            packet,
            1,
            i64::try_from(identity).map_err(|_| Trap::InvalidHandle)?,
        )?;
        let task = self.task(target)?;
        let input = self.machine.link(task, 1)?;
        if input != self.null {
            self.append(packet, input)?;
            return Ok(Some(identity));
        }
        self.machine.set_link(task, 1, packet)?;
        self.machine.set_field(task, 7, 1)?;
        let priority = self.machine.field(task, 6)?;
        let current = self.task(identity)?;
        let previous = self.machine.field(current, 6)?;
        Ok(Some(if priority > previous {
            target
        } else {
            identity
        }))
    }

    fn setup(&mut self, size: i64) -> Outcome<()> {
        self.create_task(1, (1, self.null), 1)?;
        let idle = self.task(1)?;
        self.machine.set_field(idle, 12, size)?;
        let queue = self.packet(self.null, 0, 1001)?;
        let queue = self.packet(queue, 0, 1001)?;
        self.create_task(2, (1000, queue), 2)?;
        for (identity, device, priority) in [(3, 5, 2000), (4, 6, 3000)] {
            let mut queue = self.null;
            for _ in 0..3 {
                queue = self.packet(queue, device, 1000)?;
            }
            self.create_task(identity, (priority, queue), 3)?;
        }
        self.create_task(5, (4000, self.null), 4)?;
        self.create_task(6, (5000, self.null), 4)
    }

    fn schedule(&mut self) -> Outcome<()> {
        let mut current = Some(6);
        while let Some(identity) = current {
            let task = self.task(identity)?;
            let pending = self.machine.field(task, 7)? != 0;
            let waiting = self.machine.field(task, 8)? != 0;
            let holding = self.machine.field(task, 9)? != 0;
            if holding || (!pending && waiting) {
                let next = self.machine.link(task, 0)?;
                current = self
                    .tasks
                    .iter()
                    .position(|candidate| *candidate == next)
                    .filter(|found| *found != 0);
            } else {
                current = self.run_task(identity)?;
            }
            self.machine.tick();
        }
        self.machine.settle()
    }
}

pub fn run<Implementation: Machine>(machine: &mut Implementation, size: i64) -> Outcome<String> {
    let null = machine.object(Shape { links: 0, words: 0 })?;
    let mut scheduler = Scheduler {
        machine,
        tasks: [null; 7],
        held: 0,
        queued: 0,
        null,
    };
    scheduler.setup(size)?;
    scheduler.schedule()?;
    Ok(format!("{} {}", scheduler.queued, scheduler.held))
}
