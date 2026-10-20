# web-portfolio
Web that shows my portfolio

## Flujo Spec Kit

Este repositorio sigue GitHub Spec Kit. Los comandos se invocan en el chat
de Cursor, no en la terminal. El orden de cada feature es:

1. `/speckit-specify` — especificación (`spec.md`)
2. `/speckit-plan` — plan (`plan.md`)
3. `/speckit-tasks` — tareas (`tasks.md`)
4. `/speckit-implement` — implementación
5. `/speckit-converge` — convergencia con la spec

Ninguna feature pasa a desarrollo sin un `spec.md` aprobado por Jorge.
Los principios están en `.specify/memory/constitution.md`.

### Roles

- **Jorge (Product Owner):** aprueba la constitución, cada `spec.md` y cada
  `tasks.md`, y es la única persona que hace merge.
- **Tech Lead:** `/speckit-specify`, `/speckit-plan` y `/speckit-tasks`.
- **Web Developer:** `/speckit-implement` y `/speckit-converge`.
- **Reviewer:** revisión de QA contra `spec.md`, `tasks.md` y la
  constitución antes de pedir el merge a Jorge.

### Ramas

Cada feature vive en `specs/NNN-nombre/` (`spec.md`, `plan.md`, `tasks.md`)
y en su propia rama `NNN-nombre`, con el nombre que asigna Spec Kit. Las PR
de feature tienen como base `develop` y se fusionan de una en una. `main`
solo recibe releases desde `develop`, siempre fusionadas por Jorge.
