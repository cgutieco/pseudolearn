pub(crate) const TASKS: &str = r#"type TaskFuture = Pin<Box<dyn Future<Output = ()>>>;

struct TaskSlot {
    future: Option<TaskFuture>,
    parent: usize,
    cancelled: bool,
    finished: bool,
}

thread_local! {
    static READY: RefCell<VecDeque<usize>> = RefCell::new(VecDeque::new());
    static TASKS: RefCell<Vec<TaskSlot>> = RefCell::new(Vec::new());
    static CURRENT: std::cell::Cell<usize> = std::cell::Cell::new(usize::MAX);
    static TIMERS: RefCell<Vec<(std::time::Instant, usize, Waker)>> = RefCell::new(Vec::new());
}

struct TaskWaker(usize);

impl Wake for TaskWaker {
    fn wake(self: Arc<Self>) {
        READY.with(|ready| ready.borrow_mut().push_back(self.0));
    }
}

fn schedule(future: TaskFuture) -> usize {
    let parent = CURRENT.with(|current| current.get());
    let index = TASKS.with(|tasks| {
        let mut tasks = tasks.borrow_mut();
        tasks.push(TaskSlot { future: Some(future), parent, cancelled: false, finished: false });
        tasks.len() - 1
    });
    READY.with(|ready| ready.borrow_mut().push_back(index));
    index
}

fn run_tasks(algorithm: impl Future<Output = ()> + 'static) {
    schedule(Box::pin(algorithm));
    loop {
        while let Some(index) = READY.with(|ready| ready.borrow_mut().pop_front()) {
            poll_task(index);
        }
        if !wake_next_timers() {
            break;
        }
    }
    if TASKS.with(|tasks| tasks.borrow().iter().any(|slot| !slot.finished)) {
        panic!("deadlock: every task is waiting");
    }
}

fn poll_task(index: usize) {
    let Some(mut future) = TASKS.with(|tasks| tasks.borrow_mut()[index].future.take()) else {
        return;
    };
    let waker = Waker::from(Arc::new(TaskWaker(index)));
    let previous = CURRENT.with(|current| current.replace(index));
    let polled = future.as_mut().poll(&mut Context::from_waker(&waker));
    CURRENT.with(|current| current.set(previous));
    let abandoned = cancelled_task(index) && !has_live_children(index);
    if polled.is_ready() || abandoned {
        TASKS.with(|tasks| tasks.borrow_mut()[index].finished = true);
        drop(future);
    } else {
        TASKS.with(|tasks| tasks.borrow_mut()[index].future = Some(future));
    }
}

fn current_task() -> usize {
    CURRENT.with(|current| current.get())
}

fn cancelled_task(index: usize) -> bool {
    TASKS.with(|tasks| tasks.borrow().get(index).is_some_and(|slot| slot.cancelled))
}

fn task_cancelled() -> bool {
    cancelled_task(current_task())
}

fn has_live_children(index: usize) -> bool {
    TASKS.with(|tasks| tasks.borrow().iter().any(|slot| slot.parent == index && !slot.finished))
}

fn cancel_task(index: usize) {
    let children: Option<Vec<usize>> = TASKS.with(|tasks| {
        let mut tasks = tasks.borrow_mut();
        let slot = tasks.get_mut(index).filter(|slot| !slot.finished && !slot.cancelled)?;
        slot.cancelled = true;
        let live = tasks.iter().enumerate().filter(|(_, slot)| slot.parent == index && !slot.finished);
        Some(live.map(|(child, _)| child).collect())
    });
    let Some(children) = children else {
        return;
    };
    READY.with(|ready| ready.borrow_mut().push_back(index));
    children.into_iter().for_each(cancel_task);
}

fn wake_next_timers() -> bool {
    let earliest = TIMERS.with(|timers| {
        let mut timers = timers.borrow_mut();
        timers.retain(|(_, owner, _)| TASKS.with(|tasks| tasks.borrow().get(*owner).is_some_and(|slot| !slot.finished)));
        timers.iter().map(|(deadline, _, _)| *deadline).min()
    });
    let Some(deadline) = earliest else {
        return false;
    };
    std::thread::sleep(deadline.saturating_duration_since(std::time::Instant::now()));
    let now = std::time::Instant::now();
    let due: Vec<Waker> = TIMERS.with(|timers| {
        let mut timers = timers.borrow_mut();
        let (due, waiting): (Vec<_>, Vec<_>) = timers.drain(..).partition(|(deadline, _, _)| *deadline <= now);
        *timers = waiting;
        due.into_iter().map(|(_, _, waker)| waker).collect()
    });
    due.into_iter().for_each(Waker::wake);
    true
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
            Some(value) if !task_cancelled() => Poll::Ready(value.clone()),
            _ => {
                state.waiters.push(context.waker().clone());
                Poll::Pending
            }
        }
    }
}

struct Finish(Task<()>);

impl Drop for Finish {
    fn drop(&mut self) {
        let running = self.0.state.borrow().result.is_none();
        if running {
            self.0.complete(());
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
        let (result, finish) = (task.clone(), Finish(finished.clone()));
        let index = schedule(Box::pin(async move {
            let _finish = finish;
            result.complete(work.await);
        }));
        self.children.borrow_mut().push((index, finished));
        task
    }

    fn spawn_fallible<T: Clone + 'static>(&self, work: impl Future<Output = Result<T, E>> + 'static) -> Task<T> {
        let task = Task::pending();
        let finished = Task::pending();
        let (result, finish) = (task.clone(), Finish(finished.clone()));
        let (children, failure) = (Rc::clone(&self.children), Rc::clone(&self.failure));
        let index = schedule(Box::pin(async move {
            let _finish = finish;
            match work.await {
                Ok(value) => result.complete(value),
                Err(error) => record_task_failure(&children, &failure, error),
            }
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
    let current = current_task();
    let live: Vec<(usize, Task<()>)> = children.borrow().clone();
    for (index, done) in live {
        if index == current || done.state.borrow().result.is_some() {
            continue;
        }
        cancel_task(index);
        failure.borrow_mut().cancelled += 1;
    }
}"#;
