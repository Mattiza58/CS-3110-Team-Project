(** The Player's Horizontal movement. *)
type direction = Left | Right | Stand

(** Movement Paramter, feel free to alter, especially the speed. 
min and max are boundaries based on our canvas *)
let speed = 4.
let min_x = -482.  
let max_x = 482.


(** [move_x x direction] calculates the player's next horizontal
    position based on the given movement direction.

    The player moves left or right at a fixed speed, or remains
    stationary if [direction] is [Stand]. The resulting position
    is restricted to the field boundaries.

    @param x The player's current horizontal position.
    @param direction The direction of movement.
    @return The updated horizontal position. *)

let move_x x direction =
  let movement =
    match direction with
    | Left -> -.speed
    | Right -> speed
    | Stand -> 0.
  in
  let new_x = x +. movement in
  max min_x (min max_x new_x)


(* Jumping. *)
type vertical = {y : float; vy : float; jump_status : bool;}

(* Jumping Parameters, still, feel free to change, playing with gravity parameter
is fun btw. *)
let ground = -175.
let jump_speed = 9.
let gravity = -0.45

let initial_y = {y = ground; vy = 0.; jump_status = false;}


(** [update_vertical ~jump_pressed state] updates the player's
    vertical position and velocity based on jumping and gravity.

    A player can jump only when on the ground and the jump key
    has not been held continuously. Gravity reduces upward
    velocity each update, eventually bringing the player back
    to the ground. The player's position is restricted to
    ground level when landing.

    @param jump_pressed Whether the jump key is currently pressed.
    @param state The player's current vertical movement state.
    @return The updated vertical state, including position,
    velocity, and jump key status. *)
(*DO NOT ALTER THIS PART, or there might be serious bugs when pressing keyboard!!*)
let update_vertical ~jump_pressed state =
  let can_jump =
    state.y <= ground
    && jump_pressed
    && not state.jump_status
  in

  let vy =
    if can_jump then jump_speed
    else state.vy
  in

  (* Update y-axis position, and aviod it from falling down the floor *)
  let vy = vy +. gravity in
  let y = state.y +. vy in

  if y <= ground then
    { y = ground; vy = 0.; jump_status = jump_pressed;}
  else
    {y; vy; jump_status = jump_pressed;}
