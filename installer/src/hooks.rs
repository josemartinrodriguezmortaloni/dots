use std::path::Path;

use crate::sh;

type Hook = fn(&Path) -> Vec<String>;

/// El estado del tema activo vive en `~/.local/state`, no en `~/.config`:
/// Omarchy Quattro lo movió y la ruta vieja ya no existe.
const THEME_NAME: &str = ".local/state/omarchy/current/theme.name";

/// El módulo `claude` enlaza este archivo; el script de plugins vive a su lado
/// en el repo, así que el enlace resuelto dice dónde encontrarlo.
const CLAUDE_SETTINGS: &str = ".claude/settings.json";

const HOOKS: [(&str, Hook); 6] = [
    ("hypr", reload_hyprland),
    ("waybar", restart_waybar),
    ("omarchy", apply_theme_hook),
    ("zsh", shell_hint),
    ("tmux", shell_hint),
    ("claude", sync_plugins),
];

/// Efectos que sólo tienen sentido después de que los enlaces existen.
pub fn run(keys: &[&'static str], home: &Path) -> Vec<String> {
    let mut notes: Vec<String> = HOOKS
        .iter()
        .filter(|(key, _)| keys.contains(key))
        .flat_map(|(_, hook)| hook(home))
        .collect();

    notes.dedup();

    notes
}

fn reload_hyprland(_home: &Path) -> Vec<String> {
    if !sh::has_command("hyprctl") {
        return Vec::new();
    }

    if !sh::quiet("hyprctl", &["reload"]) {
        return vec!["hyprctl reload falló".to_owned()];
    }

    let mut notes = vec!["hyprland recargado".to_owned()];
    notes.extend(config_errors());

    notes
}

fn config_errors() -> Option<String> {
    let text = sh::capture("hyprctl", &["configerrors"])?;
    let trimmed = text.trim().to_owned();

    reportable(&trimmed).then(|| format!("hyprland configerrors: {trimmed}"))
}

fn reportable(errors: &str) -> bool {
    !errors.is_empty() && errors != "ok"
}

fn restart_waybar(_home: &Path) -> Vec<String> {
    match sh::quiet("omarchy-restart-waybar", &[]) {
        true => vec!["waybar reiniciada".to_owned()],
        false => Vec::new(),
    }
}

fn apply_theme_hook(home: &Path) -> Vec<String> {
    let Some(name) = theme_name(home) else {
        return Vec::new();
    };

    sh::quiet("omarchy-hook", &["theme-set", &name]);

    vec![format!("hook theme-set aplicado (tema: {name})")]
}

fn theme_name(home: &Path) -> Option<String> {
    let raw = std::fs::read_to_string(home.join(THEME_NAME)).ok()?;
    let name = raw.trim().to_owned();

    (!name.is_empty()).then_some(name)
}

fn shell_hint(_home: &Path) -> Vec<String> {
    vec!["abrí una terminal nueva para tomar los cambios de zsh/tmux".to_owned()]
}

fn sync_plugins(home: &Path) -> Vec<String> {
    let Some(script) = plugins_script(home) else {
        return Vec::new();
    };

    match sh::quiet("bash", &[&script.to_string_lossy()]) {
        true => vec!["plugins de Claude Code sincronizados".to_owned()],
        false => vec![format!("{} falló: correlo a mano para ver el detalle", script.display())],
    }
}

fn plugins_script(home: &Path) -> Option<std::path::PathBuf> {
    let settings = std::fs::canonicalize(home.join(CLAUDE_SETTINGS)).ok()?;

    sh::has_command("claude").then(|| settings.with_file_name("plugins.sh"))
}
