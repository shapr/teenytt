-- | Diagnostics
module TeenyTT.Base.Diagnostic
  ( Diagnostic(..)
  , Severity(..)
  , Code(..)
  , Snippet(..)
  , render
  , impossible
  ) where

import Control.Exception

import Data.Text (Text)
import Data.ByteString (ByteString)
import Data.Text.Encoding (decodeUtf8)

import TeenyTT.Base.Location
import TeenyTT.Base.Pretty

--------------------------------------------------------------------------------
-- Diagnostics

data Diagnostic
    = Diagnostic
    { severity :: Severity
    , code     :: Code
    , snippets :: [Snippet]
    }
    deriving stock Show
    deriving anyclass Exception

data Severity
    = Info
    | Warning
    | Error
    | Panic
    deriving stock Show

instance Pretty Severity where
    pretty Info = "Info"
    pretty Warning = "Warning"
    pretty Error = "Error"
    pretty Panic = "Panic"

--------------------------------------------------------------------------------
-- Error Codes

data Code
    -- Info
    = HoleInfo
    -- Errors
    | LexError
    | ParseError
    | ConversionError
    | ExpectedConnective
    | UnboundVariable
    | MalformedCase
    | CannotEliminate
    | CannotSynth
    | NotAType
    -- Panics
    | NotImplemented
    | Impossible Text
    deriving stock Show

instance Pretty Code where
    pretty HoleInfo           = "[I001]: Type Hole"
    pretty LexError           = "[E001]: Lexer Error"
    pretty ParseError         = "[E002]: Parser Error"
    pretty ConversionError    = "[E003]: Conversion Error"
    pretty ExpectedConnective = "[E004]: Refiner Error"
    pretty UnboundVariable    = "[E005]: Refiner Error"
    pretty MalformedCase      = "[E006]: Refiner Error"
    pretty CannotEliminate    = "[E007]: Refiner Error"
    pretty CannotSynth        = "[E008]: Refiner Error"
    pretty NotAType           = "[E009]: Refiner Error"
    pretty NotImplemented     = "[XXXX]: Not Implemented"
    pretty (Impossible msg)   = "[XXXX]: The Impossible happened:" <+> pretty msg

--------------------------------------------------------------------------------
-- Snippets

data Snippet
    = Snippet
    { location :: Span
    , message  :: Doc ()
    }
    deriving stock Show

--------------------------------------------------------------------------------
-- Rendering

renderSnippet :: ByteString -> Snippet -> Doc ()
renderSnippet buffer snippet =
    let sourceBytes = sliceLine snippet.location buffer
        source = pretty $ decodeUtf8 $ sourceBytes
        underline = pretty $ replicate snippet.location.width '^'
        fringeWidth = snippet.location.startLine `div` 10 + 2
        location = pretty snippet.location.filename <> ":" <> pretty snippet.location.startLine <> ":" <> pretty snippet.location.startCol
    -- [FIXME: Reed M, 02/06/2022] For some reason the error locations are jacked up for parse errors.
    in vcat [ location <+> snippet.message
            , indent fringeWidth "│"
            , pretty snippet.location.startLine <+> "│" <+> source
            , indent fringeWidth "│" <+> indent snippet.location.startCol underline
            ]

render :: ByteString -> Diagnostic -> Doc ()
render buffer diag =
    let header = pretty diag.severity <+> (pretty diag.code)
    in vcat (header:fmap (renderSnippet buffer) diag.snippets)

impossible :: Text -> a
impossible msg = throw $
    Diagnostic { severity = Panic
               , code = Impossible msg
               , snippets = []
               }
