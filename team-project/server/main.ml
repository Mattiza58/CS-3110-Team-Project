open Lwt.Infix

module Server = Cohttp_lwt_unix.Server

let asset = function
  | "/" | "/index.html" ->
      Some ("index.html", "text/html; charset=utf-8")
  | "/main.js" ->
      Some ("main.js", "text/javascript; charset=utf-8")
  | "/style.css" ->
      Some ("style.css", "text/css; charset=utf-8")
  | _ -> None

let reply ?(extra = []) req status content_type text =
  let headers =
    Cohttp.Header.of_list
      ([
         ("content-type", content_type);
         ("cache-control", "no-store");
         ("content-length", string_of_int (String.length text));
       ] @ extra)
  in
  let body =
    if Cohttp.Request.meth req = `HEAD then `Empty
    else `String text
  in
  Server.respond ~status ~headers ~body ()

let text_reply req status text =
  reply req status "text/plain; charset=utf-8" text

let callback root _conn req _body =
  match Cohttp.Request.meth req with
  | `GET | `HEAD -> (
      match asset (Uri.path (Cohttp.Request.uri req)) with
      | None -> text_reply req `Not_found "Not found\n"
      | Some (name, content_type) ->
          let filename = Filename.concat root name in
          Lwt.catch
            (fun () ->
              Lwt_io.with_file ~mode:Lwt_io.input filename Lwt_io.read
              >>= fun contents ->
              reply req `OK content_type contents)
            (function
              | Unix.Unix_error
                  ((Unix.ENOENT | Unix.ENOTDIR | Unix.EISDIR), _, _) ->
                  text_reply req `Not_found "Not found\n"
              | exn ->
                  prerr_endline (Printexc.to_string exn);
                  text_reply req `Internal_server_error "Server error\n"))
  | _ ->
      reply ~extra:[("allow", "GET, HEAD")] req `Method_not_allowed
        "text/plain; charset=utf-8" "Method not allowed\n"

let run root =
  Conduit_lwt_unix.init ~src:"127.0.0.1" () >>= fun conduit ->
  let ctx = Cohttp_lwt_unix.Net.init ~ctx:conduit () in
  Printf.printf "Serving %s at http://127.0.0.1:8080\n%!" root;
  Server.create ~ctx ~mode:(`TCP (`Port 8080))
    (Server.make ~callback:(callback root) ())

let () =
  if Array.length Sys.argv <> 2 then (
    prerr_endline "Usage: main.exe DOCUMENT_ROOT";
    exit 2);
  Lwt_main.run (run Sys.argv.(1))


