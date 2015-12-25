module Main where

import Html exposing (..)

import App.Update as Up
import App.View
import Effects
import Task
import Start
import Signal
import Window
import Mouse

setWindowDimensions =
  Signal.map
    Up.SetWindowDimensions
    Window.dimensions

setMousePositions =
  Signal.map
    (\position -> Up.SubViewAction 0 (Up.SetMousePosition position))
    Mouse.position

app =
  Start.start
    { init = Up.init
    , update = Up.update
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
