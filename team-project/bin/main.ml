open Js_of_ocaml

(* Update the text of an HTML element by its ID. *)
let set_text id value =
  match Dom_html.getElementById_opt id with
  | None -> ()
  | Some element ->
      element##.textContent :=
        Js.some (Js.string value)
