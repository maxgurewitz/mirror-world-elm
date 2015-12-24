module App.View where

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (style)
import Signal
import App.Update as Update exposing (Action)
import App.Model exposing (Model, SubModel, initialSubModel)
import Array
import Utils

subView : Signal.Address Action -> Int -> Model -> Html
subView address index model =
  let
    subModel =
      Array.get index model.subModels
        |> Maybe.withDefault initialSubModel

    fontProportion = 1 / 20
    fontSize =
      (snd model.windowDimensions |> toFloat) * fontProportion * Utils.subViewDecay index

    addSubViewButton =
      a
        [ onClick address Update.AddSubView ]
        [ text "Add Counter" ]

    incrementButton =
      a
        [ onClick address (Update.Increment index) ]
        [ text "Increment" ]

    appendEm = toString >> (flip (++)) "em"

    subViewHeight =
      1 / fontProportion
      |> toString >> (flip (++)) "em"

    subViewWidth =
      model.windowDimensions
      |> fst
      |> toFloat
      |> (*) (Utils.subViewDecay index)
      |> toString >> (flip (++)) "px"

  in
    div
      [ style
          [ ("width", subViewWidth)
          , ("position", "absolute")
          , ("bottom", "0")
          , ("right", "0")
          , ("height", subViewHeight)
          , ("font-size", (toString fontSize) ++ "px")
          , ("margin", "0 auto")
          , ("border", "1px solid black")
          ]
      ]
      [ addSubViewButton
      , br [] []
      , text (toString subModel.count)
      , incrementButton
      ]

view : Signal.Address Action -> Model -> Html
view address model =
  let
    subViews =
      Array.indexedMap
        (\index _ -> subView address index model)
        model.subModels

      |> Array.toList

  in
    div [] subViews
