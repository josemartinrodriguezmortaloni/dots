use std::fs;
use std::path::{Path, PathBuf};

use anyhow::{Context, Result};

use crate::dots::Dots;
use crate::link;
use crate::ops::Op;

/// Un módulo del repositorio. `plan` sólo lee el filesystem: devuelve lo que
/// habría que hacer, nunca lo hace.
pub struct Module {
    pub key: &'static str,
    pub desc: &'static str,
    pub plan: fn(&Dots) -> Result<Vec<Op>>,
}

pub const MODULES: [Module; 13] = [
    Module { key: "nvim",     desc: "Neovim 0.11+ con tema Vesper",                plan: nvim },
    Module { key: "ghostty",  desc: "Emulador de terminal Ghostty",                plan: ghostty },
    Module { key: "hypr",     desc: "Compositor Hyprland (Omarchy Quattro Lua)",   plan: hypr },
    Module { key: "waybar",   desc: "Barra de estado Waybar",                      plan: waybar },
    Module { key: "tmux",     desc: "Tmux con prefijo C-Space",                    plan: tmux },
    Module { key: "zathura",  desc: "Visor PDF Zathura con colores del tema",      plan: zathura },
    Module { key: "zsh",      desc: "Zsh + Zinit + oh-my-posh",                    plan: zsh },
    Module { key: "ohmyposh", desc: "Prompt oh-my-posh, tema star",                plan: ohmyposh },
    Module { key: "themes",   desc: "Temas Omarchy (Token Meridian claro/oscuro)", plan: themes },
    Module { key: "omarchy",  desc: "Hook theme-set y menú Quattro",               plan: omarchy },
    Module { key: "pi",       desc: "Pi: AGENTS.md, settings, MCP, extensiones y skills", plan: pi },
    Module { key: "obsidian", desc: "Sincroniza la bóveda con GitHub",             plan: obsidian },
    Module { key: "mise",     desc: "Herramientas globales con mise (claude, pi…)", plan: mise },
];

const VSCODE_EXT: &str = ".vscode/extensions/thorstenrhau.token-vscode-themes-0.0.0";
const CURSOR_FLAG: &str = ".local/state/omarchy/toggles/skip-cursor-theme-changes";

/// `hyprland.lua` carga `hypr.monitors`: el perfil del equipo elegido se enlaza
/// con este nombre y los demás perfiles de `hypr/` no se enlazan.
const MONITORS: &str = "monitors.lua";

/// Hyprland anterior a Quattro leía estos `.conf`; Quattro carga Lua. Los
/// enlaces que dejó una instalación vieja de este repo se retiran, igual que el
/// perfil de escritorio que antes se enlazaba con su propio nombre.
const HYPR_LEGACY: [&str; 9] = [
    "autostart.conf",
    "bindings.conf",
    "envs.conf",
    "hypridle.conf",
    "hyprland.conf",
    "hyprlock.conf",
    "input.conf",
    "looknfeel.conf",
    "monitors-esc.lua",
];

/// Lo que el módulo `claude` enlazaba en `~/.claude` antes de que Pi lo
/// reemplazara. Sólo se retiran los enlaces de este repo, nunca el estado de
/// Claude Code (credenciales y sesiones), que `pi-claude-acp` sigue usando.
const CLAUDE_LEGACY: [&str; 5] = [
    "CLAUDE.md",
    "statusline.sh",
    "hooks",
    "output-styles",
    "rules",
];

/// Lo único de `~/.pi/agent` que escribe el usuario. El resto es estado de Pi
/// o de sus paquetes: credenciales, sesiones, cachés, la instalación y el tema
/// `omarchy-system.json`, que `omarchy-theme-set-pi` regenera en cada cambio.
const PI_CONFIG: [&str; 4] = ["AGENTS.md", "settings.json", "mcp.json", "statusline.json"];

/// Directorios de `pi/` que se enlazan entrada por entrada: en `~/.pi/agent`
/// conviven con lo que instalan `npx skills` y los paquetes de Pi.
const PI_SHARED_DIRS: [&str; 2] = ["skills", "extensions"];

