use super::definitions;

#[test]
fn imports_are_grouped_by_library_in_definition_files() {
    let grouped =
        definitions("kernel32.dll\tGetLastError\nntdll.dll\tmemcpy\nKERNEL32.dll\tExitProcess\n");
    assert_eq!(grouped.len(), 2);
    assert_eq!(
        grouped.get("kernel32.dll").map(String::as_str),
        Some("LIBRARY kernel32.dll\nEXPORTS\n  GetLastError\n  ExitProcess\n")
    );
    assert_eq!(
        grouped.get("ntdll.dll").map(String::as_str),
        Some("LIBRARY ntdll.dll\nEXPORTS\n  memcpy\n")
    );
}

#[test]
fn an_empty_table_produces_no_libraries() {
    assert!(definitions("").is_empty());
}

#[test]
fn malformed_lines_are_ignored() {
    let grouped = definitions("kernel32.dll\nntdll.dll\tmemset\n");
    assert_eq!(grouped.keys().collect::<Vec<_>>(), ["ntdll.dll"]);
}
