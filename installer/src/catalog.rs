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

pub const MODULES: [Module; 9] = [
    Module { key: "nvim",     desc: "Neovim 0.11+ con tema Vesper",                plan: nvim },
    Module { key: "ghostty",  desc: "Emulador de terminal Ghostty",                plan: ghostty },
    Module { key: "hypr",     desc: "Compositor Hyprland (Omarchy Quattro Lua)",   plan: hypr },
    Module { key: "waybar",   desc: "Barra de estado Waybar",                      plan: waybar },
    Module { key: "tmux",     desc: "Tmux con prefijo C-Space",                    plan: tmux },
    Module { key: "zsh",      desc: "Zsh + Zinit + oh-my-posh",                    plan: zsh },
    Module { key: "ohmyposh", desc: "Prompt oh-my-posh, tema star",                plan: ohmyposh },
    Module { key: "themes",   desc: "Temas Omarchy (Token Meridian claro/oscuro)", plan: themes },
    Module { key: "omarchy",  desc: "Hook theme-set y menú Quattro",               plan: omarchy },
];

const VSCODE_EXT: &str = ".vscode/extensions/thorstenrhau.token-vscode-themes-0.0.0";
const CURSOR_FLAG: &str = ".local/state/omarchy/toggles/skip-cursor-theme-changes";

/// Hyprland anterior a Quattro leía estos `.conf`; Quattro carga Lua. Los
/// enlaces que dejó una instalación vieja de este repo se retiran.
const HYPR_LEGACY: [&str; 8] = [
    "autostart.conf",
    "bindings.conf",
    "envs.conf",
    "hypridle.conf",
    "hyprland.conf",
    "hyprlock.conf",
    "input.conf",
    "looknfeel.conf",
];

/// Quattro sacó Walker: estos destinos quedaron huérfanos en instalaciones
/// anteriores a la 4.0.
const WALKER_LEFTOVERS: [&str; 2] = [
    ".config/walker/config.toml",
    ".config/omarchy/themed/walker.css.tpl",
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

fn zsh(dots: &Dots) -> Result<Vec<Op>> {
    Ok(vec![
        link(dots.repo("zsh/.zshrc"), dots.home(".zshrc")),
        link(dots.repo("zsh/.zshenv"), dots.home(".zshenv")),
    ])
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

    ops.extend(stale_overrides(dots, &target));

    Ok(ops)
}

fn hypr_sources(dir: &Path) -> Result<Vec<PathBuf>> {
    let mut found: Vec<PathBuf> = entries(dir)?.into_iter().filter(|p| is_hypr_source(p)).collect();
    found.sort();

    Ok(found)
}

fn is_hypr_source(path: &Path) -> bool {
    matches!(extension(path), "lua" | "conf") || file_name(path) == ".luarc.json"
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