/// Claude Code corre como backend de Pi. Su único setting apaga los plugins que
/// claude.ai sincroniza, que se habilitan por defecto y traen sus propios MCP.
const CLAUDE_SETTINGS: &str = ".claude/settings.json";

/// Quattro sacó Walker: estos destinos quedaron huérfanos en instalaciones
/// anteriores a la 4.0.
const WALKER_LEFTOVERS: [&str; 2] = [
    ".config/walker/config.toml",
    ".config/omarchy/themed/walker.css.tpl",
];

/// El timer de commit local cada 15 minutos que reemplazó `obsidian-sync`.
/// El enlace de `timers.target.wants` lo crea `systemctl enable`.
const AUTOCOMMIT_LEFTOVERS: [&str; 4] = [
    ".local/bin/obsidian-autocommit",
    ".config/systemd/user/obsidian-autocommit.service",
    ".config/systemd/user/obsidian-autocommit.timer",
    ".config/systemd/user/timers.target.wants/obsidian-autocommit.timer",
];

pub fn find(key: &str) -> Option<&'static Module> {
    MODULES.iter().find(|module| module.key == key)
}

fn nvim(dots: &Dots) -> Result<Vec<Op>> {
    Ok(vec![link(dots.repo("nvim"), dots.home(".config/nvim"))])
}

fn ghostty(dots: &Dots) -> Result<Vec<Op>> {
    Ok(vec![link(
        dots.repo("ghostty/config"),
        dots.home(".config/ghostty/config"),
    )])
}

fn waybar(dots: &Dots) -> Result<Vec<Op>> {
    Ok(vec![link(
        dots.repo("waybar/.config/waybar"),
        dots.home(".config/waybar"),
    )])
}

fn tmux(dots: &Dots) -> Result<Vec<Op>> {
    Ok(vec![link(
        dots.repo("tmux/tmux.conf"),
        dots.home(".config/tmux/tmux.conf"),
    )])
}

/// Omarchy renderiza la plantilla en el tema activo y `zathurarc` incluye el
/// resultado: los colores siguen al tema sin regenerar la config.
fn zathura(dots: &Dots) -> Result<Vec<Op>> {
    Ok(vec![
        link(dots.repo("zathura"), dots.home(".config/zathura")),
        link(
            dots.repo("zathura/omarchy-theme.tpl"),
            dots.home(".config/omarchy/themed/zathura.tpl"),
        ),
    ])
}

fn zsh(dots: &Dots) -> Result<Vec<Op>> {
    Ok(vec![
        link(dots.repo("zsh/.zshrc"), dots.home(".zshrc")),
        link(dots.repo("zsh/.zshenv"), dots.home(".zshenv")),
    ])
}

/// mise instala `claude` en la misma ruta en todos los equipos, y
/// `CLAUDE_CODE_EXECUTABLE` en `.zshrc` depende de esa ruta.
fn mise(dots: &Dots) -> Result<Vec<Op>> {
    Ok(vec![link(
        dots.repo("mise/config.toml"),
        dots.home(".config/mise/config.toml"),
    )])
}

fn ohmyposh(dots: &Dots) -> Result<Vec<Op>> {
    Ok(vec![link(
        dots.repo("ohmyposh/star.omp.json"),
        dots.home(".config/ohmyposh/star.omp.json"),
    )])
}

fn hypr(dots: &Dots) -> Result<Vec<Op>> {
    let target = dots.home(".config/hypr");
    let mut ops: Vec<Op> = hypr_sources(&dots.repo("hypr"))?
        .into_iter()
        .map(|src| link_into(src, &target))
        .collect();

    ops.push(link(
        dots.repo("hypr").join(dots.machine()?.monitors()),
        target.join(MONITORS),
    ));
    ops.extend(stale_overrides(dots, &target));

    Ok(ops)
}

fn hypr_sources(dir: &Path) -> Result<Vec<PathBuf>> {
    let mut found: Vec<PathBuf> = entries(dir)?
        .into_iter()
        .filter(|p| is_hypr_source(p) && !is_monitor_profile(p))
        .collect();
    found.sort();

    Ok(found)
}

