use reference_format::parse_document;
use reference_model::{CalloutKind, RuleId, SectionKind, SourceBlock};

const DOCUMENT: &str = "---
id: control.si
numero: \"6.1\"
tipo: construccion
titulo: La decisión `Si`
anclas: [LANG.CONTROL.IF#R1]
---

::: frase
`Si` elige un camino.
:::

## Cómo se escribe {#escribe}

```forma
Si «condición» Entonces
FinSi
```

```programa id=paraguas titulo=\"¿Llevo paraguas?\" ejecutar
Proceso P
FinProceso
```

```salida
Hola
```

- primero
  sigue
- segundo

| A | B |
|---|---|
| `x` | y |
";

#[test]
fn parses_a_complete_document() {
    let parsed = parse_document("si.md", DOCUMENT);
    assert!(parsed.is_ok());
    let Ok(document) = parsed else { return };
    assert_eq!(document.header.kind, SectionKind::Construction);
    assert_eq!(
        document.header.anchors,
        vec!["LANG.CONTROL.IF#R1".to_owned()]
    );
    assert_eq!(document.blocks.len(), 6);
    assert!(matches!(
        document.blocks.first(),
        Some(SourceBlock::Callout {
            kind: CalloutKind::Phrase,
            ..
        })
    ));
}

#[test]
fn attaches_the_promised_output_to_the_program() {
    let parsed = parse_document("si.md", DOCUMENT);
    assert!(parsed.is_ok());
    let Ok(document) = parsed else {
        return;
    };
    let program = document.blocks.iter().find_map(|block| match block {
        SourceBlock::Program(program) => Some(program),
        _ => None,
    });
    assert_eq!(
        program.and_then(|program| program.promise.output.clone()),
        Some("Hola".to_owned())
    );
    assert_eq!(program.map(|program| program.execute), Some(true));
    assert_eq!(
        program.map(|program| program.title.clone()),
        Some("¿Llevo paraguas?".to_owned())
    );
}

#[test]
fn joins_list_continuation_lines() {
    let parsed = parse_document("si.md", DOCUMENT);
    assert!(parsed.is_ok());
    let Ok(document) = parsed else {
        return;
    };
    let entries = document.blocks.iter().find_map(|block| match block {
        SourceBlock::List { entries, .. } => Some(entries.len()),
        _ => None,
    });
    assert_eq!(entries, Some(2));
}

#[test]
fn rejects_a_document_without_front_matter() {
    let result = parse_document("x.md", "# nada\n");
    assert_eq!(
        result.map_err(|violation| violation.rule),
        Err(RuleId::Format)
    );
}

#[test]
fn rejects_an_unclosed_box() {
    let text = "---\nid: a\nnumero: \"1\"\ntipo: concepto\ntitulo: A\n---\n::: frase\nTexto\n";
    assert!(parse_document("a.md", text).is_err());
}

#[test]
fn rejects_an_output_without_a_program() {
    let text = "---\nid: a\nnumero: \"1\"\ntipo: concepto\ntitulo: A\n---\n```salida\nx\n```\n";
    assert!(parse_document("a.md", text).is_err());
}

#[test]
fn rejects_an_unknown_kind() {
    let text = "---\nid: a\nnumero: \"1\"\ntipo: otro\ntitulo: A\n---\n";
    assert!(parse_document("a.md", text).is_err());
}

#[test]
fn accepts_an_empty_body() {
    let text = "---\nid: a\nnumero: \"1\"\ntipo: concepto\ntitulo: A\n---\n";
    assert_eq!(
        parse_document("a.md", text).map(|document| document.blocks.len()),
        Ok(0)
    );
}
