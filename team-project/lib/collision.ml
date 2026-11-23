
(** Detect ball-player-collisions *)
let clamp value low high =
  max low (min high value)

(** [touches_body ball player_x player_y] determines whether
    the ball intersects the player's rectangular body.

    The function finds the closest point on the player's body
    to the ball's center and compares their squared distance
    with the squared ball radius.

    @param ball The current ball state.
    @param player_x The horizontal center of the player.
    @param player_y The vertical center of the player's body.
    @return [true] if the ball touches or overlaps the body,
    and [false] otherwise. *)
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

(** [touches_head ball player_x player_y] determines whether
    the ball intersects the player's circular head.

    The function calculates the squared distance between
    the ball's center and the head's center. A collision occurs
    when this distance is less than or equal to the squared
    sum of their radii.

    @param ball The current ball state.
    @param player_x The horizontal center of the player.
    @param player_y The vertical center of the player's body.
    @return [true] if the ball touches or overlaps the head,
    and [false] otherwise. *)
let touches_head (ball : Ball.t) player_x player_y =
  let head_y = player_y +. 44. in
  let dx = ball.x -. player_x in
  let dy = ball.y -. head_y in

  let combined_r = Ball.radius +. 18. in
  dx *. dx +. dy *. dy <= combined_r *. combined_r

(** [touches_player ~ball ~player_x ~player_y] checks whether
    the ball collides with any part of the player.

    The function combines body and head collision detection.
    The player's current position is used so collisions can
    also be detected while jumping.

    @param ball The current ball state.
    @param player_x The player's current horizontal position.
    @param player_y The player's current vertical position.
    @return [true] if the ball touches either the player's
    body or head, and [false] otherwise. *)
let touches_player ~ball ~player_x ~player_y =
  touches_body ball player_x player_y || touches_head ball player_x player_y
