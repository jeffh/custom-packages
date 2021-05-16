Custom Nix Packages
====================

Run the following:

```
nix-channel --add https://github.com/jeffh/custom-packages/archive/main.tar.gz jeffh
nix-channel --update
nix-channel --list # it should be a part of this list as "jeffh"
```

Then you can build packages it provides:

```
nix-build '<jeffh>' -A hello
```


You can then use these packages in NIX like so:

```
let
  pkgs = import <jeffh>;
in
  ... use pkgs
```

See [this blog post](https://lucperkins.dev/blog/nix-channel/) for the original source of how to us this.