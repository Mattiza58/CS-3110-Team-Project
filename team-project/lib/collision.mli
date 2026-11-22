(** Check whether the ball hits any player. *)
val touches_player :
  ball:Ball.t ->
  player_x:float ->
  player_y:float ->bool