use crate::service::project_campaign::catalogue::COUNTS;
use crate::service::project_campaign::shapes::constants;
use serde_json::{Value, json};

const FILES_PER_LOCKED_PACKAGE: usize = 3;

pub struct LockWorkload {
    pub name: String,
    pub packages: Vec<Value>,
}

impl LockWorkload {
    pub fn build_arguments(&self) -> Value {
        json!({"packages": self.packages})
    }

    pub fn resolve_arguments(&self, lock: &str) -> Value {
        json!({"lock": lock, "packages": self.packages})
    }

    pub fn bytes(&self) -> usize {
        self.packages
            .iter()
            .map(|package| package.to_string().len())
            .sum()
    }
}

fn package(index: usize, count: usize, locked: bool) -> Value {
    let name = format!("p{index}");
    let dependencies: Vec<String> = (index.saturating_add(1) < count)
        .then(|| format!("p{}", index.saturating_add(1)))
        .into_iter()
        .collect();
    let mut wire = json!({
        "name": name,
        "origin": format!("pkg/{name}"),
        "kind": if locked { "locked" } else { "local" },
        "dependencies": dependencies,
    });
    if let (true, Some(fields)) = (locked, wire.as_object_mut()) {
        let values = constants(
            FILES_PER_LOCKED_PACKAGE,
            3_000_u64.saturating_add(u64::try_from(index).unwrap_or(0)),
        );
        let files: Vec<Value> = values
            .iter()
            .enumerate()
            .map(|(position, value)| json!({"path": format!("f{position}"), "text": format!("Escribir {value};\n")}))
            .collect();
        fields.insert("files".to_owned(), json!(files));
    }
    wire
}

pub fn lock_workloads() -> Vec<LockWorkload> {
    let mut found = Vec::new();
    for locked in [false, true] {
        for count in COUNTS {
            found.push(LockWorkload {
                name: format!("lock-{}-{count}", if locked { "locked" } else { "local" }),
                packages: (0..count)
                    .map(|index| package(index, count, locked))
                    .collect(),
            });
        }
    }
    found
}
