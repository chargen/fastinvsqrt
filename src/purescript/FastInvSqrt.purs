module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, logShow)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.ArrayBuffer.ArrayBuffer (create)
import Data.ArrayBuffer.DataView (READER, WRITER, whole, getInt32, getFloat32, setInt32, setFloat32)
import Data.Int.Bits (shr)
import Data.Maybe (fromJust)
import Data.Monoid (mempty)
import Global (readFloat)
import Node.Process (stdin)
import Node.ReadLine (READLINE, setLineHandler, createInterface)
import Partial.Unsafe (unsafePartial)

main :: forall e. Eff (console :: CONSOLE, readline :: READLINE, err :: EXCEPTION, reader :: READER, writer :: WRITER | e) Unit
main = do
  interface <- createInterface stdin mempty
  setLineHandler interface $ \line ->
    logShow =<< fastInvSqrt (readFloat line)

fastInvSqrt :: forall e. Number -> Eff (reader :: READER, writer :: WRITER | e) Number
fastInvSqrt x = do
  i <- floatToUInt32 x
  let j = 0x5f3759df - unsafePartial i `shr` 1
  y <- uint32ToFloat j
  pure $ y * (1.5 - 0.5 * x * y * y)

floatToUInt32 :: forall e. Number -> Eff (reader :: READER, writer :: WRITER | e) Int
floatToUInt32 x = do
  let dataView = whole $ create 4
  setFloat32 dataView x 0
  unsafePartial $ map fromJust $ getInt32 dataView 0

uint32ToFloat :: forall e. Int -> Eff (reader :: READER, writer :: WRITER | e) Number
uint32ToFloat i = do
  let dataView = whole $ create 4
  setInt32 dataView i 0
  unsafePartial $ map fromJust $ getFloat32 dataView 0
