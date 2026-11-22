open Playground

module Player = Team_project.Player
module Ball = Team_project.Ball
module Collision = Team_project.Collision

let () = Random.self_init ()

type side = P1 | P2

type model = {
  p1_x : float;
  p2_x : float;
  p1_y : Player.vertical;
  p2_y : Player.vertical;
  ball : Ball.t;
  is_rotating : bool;
  ball_v : float;
}

let initial_state = {
  p1_x = -250.;
  p2_x = 250.;
  p1_y = Player.initial_y;
  p2_y = Player.initial_y;
  ball = Ball.initial;
  is_rotating = false;
  ball_v = 0.;
}

let sector color radius degree = (
 let arc =
   List.init (int_of_float degree + 1) (fun i ->
     let theta = (float_of_int i *. 1.) *. Float.pi /. 180. in
     (radius *. Float.cos theta, radius *. Float.sin theta))
 in
 polygon color ((0., 0.) :: arc)
)

let sky_color = rgb 2 142 201
let field_color = rgb 63 155 11
let ball_shape = (group [
   circle white 20.;

   sector black 20. 30. |> rotate 75.;
   sector black 20. 30. |> rotate 135.;
   sector black 20. 30. |> rotate 219.;
   sector black 20. 30. |> rotate 15.;
   sector black 20. 30. |> rotate (-69.);
   circle white 15.;

   polygon black [
     (0., 9.);
     (8.5, 2.8);
     (5.3, -7.3);
     (-5.3, -7.3);
     (-8.5, 2.8)
   ];

   rectangle black 2. 14. |> move_up 13.;
   rectangle black 2. 13. |> move (-12.) 6. |> rotate 54.;
   rectangle black 2. 13. |> move (12.) 6. |> rotate (-54.);
   rectangle black 2. 13. |> move (-9.) (-11.) |> rotate 144.;
   rectangle black 2. 13. |> move (9.) (-11.) |> rotate (-144.);
 ]
)

let lights dx dy= ( group [
 rectangle (rgb 45 45 45) 145. 65.;
 group (
   List.init 4 (fun row ->
     group (
       List.init 8 (fun col ->
       circle (rgb 20 20 20) 4.
       |> move (float col *. 18. -. 63.) (float row *. 14. -. 21.)
       )
     )
   )
 );
 ] |> move dx dy
)

let scoreboard = ( group [
  rectangle (rgb 45 45 45 ) 325. 180.;
  rectangle (rgb 20 20 20) 60. 100. |> move_left 75.;
  rectangle (rgb 20 20 20) 60. 100. |> move_right 75.;
  words red "RED" |> move (75.) 70. |> scale 2.;
  words blue "BLUE" |> move (-75.) 70. |> scale 2.;
  ] |> move_up 150.
)

let verti_net dx dy height width color = (
  group (
  List.init 5 (fun i ->
    group [
    rectangle color width height
    |> move (dx +. float_of_int i *. 15.) dy;
    ]
  )
  );
)

let hori_net dx dy height width color = (
  group (
  List.init 7 (fun i ->
    group [
    rectangle color width height
    |> move dx (dy +. float_of_int i *. 25.);
    ]
  )
  );
)

let back_post = ( group [
  hori_net (-470.) (-185.) (2.) (100.) (rgb 230 245 230);
  rectangle (rgb 125 145 125) 20. 175. |> move (-425.) (-115.);

  hori_net (470.) (-185.) (2.) (100.) (rgb 230 245 230);
  rectangle (rgb 125 145 125) 20. 175. |> move (425.) (-115.);
  ]
)

let front_post = (group [
  verti_net (-510.) (-115.) (165.) (2.) white;
  hori_net (-490.) (-185.) (2.) (70.) white;
  rectangle (rgb 165 180 165) 20. 175. |> move (-450.) (-115.);
  rectangle (rgb 165 180 165) 85. 20. |> move (-457.5) (-37.5);

  verti_net (440.) (-115.) (165.) (2.) white;
  hori_net (490.) (-185.) (2.) (70.) white;
  rectangle (rgb 165 180 165) 20. 175. |> move (450.) (-115.);
  rectangle (rgb 165 180 165) 85. 20. |> move (457.5) (-37.5);
  ]
)

