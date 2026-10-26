use pseudolearn_abi::CapabilityKind;

pub fn find_capability_kind(name: &str) -> Option<CapabilityKind> {
    match name {
        "Consola" | "Console" => Some(CapabilityKind::Console),
        "Argumentos" | "Arguments" => Some(CapabilityKind::Arguments),
        "DirectorioCap" | "DirCap" => Some(CapabilityKind::Directory),
        "ArchivoCap" | "FileCap" => Some(CapabilityKind::File),
        "Reloj" | "Clock" => Some(CapabilityKind::Clock),
        "Temporizador" | "Timer" => Some(CapabilityKind::Timer),
        _ => None,
    }
}

pub fn capability_canonical_name(kind: CapabilityKind, spanish: bool) -> &'static str {
    match (kind, spanish) {
        (CapabilityKind::Console, true) => "Consola",
        (CapabilityKind::Console, false) => "Console",
        (CapabilityKind::Arguments, true) => "Argumentos",
        (CapabilityKind::Arguments, false) => "Arguments",
        (CapabilityKind::Directory, true) => "DirectorioCap",
        (CapabilityKind::Directory, false) => "DirCap",
        (CapabilityKind::File, true) => "ArchivoCap",
        (CapabilityKind::File, false) => "FileCap",
        (CapabilityKind::Clock, true) => "Reloj",
        (CapabilityKind::Clock, false) => "Clock",
        (CapabilityKind::Timer, true) => "Temporizador",
        (CapabilityKind::Timer, false) => "Timer",
    }
}

pub fn is_capability_name(name: &str) -> bool {
    find_capability_kind(name).is_some()
}