fn is_hypr_source(path: &Path) -> bool {
    matches!(extension(path), "lua" | "conf") || file_name(path) == ".luarc.json"
}

fn is_monitor_profile(path: &Path) -> bool {
    file_name(path).starts_with("monitors")
}

fn stale_overrides(dots: &Dots, target: &Path) -> Vec<Op> {
    HYPR_LEGACY
        .iter()
        .map(|name| target.join(name))
        .filter(|dest| owned_link(dest, dots.root()))
        .map(remove)
        .collect()
}

/// `omarchy-theme-list` acepta symlinks, así que cada tema se enlaza con su
/// propio nombre y el contenido sigue viviendo en el repo.
fn themes(dots: &Dots) -> Result<Vec<Op>> {
    let installed = dots.home(".config/omarchy/themes");
    let mut ops: Vec<Op> = dangling(&installed).into_iter().map(remove).collect();

    ops.extend(theme_links(dots, &installed)?);
    ops.push(link(
        dots.repo("vscode/token-vscode-themes"),
        dots.home(VSCODE_EXT),
    ));

    Ok(ops)
}

fn theme_links(dots: &Dots, installed: &Path) -> Result<Vec<Op>> {
    Ok(dirs(&dots.repo("themes"))?
        .into_iter()
        .map(|theme| link_into(theme, installed))
        .collect())
}

fn omarchy(dots: &Dots) -> Result<Vec<Op>> {
    let mut ops = vec![
        link(
            dots.repo("omarchy/hooks/theme-set"),
            dots.home(".config/omarchy/hooks/theme-set"),
        ),
        link(
            dots.repo("omarchy/extensions/omarchy-menu.jsonc"),
            dots.home(".config/omarchy/extensions/omarchy-menu.jsonc"),
        ),
        link(
            dots.repo("omarchy/shell.toml"),
            dots.home(".config/omarchy/shell.toml"),
        ),
    ];

    ops.extend(walker_leftovers(dots));
    ops.extend(background_pools(dots)?);
    ops.push(Op::SkipCursorThemeChanges {
        flag: dots.home(CURSOR_FLAG),
    });

    Ok(ops)
}

fn pi(dots: &Dots) -> Result<Vec<Op>> {
    let target = dots.home(".pi/agent");
    let mut ops: Vec<Op> = PI_CONFIG
        .iter()
        .map(|name| link_into(dots.repo("pi").join(name), &target))
        .collect();

    for dir in PI_SHARED_DIRS {
        ops.extend(
            dirs(&dots.repo("pi").join(dir))?
                .into_iter()
                .map(|src| link_into(src, &target.join(dir))),
        );
    }
    ops.push(link(dots.repo("pi/claude/settings.json"), dots.home(CLAUDE_SETTINGS)));
    ops.extend(claude_leftovers(dots));

    Ok(ops)
}

fn claude_leftovers(dots: &Dots) -> Vec<Op> {
    let claude = dots.home(".claude");
    let skills = entries(&claude.join("skills")).unwrap_or_default();

    CLAUDE_LEGACY
        .iter()
        .map(|name| claude.join(name))
        .chain(skills)
        .filter(|dest| owned_link(dest, dots.root()))
        .map(remove)
        .collect()
}

/// Sólo la mecánica de versionado vive en el repo: `dots` es público y la
/// bóveda, con sus notas, se queda en `~/Documents/Obsidian`.
fn obsidian(dots: &Dots) -> Result<Vec<Op>> {
    let mut ops = vec![
        link(dots.repo("obsidian/sync.sh"), dots.home(".local/bin/obsidian-sync")),
        link_into(
            dots.repo("obsidian/obsidian-sync.service"),
            &dots.home(".config/systemd/user"),
        ),
    ];
    ops.extend(autocommit_leftovers(dots));

    Ok(ops)
}

