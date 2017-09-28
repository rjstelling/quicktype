module Main
    ( main
    , urlsFromJsonGrammar
    , intSentinel
    ) where

import IRGraph

import Config as Config
import Control.Monad.State (modify)
import Core (Either, Error, SourceCode, bind, discard, pure, ($), (<$>))
import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode (decodeJson) as J
import Data.StrMap as SM
import Doc as Doc
import IR (execIR, normalizeGraphOrder, replaceNoInformationWithAnyType)
import IRTypeable (intSentinel) as IRTypeable
import IRTypeable (makeTypes)
import Options (makeOptionValues)
import Transformations as T
import UrlGrammar (GrammarMap(..), generate)

-- TODO find a better way to rexport these
intSentinel :: String
intSentinel = IRTypeable.intSentinel

-- json is a Foreign object whose type is defined in /cli/src/Main.d.ts
main :: Json -> Either Error SourceCode
main json = do
    config <- Config.parseConfig json

    let samples = Config.topLevelSamples config
    let schemas = Config.topLevelSchemas config
    let optionStrings = Config.rendererOptions config

    renderer <- Config.renderer config

    graph <- normalizeGraphOrder <$> execIR do
        makeTypes samples
        T.replaceSimilarClasses
        modify regatherClassNames

        -- We don't regatherClassNames for schemas
        -- TODO Mark, why not? Tests fail if we do.
        makeTypes schemas
        modify regatherUnionNames
        replaceNoInformationWithAnyType

    let optionValues = makeOptionValues renderer.options optionStrings
    pure $ Doc.runRenderer renderer graph optionValues

urlsFromJsonGrammar :: Json -> Either Error (SM.StrMap (Array String))
urlsFromJsonGrammar json = do
    GrammarMap grammarMap <- J.decodeJson json
    pure $ generate <$> grammarMap
