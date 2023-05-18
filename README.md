# Python Library Nix Experiments (ft. flakes)

[Nix Hour #29](https://www.youtube.com/watch?v=pP1bnQwomDg&list=PLyzwHTVJlRc8yjlx4VR4LU5A5O44og9in)
started with a minor question from
[Alex](https://github.com/t184256)
about how to include a Python library in a flake, in a way that it
can be used with arbitrary interpreter versions (and applications).
This deceivingly small questions spiraled out of control in 
[my](https://github.com/con-f-use/) mind
so that I did a bit of experimenting and yak-shaving.

# Flakes

[Flakes](https://www.tweag.io/blog/2020-05-25-flakes/) 
are kind of the elephant in the room with Nix Hour.
[Silvan](https://github.com/infinisil) doesn't use them,
so they are not talked about, but tip-toe pranced around a lot.

Python Library things, might deliver a good practical example to dive
into them. So what are they exactly?

They tie into the not-so-new, perpetually experimental command line
interface of nix.

| Older         | Old¹                        |
| :-----------: | :-------------------------: |
| `nix-shell`   | `nix develop`               |
| `nix-build`   | `nix build`                 |
| `nix-env`     | ew, don't use that! 😱      |
| `nix-channel` | `nix flake update`          |
| ...           | ...more, less used stuff... | 

Where nix used to use left, the new CLI and falkes use right.
I think they make nix more user-friendly, but your mileage may vary.

In short, they are way to facilitate code sharing in nix.
They provide a nice standard user-experience, ...somewhat.
Imagine you had some nix-code you wanted to share with the internet /
an organisation / a few people / yourself.
Suppose sharing is caring and you wanted people to be able to use that
code as part of theirs so that other people can in turn use it as part
of their's, and so on.
Flakes are your jam.

Before flakes the alternatives included:

 1. Get your code merged into [nixpkgs](https://github.com/NixOS/nixpkgs).
    - Good luck getting a reviewer, waiting for the next release and then
    having people update their channel to find it ...every time you
    change it.
 2. Use [NUR](https://github.com/nix-community/NUR). Same, except 
    updating and merging is a little easier. The initial buy in is,
    higher, tough.
 3. Get people to submodule it in their nix repo. 😜 Yeah, right!
 4. __"Non-git people can just download and immprt it."__ 
    This is 2023 and we're not animals.

So Flakes it is, if you want to share.

--------------
¹: Supposedly "experimental", although used by ~~everyone~~ many, including
the stable version of `nixpkgs`, which is a flake itself.

## Anatomy lesson

Flakes take **inputs**, which are usually other Flakes and provide
**outputs**.
The format of outputs is somewhat standardized.
Because **inputs** are subject to change, Flakes records them transitively
(meaning the whole dependency try down to the stem, i.e. your 
dependency's dependency's recurisively) in a **lock file**.
That way you always get, what you got the first time, provided you
locked your flake and did not throw away the file.
Flakes' **outputs** can be used in other Flakes.
Flakes can also contain some 
[`nixConfig`](https://nixos.org/manual/nix/stable/command-ref/conf-file.html), 
and have multiple formats to specify **inputs** optionally using some arcane 
lookup table called the
"[Flake Registry](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-registry)",
but we don't talk about Bruno, no, no, no!

```nix
{
   description = "...";  # comment

   inputs = { ... };

   outputs = { self, ... }@inputs: {
      packages = { ... };
      apps = { ... };
      overlays = { ... };
      devShells = { ... };
      nixosModules = { ... };
      nixosConfigurations = { ... };
      formatter = { ... };
      checks = { ... };
      templates = { ... };
      hydraJobs = { ... };
   };

   nixConfig = { ... };
}
```

See, it's easy. Just the skeletton.

# Providing a Python experience

In the Flake at hand, we use a Python library in almost every way
possible.

What does it do? In good tradition it just prints some stuff.
See `./packages/myPyLib/mypylib/mypylib.py`.

1. We package it in `./packages/myPyLib/default.nix`.
2. We expose that package in `./falke.nix` via `output.packages`.
3. We provide provide an overlay for `python.withPackages` so it can
   be used with different Python interpreters in `output.overlays`.
   That was Alex' original question.
4. We use it in a runnable application `output.apps`.
5. Look, there's a development environment or something with `devShells`?
5. We define a NixOS module for both.
6. We use that module to define a VM.
7. We fail to write a flake check.
8. We ignore Hydra, because we're mere mortals.
