_Reference:
[Taken from here](https://blog.nobbz.dev/2022-12-12-getting-inputs-to-modules-in-a-flake/)_

# Passing Inputs to Modules

There is a frequently recurring scenario in the various community chats and
forums, which at the end boils down to the question "How to get this input into
my configuration?"

There are basically 4 ways to achieve this goal:

Create a function over inputs to modules and pass the inputs to the function Use
`specialArgs` in the
`nixosSystem or `extraSpecialArgs`in the`homeManagerConfiguration`call Use the `\_module.args`option in an "inline module" Create an overlay providing the inputs in `pkgs`
I will give some short examples, without much of discussing their pros and cons,
as I have not yet really went through the different versions.

Personally I have settled on using the "function over inputs" as described
straight in the next section.

Please be aware that flake frameworks change how you do this, or implement one
of these versions under the hood for you. I will not discuss or mention any of
these. I assume that in the case of a framework you know how it works there or
how you translate vanilla flake approaches to that framework.

The flake will show how to get the package hello from the imaginary
`github:nobbz/example` installed via the `environment.systemPackages`.

## Function Over Inputs

The idea is that you pass all your inputs when importing the module or
configuration.

```nix
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
  inputs.example.url = "github:nobbz/example";
  outputs = {self, nixpkgs, example}@inputs: {
    nixosSystem.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        (import ./configuration.nix inputs)
      ];
    };
  };
}
```

```nix
{example, ...}:
{config, pkgs, ...}:
{
  environment.systemPackages = [
    pkgs.vim example.packages.${pkgs.system}.hello
  ];
}
```

## `(extra)specialArgs`

This makes the inputs available via the set passed into each module. There
exists 2 variants of this technique, but I will only present one of them. I
leave the transformation between this and the other variant as an exercise to
the reader.

- Pass all inputs as a single set.
- Pass all inputs individually.

**Note:** For home-manager it is done the same way, though the argument name is
`extraSpecialArgs`.

```nix
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
  inputs.example.url = "github:nobbz/example";
  outputs = {self, nixpkgs, example}@inputs: {
    nixosSystem.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        ./configuration.nix
      ];
    };
  };
}
```

```nix
{config, pkgs, inputs, ...}:
{
  environment.systemPackages = [
    pkgs.vim inputs.example.packages.${pkgs.system}.hello
  ];
}
```

## `_module.args`

Similar to the previous technique, this adds the inputs to the arguments passed
into the module, and the same 2 variants exists.

**Note:** You can't use modules from this in an imports list, that would produce
an infinite recursion error.

```nix
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
  inputs.example.url = "github:nobbz/example";
  outputs = {self, nixpkgs, example}@inputs: {
    nixosSystem.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        {_module.args = {inherit inputs;};}
      ];
    };
  };
}
```

```nix
{config, pkgs, inputs, ...}:
{
  environment.systemPackages = [
    pkgs.vim inputs.example.packages.${pkgs.system}.hello
  ];
}
```

## The Overlay

Personally I dislike overlays, and use them only when there isn't some other way
to achieve a similar goal at least.

Still, I mention it here for the following reasons:

1. In the beginning it was perceived as the only solution to the problem
2. Some people still want to use overlays for everything
3. This technique is used under the hood by at least one
   [flake-framework](https://github.com/Misterio77/nix-starter-configs/tree/main/standard/overlays)

```nix
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
  inputs.example.url = "github:nobbz/example";
  outputs = {self, nixpkgs, example}@inputs: {
    nixosSystem.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        {nixpkgs.overlays = [(final: prev: {inherit inputs;})];}
      ];
    };
  };
}
```

```nix
{config, pkgs, ...}:
{
  environment.systemPackages = [
    pkgs.vim pkgs.inputs.example.packages.${pkgs.system}.hello
  ];
}
```
