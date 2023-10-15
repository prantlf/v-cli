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
		args: ['-i', '${cli.outdir}/config-val.json']
		usage: '-i|--init <file>'
		cfg_gen_opt: 'init'
		options_anywhere: true
	}
	_, _ := initialize[Opts](cfg)!
	assert false
}
