module App.View where

import Html exposing (..)
import Html.Events exposing (onClick)
import Signal
import App.Update as Update exposing (Action)
import App.Model exposing (Model)

view : Signal.Address Action -> Model -> Html
view address model =
  div
    []
    [ text (toString model.count)
    , button
        [ onClick address Update.Increment ]
        [ text "Increment" ]
    ]
