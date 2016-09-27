package com.thoughtworks.DDF

import com.thoughtworks.DDF.Combinators.CombEval
import com.thoughtworks.DDF.Double.DEval
import com.thoughtworks.DDF.Product.ProdEval
import com.thoughtworks.DDF.Sum.SumEval

class EvalLang extends Lang[Loss, Eval] with CombEval with ProdEval with DEval with SumEval