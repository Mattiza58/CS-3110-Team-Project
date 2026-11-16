open Js_of_ocaml

(* Update the status message when OCaml runs in the browser. *)
let () =
  match Dom_html.getElementById_opt "status" with
  | None -> ()
  | Some status ->
      status##.textContent :=
        Js.some (Js.string "OCaml loaded successfully!")

