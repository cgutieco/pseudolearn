pub(super) const WORK: i64 = 1001;
pub(super) const DEVICE_A: usize = 5;
pub(super) const DEVICE_B: usize = 6;
pub(super) const HANDLER_A: usize = 3;
pub(super) const HANDLER_B: usize = 4;

#[derive(Clone, Copy, Default)]
pub(super) struct Packet {
    pub(super) link: Option<usize>,
    pub(super) identity: usize,
    pub(super) kind: i64,
    pub(super) datum: i64,
    pub(super) payload: [i64; 4],
}

#[derive(Clone, Copy, PartialEq, Eq)]
pub(super) enum Role {
    Idle {
        control: i64,
        count: i64,
    },
    Worker {
        destination: usize,
        count: i64,
    },
    Handler {
        work: Option<usize>,
        device: Option<usize>,
    },
    Device {
        pending: Option<usize>,
    },
}

#[derive(Clone, Copy)]
pub(super) struct Task {
    pub(super) link: Option<usize>,
    pub(super) priority: i64,
    pub(super) input: Option<usize>,
    pub(super) pending: bool,
    pub(super) waiting: bool,
    pub(super) holding: bool,
    pub(super) role: Role,
}

#[derive(Default)]
pub(super) struct Scheduler {
    pub(super) packets: Vec<Packet>,
    pub(super) tasks: [Option<Task>; 7],
    pub(super) list: Option<usize>,
    pub(super) holds: u64,
    pub(super) queued: u64,
}

impl Scheduler {
    fn packet(&mut self, link: Option<usize>, identity: usize, kind: i64) -> Option<usize> {
        self.packets.push(Packet {
            link,
            identity,
            kind,
            ..Packet::default()
        });
        Some(self.packets.len().wrapping_sub(1))
    }

    fn task(&mut self, identity: usize, setup: (i64, Option<usize>), role: Role) {
        let (priority, input) = setup;
        let task = Task {
            link: self.list,
            priority,
            input,
            pending: input.is_some(),
            waiting: input.is_some() || matches!(role, Role::Device { .. }),
            holding: false,
            role,
        };
        if let Some(slot) = self.tasks.get_mut(identity) {
            *slot = Some(task);
        }
        self.list = Some(identity);
    }

    pub(super) fn link_of(&self, packet: usize) -> Option<usize> {
        self.packets.get(packet).and_then(|value| value.link)
    }

    pub(super) fn set_link(&mut self, packet: usize, link: Option<usize>) {
        if let Some(value) = self.packets.get_mut(packet) {
            value.link = link;
        }
    }

    pub(super) fn append(&mut self, packet: usize, queue: Option<usize>) -> usize {
        self.set_link(packet, None);
        let Some(head) = queue else {
            return packet;
        };
        let mut current = head;
        while let Some(next) = self.link_of(current) {
            current = next;
        }
        self.set_link(current, Some(packet));
        head
    }
}

pub fn run(size: usize) -> String {
    let mut scheduler = Scheduler::default();
    let cycles = i64::try_from(size).unwrap_or_default();
    scheduler.task(
        1,
        (1, None),
        Role::Idle {
            control: 1,
            count: cycles,
        },
    );
    let queue = scheduler.packet(None, 0, WORK);
    let queue = scheduler.packet(queue, 0, WORK);
    scheduler.task(
        2,
        (1000, queue),
        Role::Worker {
            destination: HANDLER_A,
            count: 0,
        },
    );
    for (identity, device, priority) in [(HANDLER_A, DEVICE_A, 2000), (HANDLER_B, DEVICE_B, 3000)] {
        let mut queue = None;
        for _ in 0..3 {
            queue = scheduler.packet(queue, device, 1000);
        }
        scheduler.task(
            identity,
            (priority, queue),
            Role::Handler {
                work: None,
                device: None,
            },
        );
    }
    scheduler.task(DEVICE_A, (4000, None), Role::Device { pending: None });
    scheduler.task(DEVICE_B, (5000, None), Role::Device { pending: None });
    scheduler.schedule();
    format!("{} {}", scheduler.queued, scheduler.holds)
}
