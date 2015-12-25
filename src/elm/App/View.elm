module App.View where

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes as Attributes exposing (style, class)
import Signal
import App.Update as Update exposing (Action)
import App.Model exposing (Model, SubModel, initialSubModel)
import Array
import String
import Debug
import Utils

fontProportion = 1 / 20

propIfFirstSubView : Attribute -> List Attribute -> Int -> List Attribute
propIfFirstSubView attribute defaultAttributes index =
  if index == 0
  then (attribute :: defaultAttributes)
  else defaultAttributes

toPx : Float -> String
toPx number = number |> toString |> Utils.prepend "px"

constructBoxShadow : Float -> (String, String)
constructBoxShadow decay =
  let
    primaryShadowBlur = 24 * decay |> toPx
    primaryShadowDepth =  6 * decay |> toPx

    secondaryShadowBlur = 77 * decay |> toPx
    secondaryShadowDepth =  3 * decay |> toPx

    primaryShadowDepths =
      ["0", "0", primaryShadowBlur, primaryShadowDepth]
      |> String.join " "

    secondaryShadowDepths =
      ["0", "0", secondaryShadowBlur, secondaryShadowDepth]
      |> String.join " "

    boxShadow =
      primaryShadowDepths
        |> Utils.prepend " rgba(0, 0, 0, 0.2), "
        |> Utils.prepend secondaryShadowDepths
        |> Utils.prepend " rgba(0, 0, 0, 0.19)"
  in
    ( "box-shadow", boxShadow)

subView : Signal.Address Action -> Int -> Model -> Html
subView address index model =
  let
    zIndex = 10 * index + 5
    zIndexStyle = ("z-index", zIndex |> toString)

    subModel =
      Array.get index model.subModels
        |> Maybe.withDefault initialSubModel

    decay = Utils.subViewDecay index
    fontSize =
      (snd model.windowDimensions |> toFloat) * fontProportion * decay

    addSubViewButton =
      a
        (propIfFirstSubView
          (onClick address Update.AddSubView)
          [ style
              [ ("border", "1px black solid")
              , ("position", "relative")
              , ("-webkit-user-select", "none")
              , ("-moz-user-select", "none")
              , ("-ms-user-select", "none")
              , zIndexStyle
              ]
          ]
          index
        )
        [ text "Add Counter" ]

    incrementButton =
      a
        (propIfFirstSubView
          (onClick address (Update.SubViewAction index Update.Increment))
          [ style
              [ ("position", "relative")
              , ("-webkit-user-select", "none")
              , ("-moz-user-select", "none")
              , ("-ms-user-select", "none")
              , zIndexStyle
              ]
          ]
          index
        )
        [ text ("Increment: " ++ (toString subModel.count)) ]

    subViewHeight =
      1 / fontProportion
      |> toString
      |> Utils.prepend "em"

    pointerBorderSize = fontSize
    pointerBorder = toString pointerBorderSize ++ "px green solid"
    pointerBorderDiameter = toString (2 * pointerBorderSize) ++ "px"

    mouseOffset = pointerBorderSize * 2

    mouseLeftBase = ((fst model.windowDimensions |> toFloat) - (fst subModel.mousePosition |> toFloat) - pointerBorderSize / decay)
    mouseLeft = mouseLeftBase * decay |> toPx

    mouseTopBase = ((snd model.windowDimensions |> toFloat) - (snd subModel.mousePosition |> toFloat) - pointerBorderSize / decay)
    mouseTop = mouseTopBase * decay |> toPx

    mouseTrackerZIndexStyle = ("z-index", zIndex - 2 |> toString)

    mouseTracker =
      div
        [ style
            [ ("width", pointerBorderDiameter)
            , ("height", pointerBorderDiameter)
            , ("position", "absolute")
            , ("bottom", mouseTop)
            , ("right", mouseLeft)
            , mouseTrackerZIndexStyle
            ]
        ]
        [ div
            [ style
                [ ("border-radius", "100%")
                , ("border", pointerBorder)
                , mouseTrackerZIndexStyle
                ]
            ]
            []
        ]

    subViewWidth =
      model.windowDimensions
      |> fst
      |> toFloat
      |> (*) decay
      |> toPx

    defaultSubViewContents =
      [ addSubViewButton
      , br [] []
      , incrementButton
      ]

    subViewContents =
      if mouseTopBase > 0 && mouseLeftBase > 0 && (subModel.mousePosition /= (0, 0))
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
          , constructBoxShadow decay
          , ("margin", "0 auto")
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
