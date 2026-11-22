
(** Basic ball state. *)
type t = {
  x : float;
  y : float;
  vx : float;
  vy : float;
}

val radius : float

(** Initial ball position. *)
val initial : t

(** Update ball movement*)
val step : t -> t

(** Apply simple push when ball is touched by a player. *)
val kick :
  player_x:float ->
  player_vx:float -> t -> t
