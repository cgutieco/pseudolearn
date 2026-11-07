pub use crate::rails_draw::RailLabels;
use reference_model::RailRequest;

pub fn render_rails(
    request: &RailRequest,
    rule: &str,
    labels: &RailLabels<'_>,
) -> Result<String, String> {
    let tree = crate::rails_grammar::parse(rule)?;
    let tree = crate::rails_grammar::apply_contextual(tree, &request.contextual);
    let layout = crate::rails_layout::layout(&tree, labels)?;
    Ok(crate::rails_draw::draw(&layout, labels))
}
