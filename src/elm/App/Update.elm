module App.Update where

import Effects
import App.Model exposing (Model, initialSubModel, initialModel)
import Array
import Utils
import Task exposing (sleep, andThen, succeed)

type Action
  = Increment Int
  | SetWindowDimensions (Int, Int)
  | AddSubView
  | NoOp

getPositionMailbox = Signal.mailbox ""

update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    AddSubView ->
      let
        latestSubModel =
          model.subModels
          |> Utils.last
          |> Maybe.withDefault initialSubModel
      in
        ({ model | subModels = Array.push latestSubModel model.subModels }, Effects.none)

    Increment n ->
      let
        newCount =
          Array.get n model.subModels
          |> Maybe.map (.count)
          |> Maybe.withDefault 0
          |> (+) 1

        newSubModels = Array.set n { count = newCount } model.subModels

        incrementNext =
          sleep (2000 * (Utils.subViewDecay n))
            `andThen`
              (\_ ->
                if n + 1 == Array.length model.subModels
                then succeed NoOp
                else succeed (Increment (n + 1))
              )

            |> Effects.task
      in
        ({ model | subModels = newSubModels }, incrementNext)

    SetWindowDimensions (x, y) ->
      ({model | windowDimensions = (x, y) }, Effects.none)

    NoOp -> (model, Effects.none)

init : (Model, Effects.Effects Action)
init = (initialModel, Effects.tick (\_ -> NoOp))
