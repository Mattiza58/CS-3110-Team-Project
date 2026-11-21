# Web Server Commands
By Matt:

To run the locally hosted site, use these commands in the `team-project` folder:

```bash 
dune build public/index.html server/main.exe
_build/default/server/main.exe _build/default/public
```

Then open http://127.0.0.1:8080 in your browser! If you want to end the server on use `Ctrl+C` (should be the same on Mac and Windows)

Also, if you make changes to the code, run this in a ***separate*** terminal:
```bash
dune build --watch public/index.html
```
which rebuilds all the modified assets

**NOTE:** Also remember to terminate this process too when you're done with everything!