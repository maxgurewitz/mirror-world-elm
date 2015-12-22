module Main where

import Html exposing (..)
import App.Example

import App.Update
import App.View exposing (view)
import StartApp

app =
  StartApp.start
    { init = App.Update.init
    , update = App.Update.update
    , view = App.View.view
    , inputs = []
    }

main = app.html

-- sample app
-- https://github.com/elm-lang/package.elm-lang.org/tree/master/src/frontend
