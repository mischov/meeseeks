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
