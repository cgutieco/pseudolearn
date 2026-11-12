use std::rc::Rc;

type List = Option<Rc<Element>>;

struct Element {
    next: List,
}

fn make(length: usize) -> List {
    (length > 0).then(|| {
        Rc::new(Element {
            next: make(length.wrapping_sub(1)),
        })
    })
}

fn next(list: &List) -> List {
    list.as_ref().and_then(|element| element.next.clone())
}

fn shorter(first: &List, second: &List) -> bool {
    let (mut first, mut second) = (first.clone(), second.clone());
    while second.is_some() {
        if first.is_none() {
            return true;
        }
        first = next(&first);
        second = next(&second);
    }
    false
}

fn tail(first: &List, second: &List, third: &List) -> List {
    if shorter(second, first) {
        let left = tail(&next(first), second, third);
        let middle = tail(&next(second), third, first);
        let right = tail(&next(third), first, second);
        return tail(&left, &middle, &right);
    }
    third.clone()
}

fn length(list: &List) -> u32 {
    let mut count = 0_u32;
    let mut current = list.clone();
    while current.is_some() {
        count = count.wrapping_add(1);
        current = next(&current);
    }
    count
}

pub fn run(size: usize) -> String {
    let result = tail(
        &make(size),
        &make(size.wrapping_sub(5)),
        &make(size.wrapping_sub(9)),
    );
    length(&result).to_string()
}
