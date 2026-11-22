(** The Player's Horizontal movement. *)
type direction = Left | Right | Stand

(** Movement Paramter, feel free to alter, especially the speed. 
min and max are boundaries based on our canvas *)
let speed = 4.
let min_x = -482.  
let max_x = 482.

(** Move player horizontally *)
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

(*Only jump when key is pressed, and when player are standing on ground*)
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
