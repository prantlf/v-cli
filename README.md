# cli

Provides shared code for writing command-line tools.

Combines [prantlf.cargs], [prantlf.config] and [prantlf.dotennv] in a typical way how command--line tools with a configuration file a command-line and with environment variables are initialised.

## Synopsis

```go
import prantlf.cli { Cli, run }

const version = '0.0.1'

const usage = 'Updates the changelog file using git log messages.

Usage: newchanges [options]

Options:
	-c|--config <name>        file name or path of the config file
  ...
  -V|--version              print the version of the executable and exits
  -h|--help                 print the usage information and exits

Default change types to include in the log: "feat", "fix", "perf". If
the commit message includes the note "BREAKING CHANGE", it will be
included in the log regardless of its type.

Examples:
  $ newchanges -f v0.1.0 -t v0.2.0
  $ newchanges -d'
 
struct Opts {
	...
}

fn main() {
	run(Cli{
		usage: usage
		version: version
		cfg_opt: 'c'
		cfg_file: '.newchanges'
	}, body)
}

fn body(opts &Opts, _args []string) ! {
  ...
}
```

## Installation

You can install this package either from [VPM] or from GitHub:

```txt
v install prantlf.cli
v install --git https://github.com/prantlf/v-cli
```

## API

The structure `Cli` expects the following fields inherited from `prantlf.Input`:

| Field                    | Type        | Default     | Description                                                  |
|:-------------------------|:------------|:------------|:-------------------------------------------------------------|
| `version`                | `string`    | `'unknown'` | version of the tool to print if `-V|--version` is requested  |
| `args`                   | `?[]string` | `none`      | raw command-line arguments, defaults to `os.args[1..]`       |
| `disable_short_negative` | `bool`      | `false`     | disables handling uppercase letters as negated options       |
| `ignore_number_overflow` | `bool`      | `false`     | ignores an overflow when converting numbers to option fields |
| `options_anywhere`       | `bool`      | `false`     | do not look for options only after the line with `Options:`  |

And the following extra fields:

| Field      | Type     | Default | Description                                        |
|:-----------|:---------|:--------|:---------------------------------------------------|
| `usage`    | `string` | `''`    | usage instructions                                 |
| `cfg_opt`  | `string` | `''`    | short or long argument for the configuration file  |
| `cfg_file` | `string` | `''`    | the default name of the configuration file         |
| `env`      | `Env`    | `non`   | if environment variables should be read from .env  |

See [prantlf.cargs] for more information about the command-line argument parsing.

### initialize[T](cfg &Cli) !(T, []string)

Initialises the application and returns a structure initialised from the configuration file and command line and the rest of command-line arguments.

```go
struct Opts {
	...
}

opts, args := initialize[Opts](Cli{
	usage: '...'
	version: '0.0.1'
})!
```

### run(cfg &Cli, body fn (&T, []string) !)

Wraps an execution of a command-line tool. Initialises the application and calls the callback with a structure initialised from the configuration file and command line and the rest of command-line arguments.

```go
struct Opts {
	...
}

run(Cli{
	usage: '...'
	version: '0.0.1'
}, fn (opts &Opts, args []string) ! {
	...
)!
```

## Contributing

In lieu of a formal styleguide, take care to maintain the existing coding style. Lint and test your code.

## License

Copyright (c) 2023 Ferdinand Prantl

Licensed under the MIT license.

[VPM]: https://vpm.vlang.io/packages/prantlf.cli
[prantlf.cargs]: https://github/com//prantlf/v-cargs
[prantlf.config]: https://github.com/prantlf/v-config
[prantlf.dotenv]: https://github.com/prantlf/v-dotenv
