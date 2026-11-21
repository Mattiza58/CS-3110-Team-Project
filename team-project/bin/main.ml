open Playground

type side = P1 | P2

let sky_color = rgb 2 142 201
let field_color = rgb 255 223 79

let ball = circle white 20. 


let player color side = 
  group [
    rectangle color 36. 52.;
    circle (rgb 245 228 154) 18. |> move_up 44.;
    circle black 3. |> if side = P1 then move 5. 46. else move (-5.) 46.
  ]

let scene = [
  rectangle sky_color 1000. 600.;
  rectangle field_color 1000. 100. |>  move_down 250.;
  player red P2 |> move 250. (-175.); 
  player blue P1 |> move (-250.) (-175.);
  ball |> move_down (175.);
  words white "Caml League 🐫 ⚽️" |> scale 2. |> move_up 250.;
]

(* This is a 1000 x 1000 canvas so think of this as defining the coordinate system*)
let () = Playground_platform.run_app (picture scene)

(* (0,0) -> Center
(-500, 500) -> Top Left
(500, 500) ->  Top Right
(-500, -500) -> Bottom Left
(500, -500) -> Bottom Right*)

