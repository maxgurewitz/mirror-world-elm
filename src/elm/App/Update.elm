module App.Update where

import Effects
import App.Model exposing (Model, initialSubModel, initialModel)
import Array
import Debug
import Task exposing (sleep, andThen)

type Action
  = Increment Int
  | AddSubView
  | NoOp

update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    AddSubView ->
      ({ model | subModels = Array.push initialSubModel model.subModels }, Effects.none)

    Increment n ->
      let
        newCount =
          Array.get n model.subModels
          |> Maybe.map (.count)
          |> Maybe.withDefault 0
          |> (+) 1

        newSubModels = Array.set n { count = newCount } model.subModels
        -- incrementNext =
        --   sleep 1000
        --   `andThen` (\j

        -- effect =
        --   if n == Array.length model.subModels
        --   then Effects.none
        --   else
      in
        ({ model | subModels = newSubModels }, Effects.none)

    NoOp -> (model, Effects.none)

init : (Model, Effects.Effects Action)
init = (initialModel, Effects.none)
