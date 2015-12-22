module App.Update where

import Effects
import App.Model exposing (Model, initialModel)

type Action
  = Increment
  | NoOp

update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    Increment -> ({ model | count = model.count + 1 }, Effects.none)
    NoOp -> (model, Effects.none)

init : (Model, Effects.Effects Action)
init = (initialModel, Effects.none)
