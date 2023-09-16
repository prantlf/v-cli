module cli

import prantlf.cargs { Input, get_val, parse_scanned_to, scan }
import prantlf.config { error_msg_full, find_config_file_any, find_user_config_file_any, read_config_to }
import prantlf.dotenv { LoadError, load_env, load_user_env }

pub enum Env {
	non   = 0
	local = 1
	user  = 2
	both  = 3
}

pub struct Cli {
	Input
pub:
	usage    string
	cfg_opt  string
	cfg_file string
	env      Env
}

pub fn initialize[T](cfg &Cli) !(T, []string) {
	if int(cfg.env) & int(Env.user) != 0 {
		load_user_env(true)!
	}
	if int(cfg.env) & int(Env.local) != 0 {
		load_env(true)!
	}
	scanned := scan(cfg.usage, &Input(cfg))!
	mut opts := T{}
	if cfg.cfg_opt.len > 0 {
		config_name := get_val(scanned, &Input(cfg), cfg.cfg_opt, cfg.cfg_file)!
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
	return opts, parse_scanned_to(scanned, &Input(cfg), mut opts)!
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
