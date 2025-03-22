module cli

pub struct Opts {}

fn test_initialize() {
	cfg := Cli{
		usage:            '-c|--config <name> file name or path of the config file'
		version:          '0.0.1'
		cfg_opt:          'c'
		options_anywhere: true
	}
	opts, args := initialize[Opts](cfg)!
	assert args.len == 0
}

fn test_run() {
	cfg := Cli{
		version: '0.0.1'
	}
	mut called := false
	mut called_ref := &called
	body := fn [called_ref] (opts &Opts, args []string) ! {
		assert args.len == 0
		unsafe {
			*called_ref = true
		}
	}
	run(cfg, body)
	assert called
}
