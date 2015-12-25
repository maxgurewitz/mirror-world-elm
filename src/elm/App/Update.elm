module App.Update where

import Effects
import App.Model exposing (Model, initialSubModel, initialModel, SubModel)
import Array
import Utils
import Task exposing (sleep, andThen, succeed)
import Debug

type Action =
  SetWindowDimensions (Int, Int)
  | SubViewAction Int SubViewUpdate
  | AddSubView
  | NoOp

type SubViewUpdate =
  Increment
  | SetMousePosition (Int, Int)
  | NoSubViewUpdate

delayedSubViewUpdate : SubViewUpdate -> Array.Array SubModel -> Int -> Effects.Effects Action
delayedSubViewUpdate update subModels index =
  sleep (2000 * (Utils.subViewDecay index))
    `andThen`
      (\_ ->
        let
          boundedSubViewUpdate =
            if index + 1 == Array.length subModels
            then NoSubViewUpdate
            else update

          boundedSubViewAction = SubViewAction (index + 1) boundedSubViewUpdate
        in
           succeed boundedSubViewAction
      )

    |> Effects.task


updateSubView : Int -> SubViewUpdate -> Model -> (Model, Effects.Effects Action)
updateSubView n action model =
  let
    currentSubModel =
      Array.get n model.subModels
      |> Maybe.withDefault initialSubModel
  in
    case action of
      Increment ->
        let
          newSubModel = { currentSubModel | count = currentSubModel.count + 1 }
          newSubModels = Array.set n newSubModel model.subModels

          incrementNext =
            delayedSubViewUpdate Increment model.subModels n
        in
          ({ model | subModels = newSubModels }, incrementNext)

      SetMousePosition (x, y) ->
        let
          newSubModel = { currentSubModel | mousePosition = (x, y) }
          newSubModels = Array.set n newSubModel model.subModels

          setMousePositionOnNext =
            delayedSubViewUpdate (SetMousePosition (x, y)) model.subModels n
        in
          ({ model | subModels = newSubModels }, setMousePositionOnNext)

      NoSubViewUpdate -> (model, Effects.none)


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

    SubViewAction n subViewUpdate ->
      updateSubView n subViewUpdate model

    SetWindowDimensions (x, y) ->
      ({model | windowDimensions = (x, y) }, Effects.none)

    NoOp -> (model, Effects.none)

init : (Model, Effects.Effects Action)
init = (initialModel, Effects.tick (\_ -> NoOp))
