#![forbid(unsafe_code)]

mod contract;
mod kit;
mod numbers;
mod palette;
mod placeholders;
mod steps;
mod writer;

pub use contract::FIGURE_WIDTH;
pub use palette::{ColorRole, MONO_FAMILY, SANS_FAMILY};
pub use placeholders::FigureContext;
pub use steps::step_count;

use reference_model::Violation;

pub use writer::{RenderedFigure, RenderedLayer};

pub fn render_figure(
    source: &str,
    context: &FigureContext<'_>,
) -> Result<RenderedFigure, Vec<Violation>> {
    writer::render(source, context)
}
