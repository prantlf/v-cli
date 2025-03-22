module cli

import os { exists, mkdir }

pub struct Opts {}

const outdir = 'src/testout'

fn testsuite_begin() {
	if !exists(outdir) {
		mkdir(outdir)!
	}
}

fn test_initialize() {
	cfg := Cli{
		args:             ['init']
		cfg_gen_arg:      'init'
		cfg_file:         '${outdir}/config-arg.ini'
		options_anywhere: true
	}
	_, _ := initialize[Opts](cfg)!
	assert false
}
