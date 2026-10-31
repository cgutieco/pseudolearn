---
name: update-pseudolearn-vscode
description: Empaqueta e instala en el perfil personal de VS Code la extensión PseudoLearn de este checkout, verifica el bundle instalado y recarga una ventana para mostrar los cambios recientes.
---

# Actualizar PseudoLearn en VS Code

Usa esta skill cuando la persona quiera instalar o actualizar la extensión local `apps/pseudolearn_vscode` en su VS Code personal para probar los cambios actuales.

## Alcance y cuidado del perfil

- Sigue `AGENTS.md` y el `README.md` de `apps/pseudolearn_vscode`; sus scripts y el contrato del artefacto son la autoridad para empaquetar.
- Trabaja desde el checkout y la rama que ya están activos. No crees ramas ni cambies el código de la extensión como parte de una solicitud que solo pide instalarla.
- El VSIX tiene la misma identidad y versión de paquete entre cambios. Usa `--force` al instalar para reemplazarla; no hace falta desinstalar antes.
- No borres la caché general de VS Code, `globalStorage`, `workspaceStorage`, datos de usuario ni extensiones. Instalar el VSIX y recargar el host de extensiones actualiza el código activo sin eliminar datos.
- Respeta instrucciones activas sobre campañas de medición y builds. `pnpm package` reconstruye el ejecutable Rust y el bundle; si la solicitud prohíbe ese trabajo, no lo inicies. Si la persona autoriza empaquetar durante una campaña, hazlo y comunica el hash nuevo.
- No instales desde Marketplace ni Open VSX, no alteres otra extensión y no publiques el artefacto.

## Procedimiento

1. Confirma la raíz con `git rev-parse --show-toplevel`. Revisa `git status --short`, el README de la extensión, `package.json` y `artifact.contract.json`. Una modificación sin commit también forma parte del checkout que se empaquetará; informa si el árbol está sucio.
2. Identifica el CLI de la instalación personal que la persona quiere actualizar. Revisa `command -v code` y `code --version`; en macOS, si no está en el `PATH`, prueba `/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code`. Si hay perfiles o instalaciones distintas y no se puede determinar cuál es el personal, pregunta antes de instalar.
3. Desde `apps/pseudolearn_vscode`, ejecuta las verificaciones que pida la solicitud y el README. Para construir el artefacto local, ejecuta `pnpm package`; no modifiques manualmente `.artifacts/` ni el VSIX.
4. Lee `.artifacts/pseudolearn-0.1.0-darwin-arm64.vsix.sha256` y el registro `.vsix.json`. Conserva el hash para el informe.
5. Desde la raíz del repositorio, instala el VSIX local con el CLI elegido:

   ```bash
   code --install-extension apps/pseudolearn_vscode/.artifacts/pseudolearn-0.1.0-darwin-arm64.vsix --force
   ```

   Si el CLI se resolvió por una ruta completa, usa esa misma ruta en el comando.

6. Verifica la identidad con `code --list-extensions --show-versions` y localiza los archivos instalados con `code --locate-extension pseudolearn.pseudolearn-vscode`. Calcula SHA-256 del `dist/extension.js` instalado y compáralo con `bundleSha256` en `.vsix.json`. No des por verificada la instalación solo porque el CLI informó éxito.
7. Para que la ventana normal cargue el bundle nuevo, recarga la ventana con **Developer: Reload Window** o reinicia VS Code. Si la persona pidió dejar una ventana lista, abre una ventana normal sobre el workspace solicitado. No abras el Extension Development Host como sustituto de instalar en el perfil personal.

## Informe

Indica la identidad y el perfil instalados, la ruta del VSIX, su SHA-256, si el bundle instalado coincide con el registro y qué ventana debe recargarse. Separa las verificaciones ejecutadas de las que quedan manuales. No afirmes que se borró o actualizó una caché si no se hizo una operación específica y autorizada sobre ella.
