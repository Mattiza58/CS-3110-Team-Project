open OUnit2
open Team_project

let assert_float label expected actual =
  assert_equal ~msg:label ~cmp:(fun a b -> abs_float (a -. b) < 1e-9)
    ~printer:(Printf.sprintf "%.12g") expected actual

let assert_vertical ~y ~vy ~jump_status (state : Player.vertical) =
  assert_float "player y" y state.y;
  assert_float "player vy" vy state.vy;
  assert_equal ~msg:"jump status" ~printer:string_of_bool jump_status
    state.jump_status

let horizontal_test (name, x, direction, expected) =
  name >:: fun _ -> assert_float "player x" expected (Player.move_x x direction)

let player_tests =
  "Player movement" >::: [
    "horizontal" >::: List.map horizontal_test Player.[
      ("move left", 15.5, Left, 11.5);
      ("move right", -15.5, Right, -11.5);
      ("stand still", 23.5, Stand, 23.5);
      ("reach left boundary exactly", -478., Left, -482.);
      ("reach right boundary exactly", 478., Right, 482.);
      ("clamp left overshoot", -481., Left, -482.);
      ("clamp right overshoot", 481., Right, 482.);
      ("move inward from left boundary", -482., Right, -478.);
      ("move inward from right boundary", 482., Left, 478.);
    ];
    "hold outward at both boundaries" >:: (fun _ ->
      assert_float "left boundary" (-482.) (Player.move_x (-482.) Player.Left);
      assert_float "right boundary" 482. (Player.move_x 482. Player.Right));
    "standing clamps positions outside the field" >:: (fun _ ->
      assert_float "left overshoot" (-482.) (Player.move_x (-500.) Player.Stand);
      assert_float "right overshoot" 482. (Player.move_x 500. Player.Stand));
    "initial vertical state" >:: (fun _ ->
      assert_vertical ~y:(-175.) ~vy:0. ~jump_status:false Player.initial_y);
    "idle on ground" >:: (fun _ ->
      Player.update_vertical ~jump_pressed:false Player.initial_y
      |> assert_vertical ~y:(-175.) ~vy:0. ~jump_status:false);
    "jump applies gravity immediately" >:: (fun _ ->
      Player.update_vertical ~jump_pressed:true Player.initial_y
      |> assert_vertical ~y:(-166.45) ~vy:8.55 ~jump_status:true);
    "held jump keeps slowing ascent" >:: (fun _ ->
      let airborne = Player.update_vertical ~jump_pressed:true Player.initial_y in
      Player.update_vertical ~jump_pressed:true airborne
      |> assert_vertical ~y:(-158.35) ~vy:8.1 ~jump_status:true);
    "new press in midair does not jump" >:: (fun _ ->
      let airborne : Player.vertical = { y = -150.; vy = -2.; jump_status = false } in
      Player.update_vertical ~jump_pressed:true airborne
      |> assert_vertical ~y:(-152.45) ~vy:(-2.45) ~jump_status:true);
    "release during descent clears jump status" >:: (fun _ ->
      let airborne : Player.vertical = { y = -150.; vy = -2.; jump_status = true } in
      Player.update_vertical ~jump_pressed:false airborne
      |> assert_vertical ~y:(-152.45) ~vy:(-2.45) ~jump_status:false);
    "landing clamps position and resets velocity" >:: (fun _ ->
      let airborne : Player.vertical = { y = -174.; vy = -3.; jump_status = false } in
      Player.update_vertical ~jump_pressed:false airborne
      |> assert_vertical ~y:(-175.) ~vy:0. ~jump_status:false);
    "exact ground contact resets downward velocity" >:: (fun _ ->
      let airborne : Player.vertical = { y = -174.; vy = -0.55; jump_status = false } in
      Player.update_vertical ~jump_pressed:false airborne
      |> assert_vertical ~y:(-175.) ~vy:0. ~jump_status:false);
    "jump apex transitions into descent" >:: (fun _ ->
      let rising : Player.vertical = { y = -120.; vy = 0.45; jump_status = false } in
      let apex = Player.update_vertical ~jump_pressed:false rising in
      assert_vertical ~y:(-120.) ~vy:0. ~jump_status:false apex;
      Player.update_vertical ~jump_pressed:false apex
      |> assert_vertical ~y:(-120.45) ~vy:(-0.45) ~jump_status:false);
    "held key through landing requires release before another jump" >:: (fun _ ->
      let update = Player.update_vertical ~jump_pressed:true in
      let airborne = update Player.initial_y in
      let rec advance frames state =
        if frames = 0 then state else advance (frames - 1) (update state)
      in
      let landed = advance 60 airborne in
      assert_vertical ~y:(-175.) ~vy:0. ~jump_status:true landed;
      let released = Player.update_vertical ~jump_pressed:false landed in
      assert_vertical ~y:(-175.) ~vy:0. ~jump_status:false released;
      update released
      |> assert_vertical ~y:(-166.45) ~vy:8.55 ~jump_status:true);
  ]

let assert_ball ~x ~y ~vx ~vy (ball : Ball.t) =
  assert_float "ball x" x ball.x;
  assert_float "ball y" y ball.y;
  assert_float "ball vx" vx ball.vx;
  assert_float "ball vy" vy ball.vy

