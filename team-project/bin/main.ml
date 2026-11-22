open Playground

module Player = Team_project.Player
module Ball = Team_project.Ball
module Collision = Team_project.Collision

type side = P1 | P2

type model = {
  p1_x : float;
  p2_x : float;
  p1_y : Player.vertical;
  p2_y : Player.vertical;
  ball : Ball.t;
}

let initial_state = {
  p1_x = -250.;
  p2_x = 250.;
  p1_y = Player.initial_vertical;
  p2_y = Player.initial_vertical;
  ball = Ball.initial;
}

let sky_color = rgb 2 142 201
let field_color = rgb 255 223 79
let ball_shape = circle white 20.

let player color side =
  group [
    rectangle color 36. 52.;
    circle (rgb 245 228 154) 18. |> move_up 44.;
    (circle black 3. |> if side = P1 then move 5. 46. else move (-5.) 46.);
  ]

(* Determine x-axis direction from keyboard input. *)
let direction left right =
  if left = right then Player.Stay
  else if left then Player.Left
  else Player.Right

(* Show players and ball with update, this is the new version of the
 Original Scene *)
let scene _computer state =
  [
    rectangle sky_color 1000. 600.;
    rectangle field_color 1000. 100. |> move_down 250.;

    player red P2 |> move state.p2_x state.p2_y.y;
    player blue P1 |> move state.p1_x state.p1_y.y;
    ball_shape |> move state.ball.x state.ball.y;
    words white "Caml League 🐫 ⚽️" |> scale 2. |> move_up 250.;
  ]

(* Check whether player touches the ball. *)
let do_collision ball player_x old_x player_y =
  let touching = Collision.touches_player ~ball ~player_x  ~player_y
  in
  if touching then Ball.kick ~player_x ~player_vx:(player_x -. old_x) ball
  else ball

let update computer state =
  let keyboard = computer.keyboard in
  (* X-axis movement. *)
  let p1_direction = direction keyboard.ka keyboard.kd
  in
  let p2_direction = direction keyboard.kleft keyboard.kright
  in
  let p1_x = Player.move_x state.p1_x p1_direction
  in
  let p2_x = Player.move_x state.p2_x p2_direction
  in
  (* Jumping *)
  let p1_y = Player.update_vertical ~jump_pressed:keyboard.kw state.p1_y
  in

  let p2_y =Player.update_vertical ~jump_pressed:keyboard.kup state.p2_y
  in
  (* Ball physics. *)
  let ball = Ball.step state.ball in
  (* Player-ball collisions *)
  let ball = do_collision ball p1_x state.p1_x p1_y.y
  in
  let ball =do_collision ball p2_x state.p2_x p2_y.y
  in
  {p1_x; p2_x; p1_y; p2_y;ball;}

(* This is a 1000 x 1000 canvas so think of this as defining the coordinate system*)
let () = Playground_platform.run_app (game scene update initial_state)


(* (0,0) -> Center
(-500, 500) -> Top Left
(500, 500) ->  Top Right
(-500, -500) -> Bottom Left
(500, -500) -> Bottom Right*)
