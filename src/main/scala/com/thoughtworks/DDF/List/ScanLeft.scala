package com.thoughtworks.DDF.List

import com.thoughtworks.DDF.Product.Product

trait ScanLeft[Info[_], Repr[_]] extends Product[Info, Repr] with ListMin[Info, Repr] {
  def scanLeft[A, B](implicit ai: Info[A], bi: Info[B]): Repr[(B => A => B) => B => scala.List[A] => scala.List[B]]

  final def scanLeft_[A, B]: Repr[B => A => B] => Repr[B => scala.List[A] => scala.List[B]] = f =>
    app(scanLeft(arrowDomainInfo(arrowRangeInfo(reprInfo(f))), arrowDomainInfo(reprInfo(f))))(f)

  final def scanLeft__[A, B]: Repr[B => A => B] => Repr[B] => Repr[scala.List[A] => scala.List[B]] = f =>
    app(scanLeft_(f))

  final def scanLeft___[A, B]: Repr[B => A => B] => Repr[B] => Repr[scala.List[A]] => Repr[scala.List[B]] = f => x =>
    app(scanLeft__(f)(x))
}