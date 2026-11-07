pub const FIGURE_WIDTH: f64 = 340.0;
pub const MINIMUM_FONT_SIZE: f64 = 12.0;

pub const SHAPES: [&str; 7] = [
    "path", "rect", "circle", "ellipse", "line", "polyline", "polygon",
];

const ELEMENTS: [&str; 11] = [
    "g", "path", "rect", "circle", "ellipse", "line", "polyline", "polygon", "text", "tspan", "svg",
];

const ATTRIBUTES: [&str; 33] = [
    "x",
    "y",
    "x1",
    "y1",
    "x2",
    "y2",
    "width",
    "height",
    "rx",
    "ry",
    "cx",
    "cy",
    "r",
    "d",
    "points",
    "fill",
    "stroke",
    "stroke-width",
    "stroke-dasharray",
    "stroke-linecap",
    "stroke-linejoin",
    "fill-opacity",
    "stroke-opacity",
    "opacity",
    "font-size",
    "font-weight",
    "font-style",
    "font-family",
    "text-anchor",
    "transform",
    "data-paso",
    "data-hasta",
    "dx",
];

pub fn element_allowed(name: &str) -> bool {
    ELEMENTS.contains(&name)
}

pub fn attribute_allowed(name: &str) -> bool {
    ATTRIBUTES.contains(&name)
}

pub fn is_shape(name: &str) -> bool {
    SHAPES.contains(&name)
}
