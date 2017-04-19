{-# LANGUAGE
  NoImplicitPrelude,
  LambdaCase,
  TypeFamilies,
  FlexibleContexts
#-}

module DDF.Eval where

import DDF.ImportMeta
import qualified Prelude as M
import qualified Control.Monad.Writer as M (WriterT(WriterT), runWriter)
import qualified Control.Monad.State as M
import qualified GHC.Float as M
import qualified Data.Functor.Identity as M
import qualified Data.Bool as M
import qualified Data.Map as M.Map
import qualified DDF.Meta.Dual as M
import qualified DDF.Map as Map
import DDF.DLang

comb = Eval . M.const

instance DBI Eval where
  z = Eval M.fst
  s (Eval a) = Eval $ a . M.snd
  abs (Eval f) = Eval $ \h a -> f (a, h)
  app (Eval f) (Eval x) = Eval $ \h -> f h $ x h
  liftEnv (Eval x) = Eval $ \_ -> x ()

instance Bool Eval where
  bool = comb
  ite = comb M.bool

instance Char Eval where
  char = comb

instance Prod Eval where
  mkProd = comb (,)
  zro = comb M.fst
  fst = comb M.snd

instance Double Eval where
  double = comb
  doublePlus = comb (+)
  doubleMinus = comb (-)
  doubleMult = comb (*)
  doubleDivide = comb (/)
  doubleExp = comb M.exp

instance Float Eval where
  float = comb
  floatPlus = comb (+)
  floatMinus = comb (-)
  floatMult = comb (*)
  floatDivide = comb (/)
  floatExp = comb M.exp

instance Option Eval where
  nothing = comb M.Nothing
  just = comb M.Just
  optionMatch = comb $ \l r -> \case
                              M.Nothing -> l
                              M.Just x -> r x

instance Map.Map Eval where
  empty = comb M.Map.empty
  singleton = comb M.Map.singleton
  lookup = comb M.Map.lookup
  alter = comb M.Map.alter
  mapMap = comb M.fmap

instance Bimap Eval where

instance Dual Eval where
  dual = comb M.Dual
  runDual = comb M.runDual

instance Lang Eval where
  fix = comb loop
    where loop x = x $ loop x
  left = comb M.Left
  right = comb M.Right
  sumMatch = comb $ \l r -> \case
                             M.Left x -> l x
                             M.Right x -> r x
  unit = comb ()
  exfalso = comb absurd
  ioRet = comb M.return
  ioBind = comb (>>=)
  nil = comb []
  cons = comb (:)
  listMatch = comb $ \l r -> \case
                            [] -> l
                            x:xs -> r x xs
  ioMap = comb M.fmap
  writer = comb (M.WriterT . M.Identity)
  runWriter = comb M.runWriter
  float2Double = comb M.float2Double
  double2Float = comb M.double2Float
  state = comb M.state
  runState = comb M.runState
  putStrLn = comb M.putStrLn

instance DLang Eval where