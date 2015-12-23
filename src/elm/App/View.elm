module App.View where

import Html exposing (..)
import Html.Events exposing (onClick)
import Signal
import App.Update as Update exposing (Action)
import App.Model exposing (Model, SubModel)
import Array

subView : Signal.Address Action -> Int -> SubModel -> Html
subView address index subModel =
  div
    []
    [ text (toString subModel.count)
    , button
        [ onClick address (Update.Increment index) ]
        [ text "Increment" ]
    ]

view : Signal.Address Action -> Model -> Html
view address model =
  let
    subViews =
      Array.indexedMap
        (\index subModel -> subView address index subModel)
        model.subModels

      |> Array.toList

    addSubViewButton =
      button
        [ onClick address Update.AddSubView ]
        [ text "Add Counter" ]

  in
    div [] (addSubViewButton :: subViews)
