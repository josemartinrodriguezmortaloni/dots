use std::path::PathBuf;

use anyhow::{Context, Result};

use crate::catalog::{self, Module};
use crate::dots::Dots;
use crate::link;
use crate::ops::Op;

pub struct Step {
    pub key: &'static str,
    pub ops: Vec<Op>,
}

/// El plan completo, calculado antes de escribir nada. Es lo que la pantalla
/// de confirmación muestra y lo que el hilo de trabajo ejecuta.
pub struct Plan {
    pub steps: Vec<Step>,
}

impl Plan {
    pub fn build(dots: &Dots, keys: &[&'static str]) -> Result<Self> {
        let steps = keys
            .iter()
            .map(|key| step(dots, key))
            .collect::<Result<Vec<Step>>>()?;

        Ok(Self { steps })
    }

    pub fn len(&self) -> usize {
        self.steps.len()
    }

    pub fn keys(&self) -> Vec<&'static str> {
        self.steps.iter().map(|step| step.key).collect()
    }

    /// Archivos existentes que el plan va a mover al backup.
    pub fn displaced(&self) -> Vec<PathBuf> {
        self.steps
            .iter()
            .flat_map(|step| step.ops.iter())
            .filter_map(displaced_by)
            .collect()
    }
}

fn step(dots: &Dots, key: &&'static str) -> Result<Step> {
    let module = module_for(key)?;

    build(dots, module)
}

fn module_for(key: &str) -> Result<&'static Module> {
    catalog::find(key).with_context(|| format!("módulo desconocido: {key}"))
}

fn build(dots: &Dots, module: &'static Module) -> Result<Step> {
    let ops = (module.plan)(dots)
        .with_context(|| format!("no se pudo planificar {}", module.key))?;

    Ok(Step {
        key: module.key,
        ops,
    })
}

fn displaced_by(op: &Op) -> Option<PathBuf> {
    let Op::Link { src, dest } = op else {
        return None;
    };

    link::would_replace(src, dest).then(|| dest.clone())
}