let ball_tests =
  "Ball physics" >::: [
    "initial state" >:: (fun _ ->
      assert_ball ~x:0. ~y:(-80.) ~vx:2.5 ~vy:0. Ball.initial);
    "ball radius" >:: (fun _ -> assert_float "radius" 20. Ball.radius);
    "first two steps accumulate gravity" >:: (fun _ ->
      let first = Ball.step Ball.initial in
      assert_ball ~x:2.5 ~y:(-80.35) ~vx:2.5 ~vy:(-0.35) first;
      Ball.step first
      |> assert_ball ~x:5. ~y:(-81.05) ~vx:2.5 ~vy:(-0.7));
    "leftward and upward movement" >:: (fun _ ->
      Ball.step { x = 10.; y = 20.; vx = -4.; vy = 3. }
      |> assert_ball ~x:6. ~y:22.65 ~vx:(-4.) ~vy:2.65);
    "right wall clamps and reverses horizontal velocity" >:: (fun _ ->
      let bounced = Ball.step { x = 478.; y = 20.; vx = 4.; vy = 1. } in
      assert_ball ~x:480. ~y:20.65 ~vx:(-3.) ~vy:0.65 bounced;
      Ball.step bounced |> assert_ball ~x:477. ~y:20.95 ~vx:(-3.) ~vy:0.3);
    "left wall clamps and reverses horizontal velocity" >:: (fun _ ->
      Ball.step { x = -478.; y = 20.; vx = -4.; vy = 1. }
      |> assert_ball ~x:(-480.) ~y:20.65 ~vx:3. ~vy:0.65);
    "exact wall contact keeps velocity until the next step" >:: (fun _ ->
      let contact = Ball.step { x = 476.; y = 20.; vx = 4.; vy = 0. } in
      assert_ball ~x:480. ~y:19.65 ~vx:4. ~vy:(-0.35) contact;
      Ball.step contact |> assert_ball ~x:480. ~y:18.95 ~vx:(-3.) ~vy:(-0.7));
    "ground bounce retains 75 percent of impact speed" >:: (fun _ ->
      let bounced = Ball.step { x = 10.; y = -178.; vx = 2.; vy = -7.65 } in
      assert_ball ~x:12. ~y:(-180.) ~vx:2. ~vy:6. bounced;
      Ball.step bounced |> assert_ball ~x:14. ~y:(-174.35) ~vx:2. ~vy:5.65);
    "exact ground contact keeps downward velocity until the next step" >:: (fun _ ->
      let contact = Ball.step { x = 0.; y = -176.; vx = 0.; vy = -3.65 } in
      assert_ball ~x:0. ~y:(-180.) ~vx:0. ~vy:(-4.) contact;
      Ball.step contact |> assert_ball ~x:0. ~y:(-180.) ~vx:0. ~vy:3.2625);
    "small bounce stops while horizontal motion continues" >:: (fun _ ->
      let settled = Ball.step { x = 10.; y = -179.5; vx = -2.; vy = -0.5 } in
      assert_ball ~x:8. ~y:(-180.) ~vx:(-2.) ~vy:0. settled;
      Ball.step settled |> assert_ball ~x:6. ~y:(-180.) ~vx:(-2.) ~vy:0.);
    "bounce cutoff stops only speeds strictly below one" >:: (fun _ ->
      let impact vy = Ball.step { x = 0.; y = -180.; vx = 0.; vy } in
      let cutoff_impact_velocity = 0.35 -. (1. /. 0.75) in
      impact (cutoff_impact_velocity +. 0.001)
      |> assert_ball ~x:0. ~y:(-180.) ~vx:0. ~vy:0.;
      impact cutoff_impact_velocity
      |> assert_ball ~x:0. ~y:(-180.) ~vx:0. ~vy:1.;
      impact (cutoff_impact_velocity -. 0.001)
      |> assert_ball ~x:0. ~y:(-180.) ~vx:0. ~vy:1.00075);
    "successive ground bounces lose height and settle" >:: (fun _ ->
      let rec advance frames (ball : Ball.t) peaks =
        if frames = 0 then ball, List.rev peaks
        else
          let next = Ball.step ball in
          let peaks = if ball.vy > 0. && next.vy <= 0. then ball.y :: peaks else peaks in
          advance (frames - 1) next peaks
      in
      let bounced = Ball.step { x = 0.; y = -179.; vx = 0.; vy = -7.65 } in
      let settled, peaks = advance 180 bounced [] in
      (match peaks with
      | first :: second :: rest ->
          let rec descending previous = function
            | [] -> ()
            | peak :: remaining ->
                assert_bool "each bounce peaks lower" (peak < previous);
                descending peak remaining
          in
          descending first (second :: rest)
      | _ -> assert_failure "expected at least two bounce peaks");
      assert_ball ~x:0. ~y:(-180.) ~vx:0. ~vy:0. settled);
    "wall and ground bounce on the same step" >:: (fun _ ->
      Ball.step { x = 479.; y = -179.; vx = 8.; vy = -7.65 }
      |> assert_ball ~x:480. ~y:(-180.) ~vx:(-6.) ~vy:6.);
    "kick right uses minimum speed and lift" >:: (fun _ ->
      Ball.kick ~player_x:10. ~player_vx:0. { x = 11.; y = 25.; vx = 0.; vy = -2. }
      |> assert_ball ~x:48.1 ~y:25. ~vx:5. ~vy:3.);
    "kick left combines speed magnitudes and preserves higher upward velocity" >:: (fun _ ->
      Ball.kick ~player_x:10. ~player_vx:(-4.) { x = 9.; y = 25.; vx = 6.; vy = 7. }
      |> assert_ball ~x:(-28.1) ~y:25. ~vx:(-11.) ~vy:7.);
    "kick at equal x goes right and reverses an incoming ball" >:: (fun _ ->
      Ball.kick ~player_x:(-10.) ~player_vx:2. { x = -10.; y = 25.; vx = -5.; vy = 3. }
      |> assert_ball ~x:28.1 ~y:25. ~vx:8. ~vy:3.);
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
