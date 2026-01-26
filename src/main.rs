use anyhow::{Result, bail};
use clap::{Arg, Command};
use colored::*;
use serde_json::Value;
use std::collections::HashMap;
use std::fs::File;
use std::io;
use std::io::BufReader;
use std::path::PathBuf;
use std::process::Command as ProcCommand;

static/*::作者字段*/AUTHOR: &str = r#"
888       888   888       888   888       888
888   o   888   888   o   888   888   o   888
888  d8b  888   888  d8b  888   888  d8b  888
888 d888b 888   888 d888b 888   888 d888b 888
888d88888b888   888d88888b888   888d88888b888
88888P Y88888   88888P Y88888   88888P Y88888
8888P   Y8888   8888P   Y8888   8888P   Y8888
888P     Y888   888P     Y888   888P     Y888

888888888888P   d888b    888b   d088888888889
       d888P    d8888b   888b   d0888b
      d888P     d88888b  888b   d0888b
     d888P      d888Y88b 888b   d08888888b
    d888P       d888 Y88b888b   d0888b999b
   d888P        d888  Y88888b   d0888b
  d888P         d888   Y8888b   d0888b
d888888888888   d888    Y888b   d088888888889
"#;
static/*::配置文件*/CONFIG:&str="wwwzne.config.json";
fn load_config_from_exe_parent(file: PathBuf) -> Result<HashMap<String, Vec<String>>> {
    let f = File::open(file)?;
    let reader = BufReader::new(f);
    let v: Value = serde_json::from_reader(reader)?;
    match v {
        Value::Object(map) => {
            let mut out = HashMap::new();
            for (k, val) in map {
                match val {
                    Value::String(s) => {
                        out.insert(k, vec![s]);
                    }
                    Value::Array(arr) => {
                        let mut vecs = Vec::with_capacity(arr.len());
                        for item in arr {
                            match item {
                                Value::String(s) => vecs.push(s),
                                _ => bail!("array for key '{}' contains non-string", k),
                            }
                        }
                        out.insert(k, vecs);
                    }
                    _ => bail!("value for key '{}' must be string or array of strings", k),
                }
            }
            Ok(out)
        }
        _ => bail!("config root must be a JSON object"),
    }
}

fn main() -> Result<()> {
    let/*::当前调用目录*/cwd = std::env::current_dir()?;
    let/*::exe存放的路径*/exe: PathBuf = std::env::current_exe()?;
    let/*::exe存放的目录*/parent = exe.parent().ok_or_else(|| io::Error::new(io::ErrorKind::NotFound, "parent dir not found"))?;
    let/*::全局配置文件*/global_config = parent.join(CONFIG);
    let/*::局部配置文件*/local_config = cwd.join(CONFIG);
    let/*::app*/app = Command::new("wwwzne").version(env!("CARGO_PKG_VERSION"))
        .subcommand(
            Command::new("version").about("查看当前版本").long_about("详细查看当前版本号")
        ).subcommand(
            Command::new("config").about("查看配置文件").long_about("详细查看配置文件路径")
        ).subcommand(
            Command::new("path").about("查看工具位置").long_about("详细查看工具存放路径")
        ).subcommand(
            Command::new("wwwzne").about("含义").long_about("wwwzne的含义")
        ).arg(
            Arg::new("subcmd").index(1).help("子命令名称"),
        ).arg(
            Arg::new("args").index(2).trailing_var_arg(true).num_args(0..).help("传递给执行模板的额外参数"),
        );
    let matches = app.get_matches();
    match matches.subcommand() {
        Some(("version", _)) => {
            println!("{}", env!("CARGO_PKG_VERSION"));
            return Ok(());
        }
        Some(("path", _)) => {
            println!("{}", parent.to_string_lossy().bold().bright_green());
            return Ok(());
        }
        Some(("wwwzne", _)) => {
            print!("{}", "World Wide Web Zend Node Element".bright_yellow());
            return Ok(());
        }
        Some(("config", _)) => {
            if global_config.exists() {
                println!(
                    "{} {}",
                    "全局配置文件:".bold().bright_yellow(),
                    local_config.to_string_lossy().bright_green()
                );
            } else {
                println!(
                    "{} {}",
                    "全局配置文件:".bold().bright_yellow(),
                    "未配置".bright_green()
                );
            }
            if local_config.exists() {
                println!(
                    "{} {}",
                    "局部配置文件:".bold().bright_yellow(),
                    local_config.to_string_lossy().bright_green()
                );
            } else {
                println!(
                    "{} {}",
                    "局部配置文件:".bold().bright_yellow(),
                    "未配置(可选)".bright_green()
                );
            }
            return Ok(());
        }
        Some((_, _)) => {}
        None => {}
    }
    let subcmd = matches.get_one::<String>("subcmd").map(|s| s.as_str());
    if subcmd.is_none() {
        print!("{}", AUTHOR.trim().bright_green().bold());
        return Ok(());
    }
    let subcmd = subcmd.unwrap();
    if global_config.exists() {
        let cfg_2 = load_config_from_exe_parent(global_config)?;
        let cfg_1 = if local_config.exists() {
            Some(load_config_from_exe_parent(local_config)?)
        } else {
            None
        };
        let templates = match cfg_1
            .as_ref()
            .and_then(|c| c.get(subcmd))
            .or_else(|| cfg_2.get(subcmd))
        {
            Some(t) => t,
            None => {
                println!("{} {}", "未知指令:".bold().bright_red(), subcmd);
                return Ok(());
            }
        };
        let extra = matches
            .get_many::<String>("args")
            .map(|vals| vals.map(|s| s.as_str()).collect::<Vec<_>>().join(" "))
            .unwrap_or_default();
        let mut script = format!(
            "set wwwznepath={} & set wwwznedir={}",
            parent.to_string_lossy(),
            cwd.to_string_lossy()
        );

        for tpl in templates {
            let part = if extra.is_empty() {
                tpl.clone()
            } else {
                format!("{} {}", tpl, extra)
            };
            script.push_str(" & ");
            script.push_str(&part);
        }

        //windows平台特有
        #[cfg(target_os = "windows")]
        {
            let status = ProcCommand::new("cmd")
                .arg("/V:ON")
                .arg("/C")
                .arg(&script)
                .status()?;
            println!("{}", status.to_string().on_bright_yellow().black());
        }
        //linux平台特有
        #[cfg(target_os = "linux")]
        {
            let status = ProcCommand::new("sh").arg("-c").arg(&script).status()?;
            println!("{}", status);
        }
    }
    Ok(())
}
