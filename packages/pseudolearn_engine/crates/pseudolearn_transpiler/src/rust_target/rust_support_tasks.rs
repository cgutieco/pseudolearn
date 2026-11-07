pub(crate) const TASKS: &str = r#"type TaskFuture = Pin<Box<dyn Future<Output = ()>>>;

thread_local! {
    static READY: RefCell<VecDeque<usize>> = RefCell::new(VecDeque::new());
    static TASKS: RefCell<Vec<Option<TaskFuture>>> = RefCell::new(Vec::new());
    static CURRENT: std::cell::Cell<usize> = std::cell::Cell::new(usize::MAX);
}

struct TaskWaker(usize);

impl Wake for TaskWaker {
    fn wake(self: Arc<Self>) {
        READY.with(|ready| ready.borrow_mut().push_back(self.0));
    }
}

fn schedule(future: TaskFuture) -> usize {
    let index = TASKS.with(|tasks| {
        let mut tasks = tasks.borrow_mut();
        tasks.push(Some(future));
        tasks.len() - 1
    });
    READY.with(|ready| ready.borrow_mut().push_back(index));
    index
}

fn run_tasks(algorithm: impl Future<Output = ()> + 'static) {
    schedule(Box::pin(algorithm));
    while let Some(index) = READY.with(|ready| ready.borrow_mut().pop_front()) {
        let Some(mut future) = TASKS.with(|tasks| tasks.borrow_mut()[index].take()) else {
            continue;
        };
        let waker = Waker::from(Arc::new(TaskWaker(index)));
        CURRENT.with(|current| current.set(index));
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

struct ScopeFailure<E> {
    owner: Option<Waker>,
    first: Option<E>,
    associated: Vec<E>,
    cancelled: i64,
}

struct TaskScope<E> {
    children: Rc<RefCell<Vec<(usize, Task<()>)>>>,
    failure: Rc<RefCell<ScopeFailure<E>>>,
}

impl<E: Clone + 'static> TaskScope<E> {
    fn new() -> Self {
        let failure = ScopeFailure { owner: None, first: None, associated: Vec::new(), cancelled: 0 };
        TaskScope { children: Rc::new(RefCell::new(Vec::new())), failure: Rc::new(RefCell::new(failure)) }
    }

    fn spawn<T: Clone + 'static>(&self, work: impl Future<Output = T> + 'static) -> Task<T> {
        let task = Task::pending();
        let finished = Task::pending();
        let (result, done) = (task.clone(), finished.clone());
        let index = schedule(Box::pin(async move {
            result.complete(work.await);
            done.complete(());
        }));
        self.children.borrow_mut().push((index, finished));
        task
    }

    fn spawn_fallible<T: Clone + 'static>(&self, work: impl Future<Output = Result<T, E>> + 'static) -> Task<T> {
        let task = Task::pending();
        let finished = Task::pending();
        let (result, done) = (task.clone(), finished.clone());
        let (children, failure) = (Rc::clone(&self.children), Rc::clone(&self.failure));
        let index = schedule(Box::pin(async move {
            match work.await {
                Ok(value) => result.complete(value),
                Err(error) => record_task_failure(&children, &failure, error),
            }
            done.complete(());
        }));
        self.children.borrow_mut().push((index, finished));
        task
    }

    async fn run_body(&self, body: impl Future<Output = ()>) {
        let mut body = std::pin::pin!(body);
        std::future::poll_fn(|context| {
            if self.failure.borrow().first.is_some() {
                return Poll::Ready(());
            }
            let polled = body.as_mut().poll(context);
            self.failure.borrow_mut().owner = Some(context.waker().clone());
            polled
        })
        .await
    }

    async fn join(&self) {
        let children = self.children.borrow().clone();
        for (_, child) in children {
            child.await;
        }
    }

    fn report(&self) -> Option<(E, Vec<E>, i64)> {
        let failure = self.failure.borrow();
        failure.first.clone().map(|first| (first, failure.associated.clone(), failure.cancelled))
    }
}

fn record_task_failure<E>(children: &Rc<RefCell<Vec<(usize, Task<()>)>>>, failure: &Rc<RefCell<ScopeFailure<E>>>, error: E) {
    if failure.borrow().first.is_some() {
        failure.borrow_mut().associated.push(error);
        return;
    }
    failure.borrow_mut().first = Some(error);
    if let Some(owner) = failure.borrow_mut().owner.take() {
        owner.wake();
    }
    let current = CURRENT.with(|current| current.get());
    let live: Vec<(usize, Task<()>)> = children.borrow().clone();
    for (index, done) in live {
        if index == current || done.state.borrow().result.is_some() {
            continue;
        }
        let dropped = TASKS.with(|tasks| tasks.borrow_mut()[index].take());
        drop(dropped);
        done.complete(());
        failure.borrow_mut().cancelled += 1;
    }
}"#;

pub(crate) const SELECT: &str = r#"async fn select_receive<T>(channels: &[Channel<T>]) -> (usize, Option<T>) {
    std::future::poll_fn(|context| {
        for (index, channel) in channels.iter().enumerate() {
            let mut state = channel.state.borrow_mut();
            if let Some(value) = state.buffer.pop_front() {
                state.senders.drain(..).for_each(Waker::wake);
                return Poll::Ready((index, Some(value)));
            }
            if state.closed {
                return Poll::Ready((index, None));
            }
        }
        for channel in channels {
            channel.state.borrow_mut().receivers.push_back(context.waker().clone());
        }
        Poll::Pending
    })
    .await
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
                state.receivers.drain(..).for_each(Waker::wake);
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
                state.senders.drain(..).for_each(Waker::wake);
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
