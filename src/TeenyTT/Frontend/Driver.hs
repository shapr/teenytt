-- | The main driver of @teenytt@.
module TeenyTT.Frontend.Driver
  ( runDriver
  , loadFile
  , lexFile
  , parseFile
  ) where

import Control.Monad.IO.Class

import Data.ByteString qualified as BS

import TeenyTT.Base.Pretty
import Prettyprinter.Render.Text
import TeenyTT.Frontend.Driver.Monad

import TeenyTT.Frontend.Parser qualified as P

unimplemented :: String -> IO ()
unimplemented msg = liftIO $ putStrLn $ "Unimplemented: " <> msg

loadFile :: FilePath -> IO ()
loadFile path = unimplemented "File loading"

lexFile :: FilePath -> IO ()
lexFile path = do
    bytes <- BS.readFile path
    runDriver bytes $ do
        toks <- P.tokenize path bytes
        liftIO $ putDoc $ vcat $ fmap pretty toks

parseFile :: FilePath -> IO ()
parseFile path = do
    bytes <- BS.readFile path
    runDriver bytes $ do
        toks <- P.tokenize path bytes
        liftIO $ putDoc $ vcat $ fmap pretty toks
        liftIO $ putStrLn $ '\n' : replicate 80 '-' 
        cmds <- liftIO $ P.commands path bytes
        liftIO $ print cmds

