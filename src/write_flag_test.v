module cli

import os { exists, mkdir }

pub struct Opts {}

const outdir = 'src/testout'

fn testsuite_begin() {
	if !exists(cli.outdir) {
		mkdir(cli.outdir)!
	}
}

fn test_initialize() {
	cfg := Cli{
		args: ['-i']
		usage: '-i|--init'
		cfg_gen_opt: 'init'
		cfg_file: '${cli.outdir}/config-flag.json'
		options_anywhere: true
	}
	_, _ := initialize[Opts](cfg)!
	assert false
}