fn autocommit_leftovers(dots: &Dots) -> Vec<Op> {
    AUTOCOMMIT_LEFTOVERS
        .iter()
        .map(|rel| dots.home(rel))
        .filter(|dest| owned_link(dest, dots.root()))
        .map(remove)
        .collect()
}

fn walker_leftovers(dots: &Dots) -> Vec<Op> {
    WALKER_LEFTOVERS
        .iter()
        .map(|rel| dots.home(rel))
        .filter(|dest| owned_link(dest, dots.root()))
        .map(remove)
        .chain(std::iter::once(remove(dots.home(".config/walker"))))
        .collect()
}

/// `omarchy-theme-bg-next` busca fondos en `backgrounds/<slug>/`, una carpeta
/// por tema. Enlazar el pool compartido bajo cada slug se lo expone a todos;
/// los fondos propios del tema siguen apareciendo porque la búsqueda combina
/// ambos directorios.
fn background_pools(dots: &Dots) -> Result<Vec<Op>> {
    let root = dots.home(".config/omarchy/backgrounds");
    let pool = dots.repo("omarchy/backgrounds");
    let mut ops: Vec<Op> = detached_root(&root).into_iter().collect();

    ops.extend(
        slugs(dots)
            .into_iter()
            .map(|slug| link(pool.clone(), root.join(slug))),
    );

    Ok(ops)
}

/// El directorio tiene que ser real y contener un symlink por tema: una
/// versión vieja enlazaba el directorio entero y eso rompía la detección.
fn detached_root(root: &Path) -> Option<Op> {
    link::is_symlink(root).then(|| remove(root.to_owned()))
}

fn slugs(dots: &Dots) -> Vec<String> {
    let sources = [
        dots.repo("themes"),
        dots.home(".config/omarchy/themes"),
        dots.home(".local/share/omarchy/themes"),
    ];

    let mut names: Vec<String> = sources
        .iter()
        .flat_map(|dir| dirs(dir).unwrap_or_default())
        .filter_map(|dir| name_of(&dir))
        .collect();

    names.sort();
    names.dedup();

    names
}

fn link(src: PathBuf, dest: PathBuf) -> Op {
    Op::Link { src, dest }
}

fn link_into(src: PathBuf, dir: &Path) -> Op {
    let dest = dir.join(src.file_name().unwrap_or_default());

    Op::Link { src, dest }
}

fn remove(dest: PathBuf) -> Op {
    Op::Remove { dest }
}

/// Un enlace que apunta dentro del repositorio, o que quedó colgado, lo puso
/// este instalador. Cualquier otro destino es del usuario y no se toca.
fn owned_link(dest: &Path, root: &Path) -> bool {
    link::is_symlink(dest) && fs::canonicalize(dest).ok().is_none_or(|t| t.starts_with(root))
}

fn dangling(dir: &Path) -> Vec<PathBuf> {
    entries(dir)
        .unwrap_or_default()
        .into_iter()
        .filter(|path| link::is_symlink(path) && fs::canonicalize(path).is_err())
        .collect()
}

fn dirs(parent: &Path) -> Result<Vec<PathBuf>> {
    let mut found: Vec<PathBuf> = entries(parent)?.into_iter().filter(|p| p.is_dir()).collect();
    found.sort();

    Ok(found)
}

fn entries(dir: &Path) -> Result<Vec<PathBuf>> {
    let read = fs::read_dir(dir).with_context(|| format!("no se pudo leer {}", dir.display()))?;

    Ok(read.filter_map(|entry| entry.ok()).map(|e| e.path()).collect())
}

fn name_of(path: &Path) -> Option<String> {
    Some(path.file_name()?.to_string_lossy().into_owned())
}

fn extension(path: &Path) -> &str {
    path.extension().and_then(|ext| ext.to_str()).unwrap_or("")
}

