
open OUnit2

(* to run test suite, run "dune runtest" from team-project directory *)

module Ball = Team_project.Ball
module Collision = Team_project.Collision

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

let test_overlap _ =
(* choose ball + player positions; ball is at x = 30 with default radius 20
    meaning its left edge is at x = 10; this should overlap with player, who
    is centered at x = 0, with a hitbox spanning from x = -18 to x = 18. *)
  let ball : Ball.t =
    { x = 30.; y = 0.; vx = 0.; vy = 0. }
  in

(* call function being tested; pass ball and player positions into touches_player *)
  let actual =
    Collision.touches_player
      ~ball
      ~player_x:0.
      ~player_y:0.
  in

(* compare the result with desired result (true) *)
  assert_equal
    ~printer:string_of_bool
    true
    actual


let collision_tests =
  "Collision detection" >::: [

    "body_overlap" >:: (fun _ ->
        (* choose ball + player positions; ball is at x = 30 with default radius 20
        meaning its left edge is at x = 10; this should overlap with player, who
        is centered at x = 0, with a hitbox spanning from x = -18 to x = 18. *)
        let ball : Ball.t =
          { x = 30.; y = 0.; vx = 0.; vy = 0. }
        in
        (* call function being tested; pass ball and player positions into touches_player *)
        let actual =
          Collision.touches_player
          ~ball
          ~player_x:0.
          ~player_y:0.
        in

        (* compare the result with desired result (true) *)
        assert_equal
          ~printer:string_of_bool
          true
          actual 
      
      );

      
    "head_collision" >:: (fun _ ->
      (* this test follows the same format as body_overlap, with the only
      difference being ball coordinates to test if head collisions register *)
        let ball : Ball.t = 
          { x = 0.; y = 75.; vx = 0.; vy = 0. }
        in

        let actual = 
          Collision.touches_player
          ~ball
          ~player_x:0.
          ~player_y:0.
        in

        assert_equal
          ~printer:string_of_bool
          true
          actual

    );

    "boundary touching" >:: (fun _ ->
      (* this test follows the same format as body_overlap and head_collision,
       with the only difference being ball coordinates to test collision
       registers when ball is tangent to player hitbox *)
        let ball : Ball.t = 
          { x = 38.; y = 0.; vx = 0.; vy = 0. }
        in

        let actual = 
          Collision.touches_player
          ~ball
          ~player_x:0.
          ~player_y:0.
        in

        assert_equal
          ~printer:string_of_bool
          true
          actual

    );


    "collision response" >:: (fun _ ->
      (* simple test to make sure ball is moving from kick function when
      collision occurs *)
      let ball : Ball.t =
        { x = 30.; y = 0.; vx = 0.; vy = 0. }
      in
      
      let actual = Ball.kick ~player_x:0. ~player_vx:0. ball in

      assert_bool "ball position shifts right" (actual.x > ball.x);
      assert_bool "ball velocity is to the right" (actual.vx > 0.)
    );
  ]

let suite =
  "Caml League Tests" >::: [
    player_tests;
    ball_tests;
    collision_tests;
    (* this is where other testing categories go *)
  ]

let () = run_test_tt_main suite
