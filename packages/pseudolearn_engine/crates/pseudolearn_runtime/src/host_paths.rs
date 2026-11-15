use crate::IoError;
use pseudolearn_abi::IoErrorKind;

pub(crate) fn normalize(path: &str) -> Result<String, IoError> {
    if path.is_empty() || path.contains('\0') {
        return Err(invalid());
    }
    let path = path.replace('\\', "/");
    let rooted = path.starts_with('/');
    let mut parts = Vec::new();
    for part in path.split('/') {
        match part {
            "" | "." => (),
            ".." if parts.last().is_some_and(|part| *part != "..") => {
                parts.pop();
            }
            ".." if rooted => (),
            _ => parts.push(part),
        }
    }
    let prefix = if path.starts_with("//") {
        "//"
    } else if rooted {
        "/"
    } else {
        ""
    };
    Ok(format!("{prefix}{}", parts.join("/")))
}

pub(crate) fn join(parent: &str, path: &str, confined: Option<&str>) -> Result<String, IoError> {
    let absolute = path.starts_with(['/', '\\']) || path.as_bytes().get(1) == Some(&b':');
    if confined.is_some() && absolute {
        return Err(invalid());
    }
    let combined = if absolute || parent.is_empty() {
        path.to_owned()
    } else {
        format!("{parent}/{path}")
    };
    let result = normalize(&combined)?;
    if let Some(root) = confined
        && result != root
        && !result.starts_with(&format!("{root}/"))
    {
        return Err(invalid());
    }
    Ok(result)
}

fn invalid() -> IoError {
    IoError::from_kind(IoErrorKind::InvalidPath)
}

#[cfg(test)]
#[path = "host_paths_tests.rs"]
mod host_paths_tests;
