
(** Basic ball state and movement. *)
type t = {
  x : float;
  y : float;
  vx : float;
  vy : float;
}

(*Ball size, fell free to change*)
let radius = 20.

(* THESE ARE ONLY TEMPORARY BALL PHYSICS FOR DRAFT, THE MOVEMENT IS WERID
AND I DONT't KNOW IF WE NEED OTHER CONSTANTS TO MAKE THE BALL MOVE LIKE A REAL ONE*)
let gravity = -0.35
let friction = 1.
let remain_v = 0.75 (* this is how much speed the ball retains after bouncing *)

(* Field boundaries *)
let min_x = -480.
let max_x = 480.
let ground = -180.

(*Initial position and it starts with a intial speed too*)
let initial = { x = 0.; y = -80.;vx = 2.5; vy = 0.;}

(* Move the ball and handle basic bounces. *)
let step ball =
  let vx = ball.vx *. friction in
  let vy = ball.vy +. gravity in

  let x = ball.x +. vx in
  let y = ball.y +. vy in

  (*keep the ball inside the field, also reverse its x-axis speed when hits a wall.*)
  let x, vx =
    if x > max_x then
      (max_x, -. (abs_float vx) *. remain_v)
    else if x < min_x then
      (min_x, abs_float vx *. remain_v)
    else
      (x, vx)
  in
  (*handles the bouncing when hit the groud, THIS IS A ROUGH VERSION*)
  let y, vy =
    if y < ground then
      let bounce = -.vy *. remain_v in
      (ground, if bounce < 1. then 0. else bounce)
    else
      (y, vy)
  in
  { x; y; vx; vy }

(* when a player touches the ball, the ball is pushed *)
let kick ~player_x ~player_vx ball =
  let direction =
    if ball.x < player_x then -1. else 1.
  in
  let speed =
    max 5. (abs_float ball.vx +. abs_float player_vx +. 1.)
  in
  { ball with
    x = player_x +. direction *. 38.1; 
    (*do not change this 38.1, it is calculated from player half-width, 
    ball radius plus a tinygap*)
    vx = direction *. speed; vy = max ball.vy 3.;
  }
