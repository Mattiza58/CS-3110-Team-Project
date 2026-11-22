
(** Detect ball-player-collisions *)
let clamp value low high =
  max low (min high value)

(* Check collision with the player's body. *)
let touches_body (ball : Ball.t) player_x player_y =
  let nearest_x =
    clamp ball.x (player_x -. 18.) (player_x +. 18.)
  in
  let nearest_y =
    clamp ball.y (player_y -. 26.) (player_y +. 26.)
  in
  let dx = ball.x -. nearest_x in
  let dy = ball.y -. nearest_y in
  dx *. dx +. dy *. dy <= Ball.radius *. Ball.radius

(* Check collision with the player's head. *)
let touches_head (ball : Ball.t) player_x player_y =
  let head_y = player_y +. 44. in
  let dx = ball.x -. player_x in
  let dy = ball.y -. head_y in

  let combined_r = Ball.radius +. 18. in
  dx *. dx +. dy *. dy <= combined_r *. combined_r

let touches_player ~ball ~player_x ~player_y =
  touches_body ball player_x player_y || touches_head ball player_x player_y
