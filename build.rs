use std::env;
use std::fs;
use std::path::PathBuf;

fn main() -> std::io::Result<()> {
    println!("cargo:warning={}","开始");

    let out_dir = PathBuf::from(env::var("OUT_DIR").unwrap());
    let target_dir = out_dir.ancestors().nth(3).unwrap().to_path_buf();


    fs::copy("shell/runner.cmd", target_dir.join("runner.cmd"))?;
    fs::copy("shell/server.cmd", target_dir.join("server.cmd"))?;
    fs::copy("shell/test.cmd", target_dir.join("test.cmd"))?;
    fs::copy("shell/r.cmd", target_dir.join("r.cmd"))?;
    fs::copy("shell/wwwzne.config.json", target_dir.join("wwwzne.config.json"))?;

    let mut res = winres::WindowsResource::new();
    res.set_icon("icon.ico");
    res.compile()?;

    println!("cargo:warning=结束");
    Ok(())
}
