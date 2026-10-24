#![forbid(unsafe_code)]

use crate::columns::{InstructionColumns, InstructionDefinition};
use crate::identities::{BlockId, InstructionId, ValueId};
use crate::lexer::{Lexer, Token, TokenKind};
use crate::model::{Block, ClassDeclaration, FieldDeclaration, Function, Module};
use crate::operand::Operand;
use crate::operand_parser::parse_operand;
use crate::operation::Operation;
use crate::type_parser::parse_type_tokens;
use crate::types::IrType;

pub fn parse_module(source: &str) -> Result<Module, String> {
    let mut lexer = Lexer::new(source);
    let tokens = lexer.tokenize()?;
    let mut parser = Parser { tokens, cursor: 0 };
    parser.parse_module()
}

pub(crate) struct Parser {
    tokens: Vec<Token>,
    cursor: usize,
}

impl Parser {
    pub(crate) fn peek(&self) -> &TokenKind {
        self.tokens
            .get(self.cursor)
            .map_or(&TokenKind::Eof, |token| &token.kind)
    }

    pub(crate) fn advance(&mut self) -> TokenKind {
        if let Some(token) = self.tokens.get(self.cursor) {
            self.cursor = self.cursor.saturating_add(1);
            token.kind.clone()
        } else {
            TokenKind::Eof
        }
    }

    pub(crate) fn expect_word(&mut self, expected: &str) -> Result<String, String> {
        match self.advance() {
            TokenKind::Word(word) if expected.is_empty() || word == expected => Ok(word),
            other => Err(format!("Expected word '{expected}', found {other:?}")),
        }
    }

    fn parse_module(&mut self) -> Result<Module, String> {
        let _ = self.expect_word("module")?;
        let name = self.expect_word("")?;
        let vocabulary = self.expect_word("")?;
        let profiles = crate::profile_parser::parse_profiles(self)?;
        let mut classes = Vec::new();
        while self.peek() == &TokenKind::Word("class".to_owned()) {
            classes.push(self.parse_class()?);
        }
        let mut functions = Vec::new();
        while self.peek() == &TokenKind::Word("func".to_owned()) {
            functions.push(self.parse_function()?);
        }
        Ok(Module {
            name,
            vocabulary,
            profiles,
            classes,
            functions,
            origins: Default::default(),
        })
    }

    fn parse_class(&mut self) -> Result<ClassDeclaration, String> {
        let _ = self.expect_word("class")?;
        let name = self.expect_word("")?;
        let mut superclass = None;
        if self.peek() == &TokenKind::Colon {
            let _ = self.advance();
            superclass = Some(self.expect_word("")?);
        }
        if self.advance() != TokenKind::OpenBrace {
            return Err("Expected '{' for class body".to_owned());
        }
        let mut fields = Vec::new();
        while self.peek() != &TokenKind::CloseBrace && self.peek() != &TokenKind::Eof {
            let field_name = self.expect_word("")?;
            if self.advance() != TokenKind::Colon {
                return Err("Expected ':' after field name".to_owned());
            }
            let field_type = self.parse_type()?;
            fields.push(FieldDeclaration {
                name: field_name,
                field_type,
            });
            if self.peek() == &TokenKind::Comma {
                let _ = self.advance();
            }
        }
        if self.advance() != TokenKind::CloseBrace {
            return Err("Expected '}' for class body".to_owned());
        }
        Ok(ClassDeclaration {
            methods: Vec::new(),
            dense_integers: false,
            name,
            superclass,
            fields,
        })
    }

    fn parse_type(&mut self) -> Result<IrType, String> {
        parse_type_tokens(&self.tokens, &mut self.cursor)
    }

    fn expect_exact(&mut self, expected: TokenKind) -> Result<(), String> {
        let current = self.advance();
        if current == expected {
            Ok(())
        } else {
            Err(format!("Expected {expected:?}, found {current:?}"))
        }
    }

    fn parse_function(&mut self) -> Result<Function, String> {
        let _ = self.expect_word("func")?;
        let name = match self.advance() {
            TokenKind::FunctionAt(identifier) => identifier,
            other => return Err(format!("Expected @name, found {other:?}")),
        };
        self.expect_exact(TokenKind::OpenParen)?;
        let parameters = self.parse_function_parameters()?;
        self.expect_exact(TokenKind::Arrow)?;
        let return_type = self.parse_type()?;
        self.expect_exact(TokenKind::OpenBrace)?;

        let mut blocks = Vec::new();
        let mut columns = InstructionColumns::new();
        for (parameter_value, parameter_type) in &parameters {
            columns.register_value_type(*parameter_value, parameter_type.clone());
        }
        while matches!(self.peek(), TokenKind::Block(_)) {
            blocks.push(self.parse_block(&mut columns)?);
        }
        self.expect_exact(TokenKind::CloseBrace)?;

        Ok(Function {
            declaration_span: None,
            name,
            parameters,
            return_type,
            blocks,
            columns,
        })
    }

