{-# LANGUAGE
  NoImplicitPrelude,
  ExplicitForAll,
  InstanceSigs,
  ScopedTypeVariables,
  TypeApplications,
  FlexibleContexts,
  UndecidableInstances,
  TypeFamilies
#-}

module DDF.WDiff where

import DDF.DLang
import qualified Data.Map as M
import qualified DDF.Map as Map
import DDF.InfDiff ()

instance DBI r => DBI (WDiff r v) where
  z = WDiff z
  s (WDiff x) = WDiff $ s x
  abs (WDiff f) = WDiff $ abs f
  app (WDiff f) (WDiff x) = WDiff $ app f x
  hoas f = WDiff $ hoas (\x -> runWDiff $ f $ WDiff x)
  liftEnv (WDiff x) = WDiff $ liftEnv x

instance Bool r => Bool (WDiff r v) where
  bool x = WDiff $ bool x
  ite = WDiff ite

instance Char r => Char (WDiff r v) where
  char = WDiff . char

instance Prod r => Prod (WDiff r v) where
  mkProd = WDiff mkProd
  zro = WDiff zro
  fst = WDiff fst

instance Dual r => Dual (WDiff r v) where
  dual = WDiff $ dual
  runDual = WDiff $ runDual

instance (Vector r v, Double r, Dual r) => Double (WDiff r v) where
  double x = WDiff $ mkDual2 (double x) zero
  doublePlus = WDiff $ lam2 $ \l r ->
    mkDual2 (plus2 (dualOrig1 l) (dualOrig1 r)) (plus2 (dualDiff1 l) (dualDiff1 r))
  doubleMinus = WDiff $ lam2 $ \l r ->
    mkDual2 (minus2 (dualOrig1 l) (dualOrig1 r)) (minus2 (dualDiff1 l) (dualDiff1 r))
  doubleMult = WDiff $ lam2 $ \l r ->
    mkDual2 (mult2 (dualOrig1 l) (dualOrig1 r))
      (plus2 (mult2 (dualOrig1 l) (dualDiff1 r)) (mult2 (dualOrig1 r) (dualDiff1 l)))
  doubleDivide = WDiff $ lam2 $ \l r ->
    mkDual2 (divide2 (dualOrig1 l) (dualOrig1 r))
      (divide2 (minus2 (mult2 (dualOrig1 r) (dualDiff1 l)) (mult2 (dualOrig1 l) (dualDiff1 r)))
        (mult2 (dualOrig1 r) (dualOrig1 r)))
  doubleExp = WDiff $ lam $ \x -> let_2 (doubleExp1 (dualOrig1 x)) (lam $ \e -> mkDual2 e (mult2 e (dualDiff1 x)))

instance (Vector r v, Lang r) => Float (WDiff r v) where
  float x = WDiff $ mkDual2 (float x) zero
  floatPlus = WDiff $ lam2 $ \l r ->
    mkDual2 (plus2 (dualOrig1 l) (dualOrig1 r)) (plus2 (dualDiff1 l) (dualDiff1 r))
  floatMinus = WDiff $ lam2 $ \l r ->
    mkDual2 (minus2 (dualOrig1 l) (dualOrig1 r)) (minus2 (dualDiff1 l) (dualDiff1 r))
  floatMult = WDiff $ lam2 $ \l r ->
    mkDual2 (mult2 (float2Double1 (dualOrig1 l)) (dualOrig1 r))
      (plus2 (mult2 (float2Double1 (dualOrig1 l)) (dualDiff1 r)) (mult2 (float2Double1 (dualOrig1 r)) (dualDiff1 l)))
  floatDivide = WDiff $ lam2 $ \l r ->
    mkDual2 (divide2 (dualOrig1 l) (float2Double1 (dualOrig1 r)))
      (divide2 (minus2 (mult2 (float2Double1 (dualOrig1 r)) (dualDiff1 l)) (mult2 (float2Double1 (dualOrig1 l)) (dualDiff1 r)))
        (float2Double1 (mult2 (float2Double1 (dualOrig1 r)) (dualOrig1 r))))
  floatExp = WDiff (lam $ \x -> let_2 (floatExp1 (dualOrig1 x)) (lam $ \e -> mkDual2 e (mult2 (float2Double1 e) (dualDiff1 x))))

instance Option r => Option (WDiff r v) where
  nothing = WDiff nothing
  just = WDiff just
  optionMatch = WDiff optionMatch

instance Map.Map r => Map.Map (WDiff r v) where
  empty = WDiff Map.empty
  singleton = WDiff Map.singleton
  lookup :: forall h k a. Map.Ord k => WDiff r v h (k -> M.Map k a -> Maybe a)
  lookup = withDict (Map.diffOrd (Proxy :: Proxy (v, k))) (WDiff Map.lookup)
  alter :: forall h k a. Map.Ord k => WDiff r v h ((Maybe a -> Maybe a) -> k -> M.Map k a -> M.Map k a)
  alter = withDict (Map.diffOrd (Proxy :: Proxy (v, k))) (WDiff Map.alter)
  mapMap = WDiff Map.mapMap

instance Bimap r => Bimap (WDiff r v) where

instance (Vector r v, Lang r) => Lang (WDiff r v) where
  fix = WDiff fix
  left = WDiff left
  right = WDiff right
  sumMatch = WDiff sumMatch
  unit = WDiff unit
  exfalso = WDiff exfalso
  ioRet = WDiff ioRet
  ioBind = WDiff ioBind
  nil = WDiff nil
  cons = WDiff cons
  listMatch = WDiff listMatch
  ioMap = WDiff ioMap
  writer = WDiff writer
  runWriter = WDiff runWriter
  float2Double = WDiff $ bimap2 float2Double id
  double2Float = WDiff $ bimap2 double2Float id
  state = WDiff state
  runState = WDiff runState
  putStrLn = WDiff putStrLn

instance (DiffVector r v, Vector r v, DLang r, RTDiff r v) => DLang (WDiff r v) where
  nextDiff p = WDiff (nextDiff p)
  infDiffGet :: forall h x. RTDiff (WDiff r v) x => WDiff r v h (InfDiff Eval () x -> x)
  infDiffGet = WDiff $ (infDiffGet `com2` nextDiff (Proxy :: Proxy v)) \\ rtDiffDiff @r @v @x Proxy Proxy
  intDLang _ = intDLang @r Proxy
  litInfDiff x = WDiff $ litInfDiff x
  infDiffApp = WDiff infDiffApp
  rtDiffDiff _ p = rtDiffDiff @r Proxy p
  rtdd _ = rtdd @r Proxy

type instance RTDiff (WDiff r v) x = RTDiff r x 
type instance DiffInt (WDiff r v) = DiffInt r
type instance DiffVector (WDiff r _) v = DiffVector r v