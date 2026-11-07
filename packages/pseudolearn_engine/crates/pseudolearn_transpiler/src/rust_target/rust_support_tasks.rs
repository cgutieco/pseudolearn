pub(crate) const TASKS: &str = r#"type TaskFuture = Pin<Box<dyn Future<Output = ()>>>;

thread_local! {
    static READY: RefCell<VecDeque<usize>> = RefCell::new(VecDeque::new());
    static TASKS: RefCell<Vec<Option<TaskFuture>>> = RefCell::new(Vec::new());
}

struct TaskWaker(usize);

impl Wake for TaskWaker {
    fn wake(self: Arc<Self>) {
        READY.with(|ready| ready.borrow_mut().push_back(self.0));
    }
}

fn schedule(future: TaskFuture) {
    let index = TASKS.with(|tasks| {
        let mut tasks = tasks.borrow_mut();
        tasks.push(Some(future));
        tasks.len() - 1
    });
    READY.with(|ready| ready.borrow_mut().push_back(index));
}

fn run_tasks(algorithm: impl Future<Output = ()> + 'static) {
    schedule(Box::pin(algorithm));
    while let Some(index) = READY.with(|ready| ready.borrow_mut().pop_front()) {
        let Some(mut future) = TASKS.with(|tasks| tasks.borrow_mut()[index].take()) else {
            continue;
        };
        let waker = Waker::from(Arc::new(TaskWaker(index)));
        if future.as_mut().poll(&mut Context::from_waker(&waker)).is_pending() {
            TASKS.with(|tasks| tasks.borrow_mut()[index] = Some(future));
        }
    }
    if TASKS.with(|tasks| tasks.borrow().iter().any(Option::is_some)) {
        panic!("deadlock: every task is waiting");
    }
}

struct TaskState<T> {
    result: Option<T>,
    waiters: Vec<Waker>,
}

struct Task<T> {
    state: Rc<RefCell<TaskState<T>>>,
}

impl<T> Clone for Task<T> {
    fn clone(&self) -> Self {
        Task { state: Rc::clone(&self.state) }
    }
}

impl<T> Task<T> {
    fn pending() -> Self {
        Task { state: Rc::new(RefCell::new(TaskState { result: None, waiters: Vec::new() })) }
    }

    fn complete(&self, value: T) {
        let waiters = {
            let mut state = self.state.borrow_mut();
            state.result = Some(value);
            std::mem::take(&mut state.waiters)
        };
        waiters.into_iter().for_each(Waker::wake);
    }
}

impl<T: Clone> Future for Task<T> {
    type Output = T;

    fn poll(self: Pin<&mut Self>, context: &mut Context<'_>) -> Poll<T> {
        let mut state = self.state.borrow_mut();
        match &state.result {
            Some(value) => Poll::Ready(value.clone()),
            None => {
                state.waiters.push(context.waker().clone());
                Poll::Pending
            }
        }
    }
}

struct TaskScope {
    children: RefCell<Vec<Task<()>>>,
}

impl TaskScope {
    fn new() -> Self {
        TaskScope { children: RefCell::new(Vec::new()) }
    }

    fn spawn<T: Clone + 'static>(&self, work: impl Future<Output = T> + 'static) -> Task<T> {
        let task = Task::pending();
        let finished = Task::pending();
        let (result, done) = (task.clone(), finished.clone());
        schedule(Box::pin(async move {
            result.complete(work.await);
            done.complete(());
        }));
        self.children.borrow_mut().push(finished);
        task
    }

    async fn join(&self) {
        let children = self.children.borrow().clone();
        for child in children {
            child.await;
        }
    }
}"#;

pub(crate) const CHANNEL: &str = r#"struct ChannelState<T> {
    buffer: VecDeque<T>,
    capacity: usize,
    closed: bool,
    receivers: VecDeque<Waker>,
    senders: VecDeque<Waker>,
}

struct Channel<T> {
    state: Rc<RefCell<ChannelState<T>>>,
}

impl<T> Clone for Channel<T> {
    fn clone(&self) -> Self {
        Channel { state: Rc::clone(&self.state) }
    }
}

impl<T> Channel<T> {
    fn new(capacity: i64) -> Self {
        let state = ChannelState {
            buffer: VecDeque::new(),
            capacity: capacity as usize,
            closed: false,
            receivers: VecDeque::new(),
            senders: VecDeque::new(),
        };
        Channel { state: Rc::new(RefCell::new(state)) }
    }

    async fn send(&self, value: T) -> bool {
        let mut pending = Some(value);
        std::future::poll_fn(|context| {
            let mut state = self.state.borrow_mut();
            if state.closed {
                return Poll::Ready(false);
            }
            if state.buffer.len() < state.capacity {
                if let Some(value) = pending.take() {
                    state.buffer.push_back(value);
                }
                if let Some(receiver) = state.receivers.pop_front() {
                    receiver.wake();
                }
                return Poll::Ready(true);
            }
            state.senders.push_back(context.waker().clone());
            Poll::Pending
        })
        .await
    }

    async fn receive(&self) -> Option<T> {
        std::future::poll_fn(|context| {
            let mut state = self.state.borrow_mut();
            if let Some(value) = state.buffer.pop_front() {
                if let Some(sender) = state.senders.pop_front() {
                    sender.wake();
                }
                return Poll::Ready(Some(value));
            }
            if state.closed {
                return Poll::Ready(None);
            }
            state.receivers.push_back(context.waker().clone());
            Poll::Pending
        })
        .await
    }

    fn close(&self) {
        let waiters: Vec<Waker> = {
            let mut state = self.state.borrow_mut();
            state.closed = true;
            let mut waiters: Vec<Waker> = state.receivers.drain(..).collect();
            waiters.extend(state.senders.drain(..));
            waiters
        };
        waiters.into_iter().for_each(Waker::wake);
    }
}"#;
