
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

(** [step ball] calculates the ball's next position and velocity
    using basic physics and boundary collision handling.

    Gravity affects vertical velocity, while friction gradually
    reduces horizontal velocity. When the ball reaches a wall
    or the ground, its position is constrained to the boundary
    and its velocity is reversed and reduced using restitution.
    Small ground bounces are stopped to prevent continuous
    bouncing.

    @param ball The current ball state.
    @return The updated ball state after one game update. *)
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

(** [kick ~player_x ~player_vx ball] applies a simplified
    collision response when a player touches the ball.

    The ball is repositioned horizontally outside the player's
    body to prevent overlap. Its horizontal velocity is directed
    away from the player, with speed influenced by the player's
    movement and the ball's existing velocity. A small upward
    velocity is also applied.

    @param player_x The player's current horizontal position.
    @param player_vx The player's horizontal movement velocity.
    @param ball The ball state before the collision response.
    @return The ball state after applying the collision response. *)
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
