{-# LANGUAGE NoImplicitPrelude, TypeFamilies, TypeApplications, ScopedTypeVariables #-}

module DDF.UnHOAS where

import DDF.Lang
import qualified DDF.Map as Map

instance DBI repr => DBI (UnHOAS repr) where
  z = UnHOAS z
  s (UnHOAS x) = UnHOAS $ s x
  abs (UnHOAS x) = UnHOAS $ abs x
  app (UnHOAS f) (UnHOAS x) = UnHOAS $ app f x
  liftEnv (UnHOAS x) = UnHOAS $ liftEnv x

instance Bool r => Bool (UnHOAS r) where
  bool = UnHOAS . bool
  ite = UnHOAS ite

instance Char r => Char (UnHOAS r) where
  char = UnHOAS . char

instance Prod r => Prod (UnHOAS r) where
  mkProd = UnHOAS mkProd
  zro = UnHOAS zro
  fst = UnHOAS fst

instance Double r => Double (UnHOAS r) where
  double = UnHOAS . double
  doublePlus = UnHOAS doublePlus
  doubleMinus = UnHOAS doubleMinus
  doubleMult = UnHOAS doubleMult
  doubleDivide = UnHOAS doubleDivide
  doubleExp = UnHOAS doubleExp

instance Float r => Float (UnHOAS r) where
  float = UnHOAS . float
  floatPlus = UnHOAS floatPlus
  floatMinus = UnHOAS floatMinus
  floatMult = UnHOAS floatMult
  floatDivide = UnHOAS floatDivide
  floatExp = UnHOAS floatExp

instance Option r => Option (UnHOAS r) where
  nothing = UnHOAS nothing
  just = UnHOAS just
  optionMatch = UnHOAS optionMatch

instance Map.Map r => Map.Map (UnHOAS r) where
  empty = UnHOAS Map.empty
  singleton = UnHOAS Map.singleton
  alter = UnHOAS Map.alter
  lookup = UnHOAS Map.lookup
  mapMap = UnHOAS Map.mapMap

instance Bimap r => Bimap (UnHOAS r) where

instance Dual r => Dual (UnHOAS r) where
  dual = UnHOAS dual
  runDual = UnHOAS runDual

instance Unit r => Unit (UnHOAS r) where
  unit = UnHOAS unit

instance Sum r => Sum (UnHOAS r) where
  left = UnHOAS left
  right = UnHOAS right
  sumMatch = UnHOAS sumMatch

instance Int r => Int (UnHOAS r) where
  int = UnHOAS . int

instance Fix r => Fix (UnHOAS r) where
  fix = UnHOAS fix

instance IO r => IO (UnHOAS r) where
  ioMap = UnHOAS ioMap
  ioRet = UnHOAS ioRet
  ioBind = UnHOAS ioBind
  putStrLn = UnHOAS putStrLn

instance List r => List (UnHOAS r) where
  nil = UnHOAS nil
  cons = UnHOAS cons
  listMatch = UnHOAS listMatch

instance Lang r => Lang (UnHOAS r) where
  float2Double = UnHOAS float2Double
  exfalso = UnHOAS exfalso
  writer = UnHOAS writer
  runWriter = UnHOAS runWriter
  double2Float = UnHOAS double2Float
  state = UnHOAS state
  runState = UnHOAS runState
