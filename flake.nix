{
  description = "";

  inputs = {
    meptlpkgs.url = "gitlab:Meptl/meptlpkgs";
  };

  outputs = { self, nixpkgs, meptlpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {
    devShell.${system} = pkgs.mkShell {
      buildInputs = with pkgs; [
        pre-commit

        # Custom gdtoolkit 4.0 build.
        meptlpkgs.packages.${system}.gdtoolkit
      ];
    };
  };
}
