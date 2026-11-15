use super::RustEmitter;
use pseudolearn_semantic::collection_model::{CollectionAction, CollectionExpression};

impl RustEmitter<'_, '_> {
    pub(crate) fn collection_operation(&mut self, collection: &CollectionExpression) -> String {
        self.uses.insert("rc");
        let keyed = self
            .view
            .module
            .collections
            .get(&collection.class)
            .is_some_and(|entry| entry.key.is_some());
        let receiver = collection
            .receiver
            .map(|receiver| self.operand(receiver, 10))
            .unwrap_or_default();
        let arguments = collection
            .arguments
            .iter()
            .map(|argument| self.value(*argument))
            .collect::<Vec<_>>();
        self.collection_call((&collection.action, keyed), (&receiver, &arguments))
    }

    pub(crate) fn collection_call(
        &mut self,
        (action, keyed): (&CollectionAction, bool),
        (receiver, arguments): (&str, &[String]),
    ) -> String {
        let first = arguments.first().cloned().unwrap_or_default();
        let second = arguments.get(1).cloned().unwrap_or_default();
        match (action, keyed) {
            (CollectionAction::New, keyed) => self.new_collection(keyed),
            (CollectionAction::Length, _) => format!("{receiver}.borrow().len() as i64"),
            (CollectionAction::Append, _) => self.mutation(receiver, "push", &[first]),
            (CollectionAction::Insert, false) => {
                self.mutation(receiver, "insert", &[format!("{first} as usize"), second])
            }
            (CollectionAction::Insert, true) => self.mutation(receiver, "set", &[first, second]),
            (CollectionAction::Remove, false) => {
                format!(
                    "{{ {}; }}",
                    self.mutation(receiver, "remove", &[format!("{first} as usize")])
                )
            }
            _ => self.collection_call_rest((action, keyed), (receiver, arguments)),
        }
    }

    fn collection_call_rest(
        &mut self,
        (action, keyed): (&CollectionAction, bool),
        (receiver, arguments): (&str, &[String]),
    ) -> String {
        let first = arguments.first().cloned().unwrap_or_default();
        match (action, keyed) {
            (CollectionAction::Remove, true) => {
                self.mutation(receiver, "remove", &[format!("&{first}")])
            }
            (CollectionAction::Find, _) => format!("{receiver}.borrow().find(&{first})"),
            (CollectionAction::Sort, _) if arguments.is_empty() => format!(
                "{receiver}.borrow_mut().sort_by(|left, right| left.partial_cmp(right).unwrap())"
            ),
            (CollectionAction::Sort, _) => format!(
                "{{ let comparator = {first}; {receiver}.borrow_mut().sort_by(|left, right| comparator(left.clone(), right.clone()).cmp(&0)) }}"
            ),
            (CollectionAction::Reverse, _) => format!("{receiver}.borrow_mut().reverse()"),
            (CollectionAction::IndexOf, _) => format!(
                "{receiver}.borrow().iter().position(|entry| *entry == {first}).map(|position| position as i64)"
            ),
            (CollectionAction::Contains, _) => format!("{receiver}.borrow().contains(&{first})"),
            (CollectionAction::Keys, _) => {
                format!("Rc::new(RefCell::new({receiver}.borrow().keys()))")
            }
            _ => String::new(),
        }
    }

    pub(crate) fn new_collection(&mut self, keyed: bool) -> String {
        if !keyed {
            return "Rc::new(RefCell::new(Vec::new()))".to_owned();
        }
        self.require("dictionary");
        "Rc::new(RefCell::new(Dictionary::default()))".to_owned()
    }

    pub(crate) fn mutation(&self, receiver: &str, method: &str, arguments: &[String]) -> String {
        let joined = arguments.join(", ");
        if joined.contains(".borrow") {
            let names = (0..arguments.len())
                .map(|position| format!("argument{position}"))
                .collect::<Vec<_>>();
            let bindings = names
                .iter()
                .zip(arguments)
                .map(|(name, text)| format!("let {name} = {text};"))
                .collect::<Vec<_>>()
                .join(" ");
            return format!(
                "{{ {bindings} {receiver}.borrow_mut().{method}({}) }}",
                names.join(", ")
            );
        }
        format!("{receiver}.borrow_mut().{method}({joined})")
    }
}
