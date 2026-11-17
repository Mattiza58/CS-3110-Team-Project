open Js_of_ocaml

(* Update the status message when OCaml runs in the browser. 
Basically just updating the element's text to confirm OCaml loaded.) *)
let () =
  match Dom_html.getElementById_opt "status" with
  | None -> ()
  | Some status ->
      status##.textContent :=
        Js.some (Js.string "~OCaml loaded successfully~")

