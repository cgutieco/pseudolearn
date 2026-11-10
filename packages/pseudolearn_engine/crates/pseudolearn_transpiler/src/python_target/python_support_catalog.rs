use super::python_expressions::python_string;
use super::python_support_text::text_source;
use crate::target::TranspileRequest;

const VARIANTS: &str = r#"@dataclass(frozen=True)
class Some:
    value: object


@dataclass(frozen=True)
class Nothing:
    pass


@dataclass(frozen=True)
class Ok:
    value: object


@dataclass(frozen=True)
class Err:
    error: object"#;

const PROPAGATION: &str = r#"class Propagation(Exception):
    def __init__(self, result):
        super().__init__()
        self.result = result


def propagate(value):
    if isinstance(value, Some) or isinstance(value, Ok):
        return value.value
    raise Propagation(value)"#;

const TASKS: &str = r#"class TaskScope:
    def __init__(self):
        self.children = []
        self.failed = False
        self.first = None
        self.associated = []
        self.cancelled = 0
        self.owner = asyncio.current_task()
        self.in_body = True

    def absorb(self):
        asyncio.current_task().uncancel()

    def close_body(self):
        self.in_body = False

    def spawn(self, work):
        task = asyncio.ensure_future(work)
        self.children.append(task)
        return task

    def spawn_fallible(self, work):
        async def guarded():
            result = await work
            if isinstance(result, Err):
                self.fail(result.error)
                return None
            return result.value
        return self.spawn(guarded())

    def fail(self, error):
        if self.failed:
            self.associated.append(error)
            return
        self.failed = True
        self.first = error
        current = asyncio.current_task()
        for child in self.children:
            if child is not current and not child.done() and child.cancel():
                self.cancelled += 1
        if self.in_body and self.owner is not current:
            self.in_body = False
            self.owner.cancel()

    async def join(self):
        for child in self.children:
            try:
                await child
            except asyncio.CancelledError:
                pass

    def report(self, record):
        if not self.failed:
            return Nothing()
        return Some(record(self.first, list(self.associated), self.cancelled))


async def as_task(function, *arguments):
    return function(*arguments)"#;

const CHANNEL: &str = r#"def wake_one(waiters):
    while waiters:
        waiter = waiters.popleft()
        if not waiter.done():
            waiter.set_result(None)
            return


class Channel:
    def __init__(self, capacity):
        self.buffer = collections.deque()
        self.capacity = capacity
        self.closed = False
        self.receivers = collections.deque()
        self.senders = collections.deque()

    async def send(self, value):
        while True:
            if self.closed:
                return False
            if len(self.buffer) < self.capacity:
                self.buffer.append(value)
                wake_one(self.receivers)
                return True
            waiter = asyncio.get_running_loop().create_future()
            self.senders.append(waiter)
            await waiter

    async def receive(self):
        while True:
            if self.buffer:
                value = self.buffer.popleft()
                wake_one(self.senders)
                return Some(value)
            if self.closed:
                return Nothing()
            waiter = asyncio.get_running_loop().create_future()
            self.receivers.append(waiter)
            await waiter

    def close(self):
        self.closed = True
        while self.receivers:
            wake_one(self.receivers)
        while self.senders:
            wake_one(self.senders)"#;

const SELECT: &str = r#"async def select_receive(channels):
    while True:
        for position, channel in enumerate(channels):
            if channel.buffer:
                value = channel.buffer.popleft()
                wake_one(channel.senders)
                return position, Some(value)
            if channel.closed:
                return position, Nothing()
        waiter = asyncio.get_running_loop().create_future()
        for channel in channels:
            channel.receivers.append(waiter)
        await waiter"#;

const REAL_TEXT: &str = r#"def real_text(value):
    text = format(decimal.Decimal(repr(value)), "f")
    return text if "." in text else text + ".0""#;

const FINITE: &str = r#"def finite(value):
    if not math.isfinite(value):
        raise ArithmeticError("nonFiniteRealResult")
    return value"#;

const INT_DIVIDE: &str = r#"def int_divide(dividend, divisor):
    if divisor == 0:
        raise ZeroDivisionError("divisionByZero")
    quotient = abs(dividend) // abs(divisor)
    return quotient if (dividend < 0) == (divisor < 0) else -quotient"#;

const INT_MODULO: &str = r#"def int_modulo(dividend, divisor):
    return dividend - divisor * int_divide(dividend, divisor)"#;

const INT_POWER: &str = r#"def int_power(base, exponent):
    if exponent < 0:
        raise ArithmeticError("negativeExponent")
    return base ** exponent"#;

const REAL_POWER: &str = r#"def real_power(base, exponent):
    return finite(math.pow(base, exponent))"#;

const COUNTED_RANGE: &str = r#"def counted_range(start, end, step):
    if step == 0:
        raise ValueError("zeroStepInCountedLoop")
    current = start
    while (step > 0 and current <= end) or (step < 0 and current >= end):
        yield current
        current += step"#;

const INDEX: &str = r#"def index(position):
    if position < 0:
        raise IndexError("arrayIndexOutOfRange")
    return position"#;

pub(crate) fn dependencies(name: &str) -> &'static [&'static str] {
    match name {
        "variants" => &["dataclass"],
        "propagation" => &["variants"],
        "tasks" => &["asyncio", "variants"],
        "channel" => &["tasks", "collections", "variants"],
        "select" => &["channel"],
        "real_text" => &["decimal"],
        "finite" | "real_power" => &["math", "finite"],
        "int_modulo" => &["int_divide"],
        "read_integer" => &["read_line", "re"],
        "read_real" => &["read_line", "math"],
        "read_text" | "read_character" | "read_boolean" => &["read_line"],
        "round_half_away" => &["decimal", "truncate"],
        "floor" | "ceiling" => &["math", "truncate"],
        "text_to_integer" => &["re"],
        "text_to_real" => &["math"],
        "collection_text" => &["real_text", "boolean_text"],
        "text_position" | "dictionary_find" | "dictionary_remove" | "vector_index_of" => {
            &["variants"]
        }
        "random" => &["time"],
        _ => &[],
    }
}

pub(crate) fn source(name: &str, request: &TranspileRequest) -> String {
    let (truth, falsity) = (request.truth, request.falsity);
    match name {
        "boolean_text" => {
            format!(
                "def boolean_text(value):\n    return {} if value else {}",
                python_string(truth),
                python_string(falsity)
            )
        }
        "read_boolean" => format!(
            "def read_boolean():\n    while True:\n        text = read_line().strip()\n        if text == {}:\n            return True\n        if text == {}:\n            return False",
            python_string(truth),
            python_string(falsity)
        ),
        "random" => {
            let seed = request
                .seed
                .map_or_else(|| "time.time_ns()".to_owned(), |seed| seed.to_string());
            text_source("random").replace("SEED", &seed)
        }
        other => fixed(other).map_or_else(|| text_source(other), str::to_owned),
    }
}

fn fixed(name: &str) -> Option<&'static str> {
    Some(match name {
        "variants" => VARIANTS,
        "propagation" => PROPAGATION,
        "tasks" => TASKS,
        "channel" => CHANNEL,
        "select" => SELECT,
        "real_text" => REAL_TEXT,
        "finite" => FINITE,
        "int_divide" => INT_DIVIDE,
        "int_modulo" => INT_MODULO,
        "int_power" => INT_POWER,
        "real_power" => REAL_POWER,
        "counted_range" => COUNTED_RANGE,
        "index" => INDEX,
        _ => return None,
    })
}
