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
		args:             ['-i', '${outdir}/config-val.json']
		usage:            '-i|--init <file>'
		cfg_gen_opt:      'init'
		options_anywhere: true
	}
	_, _ := initialize[Opts](cfg)!
	assert false
}