    fn parse_function_parameters(&mut self) -> Result<Vec<(ValueId, IrType)>, String> {
        let mut parameters = Vec::new();
        while self.peek() != &TokenKind::CloseParen && self.peek() != &TokenKind::Eof {
            let parameter_value = self.parse_value()?;
            self.expect_exact(TokenKind::Colon)?;
            let parameter_type = self.parse_type()?;
            parameters.push((parameter_value, parameter_type));
            if self.peek() == &TokenKind::Comma {
                let _ = self.advance();
            }
        }
        self.expect_exact(TokenKind::CloseParen)?;
        Ok(parameters)
    }

    fn parse_value(&mut self) -> Result<ValueId, String> {
        match self.advance() {
            TokenKind::Value(number) => Ok(ValueId(number)),
            other => Err(format!("Expected value %n, found {other:?}")),
        }
    }

    fn parse_block(&mut self, columns: &mut InstructionColumns) -> Result<Block, String> {
        let block_number = match self.advance() {
            TokenKind::Block(number) => number,
            other => return Err(format!("Expected block identifier, found {other:?}")),
        };
        let parameters = self.parse_block_parameters(columns)?;
        let _ = self.expect_word("mass")?;
        let mass = match self.advance() {
            TokenKind::Integer(number) => {
                u32::try_from(number).map_err(|error| error.to_string())?
            }
            other => return Err(format!("Expected integer mass, found {other:?}")),
        };
        self.expect_exact(TokenKind::Colon)?;

        let mut instructions = Vec::new();
        while !matches!(self.peek(), TokenKind::Block(_))
            && self.peek() != &TokenKind::CloseBrace
            && self.peek() != &TokenKind::Eof
        {
            instructions.push(self.parse_instruction(columns)?);
        }
        Ok(Block {
            identifier: BlockId(block_number),
            parameters,
            mass,
            instructions,
        })
    }

    fn parse_block_parameters(
        &mut self,
        columns: &mut InstructionColumns,
    ) -> Result<Vec<(ValueId, IrType)>, String> {
        self.expect_exact(TokenKind::OpenParen)?;
        let mut parameters = Vec::new();
        while self.peek() != &TokenKind::CloseParen && self.peek() != &TokenKind::Eof {
            let parameter_value = self.parse_value()?;
            self.expect_exact(TokenKind::Colon)?;
            let parameter_type = self.parse_type()?;
            columns.register_value_type(parameter_value, parameter_type.clone());
            parameters.push((parameter_value, parameter_type));
            if self.peek() == &TokenKind::Comma {
                let _ = self.advance();
            }
        }
        self.expect_exact(TokenKind::CloseParen)?;
        Ok(parameters)
    }

    fn parse_instruction(
        &mut self,
        columns: &mut InstructionColumns,
    ) -> Result<InstructionId, String> {
        let result = self.parse_optional_result();
        let operation_name = self.expect_word("")?;
        let operation = Operation::from_name(&operation_name)
            .ok_or_else(|| format!("Unknown operation: {operation_name}"))?;
        let operands = self.parse_instruction_operands()?;
        let span = if let TokenKind::Span(span) = self.peek() {
            let captured = *span;
            let _ = self.advance();
            Some(captured)
        } else {
            None
        };
        let definition = InstructionDefinition {
            operation,
            result,
            span,
        };
        Ok(columns.push_instruction(definition, &operands))
    }

    fn parse_optional_result(&mut self) -> Option<ValueId> {
        if let TokenKind::Value(number) = self.peek() {
            let value_number = *number;
            if self
                .tokens
                .get(self.cursor.saturating_add(1))
                .map(|token| &token.kind)
                == Some(&TokenKind::Equal)
            {
                let _ = self.advance();
                let _ = self.advance();
                return Some(ValueId(value_number));
            }
        }
        None
    }

    fn parse_instruction_operands(&mut self) -> Result<Vec<Operand>, String> {
        let mut operands = Vec::new();
        while self.is_operand_start() {
            operands.push(parse_operand(
                &self.tokens,
                &mut self.cursor,
                parse_type_tokens,
            )?);
            if self.peek() == &TokenKind::Comma {
                let _ = self.advance();
            } else {
                break;
            }
        }
        Ok(operands)
    }

    fn is_operand_start(&self) -> bool {
        matches!(
            self.peek(),
            TokenKind::Value(_)
                | TokenKind::Block(_)
                | TokenKind::FunctionAt(_)
                | TokenKind::Integer(_)
                | TokenKind::Float(_)
                | TokenKind::CharLiteral(_)
                | TokenKind::StringLiteral(_)
                | TokenKind::Word(_)
        )
    }
}
