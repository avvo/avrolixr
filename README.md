# Avrolixr

Wrapper around [erlavro](https://github.com/avvo/erlavro) library for Elixir.

## Installation

[Available in Hex](https://hex.pm/packages/avrolixr), the package can be installed as:

  1. Add `avrolixr` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:avrolixr, "~> 0.1.0"}]
    end
    ```

  2. Ensure `avrolixr` is started before your application:

    ```elixir
    def application do
      [applications: [:avrolixr]]
    end
    ```

## Usage

**TODO**

## Tests

**TODO**

## Development

**TODO**

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/avvo/avrolixr. Please update the CHANGELOG
**unreleased** section with your changes. Please do not update version file in
pull request.

## Release Process

1. The version.rb file should only ever be updated in master, don't update it in your branch.
2. Once changes have been merged to master:
3. Update CHANGELOG.md and version.rb file with new version. Commit as "Bump version".
4. Run `mix hex.publish`, which will push to hex.pm.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
