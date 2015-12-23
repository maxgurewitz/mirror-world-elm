module Main where

import Html exposing (..)
import App.Example

import App.Update
import App.View exposing (view)
import Effects
import Task
import StartApp

app =
  StartApp.start
    { init = App.Update.init
    , update = App.Update.update
    , view = App.View.view
    , inputs = []
    }

main = app.html

port worker : Signal (Task.Task Effects.Never ())
port worker = app.tasks

-- sample app
-- https://github.com/elm-lang/package.elm-lang.org/tree/master/src/frontend
