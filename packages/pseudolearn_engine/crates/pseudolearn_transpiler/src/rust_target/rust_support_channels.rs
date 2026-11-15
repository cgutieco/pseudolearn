pub(crate) const SELECT: &str = r#"async fn select_receive<T>(channels: &[Channel<T>]) -> (usize, Option<T>) {
    std::future::poll_fn(|context| {
        if task_cancelled() {
            return Poll::Pending;
        }
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
            if task_cancelled() {
                return Poll::Pending;
            }
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
            if task_cancelled() {
                return Poll::Pending;
            }
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

pub(crate) const CANCELLATION: &str = r#"async fn until_cancelled<T>(future: impl Future<Output = T>) -> Option<T> {
    let mut future = std::pin::pin!(future);
    std::future::poll_fn(|context| {
        let polled = future.as_mut().poll(context);
        if !task_cancelled() {
            return polled.map(Some);
        }
        if has_live_children(current_task()) { Poll::Pending } else { Poll::Ready(None) }
    })
    .await
}

async fn unwound<T>() -> T {
    std::future::pending::<T>().await
}"#;

pub(crate) const SLEEP_UNTIL: &str = r#"async fn sleep_until(deadline: std::time::Instant) {
    let mut registered = false;
    std::future::poll_fn(|context| {
        if task_cancelled() {
            return Poll::Pending;
        }
        if registered && std::time::Instant::now() >= deadline {
            return Poll::Ready(());
        }
        registered = true;
        TIMERS.with(|timers| timers.borrow_mut().push((deadline, current_task(), context.waker().clone())));
        Poll::Pending
    })
    .await
}"#;
