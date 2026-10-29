from pathlib import Path
from typing import Annotated

import typer

app = typer.Typer(help="CLI para scaffolding de módulos DDD en Python.")


@app.command()
def module(
    name: str = typer.Argument(..., help="Nombre del módulo a crear"),
    path: Annotated[
        Path,
        typer.Option("--path", "-p", help="Directorio raiz donde se creará el módulo"),
    ] = Path("."),
):
    """Genera la estructura completa de un Bounded Context / Módulo."""
    base_path = Path(f"{path}/{name.lower()}")

    if base_path.exists():
        typer.secho(
            f"El módulo '{name}' ya existe en {base_path}.", fg=typer.colors.RED
        )
        raise typer.Exit(code=1)

    # Definición de carpetas a crear
    directories = [
        # Dominio
        base_path / "domain" / "aggregates",
        base_path / "domain" / "value_objects",
        base_path / "domain" / "events",
        base_path / "domain" / "repositories",
        # Aplicación
        base_path / "application" / "use_cases",
        base_path / "application" / "dtos",
        base_path / "application" / "ports",
        # Infraestructura
        base_path / "infrastructure" / "persistence" / "models",
        base_path / "infrastructure" / "persistence" / "mappers",
        base_path / "infrastructure" / "persistence" / "repositories",
        base_path / "infrastructure" / "adapters",
        # Presentación
        base_path / "presentation" / "v1" / "schemas",
    ]

    # Crear directorios
    for directory in directories:
        directory.mkdir(parents=True, exist_ok=True)
        (directory / "__init__.py").touch()

    # Crear archivos base clave
    files_to_create = {
        base_path / "domain" / "exceptions.py": "# Domain Exceptions\n",
        base_path
        / "presentation"
        / "v1"
        / "routers.py": "from fastapi import APIRouter\n\nrouter = APIRouter()\n",
        base_path / "presentation" / "dependencies.py": "# FastAPI Dependencies\n",
        base_path / "__init__.py": "",
    }

    for file_path, content in files_to_create.items():
        file_path.write_text(content, encoding="utf-8")

    typer.secho(
        f"Módulo '{name}' creado exitosamente en {path}/{name.lower()}",
        fg=typer.colors.GREEN,
    )


app()
