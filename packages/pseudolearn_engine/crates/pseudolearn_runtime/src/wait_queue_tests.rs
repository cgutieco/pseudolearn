use crate::TaskId;
use crate::wait_queue::WaitQueue;

#[test]
fn waiting_order_is_fifo_and_cancellation_removes_every_registration() {
    let mut queue = WaitQueue::default();
    assert_eq!(queue.pop(), None);
    queue.push(TaskId(9), 1);
    queue.push(TaskId(1), 2);
    queue.push(TaskId(9), 3);
    queue.remove(TaskId(9));
    assert_eq!(queue.pop(), Some((TaskId(1), 2)));
    assert_eq!(queue.pop(), None);
}
