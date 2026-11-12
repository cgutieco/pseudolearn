use crate::contract::{
    FIGURE_WIDTH, MINIMUM_FONT_SIZE, attribute_allowed, element_allowed, is_shape,
};
use crate::numbers::{escape, format_number, parse_number};
use crate::palette::{ColorRole, SANS_FAMILY, color_value, font_family};
use crate::placeholders::FigureContext;
use reference_model::{RuleId, Violation};
use roxmltree::{Document, Node};

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct RenderedLayer {
    pub from_step: usize,
    pub until_step: Option<usize>,
    pub svg: String,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct RenderedFigure {
    pub svg: String,
    pub layers: Vec<RenderedLayer>,
}

pub fn render(source: &str, context: &FigureContext<'_>) -> Result<RenderedFigure, Vec<Violation>> {
    let location = format!("figures/{}.svg", context.id);
    let document = Document::parse(source).map_err(|error| {
        vec![Violation::new(
            RuleId::FigureContract,
            location.clone(),
            error.to_string(),
        )]
    })?;
    let mut writer = Writer {
        context,
        output: String::new(),
        layers: Vec::new(),
        violations: Vec::new(),
        location,
    };
    writer.root(document.root_element());
    if writer.violations.is_empty() {
        Ok(RenderedFigure {
            svg: writer.output,
            layers: writer.layers,
        })
    } else {
        Err(writer.violations)
    }
}

pub struct Writer<'writer> {
    context: &'writer FigureContext<'writer>,
    output: String,
    layers: Vec<RenderedLayer>,
    violations: Vec<Violation>,
    location: String,
}

impl Writer<'_> {
    pub fn push(&mut self, text: &str) {
        self.output.push_str(text);
    }

    pub fn report(&mut self, rule: RuleId, detail: impl Into<String>) {
        self.violations
            .push(Violation::new(rule, self.location.clone(), detail));
    }

    pub fn substitute(&mut self, text: &str) -> String {
        match self.context.substitute(text) {
            Ok(substituted) => substituted,
            Err(detail) => {
                self.report(RuleId::FigureContract, detail);
                String::new()
            }
        }
    }

    pub fn check_font_size(&mut self, size: f64) {
        if size < MINIMUM_FONT_SIZE {
            self.report(
                RuleId::FigureNarrow,
                format!("text of size {} is below 12 units", format_number(size)),
            );
        }
    }

    fn root(&mut self, root: Node<'_, '_>) {
        if root.tag_name().name() != "svg" {
            self.report(RuleId::FigureContract, "the root element must be svg");
            return;
        }
        let height = self.view_box_height(root);
        let height = format_number(height);
        self.push(&format!(
            "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 340 {height}\" width=\"340\" height=\"{height}\">"
        ));
        self.accessible_text();
        for child in root.children() {
            match crate::steps::step_range(child) {
                Some(range) if child.is_element() => self.layer(child, range),
                _ => self.child(child),
            }
        }
        self.push("</svg>");
    }

    fn accessible_text(&mut self) {
        for (key, element) in [("titulo", "title"), ("descripcion", "desc")] {
            match self.context.string(key) {
                Ok(text) => self.push(&format!("<{element}>{}</{element}>", escape(&text))),
                Err(detail) => self.report(RuleId::FigureContract, detail),
            }
        }
    }

    fn view_box_height(&mut self, root: Node<'_, '_>) -> f64 {
        let numbers: Vec<f64> = root
            .attribute("viewBox")
            .unwrap_or_default()
            .split_whitespace()
            .filter_map(parse_number)
            .collect();
        match numbers.as_slice() {
            [_, _, width, height] if (*width - FIGURE_WIDTH).abs() < f64::EPSILON => *height,
            [_, _, _, height] => {
                self.report(RuleId::FigureNarrow, "the viewBox must be 340 units wide");
                *height
            }
            _ => {
                self.report(RuleId::FigureContract, "the svg needs a viewBox");
                0.0
            }
        }
    }

    fn layer(&mut self, node: Node<'_, '_>, (from_step, until_step): (usize, Option<usize>)) {
        let base = std::mem::take(&mut self.output);
        self.element(node);
        let svg = std::mem::replace(&mut self.output, base);
        self.layers.push(RenderedLayer {
            from_step,
            until_step,
            svg,
        });
    }

    pub fn children(&mut self, node: Node<'_, '_>) {
        for child in node.children() {
            if crate::steps::step_range(child).is_some() {
                self.report(
                    RuleId::FigureContract,
                    "only top-level groups may belong to a step",
                );
            }
            self.child(child);
        }
    }

    fn child(&mut self, child: Node<'_, '_>) {
        if child.is_element() {
            self.element(child);
        } else if child.is_comment() {
            self.report(
                RuleId::FigureContract,
                "comments are not allowed in figures",
            );
        } else if let Some(text) = child.text().filter(|text| !text.trim().is_empty()) {
            let substituted = self.substitute(text.trim());
            self.push(&escape(&substituted));
        }
    }

    fn element(&mut self, node: Node<'_, '_>) {
        match node.tag_name().name() {
            "caja" => crate::kit::write_box(self, node),
            "flecha" => crate::kit::write_arrow(self, node),
            name if element_allowed(name) && name != "svg" => self.generic(node),
            other => self.report(
                RuleId::FigureContract,
                format!("element `{other}` is not allowed"),
            ),
        }
    }

    fn generic(&mut self, node: Node<'_, '_>) {
        let name = node.tag_name().name();
        self.push(&format!("<{name}"));
        for attribute in node.attributes() {
            self.attribute(attribute.name(), attribute.value());
        }
        self.defaults(node);
        self.push(">");
        self.children(node);
        self.push(&format!("</{name}>"));
    }

    fn defaults(&mut self, node: Node<'_, '_>) {
        let name = node.tag_name().name();
        let textual = matches!(name, "text" | "tspan");
        if textual && node.attribute("fill").is_none() {
            self.push(&format!(" fill=\"{}\"", ColorRole::Ink.sentinel()));
        }
        if name == "text" && node.attribute("font-family").is_none() {
            self.push(&format!(" font-family=\"{SANS_FAMILY}\""));
        }
        if is_shape(name) && node.attribute("fill").is_none() {
            self.report(
                RuleId::FigureContract,
                format!("a `{name}` must declare its fill"),
            );
        }
    }

    fn attribute(&mut self, name: &str, value: &str) {
        if name.starts_with("data-") {
            return;
        }
        if !attribute_allowed(name) {
            self.report(
                RuleId::FigureContract,
                format!("attribute `{name}` is not allowed"),
            );
            return;
        }
        let converted = match name {
            "fill" | "stroke" => color_value(value),
            "font-family" => font_family(value).map(str::to_owned),
            "font-size" => Ok(self.font_size(value)),
            _ => Ok(value.to_owned()),
        };
        match converted {
            Ok(text) => self.push(&format!(" {name}=\"{}\"", escape(&text))),
            Err(detail) => self.report(RuleId::FigureContract, detail),
        }
    }

    fn font_size(&mut self, value: &str) -> String {
        let size = parse_number(value).unwrap_or_default();
        self.check_font_size(size);
        value.to_owned()
    }
}
