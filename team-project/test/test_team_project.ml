
open OUnit2

(* Player Movement Tests (Not Exhausive) *)

let player_tests =
  "Player movement" >::: [

    "move left" >:: (fun _ ->
      (* TODO: Check that moving left decreases the player's x position by the correct speed. *)
      skip_if true "TODO"
    );

    "move right" >:: (fun _ ->
      (* TODO*)
      skip_if true "TODO"
    );

    "stay still" >:: (fun _ ->
      (* TODO: Check that the player's position remains unchanged when no movement key is pressed. *)
      skip_if true "TODO"
    );

    "field boundaries" >:: (fun _ ->
      (* TODO: Check that players cannot move beyond the left or right field boundaries. *)
      skip_if true "TODO"
    );

    "jump" >:: (fun _ ->
      (* TODO: Check that pressing jump gives the player upward velocity and increases y. *)
      skip_if true "TODO"
    );

    "gravity and landing" >:: (fun _ ->
      (* TODO: Check that gravity pulls the player down and that the player stops at ground level. *)
      skip_if true "TODO"
    );

  ]

(* Ball Physics Tests                        *)

let ball_tests =
  "Ball physics" >::: [

    "ball movement" >:: (fun _ ->
      (* TODO: Check that the ball's position changes according to its velocity. *)
      skip_if true "TODO"
    );

    "gravity" >:: (fun _ ->
      (* TODO: Check that gravity decreases the ball's vertical velocity over time. *)
      skip_if true "TODO"
    );

    "remainig speed" >:: (fun _ ->
      (* TODO: Check that the ball loses speed after bouncing according to restitution. *)
      skip_if true "TODO"
    );

    "ball kick" >:: (fun _ ->
      (* TODO: Check that a player collision changes the ball's velocity and position correctly. *)
      skip_if true "TODO"
    );
  ]

(* Collision Tests*)

let collision_tests =
  "Collision detection" >::: [

    "body collision" >:: (fun _ ->
      (* TODO: Check that collision is detected when the ball overlaps the player's body. *)
      skip_if true "TODO"
    );

    "head collision" >:: (fun _ ->
      (* TODO: Check that collision is detected when the ball touches the player's head. *)
      skip_if true "TODO"
    );

    "boundary touching" >:: (fun _ ->
      (* TODO: Check that collision is detected when the ball just touches the player's edge. *)
      skip_if true "TODO"
    );


    "collision response" >:: (fun _ ->
      (* TODO: Check that the ball moves away from the player after a collision. *)
      skip_if true "TODO"
    );
  ]

let suite =
  "Caml League Tests" >::: [
    player_tests;
    ball_tests;
    collision_tests;
  ]

let () = run_test_tt_main suite
