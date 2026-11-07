use reference_figures::{ColorRole, RailLabels, render_rails};
use reference_model::RailRequest;

fn terminal(identity: &str) -> (String, ColorRole) {
    (identity.to_owned(), ColorRole::StructuredAccent)
}

fn nonterminal(name: &str) -> String {
    name.to_owned()
}

fn labels() -> RailLabels<'static> {
    RailLabels {
        terminal: &terminal,
        nonterminal: &nonterminal,
        title: "Diagrama".to_owned(),
        description: "Vías".to_owned(),
    }
}

fn request(production: &str) -> RailRequest {
    RailRequest {
        production: production.to_owned(),
        contextual: Vec::new(),
    }
}

#[test]
fn draws_a_wrapped_conditional() {
    let rule =
        "@ifKeyword, expression, @then, line, body, [ @elseKeyword, line, body ], @endIf, line";
    let svg = render_rails(&request("conditional"), rule, &labels());
    assert!(svg.is_ok());
    let svg = svg.unwrap_or_default();
    assert!(svg.starts_with("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 340 "));
    assert!(svg.contains(">ifKeyword<") && svg.contains(">expression<"));
    assert!(!svg.contains(">line<"));
}

#[test]
fn replaces_contextual_identifiers() {
    let mut contextual = request("forEachLoop");
    contextual.contextual = vec![Some("eachKeyword".to_owned()), None];
    let svg = render_rails(
        &contextual,
        "@forKeyword, identifier, identifier",
        &labels(),
    )
    .unwrap_or_default();
    assert!(svg.contains(">eachKeyword<") && svg.contains(">identifier<"));
}

#[test]
fn draws_repetitions_and_choices() {
    let svg = render_rails(
        &request("addition"),
        "multiplication, { ( @plus | @minus ), multiplication }",
        &labels(),
    );
    assert!(svg.is_ok_and(|svg| svg.contains(">plus<") && svg.contains(">minus<")));
}

#[test]
fn rejects_malformed_rules() {
    assert!(render_rails(&request("x"), "( @a", &labels()).is_err());
    assert!(render_rails(&request("x"), "@a )", &labels()).is_err());
    assert!(render_rails(&request("x"), "", &labels()).is_err());
}

#[test]
fn rejects_a_diagram_that_does_not_fit() {
    let wide = "( @aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa | @b )";
    assert!(render_rails(&request("x"), wide, &labels()).is_err());
}

#[test]
fn wraps_a_member_that_fills_a_whole_row() {
    let failures: Vec<usize> = (1..=28)
        .filter(|length| {
            let name = "n".repeat(*length);
            let rule = format!("@opening, [ @middle, @separator, {name} ], @closing");
            render_rails(&request("x"), &rule, &labels()).is_err()
        })
        .collect();
    assert_eq!(failures, Vec::<usize>::new());
}
