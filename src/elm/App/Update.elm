module App.Update where

import Effects
import App.Model exposing (Model, initialSubModel, initialModel, SubModel)
import Array
import Utils
import Task exposing (sleep, andThen, succeed)
import Debug

type Action
  = Increment Int
  | SetWindowDimensions (Int, Int)
  | SetMousePosition Int (Int, Int)
  | AddSubView
  | NoOp

delayedAction : Action -> Array.Array SubModel -> Int -> Effects.Effects Action
delayedAction action subModels index =
  sleep (2000 * (Utils.subViewDecay index))
    `andThen`
      (\_ ->
        if index + 1 == Array.length subModels
        then succeed NoOp
        else succeed action
      )

    |> Effects.task

update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    AddSubView ->
      let
        latestSubModel =
          model.subModels
          |> Utils.last
          |> Maybe.withDefault initialSubModel

        newSubModels = Array.push latestSubModel model.subModels
      in
        ({ model | subModels = newSubModels }, Effects.none)

    Increment n ->
      let
        currentSubModel =
          Array.get n model.subModels
          |> Maybe.withDefault initialSubModel

        newSubModel = { currentSubModel | count = currentSubModel.count + 1 }
        newSubModels = Array.set n newSubModel model.subModels
        incrementNext =
          delayedAction (Increment (n + 1)) model.subModels n
      in
        ({ model | subModels = newSubModels }, incrementNext)

    SetWindowDimensions (x, y) ->
      ({model | windowDimensions = (x, y) }, Effects.none)

    SetMousePosition n (x, y) ->
      let
        currentSubModel =
          Array.get n model.subModels
          |> Maybe.withDefault initialSubModel

        newSubModel = { currentSubModel | mousePosition = (x, y) }
        newSubModels = Array.set n newSubModel model.subModels
        setMousePositionOnNext =
          delayedAction (SetMousePosition (n + 1) (x, y)) model.subModels n
      in
        ({ model | subModels = newSubModels }, setMousePositionOnNext)

    NoOp -> (model, Effects.none)

init : (Model, Effects.Effects Action)
init = (initialModel, Effects.tick (\_ -> NoOp))
