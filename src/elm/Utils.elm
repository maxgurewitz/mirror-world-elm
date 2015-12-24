module Utils where
import Array

last : Array.Array a -> Maybe a
last arr =
  Array.get ((Array.length arr) - 1) arr

subViewDecay : Int -> Float
subViewDecay index =
  e ^ -(toFloat index/3)
