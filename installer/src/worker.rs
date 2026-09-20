use std::path::{Path, PathBuf};
use std::sync::mpsc::{self, Receiver};
use std::thread;

use crate::hooks;
use crate::link::{self, Backup};
use crate::ops::Outcome;
use crate::plan::{Plan, Step};

/// Lo que el hilo de trabajo le cuenta al hilo de dibujo. El de dibujo nunca
/// toca el filesystem, así que el donut sigue girando mientras se instala.
pub enum Progress {
    Started {
        index: usize,
        total: usize,
        key: &'static str,
    },
    Failed {
        key: &'static str,
        error: String,
    },
    Finished(Summary),
}

#[derive(Debug, Clone)]
pub struct Summary {
    pub linked: usize,
    pub backed: usize,
    pub backup: PathBuf,
    pub failures: Vec<String>,
    pub notes: Vec<String>,
}

impl Summary {
    fn new(backup: &Path) -> Self {
        Self {
            linked: 0,
            backed: 0,
            backup: backup.to_owned(),
            failures: Vec::new(),
            notes: Vec::new(),
        }
    }

    fn record(&mut self, outcome: Outcome) {
        self.linked += usize::from(outcome.links());
        self.backed += usize::from(outcome.backs_up());
    }
}

pub fn spawn(plan: Plan, backup: Backup, home: PathBuf) -> Receiver<Progress> {
    let (sender, receiver) = mpsc::channel();

    thread::spawn(move || {
        execute(&plan, &backup, &home, &mut |progress| {
            sender.send(progress).ok();
        })
    });

    receiver
}

/// Ningún módulo aborta la corrida: los errores se acumulan y se listan al
/// final, porque un `git clone` sin red no es razón para no enlazar nvim.
pub fn execute(
    plan: &Plan,
    backup: &Backup,
    home: &Path,
    report: &mut impl FnMut(Progress),
) -> Summary {
    let mut summary = Summary::new(backup.root());
    let total = plan.len();

    for (index, step) in plan.steps.iter().enumerate() {
        report(Progress::Started {
            index,
            total,
            key: step.key,
        });
        run_step(step, backup, &mut summary, report);
    }

    summary.notes = hooks::run(&plan.keys(), home);
    report(Progress::Finished(summary.clone()));

    summary
}

fn run_step(
    step: &Step,
    backup: &Backup,
    summary: &mut Summary,
    report: &mut impl FnMut(Progress),
) {
    for op in &step.ops {
        let result = link::apply(op, backup);
        absorb(step.key, result, summary, report);
    }
}

fn absorb(
    key: &'static str,
    result: anyhow::Result<Outcome>,
    summary: &mut Summary,
    report: &mut impl FnMut(Progress),
) {
    match result {
        Ok(outcome) => summary.record(outcome),
        Err(error) => fail(key, &error.to_string(), summary, report),
    }
}

fn fail(key: &'static str, error: &str, summary: &mut Summary, report: &mut impl FnMut(Progress)) {
    summary.failures.push(format!("{key}: {error}"));
    report(Progress::Failed {
        key,
        error: error.to_owned(),
    });
}
