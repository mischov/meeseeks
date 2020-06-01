# Deployment

Meeseeks requires that the Rust compiler be [installed](https://www.rust-lang.org/tools/install) wherever Meeseeks is compiled.

### Deploying to Heroku

Most Heroku buildpacks for Elixir do not come with Rust installed; you will need to:

- Add a Rust buildpack to your app, setting it to run before Elixir; and
- Add a `RustConfig` file to your project's root directory, with `RUST_SKIP_BUILD=1` set.

For example:
```bash
heroku buildpacks:add -i 1 https://github.com/emk/heroku-buildpack-rust.git
echo "RUST_SKIP_BUILD=1" > RustConfig
```

### Deploying with Docker

Make sure Rust is installed prior to running `mix deps.compile`. You can see examples of what commands to include in your Dockerfile by looking at the official Rust Dockerfiles. For example, here are the commands for [`alpine3.11`](https://github.com/rust-lang/docker-rust/blob/009cc0a821ff773d54875350312731ed490d5cce/1.43.1/alpine3.11/Dockerfile) based images.

If your Dockerfile is separated into a build stage and a release stage Rust only needs to be installed on the build stage. **However**, your release stage will need to have `libgcc` installed.

Alpine, for example, does not include `libgcc` by default and you will need to install it.

```
RUN apk add --no-cache libgcc
```

You will also need to have the following environment variable set during the `build` stage or else `mix compile` will fail.

```
RUSTFLAGS='--codegen target-feature=-crt-static'
```
