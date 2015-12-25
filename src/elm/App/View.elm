module App.View where

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (style)
import Signal
import App.Update as Update exposing (Action)
import App.Model exposing (Model, SubModel, initialSubModel)
import Array
import Debug
import Utils

subView : Signal.Address Action -> Int -> Model -> Html
subView address index model =
  let
    zIndexStyle = ("z-index", 10 * index |> toString)
    subModel =
      Array.get index model.subModels
        |> Maybe.withDefault initialSubModel

    fontProportion = 1 / 20
    decay = Utils.subViewDecay index
    fontSize =
      (snd model.windowDimensions |> toFloat) * fontProportion * decay

    addSubViewButton =
      a
        [ style
            [ ("border", "1px black solid") ]
        , onClick address Update.AddSubView
        ]
        [ text "Add Counter" ]

    incrementButton =
      a
        [ style
          [ ("border", "1px black solid") ]
        , onClick address (Update.SubViewAction index Update.Increment)
        ]
        [ text "Increment" ]

    subViewHeight =
      1 / fontProportion
      |> toString >> (flip (++)) "em"

    mouseOffset = 5

    mouseLeftBase = ((fst model.windowDimensions |> toFloat) - (fst subModel.mousePosition |> toFloat) - mouseOffset)
    mouseLeft =
      mouseLeftBase * decay
      |> toString
      |> (flip (++)) "px"

    mouseTopBase = ((snd model.windowDimensions |> toFloat) - (snd subModel.mousePosition |> toFloat) - mouseOffset)
    mouseTop =
      mouseTopBase * decay
      |> toString
      |> (flip (++)) "px"

    pointerBorder = (fontSize / 3 |> toString) ++ "px green solid"

    mouseTracker =
      div
        [ style
            [ ("width", "1px")
            , ("height", "1px")
            , ("position", "absolute")
            , ("bottom", mouseTop)
            , ("right", mouseLeft)
            , zIndexStyle
            ]
        ]
        [ div
            [ style
                [ ("border-radius", "100%")
                , ("border", pointerBorder)
                , ("width", "1px")
                , ("height", "1px")
                , zIndexStyle
                ]
            ]
            []
        ]

    subViewWidth =
      model.windowDimensions
      |> fst
      |> toFloat
      |> (*) (Utils.subViewDecay index)
      |> toString >> (flip (++)) "px"

    defaultSubViewContents =
      [ addSubViewButton
      , br [] []
      , text (toString subModel.count)
      , incrementButton
      ]

    subViewContents =
      if mouseTopBase > mouseOffset ^ 2 && mouseLeftBase > mouseOffset ^ 2 * mouseOffset && (subModel.mousePosition /= (0, 0))
      then defaultSubViewContents ++ [mouseTracker]
      else defaultSubViewContents

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
          , ("background-color", "white")
          , zIndexStyle
          ]
      ]
      subViewContents

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
