
type direction = Left | Right | Stand

(** [move_x x direction] calculates the next horizontal position of a player *)
val move_x : float -> direction -> float

(** Vertical position and jumping state. *)
type vertical = {y : float; vy : float; jump_status : bool;}

(** Initial ground state. *)
val initial_y : vertical

(** Update jumping. *)
val update_vertical :
  jump_pressed:bool -> vertical -> vertical
