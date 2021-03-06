module App.View where

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes as Attributes exposing (style, class, property)
import Signal
import Json.Encode
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

colorPeriod = 7
colorAngularVelocity = 360 / colorPeriod

generateColor : Int -> String
generateColor index =
  let
    colorArgs =
      [ toString (colorAngularVelocity * toFloat index)
      , "50%"
      , "50%"
      ]
      |> String.join ", "
  in
    "hsl(" ++ colorArgs ++ ")"

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
      [ "inset "
      , primaryShadowDepths
      , " rgba(0, 0, 0, 0.2), "
      , "inset "
      , secondaryShadowDepths
      , " rgba(0, 0, 0, 0.19)"
      ]
      |> String.join ""
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
      span
        (propIfFirstSubView
          (onClick address Update.AddSubView)
          [ style
              [ ("position", "relative")
              , ("-webkit-user-select", "none")
              , ("-moz-user-select", "none")
              , ("-ms-user-select", "none")
              , zIndexStyle
              , ("color", "white")
              ]
          , class "glyphicon glyphicon-plus"
          , property "aria-hidden" (Json.Encode.string "true")
          ]
          index
        )
        []

    incrementButton =
      span
        (propIfFirstSubView
          (onClick address (Update.SubViewAction index Update.Increment))
          [ style
              [ ("position", "relative")
              , ("-webkit-user-select", "none")
              , ("-moz-user-select", "none")
              , ("-ms-user-select", "none")
              , zIndexStyle
              , ("color", generateColor (subModel.count + 2))
              ]
          , class "glyphicon glyphicon-triangle-right"
          ]
          index
        )
        []

    subViewHeight =
      1 / fontProportion
      |> toString
      |> Utils.prepend "em"

    pointerBorderSize = fontSize
    pointerBorder = toString pointerBorderSize ++ "px solid " ++ generateColor (subModel.count + ceiling (colorPeriod / 2))
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

    controls =
      div
        [ style [ ("padding", ".5em") ] ]
        [ addSubViewButton
        , br [] []
        , incrementButton
        ]

    subViewContents =
      if mouseTopBase > 0 && mouseLeftBase > 0 && (subModel.mousePosition /= (0, 0))
      then [controls] ++ [mouseTracker]
      else [controls]

    primaryColor = generateColor subModel.count
    secondaryColor = generateColor (subModel.count + 1)

    backgroundImageArgs =
      [ "to bottom right"
      , primaryColor
      , secondaryColor ++ " 70%"
      ]
      |> String.join ", "

    backgroundImage = "linear-gradient(" ++ backgroundImageArgs ++ ")"

  in
    div
      [ style
          [ ("width", subViewWidth)
          , ("position", "absolute")
          , ("bottom", "0")
          , ("right", "0")
          , ("background-image", backgroundImage)
          , ("height", subViewHeight)
          , ("font-size",  fontSize |> toPx)
          , constructBoxShadow decay
          , ("margin", "0 auto")
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
