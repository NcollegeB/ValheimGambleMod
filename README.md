# GambleMod

A Valheim mod project using [Jotunn](https://github.com/Valheim-Modding/Jotunn) including build tools and a basic Unity project stub.
This repository is configured for `GambleMod` instead of the default template names.

# Setup Guide

Please see [Jotunn Docs](https://valheim-modding.github.io/Jotunn/guides/overview.html) for detailed setup documentation.

### Post Build Automations

Included in this repo is a PowerShell script `publish.ps1`.
The script is referenced in the project file as a post-build event.
Depending on the chosen configuration in Visual Studio the script executes the following actions.

### Building Debug

The compiled dll and a `dll.mdb` debug file are copied to `<ValheimDir>\BepInEx\plugins` or the path set in `MOD_DEPLOYPATH`.

### Building Release

A compressed file with the binaries is created in `<GambleMod>\Package` ready for upload to Thunderstore.
Do not forget to include your information in the `manifest.json` and to update the project's README file.

## Developing Assets with Unity

New assets can be created with Unity and imported into Valheim using the mod.
A Unity project is included in this repository under `<GambleModUnity>`.

### Unity Editor Setup

1. [Download](https://public-cdn.cloud.unity3d.com/hub/prod/UnityHubSetup.exe) Unity Hub directly from Unity or install it with the Visual Studio Installer via `Individual Components` -> `Visual Studio Tools for Unity`
2. You will need a Unity account to register your PC and get a free license. Create the account, log in through Unity Hub, and get your license via `Settings` -> `License Management`
3. Install Unity Editor version `2022.3.17f`
4. Compile the project. This copies all assemblies into `<GambleModUnity>\Assets\Assemblies`. Do not open Unity before this step or it will remove assembly references.
5. These assembly files are copyrighted material. To avoid committing them, keep the `.gitignore` file in the Unity project folder when cloning or copying this repository.
6. Open Unity Hub and add the `GambleModUnity` project
7. Open the project in Unity
8. Install the `AssetBundle Browser` package in the Unity Editor via `Window` -> `Package Manager` for easy bundle creation

## Debugging

See the wiki page [Debugging Plugins via IDE](https://github.com/Valheim-Modding/Wiki/wiki/Debugging-Plugins-via-IDE) for more information.

## Actions After a Game Update

When Valheim updates it is likely that parts of the assembly files change.
If that happens, the references to the assembly files must be renewed in Visual Studio and Unity.

### Prebuild Actions

1. There is a file called `DoPrebuild.props` included in the solution. When you set its only value to `true`, Jotunn will automatically generate publicized assemblies for you. Otherwise you must do this step manually.

### Unity Actions

1. Copy all `assembly_*.dll` files from `<ValheimDir>\valheim_Data\Managed` into `<GambleModUnity>\Assets\Assemblies`.
2. Go to Unity Editor and press `Ctrl+R`. This reloads all files from the filesystem and re-imports the copied dlls into the project.
