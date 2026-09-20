use anyhow::{Result, bail};

pub enum Mode {
    Interactive,
    All,
    Help,
}

pub fn parse(args: &[String]) -> Result<Mode> {
    let Some(flag) = args.first() else {
        return Ok(Mode::Interactive);
    };

    mode_for(flag)
}

fn mode_for(flag: &str) -> Result<Mode> {
    match flag {
        "-a" | "--all" => Ok(Mode::All),
        "-h" | "--help" => Ok(Mode::Help),
        other => bail!("opción desconocida: {other}"),
    }
}
