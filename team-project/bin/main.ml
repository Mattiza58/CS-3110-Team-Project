open Js_of_ocaml

(* Update the text of an HTML element by its ID. *)
let set_text id value =
  match Dom_html.getElementById_opt id with
  | None -> ()
  | Some element ->
      element##.textContent :=
        Js.some (Js.string value)

(* Register the interface button's click handler. *)
let setup_test_button () =
  match Dom_html.getElementById_opt "test-ui" with
  | None -> ()
  | Some button ->
      button##.onclick :=
        Dom_html.handler (fun _ ->
          set_text "status"
            "Button clicked.";
          Js._true)

(* Initialize the interface when the page loads. *)
let () =
  set_text "status" "OCaml connected. UI is ready.";
  setup_test_button ()
