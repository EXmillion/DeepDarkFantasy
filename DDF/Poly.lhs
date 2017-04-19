> {-# LANGUAGE
>   NoImplicitPrelude,
>   MultiParamTypeClasses,
>   RankNTypes,
>   ScopedTypeVariables,
>   FlexibleInstances,
>   FlexibleContexts,
>   UndecidableInstances,
>   IncoherentInstances,
>   PolyKinds,
>   LambdaCase,
>   NoMonomorphismRestriction,
>   TypeFamilies,
>   LiberalTypeSynonyms,
>   EmptyCase
> #-}

> module DDF.Poly where
> import Control.Monad (when)
> import DDF.Util
> import DDF.Lang
> import DDF.Show
> import DDF.WDiff ()
> import qualified Control.Monad as M
> import Prelude (Integer)
> import qualified Prelude as M
> import qualified DDF.Meta.Dual as M
> import DDF.Eval ()

Importing files and opening language extension...
So, our goal is to find x, where x * x + 2 * x + 3 = 27.
To do so, we try to minimize their difference squared (l2 norm).

> poly :: forall repr h. Lang repr => repr h (M.Double -> M.Double)
> poly = lam $ \x -> plus2 (mult2 x x) (plus2 (mult2 (double 2.0) x) (double 3.0))

poly x = x * x + (2 * x + 3)

> l2 = lam $ \x -> mult2 (minus2 x (double 27)) (minus2 x (double 27))

l2 x = (x - 27) * (x - 27)
l2 measure how far is the input from 27

> comp = com2 l2 poly

By composing the two, we can measure how far is x * x + 2 * x + 3 from 27.
We want to minimize this distance.

Now write a generic function that calculate x and return it.

> solve :: forall m. M.Monad m => (AST -> m ()) -> (Integer -> M.Double -> m ()) -> m M.Double
> solve doAST doIter = do

Let's begin by trying to print poly

>   doAST $ runShow poly vars 0
>   go 0 0
>   where

The main loop. i is step and w is weight (our current estimate of x).
We start by assuming x = 0 is the solution,
and minimize (comp x) by taking derivative of x, and decrease it whenever it is positive (and vice versa).

>     go :: Integer -> M.Double -> m M.Double
>     go i w | i < 200 = do
>       doIter i w
>       go (1 + i) $ w - 0.001 * M.dualDiff (runEval (runWDiff $ noEnv comp) () $ M.Dual (w, 1))

noEnv comp assume the term (which is a De Brujin Index term) need no environment (is free)
and it is a finally tagless term, with WDiff interpreter being implicitly applied,
which return another finally tagless term, but taking derivative of x.
it is then applied to Eval interpreter (which eval it in the meta language, haskell).
similar to runWDiff, we use runEval to take out the term from a newtype
now we apply the environment (remember it has no environment? so just stick a unit)
and a pair, the zeroth being x, the first being derivative of x, which is 1.
the whole computation return a pair of (x * x + (2 * x + 3) - 27)^2, and it's derivative.
we modify w using the derivative.

>     go _ w = M.return w

By running the program, you shall see
(\a -> (plus (mult a a) (plus (mult 2.0 a) 3.0)))
since we pretty print poly
followed by something like
0.0
9.6e-2
0.43573084645674215
1.1890033104995505
2.498644212525056
3.652210805402036
3.9662181049468925
3.9981203814732154
3.9999338218043157
3.999998509763363
3.9999999785234146
3.9999999998019136
3.9999999999988307
3.9999999999999956
3.999999999999999
which mean we found 4 as a soultion.
plugging it back to the equation, we can verify that (4 * 4) + 2 * 4 + 3 is indeed 27!

Now the main function:

> main :: IO ()
> main = do
>   d <- solve print printSquare
>   M.putStrLn $ "x is: " ++ (show d)
>   M.return ()
>   where
>     printSquare i x = when (isSquare i) (print x)

the only thing worth noting is that we print the weight in increasing interval,
so initially more weight is printed
