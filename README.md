# web-portfolio
Web that shows my portfolio

## Flujo Spec Kit

Este repositorio sigue GitHub Spec Kit. Los comandos se invocan en el chat
de Cursor, no en la terminal. El orden de cada feature es:

1. `/speckit-specify` — `spec.md`, en una PR que solo contiene ese fichero
2. `/speckit-plan` y `/speckit-tasks` — `plan.md` y `tasks.md`, en una
   segunda PR, después de que Jorge haya fusionado la spec
3. `/speckit-implement` — una tarea, o un grupo pequeño y cohesionado, por PR
4. `/speckit-converge` — se repite hasta `Converged`. La última PR guarda
   la salida en `specs/NNN-nombre/converge.md` (fecha, SHA y veredicto)

Jorge aprueba al fusionar en `develop`. En `spec.md` el Tech Lead sustituye
`**Status**: Draft` por `Estado: Aprobada por Jorge — PR #N` (sin fecha; la
fecha es el merge). En `plan.md` y `tasks.md` esa línea es el único estado.
No se abre una PR de implementación antes de que la PR de tareas esté
fusionada. Si converge añade tareas dentro de la spec, se implementan en
PR posteriores y se vuelve a ejecutar converge. Si cambian el alcance de
la spec, primero va otra PR de `spec.md` aprobada por Jorge.
Los principios están en `.specify/memory/constitution.md`. El workflow
empaquetado `.specify/workflows/speckit/workflow.yml` no sustituye este
flujo. `/speckit-taskstoissues` no se usa.

### Roles

- **Jorge (Product Owner):** aprueba la constitución, la PR de `spec.md` y
  la PR de `plan.md` + `tasks.md`. Es la única persona que hace merge.
- **Tech Lead:** `/speckit-specify`, `/speckit-plan` y `/speckit-tasks`.
- **Web Developer:** `/speckit-implement` y `/speckit-converge`.
- **Reviewer:** revisión de QA contra `spec.md`, `tasks.md` y la
  constitución antes de pedir el merge a Jorge.

### Ramas

La spec y el plan viven en `specs/NNN-nombre/` (`spec.md`, `plan.md`,
`tasks.md`). Sus PR salen de la rama `NNN-nombre`. Cada PR de
implementación sale de `NNN-nombre-tXX`, creada desde `develop`, y vuelve
a `develop`. La descripción lista los ids que cierra y `tasks.md` los marca
`[X]`. Las features se fusionan de una en una. En una rama de tarea hay
que exportar `SPECIFY_FEATURE_DIRECTORY=specs/NNN-nombre`.
`SPECIFY_FEATURE` no localiza el directorio. `.specify/feature.json` es
local y no se versiona.

`chore/`, `docs/`, `fix/` y `ci/` sirven para cambios sin comportamiento
nuevo visible. Van a `develop`, pasan los mismos gates y las fusiona Jorge.
Cualquier comportamiento nuevo exige spec. `main` solo recibe releases
desde `develop`, siempre fusionadas por Jorge.
