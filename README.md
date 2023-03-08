# GBAsic

This project aims to make gba homebrew development lighter and more accessible to modern systems.

This is for all intents and purposes a project template and is not aimed towards a full blown system installation.

I have found this to be the best compromise for GBA development in my case.

# Installation

## Requirements (Fedora / WSL Fedora)

```
sudo dnf install make git gcc arm-none-eabi-binutils-cs arm-none-eabi-gcc-cs arm-none-eabi-gcc-cs-c++ arm-none-eabi-newlib
```

## Requirements (Ubuntu / WSL Ubuntu)
```
sudo apt install build-essential git gcc-arm-none-eabi binutils-arm-none-eabi libnewlib-arm-none-eabi libnewlib-dev libstdc++-arm-none-eabi-dev libstdc++-arm-none-eabi-newlib
```

## Clone
```
git clone --recurse-submodules https://github.com/EssGeeEich/GBAsic.git
cd GBAsic
```

## Build
```
make -j
```

## Development
It is suggested to find an appropriate IDE for development.

For convenience, a VSCode workspace is provided.
To open VSCode in WSL, you must install vscode in WSL (command "code" must exist); Afterwards, you can open `wsl_open_workspace.bat` to open the VSCode workspace in the default WSL distribution.

You can adapt this batch file to any other WSL distribution.

# RAM

malloc and new calls allocate memory in EWRAM between address 0x02000000 and 0x0203FFFF (256 KB)

# Stack

The stack uses memory in IWRAM between address 0x03000000 and 0x03007FFF (32 KB)

# ROM

ROM data is accessible via memory between address 0x08000000 and 0x47FFFFFF (32 MB)

# Libraries

libgba is included and preconfigured. Some standard libraries are available and working.

# Limitations

C++ features need more testing (Classes). Exceptions are disabled.
