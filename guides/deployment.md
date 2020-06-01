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

Make sure rust is installed prior to running `mix deps.compile`. You can see examples of what commands to include in your Dockerfile by looking at the official rust Dockerfiles. For example, here are the commands for [`alpine3.11`](https://github.com/rust-lang/docker-rust/blob/009cc0a821ff773d54875350312731ed490d5cce/1.43.1/alpine3.11/Dockerfile) based images.

If your Dockerfile is separated into a `build stage` and a `release stage` rust only needs to be installed during the build phase. **However**, your image will need to have `libcc` installed during the `release stage`.

```
RUN apk add --no-cache libgcc
```

You will also need to have the folloing environment variable set during the `build` stage or else `mix compile` will fail.

```
RUSTFLAGS='--codegen target-feature=-crt-static'
```
