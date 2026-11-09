# PseudoLearn para VS Code

Escribe, comprueba y ejecuta programas de PseudoLearn (archivos `.pseudo`) sin salir del editor: resaltado de sintaxis,
errores mientras escribes, ayuda en el cursor, ejecución con entrada por teclado y depuración.

> Versión previa a producción para uso privado. Se instala desde un archivo VSIX; no se publica en Marketplace ni en
> Open VSX, no envía telemetría y no se actualiza sola.

## Qué incluye

- **Resaltado y edición** de archivos `.pseudo`, con el vocabulario en español o en inglés.
- **Errores y advertencias** a medida que escribes, también en el panel «Problemas».
- **Navegación y renombrado**: ir a la definición, buscar referencias, símbolos del archivo y renombrar un nombre en
  todos los módulos del proyecto.
- **Ayuda en el cursor**: pasa el ratón sobre una palabra o pulsa `Cmd+K Cmd+E` (`Ctrl+K Ctrl+E` en Windows y Linux).
- **Ejecución** de un archivo suelto o de un proyecto con varios módulos. Cuando el programa pide datos (`Leer`), se
  abre un cuadro de entrada.
- **Depuración** con puntos de parada (en escritorio).
- **Traducción del vocabulario** de un archivo entre español e inglés, como una sola edición que se puede deshacer.
- **Asistentes de código**: la extensión da a Copilot y al chat de VS Code herramientas para comprobar y ejecutar
  programas PseudoLearn.

## Requisitos

|                    |                                                                               |
|--------------------|-------------------------------------------------------------------------------|
| Plataforma         | macOS con Apple silicon (`darwin-arm64`); es la única calificada              |
| VS Code            | Stable 1.144.0 o superior                                                     |
| Herramientas extra | Ninguna: el VSIX trae el ejecutable `pseudo` y no necesita Rust, Node ni pnpm |

La variante para navegador (VS Code para la Web) ejecuta y comprueba programas, pero no incluye depuración ni asistentes
de código.

## Instalar

```bash
code --install-extension pseudolearn-0.1.0-darwin-arm64.vsix
```

También sirve «Extensions: Install from VSIX…» en la paleta de comandos (`Cmd+Shift+P`). Instalar una versión nueva con
la misma identidad sustituye a la anterior. Para volver atrás, desinstala con
`code --uninstall-extension pseudolearn.pseudolearn-vscode` e instala el VSIX anterior.

## Primeros pasos

1. Crea un archivo `saludo.pseudo`:

   ```
   Algoritmo Saludo
   Definir nombre Como Cadena <- "";
   Escribir "Como te llamas?";
   Leer nombre;
   Escribir "Hola " + nombre;
   FinAlgoritmo
   ```

2. Guárdalo y ejecuta `PseudoLearn: Run File` desde la paleta de comandos. Escribe tu nombre en el cuadro que aparece.
3. La salida aparece en el canal `PseudoLearn` de la vista «Salida».

El programa debe estar guardado: con cambios sin guardar no se ejecuta, para que lo que corre sea lo que ves.

## Comandos

Todos están en la paleta de comandos, bajo la categoría `PseudoLearn`.

| Comando                        | Qué hace                                                                                                                                          |
|--------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| `Run File`                     | Ejecuta el archivo `.pseudo` activo                                                                                                               |
| `Run Project`                  | Ejecuta el proyecto de la primera carpeta del espacio de trabajo                                                                                  |
| `Select Project Entry`         | Elige qué módulo arranca el proyecto                                                                                                              |
| `Stop Run`                     | Detiene la ejecución en curso                                                                                                                     |
| `Explain at Cursor`            | Muestra la ayuda de la posición del cursor                                                                                                        |
| `Translate Vocabulary`         | Pasa el vocabulario del archivo a español o a inglés                                                                                              |
| `Debug File` / `Debug Project` | Inicia la depuración del archivo o del proyecto                                                                                                   |
| `Create Agent Instructions`    | Crea `AGENTS.md` y `.github/copilot-instructions.md` con las reglas del lenguaje para asistentes de código; nunca sobrescribe archivos existentes |
| `Restart Language Server`      | Reinicia el servidor de lenguaje si dejó de responder                                                                                             |

## Proyectos con varios módulos

Abre la carpeta del proyecto, elige el punto de entrada con `Select Project Entry` y ejecuta `Run Project`. Solo hay una
ejecución a la vez; para pararla usa `Stop Run`. Si el programa no responde a la cancelación en 5 segundos, la extensión
lo termina.

## Configuración

| Ajuste                          | Valores                  | Para qué sirve                                                         |
|---------------------------------|--------------------------|------------------------------------------------------------------------|
| `pseudolearn.profile`           | `es` (por omisión), `en` | Vocabulario con el que se analizan los archivos del espacio de trabajo |
| `pseudolearn.interfaceLanguage` | `es` (por omisión), `en` | Idioma de los mensajes y diagnósticos de la extensión                  |

## Seguridad

- Los programas se ejecutan con los permisos de tu usuario: pueden leer y escribir archivos y usar la red. Ejecuta solo
  código en el que confíes.
- En un espacio de trabajo no confiable (Modo restringido) solo hay resaltado; no se ejecuta nada.
- La entrada que escribes no se registra.

## Problemas conocidos

Los errores de ejecución y los diagnósticos aparecen en el canal `PseudoLearn`; los registros técnicos locales, en
`PseudoLearn (technical)`. Si el servidor de lenguaje deja de responder, ejecuta `PseudoLearn: Restart Language Server`.

## Licencia

Apache-2.0. Los avisos de las dependencias del ejecutable incluido están en `third-party-notices.md`, dentro del
paquete.