fn file_name(path: &Path) -> &str {
    path.file_name().and_then(|name| name.to_str()).unwrap_or("")
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::machine::Machine;
    use std::os::unix::fs as unix;
    use tempfile::TempDir;

    fn pi_repo() -> (TempDir, Dots) {
        let dir = TempDir::new().expect("tempdir");
        let skills = dir.path().join("repo/pi/skills");
        fs::create_dir_all(skills.join("locality")).expect("skill");
        fs::create_dir_all(dir.path().join("repo/pi/extensions/guard")).expect("extension");
        fs::write(skills.join("README.md"), "").expect("file");

        let dots = Dots::at(dir.path().join("repo"), dir.path().join("home"), Some(Machine::Notebook));

        (dir, dots)
    }

    fn hypr_repo(machine: Option<Machine>) -> (TempDir, Dots) {
        let dir = TempDir::new().expect("tempdir");
        let hypr = dir.path().join("repo/hypr");
        fs::create_dir_all(&hypr).expect("hypr");

        for name in ["hyprland.lua", "monitors.lua", "monitors-esc.lua"] {
            fs::write(hypr.join(name), "").expect("file");
        }

        let dots = Dots::at(dir.path().join("repo"), dir.path().join("home"), machine);

        (dir, dots)
    }

    fn links(ops: &[Op]) -> Vec<(PathBuf, PathBuf)> {
        ops.iter()
            .filter_map(|op| match op {
                Op::Link { src, dest } => Some((src.clone(), dest.clone())),
                _ => None,
            })
            .collect()
    }

    fn monitors_source(machine: Machine) -> Vec<PathBuf> {
        let (_dir, dots) = hypr_repo(Some(machine));

        monitors_of(&dots)
    }

    fn monitors_of(dots: &Dots) -> Vec<PathBuf> {
        let dest = dots.home(".config/hypr").join(MONITORS);

        links(&hypr(dots).expect("plan"))
            .into_iter()
            .filter(|(_, d)| *d == dest)
            .map(|(src, _)| src.strip_prefix(dots.root()).expect("repo").to_owned())
            .collect()
    }

    #[test]
    fn hypr_links_desktop_profile_as_monitors() {
        assert_eq!(
            monitors_source(Machine::Desktop),
            [PathBuf::from("hypr/monitors-esc.lua")]
        );
    }

    #[test]
    fn hypr_links_notebook_profile_as_monitors() {
        assert_eq!(
            monitors_source(Machine::Notebook),
            [PathBuf::from("hypr/monitors.lua")]
        );
    }

    #[test]
    fn hypr_does_not_link_profiles_by_their_own_name() {
        let (_dir, dots) = hypr_repo(Some(Machine::Desktop));

        let found = dests(&hypr(&dots).expect("plan"));

        assert!(found.contains(&dots.home(".config/hypr/hyprland.lua")));
        assert!(!found.contains(&dots.home(".config/hypr/monitors-esc.lua")));
    }

    #[test]
    fn hypr_fails_until_a_machine_is_chosen() {
        let (_dir, mut dots) = hypr_repo(None);
        assert!(hypr(&dots).is_err());

        dots.choose(Machine::Notebook);
        assert_eq!(
            monitors_of(&dots),
            [PathBuf::from("hypr/monitors.lua")]
        );
    }

    fn dests(ops: &[Op]) -> Vec<PathBuf> {
        ops.iter()
            .filter_map(|op| match op {
                Op::Link { dest, .. } => Some(dest.clone()),
                _ => None,
            })
            .collect()
    }

    fn removals(ops: &[Op]) -> Vec<PathBuf> {
        ops.iter()
            .filter_map(|op| match op {
                Op::Remove { dest } => Some(dest.clone()),
                _ => None,
            })
            .collect()
    }

    #[test]
    fn pi_links_config_skills_and_extensions_into_the_agent_dir() {
        let (_dir, dots) = pi_repo();
        let agent = dots.home(".pi/agent");

        let found = dests(&pi(&dots).expect("plan"));

        for name in PI_CONFIG {
            assert!(found.contains(&agent.join(name)), "{name}");
        }
        assert!(found.contains(&agent.join("skills/locality")));
        assert!(found.contains(&agent.join("extensions/guard")));
        assert!(!found.contains(&agent.join("skills/README.md")));
        assert!(!found.contains(&agent.join("skills")));
        assert!(!found.contains(&agent.join("themes/omarchy-system.json")));
        assert!(found.contains(&dots.home(CLAUDE_SETTINGS)));
    }

    #[test]
    fn pi_retires_only_the_claude_links_this_repo_owns() {
        let (dir, dots) = pi_repo();
        let claude = dots.home(".claude");
        fs::create_dir_all(claude.join("skills")).expect("skills");
        fs::create_dir_all(dir.path().join("elsewhere")).expect("foreign target");
        unix::symlink(dots.root().join("claude/CLAUDE.md"), claude.join("CLAUDE.md")).expect("owned");
        unix::symlink(dots.root().join("claude/skills/locality"), claude.join("skills/locality")).expect("owned");
        unix::symlink(dir.path().join("elsewhere"), claude.join("skills/foreign")).expect("foreign");
        unix::symlink(dots.root().join("pi/claude/settings.json"), dots.home(CLAUDE_SETTINGS)).expect("current");
        fs::write(claude.join(".credentials.json"), "{}").expect("state");

        let removed = removals(&pi(&dots).expect("plan"));

        assert!(removed.contains(&claude.join("CLAUDE.md")));
        assert!(removed.contains(&claude.join("skills/locality")));
        assert!(!removed.contains(&claude.join("skills/foreign")));
        assert!(!removed.contains(&claude.join(".credentials.json")));
        assert!(!removed.contains(&dots.home(CLAUDE_SETTINGS)));
    }

    #[test]
    fn mise_links_the_global_config() {
        let (_dir, dots) = pi_repo();

        let found = dests(&mise(&dots).expect("plan"));

        assert_eq!(found, [dots.home(".config/mise/config.toml")]);
    }

    #[test]
    fn zathura_links_the_config_and_the_theme_template() {
        let (_dir, dots) = pi_repo();

        let found = links(&zathura(&dots).expect("plan"));

        assert_eq!(
            found,
            [
                (dots.repo("zathura"), dots.home(".config/zathura")),
                (
                    dots.repo("zathura/omarchy-theme.tpl"),
                    dots.home(".config/omarchy/themed/zathura.tpl"),
                ),
            ]
        );
    }

    #[test]
    fn obsidian_links_the_script_and_unit_but_not_the_vault() {
        let (_dir, dots) = pi_repo();

        let found = dests(&obsidian(&dots).expect("plan"));

        assert!(found.contains(&dots.home(".local/bin/obsidian-sync")));
        assert!(found.contains(&dots.home(".config/systemd/user/obsidian-sync.service")));
        assert!(!found.contains(&dots.home("Documents/Obsidian")));
    }

    #[test]
    fn obsidian_retires_the_autocommit_timer_links() {
        let (dir, dots) = pi_repo();
        let units = dots.home(".config/systemd/user");
        let wants = units.join("timers.target.wants");
        fs::create_dir_all(&wants).expect("units");
        fs::create_dir_all(dots.home(".local/bin")).expect("bin");
        fs::write(dir.path().join("elsewhere"), "").expect("foreign target");
        unix::symlink(dots.root().join("obsidian/autocommit.sh"), dots.home(".local/bin/obsidian-autocommit")).expect("owned");
        unix::symlink(dots.root().join("obsidian/obsidian-autocommit.timer"), units.join("obsidian-autocommit.timer")).expect("owned");
        unix::symlink(units.join("obsidian-autocommit.timer"), wants.join("obsidian-autocommit.timer")).expect("enabled");
        unix::symlink(dir.path().join("elsewhere"), units.join("obsidian-autocommit.service")).expect("foreign");

        let removed = removals(&obsidian(&dots).expect("plan"));

        assert!(removed.contains(&dots.home(".local/bin/obsidian-autocommit")));
        assert!(removed.contains(&units.join("obsidian-autocommit.timer")));
        assert!(removed.contains(&wants.join("obsidian-autocommit.timer")));
        assert!(!removed.contains(&units.join("obsidian-autocommit.service")));
    }
}
