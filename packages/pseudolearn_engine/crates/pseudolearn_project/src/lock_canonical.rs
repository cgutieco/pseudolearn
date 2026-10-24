use crate::lock_model::{Lock, LockKind, LockPackage};

impl Lock {
    pub fn canonical_text(&self) -> String {
        let mut text = String::from("schema = 1\n");
        for package in self.packages.values() {
            text.push('\n');
            write_package(&mut text, package);
        }
        text
    }
}

fn write_package(text: &mut String, package: &LockPackage) {
    let name = quote(&package.name);
    text.push_str(&format!("[packages.{name}]\n"));
    text.push_str(&format!("origin = {}\n", quote(&package.origin)));
    text.push_str(&format!("kind = {}\n", quote(package.kind.as_str())));
    let dependencies: Vec<String> = package
        .dependencies
        .iter()
        .map(|each| quote(each))
        .collect();
    text.push_str(&format!("dependencies = [{}]\n", dependencies.join(", ")));
    if package.kind == LockKind::Locked {
        write_content(text, package, &name);
    }
}

fn write_content(text: &mut String, package: &LockPackage, name: &str) {
    if let Some(digest) = &package.digest {
        text.push_str(&format!("digest = {}\n", quote(digest)));
    }
    if package.files.is_empty() {
        return;
    }
    text.push_str(&format!("\n[packages.{name}.files]\n"));
    for (path, digest) in &package.files {
        text.push_str(&format!("{} = {}\n", quote(path), quote(digest)));
    }
}

fn quote(text: &str) -> String {
    let mut quoted = String::from("\"");
    for character in text.chars() {
        match character {
            '"' => quoted.push_str("\\\""),
            '\\' => quoted.push_str("\\\\"),
            '\n' => quoted.push_str("\\n"),
            '\t' => quoted.push_str("\\t"),
            other if other.is_control() => quoted.push_str(&format!("\\u{:04X}", u32::from(other))),
            other => quoted.push(other),
        }
    }
    quoted.push('"');
    quoted
}
