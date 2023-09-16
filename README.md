# cli

Provides shared code for writing command-line tools.

Uses [prantlf.ini], [prantlf.json] and [prantlf.yaml]. Can be combined with [prantlf.cargs] to override selected options from the command-line.

## Synopsis

Declare a structure for the configuration and read its contents from the first file found with any supported file extension:

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
	quiet        bool
	verbose      bool
	log          string
	tag_prefix   string            [json: 'tag-prefix'] = 'v'
	from         string
	to           string
	path         string
	repo_url     string            [json: 'repo-url']
	bump_major_0 bool              [json: 'bump-major-0']
	dry_run      bool              [json: 'dry-run']
	commit_sep   string            [json: 'commit-sep'] = '----------==========----------'
	subject_re   string            [json: 'subject-re'] = r'^\s*(?<type>[^: ]+)\s*:\s*(?<description>.+)$'
	body_re      string            [json: 'body-re']
	footer_re    string            [json: 'footer-re']
	version_re   string            [json: 'version-re'] = r'^\s*(?<heading>#+)\s+(?:(?<version>\d+\.\d+\.\d+)|(?:\[(?<version>\d+\.\d+\.\d+)\])).+\([-\d]+\)\s*$'
	prolog       string = '# Changes'
	version_tpl  string            [json: 'version-tpl'] = '{heading} [{version}]({repo_url}/compare/{tag_prefix}{prev_version}...{tag_prefix}{version}) ({date})'
	change_tpl   string            [json: 'change-tpl']  = '#{heading} {title}'
	commit_tpl   string            [json: 'commit-tpl']  = '* {description} ([{short_hash}]({repo_url}/commit/{hash}))'
	logged_types []string          [json: 'logged-types'; split] = ['feat', 'fix', 'perf']
	type_titles  map[string]string [json: 'type-titles'] = {
		'feat':            'Features'
		'fix':             'Bug Fixes'
		'perf':            'Performance Improvements'
		'chore':           'Chores'
		'BREAKING_CHANGE': 'BREAKING CHANGES'
	}
mut:
	heading int = 2
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

Specify usage description and version of the command-line tool. Declare a structure with all command-line options. Import the command-line parser and parse the options and arguments:

```go
import prantlf.cargs { Input, parse_to }
import prantlf.cli { find_config_file, read_config }

const usage = '...'
struct Opts { ... }

mut opts := if config_file := find_config_file('.', [
  '.newchanges.ini',
  '.newchanges.properties',
  '.newchanges.json',
  '.newchanges.yml',
  '.newchanges.yaml',
], 10, true) {
  read_config[Opts](config_file)!
} else {
  &Opts{}
}
cmds := parse_to(usage, Input{ version: version }, mut opts)!
```

## Installation

You can install this package either from [VPM] or from GitHub:

```txt
v install prantlf.cli
v install --git https://github.com/prantlf/v-cli
```

## API

The following functions are exported:

### find_config_file(start_dir string, names []string, depth int, user bool) ?string

Searches for files or directories with the specified names. The search starts in the directory `start_dir` and continues to a parent directory as many times as is the number `depth`. The dept 0 means searching only the directory `start_dir`. If the flg `user` is true, it will look to the home directory of the current user too.

Files and directories will be matched with the specified names in the order of the names in the array. The first one matching will cause the method return the absolute path to the found file. If no file or directory with the specified names can be found, `none` will be returned.

```go
config_file := find_config_file('.', [
  '.newchanges.ini',
  '.newchanges.properties',
  '.newchanges.json',
  '.newchanges.yml',
  '.newchanges.yaml',
], 10, true)
```

### find_config_file_any(start_dir string, name string, depth int, user bool) ?string

Simplifies calls to the previous function if you accept all of the configuration files extensions.

```go
config_file := find_config_file_any('.', '.newchanges', 10, true)
```

### find_user_config_file(names []string) ?string

Searches for files or directories with the specified names in the home directory of the current user.

Files and directories will be matched with the specified names in the order of the names in the array. The first one matching will cause the method return the absolute path to the found file. If no file or directory with the specified names can be found, `none` will be returned.

```go
config_file := find_user_config_file([
  '.newchanges.ini',
  '.newchanges.properties',
  '.newchanges.json',
  '.newchanges.yml',
  '.newchanges.yaml',
])
```

### find_user_config_file_any(name string) ?string

Simplifies calls to the previous function if you accept all of the configuration files extensions.

```go
config_file := find_user_config_file_any('.newchanges')
```

### read_config[T](file string) !T

Reads the file and deserialises its contents from the format assumed by the file extension to a new object.

| Extension     | Format                 |
|:--------------|:-----------------------|
| `.ini`        | [INI]                  |
| `.properties` | [INI]                  |
| `.json`       | [JSON]/[JSONC]/[JSON5] |
| `.yml`        | [YAML]                 |
| `.yaml`       | [YAML]                 |

```go
opts := read_config[Opts]('~/.newchanges.json')!
```

### read_config_to[T](file string, mut cfg T) !

Reads the file and deserialises its contents from the format assumed by the file extension to an existing object.

| Extension     | Format                 |
|:--------------|:-----------------------|
| `.ini`        | [INI]                  |
| `.properties` | [INI]                  |
| `.json`       | [JSON]/[JSONC]/[JSON5] |
| `.yml`        | [YAML]                 |
| `.yaml`       | [YAML]                 |

```go
mut opts := Opts{}
opts := read_config_to('~/.newchanges.json', mut opts)!
```
### Errors

If parsing the configuration file fails because of an invalid syntax, a more descriptive message can be printed than the default, single-line one.

```go
import prantlf.cli { read_config, error_msg_full }

struct Config { ... }

if cli := read_config[Config]('.newchanges.ini') {
  ...
} else {
  eprintln(error_msg_full(err))
}
```

For example, parsing the following contents:

    answer=42
    question

will return the following short message by `err.msg()`:

    unexpected end encountered when parsing a property name on line 2, column 9

and the following long and colourful message by `error_msg_full()`:

		unexpected end encountered when parsing a property name:
     1 | answer=42
     2 | question
       |         ^


## Contributing

In lieu of a formal styleguide, take care to maintain the existing coding style. Lint and test your code.

## License

Copyright (c) 2023 Ferdinand Prantl

Licensed under the MIT license.

[VPM]: https://vpm.vlang.io/packages/prantlf.cli
[INI]: https://en.wikipedia.org/wiki/INI_file#Example
[JSON]: https://www.json.org/
[JSONC]: https://changelog.com/news/jsonc-is-a-superset-of-json-which-supports-comments-6LwR
[JSON5]: https://spec.json5.org/
[YAML]: https://yaml.org/
[prantlf.cargs]: https://github/com//prantlf/v-cargs
[prantlf.ini]: https://github.com/prantlf/v-ini
[prantlf.json]: https://github.com/prantlf/v-json
[prantlf.yaml]: https://github.com/prantlf/v-yaml
