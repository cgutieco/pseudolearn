use std::collections::BTreeMap;

#[derive(Clone, Debug, PartialEq)]
pub struct MapDelta<MapKey, MapValue> {
    pub restore: BTreeMap<MapKey, Option<MapValue>>,
}

impl<MapKey: Ord + Clone, MapValue: Clone + PartialEq> MapDelta<MapKey, MapValue> {
    pub fn copied_entries(&self) -> usize {
        self.restore.len()
    }

    pub fn advance(
        tip: &mut BTreeMap<MapKey, MapValue>,
        live: &BTreeMap<MapKey, MapValue>,
    ) -> Self {
        let mut restore = BTreeMap::new();
        for (key, value) in live {
            match tip.get(key) {
                Some(old) if old == value => {}
                Some(old) => {
                    restore.insert(key.clone(), Some(old.clone()));
                }
                None => {
                    restore.insert(key.clone(), None);
                }
            }
        }
        for (key, old) in tip.iter() {
            if !live.contains_key(key) {
                restore.insert(key.clone(), Some(old.clone()));
            }
        }
        for key in restore.keys() {
            match live.get(key) {
                Some(value) => {
                    tip.insert(key.clone(), value.clone());
                }
                None => {
                    tip.remove(key);
                }
            }
        }
        Self { restore }
    }

    pub fn revert(&self, current: &mut BTreeMap<MapKey, MapValue>) {
        for (key, old) in &self.restore {
            match old {
                Some(value) => {
                    current.insert(key.clone(), value.clone());
                }
                None => {
                    current.remove(key);
                }
            }
        }
    }

    pub fn compose(first_applied: &Self, older: &Self) -> Self {
        let mut restore = first_applied.restore.clone();
        restore.extend(older.restore.clone());
        Self { restore }
    }
}
