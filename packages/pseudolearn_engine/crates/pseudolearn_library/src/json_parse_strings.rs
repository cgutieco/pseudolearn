#![forbid(unsafe_code)]

use serde::Deserializer;
use serde::de::{DeserializeSeed, MapAccess, SeqAccess, Visitor};
use serde_json::de::Deserializer as JsonDeserializer;
use std::collections::BTreeSet;
use std::fmt::Formatter;

pub fn validate(text: &str, maximum_depth: usize) -> Result<(), serde_json::Error> {
    let mut parser = JsonDeserializer::from_str(text);
    ShapeSeed {
        depth: 0,
        maximum_depth,
    }
    .deserialize(&mut parser)?;
    parser.end()
}

struct ShapeSeed {
    depth: usize,
    maximum_depth: usize,
}

impl<'value> DeserializeSeed<'value> for ShapeSeed {
    type Value = ();

    fn deserialize<DeserializerType>(
        self,
        deserializer: DeserializerType,
    ) -> Result<Self::Value, DeserializerType::Error>
    where
        DeserializerType: Deserializer<'value>,
    {
        deserializer.deserialize_any(ShapeVisitor {
            depth: self.depth,
            maximum_depth: self.maximum_depth,
        })
    }
}

struct ShapeVisitor {
    depth: usize,
    maximum_depth: usize,
}

impl<'value> Visitor<'value> for ShapeVisitor {
    type Value = ();

    fn expecting(&self, formatter: &mut Formatter<'_>) -> std::fmt::Result {
        formatter.write_str("a JSON value")
    }

    fn visit_unit<ErrorType>(self) -> Result<Self::Value, ErrorType> {
        Ok(())
    }

    fn visit_bool<ErrorType>(self, _: bool) -> Result<Self::Value, ErrorType> {
        Ok(())
    }

    fn visit_i64<ErrorType>(self, _: i64) -> Result<Self::Value, ErrorType> {
        Ok(())
    }

    fn visit_u64<ErrorType>(self, _: u64) -> Result<Self::Value, ErrorType> {
        Ok(())
    }

    fn visit_f64<ErrorType>(self, _: f64) -> Result<Self::Value, ErrorType> {
        Ok(())
    }

    fn visit_str<ErrorType>(self, _: &str) -> Result<Self::Value, ErrorType> {
        Ok(())
    }

    fn visit_string<ErrorType>(self, _: String) -> Result<Self::Value, ErrorType> {
        Ok(())
    }

    fn visit_seq<SequenceType>(
        self,
        mut sequence: SequenceType,
    ) -> Result<Self::Value, SequenceType::Error>
    where
        SequenceType: SeqAccess<'value>,
    {
        let seed = self.child_seed()?;
        while sequence.next_element_seed(seed.clone())?.is_some() {}
        Ok(())
    }

    fn visit_map<MapType>(self, mut map: MapType) -> Result<Self::Value, MapType::Error>
    where
        MapType: MapAccess<'value>,
    {
        let seed = self.child_seed()?;
        let mut names = BTreeSet::new();
        while let Some(name) = map.next_key::<String>()? {
            if !names.insert(name) {
                return Err(serde::de::Error::custom("json_duplicate_key"));
            }
            map.next_value_seed(seed.clone())?;
        }
        Ok(())
    }
}

impl ShapeVisitor {
    fn child_seed<ErrorType>(&self) -> Result<ShapeSeed, ErrorType>
    where
        ErrorType: serde::de::Error,
    {
        let depth = self
            .depth
            .checked_add(1)
            .ok_or_else(|| ErrorType::custom("json_depth_exceeded"))?;
        if depth > self.maximum_depth {
            return Err(ErrorType::custom("json_depth_exceeded"));
        }
        Ok(ShapeSeed {
            depth,
            maximum_depth: self.maximum_depth,
        })
    }
}

impl Clone for ShapeSeed {
    fn clone(&self) -> Self {
        Self {
            depth: self.depth,
            maximum_depth: self.maximum_depth,
        }
    }
}