let cloud dx dy = (group [
  circle white 50.;
  circle white 30. |> move_left 40.;
  circle white 20. |> move_right 50.;
  rectangle sky_color 140. 100. |> move_down 50.;
] |> move dx dy
)

let choose_color () = (
 let n = Random.int 100 in
 if n < 45 then red
 else if n < 90 then blue
 else (
   let r, g, b= Random.int 256, Random.int 256, Random.int 256 in
   rgb r g b
 )
)

let npc color dx dy cycle time = (
 group [
   circle (rgb 35 35 35) 10. |> move_down 10.;
   circle (rgb 245 228 154) 7. |> move_up 17.;
   rectangle color 13. 17.
 ]
 |> move dx (dy +. (wave 0. 6. cycle time))
)

let crowd_colors = (
 Array.init 100 (fun i ->
   choose_color ()
 )
)

let make_crowd height = (
  Array.init 35 (fun i ->
   let x = -480. +. float_of_int i *. 28. in
   let visible = Random.int 10 < 7 in
   let color = crowd_colors.(i) in
   let cycle = 1. +. Random.float 25. in
   (x, height, visible, color, cycle)
 )
)

let back_crowd = make_crowd 15.
let front_crowd = make_crowd (-25.)

let crowd_row crowd time = (
 Array.to_list (Array.map (fun (x, y, visible, color, cycle) ->
   if visible then
     npc color x y cycle time
   else
     group []
 ) crowd)
)

let crowd_stand height time = (
 group [
   rectangle (rgb 0 0 0) 1000. 95.;
   rectangle (rgb 105 105 105) 1000. 95. |> fade 0.4;
   group (crowd_row back_crowd time) |> fade 0.5;
   group (crowd_row front_crowd time) |> fade 0.5;
 ]
 |> move 0. height
)

let player color side =
  group [
    rectangle color 36. 52.;
    circle (rgb 245 228 154) 18. |> move_up 44.;
    (circle black 3. |> if side = P1 then move 5. 46. else move (-5.) 46.);
  ]

(* Determine x-axis direction from keyboard input. *)
let direction left right =
  if left = right then Player.Stand
  else if left then Player.Left
  else Player.Right

(* Show players and ball with update, this is the new version of the
 Original Scene *)

let scene computer state = (
 [
   rectangle sky_color 1000. 600.;
    cloud (-400.) 180. |> scale 1.3; 
   cloud (200.) 220.; 
   rectangle (rgb 100 100 100) 1000. 300.
   |> move_down 50.;
   crowd_stand 0. computer.time;
   crowd_stand (-100.) computer.time;
   rectangle (rgb 200 200 200) 1000. 100.
   |> move_down 178.;
   lights (-350.) 120.;
   lights (350.) 120.;
   scoreboard;
   back_post;
   rectangle field_color 1000. 100.
   |> move_down 250.;
   player red P2
   |> move state.p2_x state.p2_y.y;
   player blue P1
   |> move state.p1_x state.p1_y.y;
   ball_shape
   |> move state.ball.x state.ball.y 
   |> rotate (if state.is_rotating then spin (Float.min 2. (32. /. state.ball_v)) computer.time else 0.);
   front_post;
   words white "Caml League 🐫 ⚽️"
   |> scale 3.
   |> move_up 270.;
 ]
)

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
  let is_rotating = abs_float ball.vy > 0. || abs_float ball.vx > 0. 
  in 
  let ball_v = Float.sqrt (ball.vx *. ball.vx +. ball.vy *. ball.vy) in 
  {p1_x; p2_x; p1_y; p2_y; ball; is_rotating; ball_v}

(* This is a 1000 x 1000 canvas so think of this as defining the coordinate system*)
let () = Playground_platform.run_app (game scene update initial_state)

(* (0,0) -> Center
(-500, 500) -> Top Left
(500, 500) ->  Top Right
(-500, -500) -> Bottom Left
(500, -500) -> Bottom Right*)
