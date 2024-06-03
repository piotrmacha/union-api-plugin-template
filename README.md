# Union API Plugin Template

Template repository for creating Union plugins based on the [Union API](https://gitlab.com/union-framework/union-api)
and [Gothic API](https://gitlab.com/union-framework/gothic-api) projects. It's created to provide an easy way of 
starting a Union API project and quality of life features:

* CMake as the build system generator
* Union API and Gothic API are downloaded as a source code to build or as a prebuilt library
* `Configuration.cmake` lets you configure all aspects of the build without touching any CMakeLists.txt
* [Multiplatform development (single plugin, many engines)](https://gitlab.com/union-framework/gothic-api/-/wikis/Multiplatform-development)
* [Union::Signature](https://gitlab.com/union-framework/union-api/-/wikis/hooks:-about-Signatures) files generator and bundler 
* Gothic UserAPI structure (adding new methods to Gothic classes) 
* Build target to create VDFS package  
* GitHub Actions
* QoL: Build targets to copy plugin into the Gothic directory
* QoL: PowerShell module to manage the project setup

## Table of Contents

* [Requiements](https://github.com/piotrmacha/union-api-plugin-template?tab=readme-ov-file#requirements)
* [Usage](https://github.com/piotrmacha/union-api-plugin-template?tab=readme-ov-file#usage)
* [Build](https://github.com/piotrmacha/union-api-plugin-template?tab=readme-ov-file#build)
* [PowerShell Module](https://github.com/piotrmacha/union-api-plugin-template?tab=readme-ov-file#powershell-module)
* [Source Code Structure](https://github.com/piotrmacha/union-api-plugin-template?tab=readme-ov-file#source-code-structure)

## Requirements

* MSVC 14.30+ or 14.40+ (Visual Studio 2022)
* CMake 3.28+
* PowerShell 7+ (optional)

## Usage

Click "Use this template" on GitHub (top-right, green) or download the repository as a ZIP file ("Code" button -> Download ZIP).

The first thing you would like to do is setting up CMake variables. Open `Configuration.cmake` and set your project's name:
```cmake
set(PROJECT_NAME "MyPlugin"
        CACHE STRING "The name of the project" FORCE)
```

By default, Union API is linked as a shared DLL. If you prefer static linking, change this:
```cmake
set(UNION_API_LINK_TYPE STATIC
        CACHE STRING "The linking method of Union API. STATIC = static linking of .lib, SHARED = DLL" FORCE)
```

You can also change the Union API to fetch and build sources (default BINARY uses a prebuilt library). It doesn't change
the version of Union API, though - it's still the same distribution.
```cmake
set(UNION_API_FETCH_TYPE "SOURCE"
        CACHE STRING "How to fetch Union API: SOURCE = download source and build locally, BINARY = download prebuilt artifacts" FORCE)
```

Every option is described, so you can have a look. The defaults are also good.
There are some options (like `COPY_DLL_AUTORUN_DIRECTORY`) that would be different for different people so for them,
you can create `Configuration.override.cmake` and put the config here. This file's settings take precedence over normal
configuration and this file is not commited to the repository.

### Build

To build the project use IDE or code editor with CMake integration (Visual Studio, CLion, VS Code) or use CMake directly
from the command line. The first thing is to choose one of the profiles from `CMakePresets.json` and run CMake configuration.

* x86-debug - debug builds for development
* x86-release - release builds for publication
* x86-relwithdebinfo - release with debug symbols
* x86-minsizerel - most optimized release (longer build)

If you IDE doesn't support `CMakeProfiles.json` set up the profile manually using:

* Generator "Ninja" (not "Ninja Multi-Config", just "Ninja")
* CMake variable `CMAKE_BUILD_TYPE`, one of: Debug, Release, RelWithDebInfo, MinSizeRel

Manually, we can configure the project using CLI CMake:

```bash
cmake --preset x86-debug
```

Then build and install:

```bash
$PRESET = "x86-debug"
cmake --build out/build/$PRESET --target all -j 10
cmake --install out/build/$PRESET --prefix out/install/$PRESET
```

Build artifacts will be available at `out/install/{preset}/bin`.

#### Build Targets

The project sets up several targets for different use cases.

##### Build (named after your PROJECT_NAME)

Builds the plugin and puts the binaries in `out/build/{preset}`.

##### BuildVDF

Creates a VDF package with the plugin.

##### CopyDLLAutorun

Available if you set up `COPY_BUILD_DLL_AUTORUN` option in the configuration. Builds the project and copies all 
required files to the Autorun directory set in `COPY_BUILD_DLL_AUTORUN_DIRECTORY`.
Use this for development to not copy the files manually a milion times.

##### CopyVDFData

Available if you set up `COPY_BUILD_VDF_DATA` option in the configuration. Builds the project (VDF) and copies it 
to the Data directory set in `COPY_BUILD_VDF_DATA_DIRECTORY`.
Use this for development to not copy the files manually a milion times.

### PowerShell Module

The project includes a PowerShell module help with repository management. To run it, **you need PowerShell 7**,
and the default installation for Windows is 5.1, so if you haven't yet, download and install PowerShell 7.
To activate the module, run `Nek.ps1`.

```powershell
PS C:\dev\union-api-template> .\Nek.ps1

Module Name                    Usage                             About                                             Arguments
------ ----------------------- -----                             -----                                             ---------
Nek    Clear-Build             Nek\Clear-Build                   Clears CMake build directory                      {}
Nek    Get-UnionApiVersion     Nek\Get-UnionApiVersion           Shows the available versions of Union API         {}
Nek    Set-UnionApiVersion     Nek\Set-UnionApiVersion [version] Sets the Union API version in Configuration.cmake {[Required] Version: string}

```

To get help for some command, run `Get-Help Nek\NameOfCommand` with the command name. 

#### Updating Union API dependency

CMake downloads the required files for Union API during configuration from configured repositories and gets only 
the configured version. By default, the version is pinned to specific release, so we don't break someone's build
by a Union API update.

You can update the dependencies using the PowerShell module. First, get the list of available releases.

```powershell
PS C:\dev\union-api-template> Nek\Get-UnionApiVersion
Union API fetch:        BINARY
Union API version:      20240602.0235

Version              Union API Ref                            Gothic API Ref                           Date
-------------------- -------------                            --------------                           ----
20240602.0235        406e3fb32232300bae2ff2ee0018685c15c7f1ef 102f42aaf6fe2f2c9c296f8ec66ee8fcde08d646 02.06.2024 00:38:01
20240602.0024        406e3fb32232300bae2ff2ee0018685c15c7f1ef 102f42aaf6fe2f2c9c296f8ec66ee8fcde08d646 01.06.2024 22:26:30
20240601.1424        102f42aaf6fe2f2c9c296f8ec66ee8fcde08d646 unknonw                                  01.06.2024 12:26:12

To change the version: Nek\Set-UnionApiVersion [version]
To install the newest: Nek\Set-UnionApiVersion 20240602.0235

```

The releases are fetch from [union-api.cmake](https://github.com/piotrmacha/union-api.cmake) repository using GitHub API.

To change the release use `Nek\Set-UnionApiVersion`. It will update `Configuration.cmake` keys.

```powershell
PS C:\dev\union-api-template> Nek\Set-UnionApiVersion 20240602.0235
[Source] Union API commitRef:   tags/20240602.0235
[Source] Union API version:     20240602.0235
[Binary] Union API version:     20240602.0235
Changed configuration UNION_API_COMMIT_REF = tags/20240602.0235
             to value UNION_API_COMMIT_REF = tags/20240602.0235
Changed configuration UNION_API_VERSION = 20240602.0235
             to value UNION_API_VERSION = 20240602.0235
[Source] Union API commitRef:   tags/20240602.0235
[Source] Union API version:     20240602.0235
[Binary] Union API version:     20240602.0235

Run CMake configure again to apply the changes. You may need to Nek\Clear-Build first.
```

## Source Code Structure

The source code is located in `src/` for the plugin sources and `userapi/` for .inl files included by Gothic API.

Entrypoint `Plugin.cpp` takes care of setting up [Multiplatform build](https://gitlab.com/union-framework/gothic-api/-/wikis/Multiplatform-development)
and the `Plugin.hpp` contains the actual code (or `#include` directives). An important thing to know is that the
`Plugin.hpp` is included 4 times, once for every game engine, and all code resides in the final binary, so you
have to take care proper includes and global variables using Gothic classes.
Read the  [Multiplatform docs](https://gitlab.com/union-framework/gothic-api/-/wikis/Multiplatform-development)
to better understand what can go wrong and how to write safe code.

The `Plugin.hpp` also uses `GOTHIC_NAMESPACE` as the namespace name, which is a macro expanded to the currently 
included namespace of a single engine.

```
Gothic_I_Classic
Gothic_I_Addon
Gothic_II_Classic
Gothic_II_Addon
```

There are also `Plugin_[ENGINE].hpp` files, which are included only for specific engine. 

### Suggested project structure

You can structure the code however you like, but for good separation of concerns I suggest following split:

```
src/
    YourProjectName/ (
        # files that don't depend on Gothic API and in namespace "YourProjectName"
    Gothic/
        # .hpp files that depend on Gothic API
        SomeModuleName/
            # if you do many features in a plugin, split them in modules
            Hooks.hpp
            Externals.hpp
            SomeModuleName.hpp
        # Common files
        Globals.hpp     # Global variables (if needed)
        Hooks.hpp       # Hook definitions
        Externals.hpp   # Externals definitions 
        Options.hpp     # Function to load .ini settings
    Gothic.cpp
    Gothic.hpp
    Gothic_G1.hpp
    Gothic_G1A.hpp
    Gothic_G2.hpp
    Gothic_G2A.hpp
```

Then your `Gothic.hpp` would contain only `#include`s to the files inside `Gothic` directory.

```cpp
// Globals and Options first, because they are used by others
#include <Gothic/Globals.hpp>
#include <Gothic/Options.hpp>
// Here any files with code used by Externals or Hooks
//  ...
// Here the includes for module main file (which includes other module files)
#include <Gothic/SomeModuleName/SomeModuleName.hpp>
// Externals definitions and hooks go last, because they use the other code 
#include <Gothic/Externals.hpp>
#include <Gothic/Hooks.hpp>
```

All headers in `Gothic/` must not contain `#pragma once` or any include guards, because we need to load them for 
every engine version. That's way the includes are in one file, and you should not include other `Gothic/` files 
inside them. Including external files (like `YourProjectName/`) is fine and files in it should have `#pragma once`
or include guards.

### Disable or limit multiplatform

If you would like to build the project only for a single engine or a limited set of engines, disable them using `Configuration.cmake`.

```cmake
set(GOTHIC_API_G1 ON
        CACHE BOOL "Enable Gothic API for Gothic 1" FORCE)
set(GOTHIC_API_G1A ON
        CACHE BOOL "Enable Gothic API for Gothic Sequel" FORCE)
set(GOTHIC_API_G2 ON
        CACHE BOOL "Enable Gothic API for Gothic 2 Classic" FORCE)
set(GOTHIC_API_G2A ON
        CACHE BOOL "Enable Gothic API for Gothic 2 Night of the Raven" FORCE)
```

### BuildInfo.h

The `src/BuildInfo.h.in` is a template that's configured by CMake and put in the build directory. It contains
variables with the information about current build. You can `#include <BuildInfo.h>` somewhere and use the 
variables to provide build info at runtime.

### HookUtils.h

The `src/Union/HookUtils.h` has a macro and a function to retrieve an original address of some game method
by using information in files generated during CMake configuration. You can use it to set Hooks with the target
method reference instead of looking for an address.

```cpp
auto CGameManager_Init_Ivk = Union::CreateHook(
        ADDRESS_OF(&CGameManager::Init), // use ADDRESS_OF(what) macro to get the address of a Gothic function 
        &CGameManager::Init_Hooked)
```

Only Gothic classes are supported by this method. If you need to hook some other code, you have to use an address.