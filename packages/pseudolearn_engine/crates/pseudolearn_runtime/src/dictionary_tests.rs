use super::{dictionary_find, dictionary_remove, dictionary_set, index};
use crate::{
    CollectionWords, DictionaryKeyKind, DictionaryLayout, Heap, MemoryError, MemoryOptions,
    VectorLayout,
};

#[test]
fn seeded_collisions_keep_distinct_keys_through_deletion_and_growth() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let keys = (0..200_000)
        .filter_map(|key| {
            index::hash(&heap, DictionaryKeyKind::Integer, key)
                .ok()
                .filter(|hash| hash & 255 == 0)
                .map(|_| key)
        })
        .take(64)
        .collect::<Vec<_>>();
    assert_eq!(keys.len(), 64);
    let layout = DictionaryLayout {
        key: DictionaryKeyKind::Integer,
        value: VectorLayout {
            scalar_words: 1,
            reference_words: 0,
            type_identity: 0,
        },
    };
    let handle = crate::new_dictionary(&mut heap, layout, &[])?;
    for key in &keys {
        dictionary_set(
            &mut heap,
            handle,
            (
                *key,
                CollectionWords {
                    scalars: vec![*key],
                    references: vec![],
                },
            ),
            &[handle],
        )?;
    }
    for key in keys.iter().step_by(2) {
        dictionary_remove(&mut heap, handle, *key)?;
    }
    for (ordinal, key) in keys.iter().enumerate() {
        let value = dictionary_find(&heap, handle, *key)?;
        assert_eq!(
            value.map(|value| value.scalars),
            if ordinal % 2 == 0 {
                None
            } else {
                Some(vec![*key])
            }
        );
    }
    Ok(())
}
