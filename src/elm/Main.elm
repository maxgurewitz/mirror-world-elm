module Main where

import Html exposing (..)
import App.Example

import App.Update
import App.View exposing (view)
import Effects
import Task
import Start
import Signal
import Window

app =
  Start.start
    { init = App.Update.init
    , update = App.Update.update
    , view = App.View.view
    , inputs = []
    , inputsWithInit =
        [ Signal.map App.Update.SetWindowDimensions Window.dimensions ]
    }

main = app.html

port worker : Signal (Task.Task Effects.Never ())
port worker = app.tasks
