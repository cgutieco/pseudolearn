mod support;

use reference_figures::{render_figure, step_count};

const STEPPED: &str = "<svg viewBox=\"0 0 340 80\"><rect x=\"0\" y=\"0\" width=\"1\" height=\"1\" fill=\"@tinta\"/><g data-paso=\"1\" data-hasta=\"1\"><rect x=\"1\" y=\"1\" width=\"1\" height=\"1\" fill=\"@exito\"/></g><g data-paso=\"2\"><rect x=\"2\" y=\"2\" width=\"2\" height=\"2\" fill=\"@error\"/></g></svg>";

#[test]
fn counts_steps() {
    assert_eq!(step_count(STEPPED), 2);
    assert_eq!(step_count("<svg/>"), 0);
    assert_eq!(step_count("<svg"), 0);
}

#[test]
fn splits_stepped_groups_into_layers() {
    let strings = support::strings();
    let rendered = render_figure(STEPPED, &support::context(&strings));
    assert!(rendered.is_ok());
    let figure = rendered.unwrap_or_default();
    assert!(figure.svg.contains("#FF0001") && !figure.svg.contains("#FF0009"));
    let ranges: Vec<(usize, Option<usize>)> = figure
        .layers
        .iter()
        .map(|layer| (layer.from_step, layer.until_step))
        .collect();
    assert_eq!(ranges, vec![(1, Some(1)), (2, None)]);
    assert!(
        figure
            .layers
            .iter()
            .all(|layer| layer.svg.starts_with("<g>") && !layer.svg.contains("data-paso"))
    );
}

#[test]
fn rejects_nested_stepped_groups() {
    let strings = support::strings();
    let nested = "<svg viewBox=\"0 0 340 80\"><g><g data-paso=\"1\"></g></g></svg>";
    assert!(render_figure(nested, &support::context(&strings)).is_err());
}
