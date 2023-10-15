module cli

import prantlf.cargs { Input, get_flag, get_val, needs_val, parse_scanned_to, scan }
import prantlf.config { error_msg_full, find_config_file_any, find_user_config_file_any, read_config_to, write_config }
import prantlf.dotenv { LoadError, load_env, load_user_env }
import prantlf.strutil { contains_u8_within }

pub enum Env {
	non   = 0
	local = 1
	user  = 2
	both  = 3
}

pub struct Cli {
	Input
pub:
	usage       string
	cfg_opt     string
	cfg_gen_opt string
	cfg_gen_arg string
	cfg_gen_ext string
	cfg_file    string
	env         Env
}

pub fn initialize[T](cfg &Cli) !(&T, []string) {
	if int(cfg.env) & int(Env.user) != 0 {
		load_user_env(true)!
	}
	if int(cfg.env) & int(Env.local) != 0 {
		load_env(true)!
	}
	scanned := scan(cfg.usage, &Input(cfg))!
	mut opts := T{}
	if cfg.cfg_opt.len > 0 {
		config_name := get_val(scanned, cfg.cfg_opt, cfg.cfg_file)!
		if config_name.contains_u8(`/`) || config_name.contains_u8(`\\`) {
			read_config_to(config_name, mut opts)!
		} else {
			if config_file := find_user_config_file_any(config_name) {
				read_config_to(config_file, mut opts)!
			}
			if config_file := find_config_file_any('.', config_name, 10, false) {
				read_config_to(config_file, mut opts)!
			}
		}
	}
	if cfg.cfg_gen_opt.len > 0 {
		mut config_name := if needs_val(scanned, cfg.cfg_gen_opt)! {
			get_val(scanned, cfg.cfg_gen_opt, '')!
		} else {
			if get_flag(scanned, cfg.cfg_gen_opt)! {
				cfg.cfg_file
			} else {
				''
			}
		}
		if config_name.len > 0 {
			gen_cfg(cfg, opts, config_name)!
		}
	}
	args := parse_scanned_to(scanned, &Input(cfg), mut opts)!
	if cfg.cfg_gen_arg.len > 0 && args.len > 0 && args[0] == cfg.cfg_gen_arg {
		gen_cfg(cfg, opts, cfg.cfg_file)!
	}
	return &opts, args
}

fn gen_cfg[T](cfg &Cli, opts &T, config_name string) ! {
	config_file := if !contains_u8_within(config_name, `.`, 1, -1) {
		ext := if cfg.cfg_gen_ext.len > 0 {
			cfg.cfg_gen_ext
		} else {
			'.ini'
		}
		'${config_name}${ext}'
	} else {
		config_name
	}
	write_config(config_file, opts)!
	println('configuration written to "${config_file}')
	exit(0)
}

fn run_int[T](cfg &Cli, body fn (&T, []string) !) ! {
	opts, args := initialize[T](cfg)!
	body(opts, args)!
}

pub fn run[T](cfg &Cli, body fn (&T, []string) !) {
	run_int[T](cfg, body) or {
		msg := if err is LoadError {
			err.msg_full()
		} else {
			error_msg_full(err)
		}
		eprintln(msg)
		exit(1)
	}
}
