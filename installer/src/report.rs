use crate::catalog::MODULES;
use crate::worker::{Progress, Summary};

/// Salida en texto plano: el modo `--all` no inicializa ratatui, y el resumen
/// se reimprime fuera de la pantalla alternativa para que sobreviva a la TUI.
pub fn help() {
    println!("\n  instalador de dotfiles");
    println!("  enlaza cada módulo del repositorio en su ubicación esperada\n");
    println!("  USO");
    println!("    ./install.sh [OPCIONES]\n");
    println!("  OPCIONES");
    println!("    -a, --all     instala todos los módulos sin TUI");
    println!("    -h, --help    muestra esta ayuda\n");
    println!("  MÓDULOS");

    for module in &MODULES {
        println!("    {:<9} {}", module.key, module.desc);
    }

    println!();
}

pub fn line(progress: &Progress) {
    match progress {
        Progress::Started { index, total, key } => println!("  [{}/{}] {key}", index + 1, total),
        Progress::Failed { key, error } => eprintln!("  {key}: {error}"),
        Progress::Finished(_) => {}
    }
}

pub fn summary(summary: Option<&Summary>) {
    let Some(summary) = summary else {
        return;
    };

    println!(
        "\n  {} enlace(s) creados · {} respaldado(s)",
        summary.linked, summary.backed
    );
    println!("  backup → {}", summary.backup.display());

    print_all(&summary.failures);
    print_all(&summary.notes);
    println!();
}

fn print_all(items: &[String]) {
    for item in items {
        println!("  {item}");
    }
}
