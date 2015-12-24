module App.Model where

import Array exposing (Array, fromList)

type alias SubModel =
  { count : Int
  }

type alias Model =
  { subModels : Array SubModel
  , windowDimensions : (Int, Int)
  }

initialSubModel : SubModel
initialSubModel = { count = 0 }

initialModel : Model
initialModel =
  { subModels = fromList [ initialSubModel ]
  , windowDimensions = (0, 0)
  }
