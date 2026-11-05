use crate::identities::ConstantId;
use crate::service_model::ServiceSymbolTarget;
use crate::session::AnalysisSession;

impl AnalysisSession<'_> {
    pub(crate) fn note_use(&mut self, node: usize, target: ServiceSymbolTarget) {
        let Some(token) = self
            .tree
            .node(node)
            .and_then(|syntax| usize::try_from(syntax.first_token).ok())
        else {
            return;
        };
        if let Some(span) = self.tree.tokens.span(token) {
            self.module.name_uses.insert((span, target));
        }
    }

    pub(crate) fn note_declaration(&mut self, node: usize, target: ServiceSymbolTarget) {
        let span = self.span(node);
        self.module.name_declarations.insert((span, target));
    }

    pub(crate) fn note_constant(&mut self, node: usize, name: &str) {
        let index = self.module.constant_names.len();
        self.module.constant_names.push(name.to_owned());
        let identifier = ConstantId(u32::try_from(index).unwrap_or(u32::MAX));
        self.note_declaration(node, ServiceSymbolTarget::Constant(identifier));
    }
}
