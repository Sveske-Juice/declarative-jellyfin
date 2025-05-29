{pkgs}: plugin:
pkgs.buildDotnetModule {
  name = plugin.name;
  version = plugin.version;

  src = plugin.src;

  propegatedBuildInputs =
    if builtins.hasAttr "additionalBuildInputs" plugin
    then plugin.additionalBuildInputs
    else [];

  projectFile = plugin.projectFile;

  nugetDeps = ./nuget-deps.json;

  dotnet-sdk = pkgs.dotnetCorePackages.sdk_8_0;
  dotnet-runtime = pkgs.dotnetCorePackages.aspnetcore_8_0;
  dotnetBuildFlags = ["--no-self-contained"];
}
