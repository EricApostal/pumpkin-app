# Pumpkin Mobile
Implementation of the [Pumpkin](https://github.com/Pumpkin-MC/Pumpkin) Rust-based Minecraft server.

## How it works
- Connects to pumpkin over FFI
- Each update will automatically link the latest version of Pumpkin from master

## Limitationsr
- You must relaunch the app in order to start a server after stopping it. I believe this to be a bug with Pumpkin itself.

- There is no plugin support at the moment; loading them might be quite tricky due to SELinux policies (unsure / untested).

- You will not be able to change Pumpkin builds / versions. It is tied to the app version and this will not change due to much stricter SELinux policies (executables cannot be downlaoded at runtime past API version 29).

- There is currently no system from running the server in the background, so your phone screen must be on and the app must be focused. This is an easy fix.