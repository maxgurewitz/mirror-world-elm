module Utils where
import Array

last : Array.Array a -> Maybe a
last arr =
  Array.get ((Array.length arr) - 1) arr

prepend : String -> String -> String
prepend pre post =
  post ++ pre

subViewDecay : Int -> Float
subViewDecay index =
  e ^ -(toFloat index/3)
