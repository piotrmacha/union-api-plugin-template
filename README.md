# Union API Plugin Template

Template repository for creating Union plugins based on the [Union API](https://gitlab.com/union-framework/union-api)
and [Gothic API](https://gitlab.com/union-framework/gothic-api) projects. It's created to provide an easy way of 
starting a Union API project and includes quality of life features:

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

* [Requirements](https://github.com/piotrmacha/union-api-plugin-template?tab=readme-ov-file#requirements)
* [Usage](https://github.com/piotrmacha/union-api-plugin-template?tab=readme-ov-file#usage)
  * [Build](https://github.com/piotrmacha/union-api-plugin-template?tab=readme-ov-file#build)
  * [PowerShell Module](https://github.com/piotrmacha/union-api-plugin-template?tab=readme-ov-file#powershell-module)
* [Source code structure](https://github.com/piotrmacha/union-api-plugin-template?tab=readme-ov-file#source-code-structure)
  * [Suggested project structure](https://github.com/piotrmacha/union-api-plugin-template?tab=readme-ov-file#suggested-project-structure)
  * [Gothic UserAPI](https://github.com/piotrmacha/union-api-plugin-template?tab=readme-ov-file#gothic-userapi)
  * [Disable or limit multiplatform](https://github.com/piotrmacha/union-api-plugin-template?tab=readme-ov-file#disable-or-limit-multiplatform)
  * [BuildInfo.h](https://github.com/piotrmacha/union-api-plugin-template?tab=readme-ov-file#buildinfoh)
  * [HookUtils.h](https://github.com/piotrmacha/union-api-plugin-template?tab=readme-ov-file#hookutilsh)
* [Linking other libraries](https://github.com/piotrmacha/union-api-plugin-template?tab=readme-ov-file#linking-other-libraries)
* [GitHub Actions](https://github.com/piotrmacha/union-api-plugin-template?tab=readme-ov-file#github-actions)
  * [Release job](https://github.com/piotrmacha/union-api-plugin-template?tab=readme-ov-file#release-job)
  * [Run less jobs](https://github.com/piotrmacha/union-api-plugin-template?tab=readme-ov-file#run-less-jobs)
  * [Self-hosted runner](https://github.com/piotrmacha/union-api-plugin-template?tab=readme-ov-file#self-hosted-runner)
  * [Other CI systems](https://github.com/piotrmacha/union-api-plugin-template?tab=readme-ov-file#other-ci-systems)
* [License](https://github.com/piotrmacha/union-api-plugin-template?tab=readme-ov-file#license)

## Requirements

* MSVC 14.30+ or 14.40+ (Visual Studio 2022)
* CMake 3.28+
* PowerShell 7+ (optional)

## Dependencies

The template project downloads Union API and Gothic API from [union-api.cmake](https://github.com/piotrmacha/union-api.cmake)
that's non-official CMake Targets for Union API. The CMake repository fetches Union API and Gothic API directly from
respective sources. It's convenient, because we don't need to include the CMake configuration for Union API here, and
we can use prebuilt libraries instead of source compilation. The drawback is that the CMake repository may not have
the newest Union API version, however I'll do my best to keep it updated, and you can't download arbitrary Union API
versions not provided by union-api.cmake.

If you have concerns about using a non-official repo as the source for dependencies, or you'd like to change Union API code,
feel free to clone the union-api.cmake repository and change the URLs in `Configuration.cmake`. You can also download it
locally and modify `cmake/FindUnionAPI.cmake` to use `add_subdirectory(path/to/local)` for SOURCE builds instead of 
`FetchContent`. It would look like this:

```cmake
    if(${UNION_API_FETCH_TYPE} STREQUAL "SOURCE")
        # Comment out or delete FetchContent
        #FetchContent_Declare(UnionAPI GIT_REPOSITORY ${UNION_API_URL} GIT_TAG ${UNION_API_COMMIT_REF})
        #FetchContent_MakeAvailable(UnionAPI)
        #FetchContent_GetProperties(UnionAPI SOURCE_DIR UnionAPI_SOURCES)
        # Set UnionAPI_SOURCES variable to point to the union-api.cmake directory 
        set(UnionAPI_SOURCES ${CMAKE_SOURCE_DIR}/union-api.cmake) 
        # Add subdirectory with Union API
        add_subdirectory(${UnionAPI_SOURCES})
        # The rest of the code stays the same
        set(UnionAPI_INCLUDE ${UnionAPI_SOURCES}/union-api/union-api)
        set(UnionAPI_LIB_SHARED UnionAPI)
        set(UnionAPI_LIB_STATIC UnionAPIStatic)
        set(GothicAPI_INCLUDE ${UnionAPI_SOURCES}/gothic-api)
        set(GothicAPI_LIB GothicAPI)
```

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
cmake --build out/build/$PRESET --target all -j 16
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

The project includes a PowerShell module to help with repository management. To run it, **you need PowerShell 7**,
and the default installation for Windows is 5.1, so if you haven't done it yet, [download and install PowerShell 7](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4).
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

#### Clear build directory

The best solution for CMake issues is to clear the output directory with its cache. You can do it either manually by
deleting `out` directory or using `Nek/Clear-Build` command.

#### Updating Union API dependency

CMake downloads the required files for Union API during configuration stage from the defined repository, and it gets only 
the configured version. By default, the version is pinned to specific release, so we don't break someone's build
by a Union API update.

You can update the dependencies using the PowerShell module. First, get the list of available releases.

```powershell
PS C:\dev\union-api-template> Nek\Get-UnionApiVersion
Union API fetch:        BINARY
Union API version:      20240603.1019

Version              Union API Ref                            Gothic API Ref                           Date
-------------------- -------------                            --------------                           ----
20240603.1019        406e3fb32232300bae2ff2ee0018685c15c7f1ef 102f42aaf6fe2f2c9c296f8ec66ee8fcde08d646 03.06.2024 08:21:46
20240602.0235        406e3fb32232300bae2ff2ee0018685c15c7f1ef 102f42aaf6fe2f2c9c296f8ec66ee8fcde08d646 02.06.2024 00:38:01
20240602.0024        406e3fb32232300bae2ff2ee0018685c15c7f1ef 102f42aaf6fe2f2c9c296f8ec66ee8fcde08d646 01.06.2024 22:26:30
20240601.1424        102f42aaf6fe2f2c9c296f8ec66ee8fcde08d646 unknonw                                  01.06.2024 12:26:12

To change the version: Nek\Set-UnionApiVersion [version]
To install the newest: Nek\Set-UnionApiVersion 20240603.1019
```

The releases are fetched from [union-api.cmake](https://github.com/piotrmacha/union-api.cmake) repository using GitHub API.

To change the release use `Nek\Set-UnionApiVersion`. It will update config keys in  `Configuration.cmake`

```powershell
PS C:\dev\union-api-template> Nek\Set-UnionApiVersion 20240603.1019
[Source] Union API commitRef:   tags/20240602.0235
[Source] Union API version:     20240602.0235
[Binary] Union API version:     20240602.0235
Changed configuration UNION_API_COMMIT_REF = tags/20240602.0235
             to value UNION_API_COMMIT_REF = tags/20240603.1019
Changed configuration UNION_API_VERSION = 20240602.0235
             to value UNION_API_VERSION = 20240603.1019
[Source] Union API commitRef:   tags/20240603.1019
[Source] Union API version:     20240603.1019
[Binary] Union API version:     20240603.1019

Run CMake configure again to apply the changes. You may need to Nek\Clear-Build first.
```

Important information is that `UNION_API_COMMIT_REF` format depends on the input. If it starts with `202` or `v`, we
add `tags/` to the beginning, because it's a version tag. In other cases, we assume that the provided version is a valid
Git ref (branch, commit hash). If something is wrong, you can always fix it manually in `Configuration.cmake`.

You can also set the config keys to always download latest version. I don't recommend that, because an update can
break something in your build and should be tested first, but if you'd like to:

```
# Configuration.cmake
# ...
# For SOURCE builds
set(UNION_API_COMMIT_REF "main"
        CACHE STRING "The Git branch or commit ref to download" FORCE)
# ...
# For BINARY builds
# Change URL because it's different for latest release
set(UNION_API_URL "https://github.com/piotrmacha/union-api.cmake/releases/{version}/download/{package}.zip"
        CACHE STRING "The URL to download the Union API release. Use {version} and {package} replacements" FORCE)
set(UNION_API_VERSION "latest"
        CACHE STRING "The version of Union API build from https://github.com/piotrmacha/union-api.cmake/releases/" FORCE)
# ...        
```

## Source code structure

The source code is located in `src/` for the plugin sources and `userapi/` for .inl files included by Gothic API.

Entrypoint `Plugin.cpp` takes care of setting up [Multiplatform build](https://gitlab.com/union-framework/gothic-api/-/wikis/Multiplatform-development)
and the `Plugin.hpp` contains the actual code (or `#include` directives). An important thing to know is that the
`Plugin.hpp` is included 4 times, once for every game engine, and all code resides in the final binary, so you
have to take care of proper includes and global variables using Gothic classes.
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

You can structure the code however you'd like, but for a good separation of concerns I suggest following split:

```
src/
    YourProjectName/
        # files that don't depend on Gothic API and are in namespace "YourProjectName"
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
inside themselves (excl. `Gothic.hpp` and module roots). 
Including external files (like `YourProjectName/`) is fine and there you should use `#pragma once` or include guards.

For an example of this structure, you can have a look at [zBassMusic](https://github.com/Silver-Ore-Team/zBassMusic).

### Gothic UserAPI

Gothic UserAPI files are included in that order:

```
userapi/
<Union API>/ZenGin/Gothic_UserAPI/
```

The local directory takes precedence over the default directory so you only have to copy the files you would like
to override. Full list of available files is here: https://gitlab.com/union-framework/gothic-api/-/tree/main/ZenGin/Gothic_UserAPI

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

The signature files are generated from Gothic API `Names.txt` using [Convert-Gothic-Names.ps1](scripts/Convert-Gothic-Names.ps1)
and placed in the build artifacts inside `Singatures/*.tsv`. If you install the plugin in physical Autorun, you also 
have to copy the `Signatures` directory. VDF build already packs them inside the archive.  

## Linking other libraries

To link other libraries you have to edit `CMakeLists.cmake`. The best place for it is right after the plugin definition.
```cmake
add_library(${PLUGIN_LIBRARY} SHARED ${PLUGIN_SOURCES})
target_include_directories(${PLUGIN_LIBRARY} PRIVATE ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR}/generated)
target_include_directories(${PLUGIN_LIBRARY} PRIVATE BEFORE ${CMAKE_SOURCE_DIR}/userapi)
set_target_properties(${PLUGIN_LIBRARY} PROPERTIES
        OUTPUT_NAME ${OUTPUT_BINARY_NAME})

# Here you can link other libaries using, for example:
# Subdirectories:
#   add_subdirectory(library_sub_dir)
#   target_link_libraries(${PLUGIN_LIBRARY} PRIVATE SomeLib)
#
# FindPackage:
#   find_package(SomeLib CONFIG REQUIRED)   
#   target_link_libraries(${PLUGIN_LIBRARY} PRIVATE SomeLib::SomeTarget)
#
# FetchContent:
#   include(FetchContent)
#   FetchContent_Declare(SomeLib GIT_REPOSITORY git@github.com:SomeAuthor/SomeRepo.git GIT_TAG main)
#   FetchContent_MakeAvailable(SomeLib)
#   target_link_libraries(${PLUGIN_LIBRARY} PRIVATE SomeLib::SomeTarget)
#
# VCPKG/Conan
#   # Setup VCPKG or Conan separately, the template doesn't have any shortcuts
#   target_link_libraries(${PLUGIN_LIBRARY} PRIVATE SomeLib::SomeTarget)
```

## GitHub Actions

The template has workflows for building and releasing the plugin using GitHub Actions. You can find them in `.github/workflows/`.

`build.yaml` is a reusable workflow that builds the project on a single build type. It's not executed directly but called
by other workflows.

`on-push.yaml` runs on push to "main" or "dev" branches and on Pull Requests to them. Workflows start 4 builds,
one for every build type, to verify that the plugin compiles.

`release.yaml` runs on tags starting with `v` (e.g. `v0.0.1`). Release starts 3 builds (Release, RelWithDebInfo, MinSizeRel), 
then it creates a GitHub Release and uploads the artifacts ready to be included in game. Changelog is generated automatically from
Pull Requests. It's highly recommended to use Semantic Versioning for versions. CMake requires the format with 3 or 4 numbers
separated by a dot (0.1.2 or 0.1.2.3) but you can freely use formats like "v0.1.2", "v0.1.2-rc3", "v0.1.2.3", "v0.1.2.3-rc4"
because the build job strips all characters that are not a digit or a dot. As said before, best if you just use 
[Semantic Versioning](https://semver.org/).

### Release job

To trigger the release job, you have to create and push a tag. You can't create a tag on GitHub UI without creating a
release, so we need to do it in the console.

```bash
# Make sure that you are on main and with current state
git checkout -b main
git pull origin main
# Create a tag with version
git tag v0.1.2 -m v0.1.2
# Push tags to origin
git push origin --tags
```

The workflow for release will trigger, and soon it will create a release on GitHub. Best strategy for versioning is 
using [Semantic Versioning](https://semver.org/) with following suggestions:

* `v0.y.z` - development stage, plugin not stable
* `v1.y.z` - stable plugin was published 
* `y` - increment on every new feature (reset `z` to 0)
* `z` - increment on every bug fix 

You would rather not bump the first segment beyond `1` because it means that the change is not backwards compatible, 
and it's hard to define compatibility in a Union plugin. It makes sense for libraries but for plugins you can stay 
with `1` or bump it only for very huge releases just for the flex. Up to you. 

Btw. SemVer can go beyond single digit. If you have `v0.1.9`, you don't have to create `v0.2.0`. The correct bump
for a bugfix would be `v0.1.10` and beyond. That may be obvious, but I have seen people who thought they are limited
to 0-9 (not looking at you Microsoft, good job with MSVC 14.40 / v143).

#### Failed release jobs

If your release job fail for some reason, you need to fix it, obviously. But then our tag still exists, so to 
reuse it, first we need to delete it from GitHub UI in "Tags" menu. Then, we need to delete a local tag and create it
again.

```bash
# Make sure that you are on main and with current state
git checkout -b main
git pull origin main
# Remove local tag
git tag -d v0.1.2
# Create a tag with version
git tag v0.1.2 -m v0.1.2
# Push tags to origin
git push origin --tags
```

Instead of deleting the tag from GitHub UI, you can also `git push origin --tags --force` but don't. If we don't have
to force-push, we don't force-push.

### Run less jobs

By default, each push starts 4 build jobs and every release starts 3 (+4 from the commit). If your repository is private,
and you would like to not waste the CI minutes, you can remove some jobs from the workflows.

* `on-push.yaml`: just remove the job from `jobs:` key
* `release.yaml`: remove build job from `jobs:`, remove download action from `jobs.publish.steps:`, remove `Compress-Archive` 
  and `Copy-Item` pair from the PowerShell script in `jobs.publish.steps.[id: prepare-release]`.

### Self-hosted runner

You can also set up a [self-hosted runner](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners).
To do it, you would need to set up a Windows Server 2022 (or Windows 10/11) on some host with Internet access (public IP not required) and
install Visual Studio 2022 with MSVC 14.39, CMake and the GitHub Runner agent on it. You can use other MSVC versions if
you update them in the workflows YAMLs. This setup should work well with our workflows.

**Never setup self-hosted runner on a public repository**. Unless you can secure it for executing completely arbitrary 
code from very bad people(1) :)

(1) Tricky question. Instead of trying to secure such runner, the proper way is to spin an ephemeral VM for every action 
run with full network and storage isolation, and then destroy it after workflow execution. That's how GitHub is doing it,
and this is the only reasonable way of running public runners.

### Other CI systems

The template doesn't have any prepared pipelines for other CI (excl. Gitea which is compatible with GitHub Actions, just rename .github to .gitea).

You can create such pipeline yourself based on the GitHub workflows, and if you do, please open a Pull Request :)

## License

The template is licensed under [MIT License](LICENSE.md). 

[union-api](https://gitlab.com/union-framework/union-api)
and [gothic-api](https://gitlab.com/union-framework/gothic-api) are licensed
under [GNU GENERAL PUBLIC LICENSE V3](https://gitlab.com/union-framework/union-api-/blob/main/LICENSE).

GothicVDFS 2.6 [Copyright (c) 2001-2003, Nico Bendlin, Copyright (c) 1994-2002, Peter Sabath / TRIACOM Software GmbH](vdf/GothicVFS.License.txt)