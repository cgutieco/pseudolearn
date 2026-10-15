#[derive(Clone, Copy, Debug, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub struct SymbolId(pub u32);

#[derive(Clone, Copy, Debug, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub struct ScopeId(pub u32);

#[derive(Clone, Copy, Debug, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub struct TypeId(pub u32);

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Arena<Element> {
    elements: Vec<Element>,
}

impl<Element> Arena<Element> {
    pub fn new() -> Self {
        Self {
            elements: Vec::new(),
        }
    }

    pub fn allocate(&mut self, element: Element) -> u32 {
        let index = self.elements.len();
        self.elements.push(element);
        u32::try_from(index).unwrap_or(u32::MAX)
    }

    pub fn get(&self, identifier: u32) -> Option<&Element> {
        let index = usize::try_from(identifier).ok()?;
        self.elements.get(index)
    }

    pub fn get_mut(&mut self, identifier: u32) -> Option<&mut Element> {
        let index = usize::try_from(identifier).ok()?;
        self.elements.get_mut(index)
    }

    pub fn count(&self) -> usize {
        self.elements.len()
    }

    pub fn iter(&self) -> impl Iterator<Item = &Element> {
        self.elements.iter()
    }
}

impl<Element> Default for Arena<Element> {
    fn default() -> Self {
        Self::new()
    }
}
