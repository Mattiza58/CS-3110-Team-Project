# Elm_playground Guide

Written by Matt:

This is a short guide to explain how `elm_playground` works. After using it, it's actually a really intuitive library and most functions work how you intend them to. Documentation also exists here: https://aryx.github.io/ocaml-elm-playground/elm_playground/

## Setup

Make sure you install elm_playground and it's on version `0.3.6`. We need the web verision of it, so install:

```bash
opam install elm_playground elm_playground_web
```

The version still needs to be updated (for some reason this library kinda sucks when it comes to maintenance). So run this

```bash
opam update
opam upgrade elm_playground elm_playground_web
```

Check to see if the version is `0.3.6`, otherwise the project won't work:

```bash
opam list elm_playground elm_playground_web
```

From here, you should be good! I modified the `dune` files and the `libraries` dependencies to include elm.


## Basics

Everything is made up of `shapes` which include circles, rectangles, and text that each have their own functions (because unfortunately we're dealing with ocaml :( )

The constructors look like this:

- `circle: color -> number -> shape`: Takes in a color and then a radius, returns a circle of type `shape`
- `rectangle: color -> number -> number -> shape`: Takes in a color, width, and height a returns a rectangle of type `shape`


To render these shapes, we have to pass them as a `list` of shapes into `picture` and then call `Playground_platform.run_app (picture scene)`:

```ocaml
open Playground

let scene =
  [
    rectangle black 900. 360.;
    rectangle green 900. 20. |> move_y (-170.);
    circle blue 18. |> move (-240.) (-142.);
    circle red 18. |> move 240. (-142.);
    circle white 12. |> move 0. (-148.);
  ]

let () = Playground_platform.run_app (picture scene)
```

There are different functions like `move` that modify a shape and return a new one (dealing with immutability *unfortunately*), and you can use the pipe operator `|>` as syntatic sugar just to make things look cleaner. 

Also, these are `svg` elements, so similar to what we did in A2. It's actually really similar the things you could do with elm_playground, it's just finding the right syntax for it. And because of this we need no HTML elemenets at all meaning our `<body>` tag in `index.html` can be empty. 

You can also group shapes together using `group`, for example:

```ocaml
let player color side = 
  group [
    rectangle color 36. 52.;
    circle (rgb 245 228 154) 18. |> move_up 44.;
  ]
```

And this can then be pased into `picture` as just one shape

Also, you can use `rgb` to set custom colors, and `move` has different variants like `move_up` and `move_down` which are self explanatory.


## The Canvas

By default (you can change this later), the canvas has 1000 x 1000 dimensions. So think of it as all the shapes adhering to a 1000 x 1000 coordinate system. When a shape is rendered, it is set dead center in the middle which you can think of as `(0,0)`.

For this 1000 x 1000 canvas, you can refer to these points when deciding where shapes should go:

- (0,0) -> Center
- (-500, 500) -> Top Left
- (500, 500) ->  Top Right
- (-500, -500) -> Bottom Left
- (500, -500) -> Bottom Right

**NOTE:** When using functions like `move` for example, you have to use ***floats***, not integers so put the dot at the end like this: `0.`. Also for negative numbers, wrap the number in parentheses like this `(

## Movement

I haven't done movement yet, but it would look something like this by using `game` and `_computer` and updating the frame using keyboard input

Setting the view:
```ocaml
(** Draw the scene based on position [x] and [y]*)
let view _computer (x, y) = [
  rectangle sky_color 1000. 600.;
  rectangle field_color 1000. 100. |> move_down 250.;
  player red P2 |> move 250. (-175.);
  player blue P1 |> move x y;
  words white "Caml League 🐫 ⚽️" |> scale 2. |> move_up 250.;
]
```

Then you would make an update function which takes in `computer` and a position pair `(x,y)`
```ocaml 
let update computer (x, y) =
  let speed = 4. in
  ( x +. speed *. to_x computer.keyboard,
    y +. speed *. to_y computer.keyboard )

```

Then you would call `game` instead of picture and do:
```ocaml
let () =
  Playground_platform.run_app
    (game view update initial_position)
```

**NOTE:** `initital_position` can be set to anything. You could define a value beforehand, and this for initial position of player 1 (aka the player in blue)