module StringParser (parseString) where

import Control.Applicative ((<*))
import Control.Monad (liftM)
import Data.Maybe (catMaybes)
import Text.Parsec

type Parser = Parsec String ()

str :: String -> Parser String
str s = try $ string s

parseString :: String -> Either String String
parseString s = either (Left . show) Right $ parse parseStr "" s

parseStr :: Parser String
parseStr = quotedEscaped (str "\"\"\"")
       <|> quotedEscaped (str "'''")
       <|> quotedEscaped (str "\"")
       <|> quotedEscaped (str "'")
  where quotedEscaped quotes = quoted quotes (parseEscapedString quotes) <* eof
        quoted quotes = between quotes quotes

parseRawString :: Parser String
parseRawString = error "StringParser.parseRawString not implemented"

parseEscapedString :: Parser String -> Parser String
parseEscapedString quotes = catMaybes `liftM` manyTill parseEscapedChar (lookAhead quotes)

parseEscapedChar :: Parser (Maybe Char)
parseEscapedChar = (str "\\\n" >> return Nothing)
               <|> (str "\\\\" >> ret '\\')
               <|> (str "\\'" >> ret '\'')
               <|> (str "\\\"" >> ret '"')
               <|> (str "\\a" >> ret '\a')
               <|> (str "\\b" >> ret '\b')
               <|> (str "\\f" >> ret '\f')
               <|> (str "\\n" >> ret '\n')
               <|> (str "\\N" >> between (char '{') (char '}') parseUnicodeName >>= ret)
               <|> (str "\\r" >> ret '\r')
               <|> (str "\\t" >> ret '\t')
               <|> (str "\\u" >> parseFourDigitHex >>= ret)
               <|> (str "\\U" >> parseEightDigitHex >>= ret)
               <|> (str "\\v" >> ret '\v')
               <|> (try (char '\\' >> octDigit) >> parseOct >>= ret)
               <|> (str "\\x" >> parseHex >>= ret)
               <|> (anyChar >>= ret)
  where ret = return . Just

-- Parse stuff like: LATIN SMALL LETTER B, single space between words (in python 3.2.3)
parseUnicodeName :: Parser Char
parseUnicodeName = sepBy1 parseUnicodeNameWord (char ' ') >>=
                   error "StringParser.parseUnicodeName not implemented"

parseUnicodeNameWord :: Parser String
parseUnicodeNameWord = many1 letter

-- parse /[0-9a-fA-F]{4,4}/
parseFourDigitHex :: Parser Char
parseFourDigitHex = error "StringParser.parseFourDigitHex not implemented"

-- parse /[0-9a-fA-F]{8,8}/
parseEightDigitHex :: Parser Char
parseEightDigitHex = error "StringParser.parseEightDigitHex not implemented"

-- parse /\\[0-7]{1,3}/
parseOct :: Parser Char
parseOct = error "StringParser.parseOct not implemented"

-- parse /\\x[0-9a-fA-F]{3,3}/
parseHex :: Parser Char
parseHex = error "StringParser.parseHex not implemented"
