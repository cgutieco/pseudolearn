use crate::completion::{CompletionResult, CompletionTextEdit};
use crate::completion_types::CompletionEntry;
use crate::document_session::DocumentSession;
use crate::insertion::{Insertion, TextChange, build_insertion};
use crate::navigation::Position;
use crate::on_type::{OnTypeOutcome, apply_changes, on_type};
use crate::positions::position_at;
use crate::template_insertion::build_template_insertion;
use crate::template_session::{StopDirection, StopNavigation, TemplateSession};
use pseudolearn_lexicon::Profile;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum EditError {
    StaleRevision { current: u64 },
    InvalidCursor,
    UnknownCandidate,
    NoTemplateSession,
}

struct Offer {
    revision: u64,
    replace: CompletionTextEdit,
    entries: Vec<CompletionEntry>,
}

pub struct EditSession {
    pub document: DocumentSession,
    pub revision: u64,
    offer: Option<Offer>,
    template: Option<TemplateSession>,
}

impl EditSession {
    pub fn new(text: String, profile: Profile, strict: bool) -> Self {
        Self {
            document: DocumentSession::new(text, profile, strict),
            revision: 1,
            offer: None,
            template: None,
        }
    }

    pub fn template_active(&self) -> bool {
        self.template.is_some()
    }

    pub fn apply_edits(&mut self, revision: u64, edits: &[TextChange]) -> Result<u64, EditError> {
        self.check(revision)?;
        Ok(self.commit(edits))
    }

    pub fn complete(
        &mut self,
        revision: u64,
        cursor: usize,
    ) -> Result<CompletionResult, EditError> {
        self.check(revision)?;
        let text = self.document.text();
        if text.get(..cursor).is_none() {
            return Err(EditError::InvalidCursor);
        }
        let position: Position = position_at(text, cursor);
        let result = self.document.queries().complete_with_edit(position);
        self.offer = Some(Offer {
            revision,
            replace: result.text_edit.clone(),
            entries: result.entries.clone(),
        });
        Ok(result)
    }

    pub fn accept(
        &mut self,
        revision: u64,
        acceptance: Acceptance<'_>,
    ) -> Result<Accepted, EditError> {
        self.check(revision)?;
        let insertion = match acceptance {
            Acceptance::Candidate(slot) => self.candidate_insertion(slot)?,
            Acceptance::Template {
                construction,
                start,
                end,
            } => build_template_insertion(&self.document, construction, (start, end))
                .ok_or(EditError::InvalidCursor)?,
        };
        let revision = self.commit(std::slice::from_ref(&insertion.edit));
        self.template = TemplateSession::from_insertion(&insertion);
        Ok(Accepted {
            revision,
            insertion,
        })
    }

    fn candidate_insertion(&mut self, slot: usize) -> Result<Insertion, EditError> {
        let offer = self.offer.take().ok_or(EditError::UnknownCandidate)?;
        let entry = offer
            .entries
            .get(slot)
            .filter(|_| offer.revision == self.revision)
            .ok_or(EditError::UnknownCandidate)?;
        Ok(build_insertion(
            entry,
            &offer.replace,
            self.document.text(),
            self.document.profile,
        ))
    }

    pub fn on_type(
        &mut self,
        revision: u64,
        cursor: usize,
        typed: char,
    ) -> Result<(u64, OnTypeOutcome), EditError> {
        self.check(revision)?;
        if self.document.text().get(..cursor).is_none() {
            return Err(EditError::InvalidCursor);
        }
        let outcome = on_type(&self.document, cursor, typed);
        let revision = if outcome.edits.is_empty() {
            self.revision
        } else {
            self.commit(&outcome.edits)
        };
        Ok((revision, outcome))
    }

    pub fn navigate_stop(
        &mut self,
        revision: u64,
        direction: StopDirection,
    ) -> Result<StopNavigation, EditError> {
        self.check(revision)?;
        let session = self.template.as_mut().ok_or(EditError::NoTemplateSession)?;
        let navigation = session.navigate(direction);
        if matches!(navigation, StopNavigation::Exited { .. }) {
            self.template = None;
        }
        Ok(navigation)
    }

    fn check(&self, revision: u64) -> Result<(), EditError> {
        if revision == self.revision {
            Ok(())
        } else {
            Err(EditError::StaleRevision {
                current: self.revision,
            })
        }
    }

    fn commit(&mut self, edits: &[TextChange]) -> u64 {
        let updated = apply_changes(self.document.text(), edits);
        self.document.apply_edit(updated);
        self.revision = self.revision.saturating_add(1);
        self.offer = None;
        let keeps = self
            .template
            .as_mut()
            .is_some_and(|session| edits.iter().rev().all(|change| session.follow(change)));
        if !keeps {
            self.template = None;
        }
        self.revision
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Acceptance<'name> {
    Candidate(usize),
    Template {
        construction: &'name str,
        start: usize,
        end: usize,
    },
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Accepted {
    pub revision: u64,
    pub insertion: Insertion,
}
