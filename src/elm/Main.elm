module Main where

import Html exposing (..)

import App.Update
import App.View exposing (view)
import Effects
import Task
import Start
import Signal
import Window
import Mouse

setWindowDimensions =
  Signal.map
    App.Update.SetWindowDimensions
    Window.dimensions

setMousePositions =
  Signal.map
    (App.Update.SetMousePosition 0)
    Mouse.position

app =
  Start.start
    { init = App.Update.init
    , update = App.Update.update
    , view = App.View.view
    , inputs = []
    , inputsWithInit =
        [ setWindowDimensions
        , setMousePositions
        ]
    }

main = app.html

port worker : Signal (Task.Task Effects.Never ())
port worker = app.tasks
