# Constitución de web-portfolio

## Core Principles

### I. Spec-driven y aprobación del PO

El desarrollo MUST NOT comenzar sin un `spec.md` aprobado por Jorge
(Product Owner). El flujo de cada feature MUST ser, en este orden:
`/speckit-specify`, `/speckit-plan`, `/speckit-tasks`, `/speckit-implement`,
`/speckit-converge`. MUST NOT saltarse ninguna fase.

Solo Jorge MAY hacer merge. Cualquier otra persona o bot MUST NOT hacerlo.

La aprobación queda registrada solo así, y en este orden:

1. Una PR, desde la rama `NNN-nombre` y con base `develop`, que contiene
   únicamente `specs/NNN-nombre/spec.md`. El Tech Lead, en esa PR, MUST
   sustituir el campo `**Status**: Draft` de la plantilla por
   `Estado: Aprobada por Jorge — PR #N`
   (N es el número de esa PR). Ese campo se reemplaza: MUST NOT quedar
   `Status: Draft` ni un segundo campo de estado. La línea MUST NOT llevar
   fecha. La fecha de la aprobación es el commit de merge en el historial.
   Jorge la fusiona.
2. Después, una segunda PR desde la misma rama `NNN-nombre`, con
   `plan.md` y `tasks.md`. Esas plantillas no traen `Status`. El Tech Lead
   MUST añadir en cada uno, como único campo de estado, la misma línea con
   el número de esta segunda PR. MUST NOT añadirse otro campo de estado.
   `spec.md` MUST estar ya en `develop` antes de abrir esta PR: Jorge
   aprueba la spec antes del plan y de las tareas.
3. MUST NOT abrirse una PR de implementación antes de que la PR de
   `tasks.md` esté fusionada en `develop`.

Las PR de spec, plan y tareas salen de `NNN-nombre`. Cada PR de
implementación sale de una rama efímera `NNN-nombre-tXX`, creada desde
`develop`, y vuelve a `develop`. El prefijo `NNN-` es una convención
humana para leer la rama junto a `specs/NNN-nombre/`. Los scripts de
Spec Kit 1.2.2 no resuelven el directorio por el nombre de la rama git.

En `get_feature_paths()` (`.specify/scripts/bash/common.sh`) el directorio
sale solo de `SPECIFY_FEATURE_DIRECTORY` o de `.specify/feature.json`.
En una rama de tarea, antes de esos scripts, la sesión MUST exportar
`SPECIFY_FEATURE_DIRECTORY=specs/NNN-nombre`. Sin eso, y sin
`feature.json`, el script termina en error. `SPECIFY_FEATURE` es
opcional: `get_current_branch()` solo lo copia a `CURRENT_BRANCH`. Por sí
solo MUST NOT usarse para encontrar la feature.

`.specify/feature.json` es estado por desarrollador. `_persist_feature_json`
lo reescribe al usar `SPECIFY_FEATURE_DIRECTORY`, salvo `--paths-only` o
`--no-persist`. MUST NOT versionarse. Está ignorado en `.gitignore` y en
`.specify/.gitignore`.

Las PR de una feature MUST fusionarse de una en una. MUST NOT fusionarse
en paralelo el trabajo de dos features. `main` MUST recibir solo releases
desde `develop`, y ese merge MUST hacerlo Jorge.

El fichero `.specify/workflows/speckit/workflow.yml` no gobierna este
repo: acaba en implement, no incluye converge y su lista de integraciones
es orientativa (no nombra `cursor-agent`). Manda el flujo de esta
constitución. `/speckit-taskstoissues` está deprecado en 1.2.2 y MUST NOT
usarse.

**Comprobación:** en `develop`, `spec.md` tiene
`Estado: Aprobada por Jorge — PR #N` y no tiene `Status: Draft`; `plan.md`
y `tasks.md` tienen la línea de su PR y ningún otro estado; no hay PR de
implementación abierta antes de ese segundo merge; la base de cada PR de
feature es `develop`; `main` solo tiene merges desde `develop` hechos por
Jorge. `git check-ignore -v .specify/feature.json` señala un ignore.

### II. Stack fijo

El sitio MUST construirse con Hugo extended en una versión fijada en un
solo sitio y documentada. El tema PaperMod MUST ser un git submodule en
`themes/PaperMod` fijado a un tag de release, no a una rama. El tema MUST
NOT editarse.

La restricción de personalización se refiere a overrides del tema y a
CSS o JS propio: eso MUST vivir solo en `layouts/` o `assets/`. MUST NOT
aplicarse a la configuración ni al contenido. `hugo.yaml`, `content/`,
`static/` (incluido un PDF o imágenes) e `i18n/` están permitidos.

**Comprobación:** el puntero del submodule es un tag; el diff no modifica
ficheros dentro de `themes/PaperMod` salvo ese puntero; no hay CSS ni JS
propio fuera de `layouts/` y `assets/`. `hugo.yaml`, `content/`, `static/`
e `i18n/` no cuentan como edición del tema.

### III. Hosting en AWS como restricción

El hosting MUST ser AWS, con estas reglas:

- Bucket S3 privado (Block Public Access activado) y CloudFront con Origin
  Access Control (OAC). El certificado ACM MUST estar en `us-east-1`.
- La infraestructura MUST definirse con Terraform y estado remoto.
- GitHub Actions MUST autenticarse con OIDC. MUST NOT usarse claves de AWS
  de larga duración. Los permisos MUST ser de mínimo privilegio.
- MUST existir dos roles OIDC distintos. El rol de las PR MUST ser de solo
  lectura y MUST usarse para `terraform plan`; ese rol MUST NOT poder
  aplicar ni desplegar. El rol de apply/deploy MUST ser otro, y MUST estar
  restringido a `main` (o a `develop`, si más adelante se decide desplegar
  desde ahí) mediante un GitHub Environment protegido.
- MUST existir una alerta de AWS Budgets de aproximadamente 1 USD al mes.
- La región del bucket y el DNS MUST decidirse en el plan de la feature de
  despliegue, y ese plan MUST contar con la aprobación de Jorge antes de
  implementarse. Esta constitución no fija región ni DNS.

**Comprobación:** la política del rol de plan no permite apply ni cambios
en S3/CloudFront; el Environment del rol de deploy exige protección y no
está disponible en PR; el `plan.md` de la feature de despliegue registra
región y DNS con la aprobación de Jorge; gitleaks no encuentra claves
estáticas.

### IV. Calidad verificable en CI

Estos gates MUST pasar para poder hacer merge, en PR de feature y en PR
que no son de feature:

- `hugo --gc --minify --panicOnWarning` termina sin errores. En CI el sitio
  MUST construirse con un `baseURL` relativo o local (por ejemplo
  `--baseURL /`).
- Los enlaces internos MUST comprobarse con lychee sobre `public/` usando
  `--root-dir` (apuntando a `public/`) para que las rutas absolutas del
  sitio se resuelvan en local. Un enlace interno roto MUST fallar CI. Un
  enlace externo roto MUST NOT fallar el merge: lychee MUST tratarlo solo
  como aviso.
- El escaneo de secretos con gitleaks MUST pasar. La prueba de que el gate
  falla MUST usar un secreto sintético que el ruleset de gitleaks realmente
  detecte. MUST NOT usarse `AKIAIOSFODNN7EXAMPLE`: las reglas por defecto
  lo tienen en la allowlist y la prueba no fallaría.
- En PR que toquen Terraform, MUST ejecutarse `terraform fmt -check`,
  `terraform validate`, `tflint` y `terraform plan` (este último con el rol
  OIDC de solo lectura del principio III).

Todo criterio de aceptación MUST ser comprobable en CI o mediante un paso
manual concreto descrito en `spec.md` o `tasks.md`. Un gate obligatorio en
rojo MUST bloquear el merge. Cuando existan esos workflows, `develop` y
`main` MUST tener branch protection con esos checks como required. Jorge
SHOULD NOT saltarse esa protección, aunque sea admin. Activar la
protección es criterio de la spec que introduzca el CI.

**Comprobación:** un shortcode inexistente, un enlace interno roto
(por ejemplo `[x](/no-existe/)`) o el secreto sintético de la prueba hacen
fallar el job correspondiente; sin ellos, el job pasa. `lychee` se invoca
con `--root-dir` sobre el `public/` generado con `--baseURL /`. Un enlace
externo roto queda en aviso y el job sigue en verde.

### V. PR de implementación acotada

Cada PR de implementación MUST ser pequeña y MUST cubrir una tarea o un
grupo pequeño y cohesionado de tareas de `tasks.md`. MUST salir de la rama
`NNN-nombre-tXX`, creada desde `develop`, con base `develop`.

Esa PR MUST enlazar `spec.md` y `tasks.md`. MUST explicar qué criterios de
aceptación cubre y cómo probarlos. MUST listar en la descripción los ids
de tarea que cierra (por ejemplo `T012`, `T013`). MUST marcar esos mismos
ids como hechos (`[X]`) en `specs/NNN-nombre/tasks.md`, en el mismo cambio.
Los ids de la descripción y los de `tasks.md` MUST coincidir.

Salvo el caso de converge de abajo, una PR de implementación MUST cambiar
`tasks.md` solo para marcar `[X]` los ids que cierra.

`/speckit-converge` lee `spec.md`, `plan.md` y `tasks.md`. Si queda
trabajo, el resultado es `tasks_appended`: solo añade
`## Phase N: Convergence` al final de `tasks.md`. MUST NOT reescribir
tareas ya existentes y MUST NOT modificar `spec.md` ni `plan.md`. Si no
queda trabajo, el resultado es `Converged` y `tasks.md` no cambia. El
skill no guarda esa salida en un fichero: la PR MUST hacerlo, como se
dice más abajo.

Si las tareas añadidas caben en el `spec.md` ya aprobado, se quedan en
`tasks.md` y MUST implementarse en PR posteriores `NNN-nombre-tXX`, con
las mismas reglas. Después MUST volver a ejecutarse `/speckit-converge`
hasta `Converged`.

Si una tarea añadida exigiría cambiar el alcance de `spec.md`, MUST NOT
implementarse antes de una PR nueva de spec. Esa PR solo actualiza
`spec.md`, sustituye el estado por `Estado: Aprobada por Jorge — PR #N`
de esa PR, y la fusiona Jorge.

La última PR de implementación de la feature es la que obtiene
`Converged`. MUST añadir `specs/NNN-nombre/converge.md` con la salida
completa de esa ejecución final, la fecha, el SHA del commit sobre el que
se ejecutó y el veredicto `Converged`. La descripción de la PR MUST copiar
ese veredicto. QA MUST bloquear la PR si el fichero no está o el veredicto
no es `Converged`.

El Reviewer MUST hacer la revisión de QA contra `spec.md`, `tasks.md`,
`converge.md` cuando sea la última PR, y esta constitución antes de pedir
el merge a Jorge. Sin esa revisión, la PR MUST NOT fusionarse.

**Comprobación:** la descripción lista los ids, `tasks.md` los tiene en
`[X]`, y no hay ids de más ni de menos. Una PR que no es la de converge
no reescribe tareas ni cambia `spec.md`. La última PR contiene
`converge.md` con fecha, SHA y `Converged`, y la descripción repite el
veredicto. Si falta el fichero o el veredicto es otro, QA bloquea. La
revisión de QA está registrada antes del merge de Jorge.

### VI. Explicable en entrevista y barato

Las soluciones SHOULD ser simples y estar documentadas, de forma que puedan
explicarse de punta a punta en una entrevista de MLOps. El coste mensual
del sitio MUST mantenerse en torno a 0–1 USD, salvo excepción documentada
en el plan y aprobada por Jorge. MUST NOT añadirse un servicio opaco que
oculte la infraestructura cuando un primitivo documentado cumple el
requisito.

**Comprobación:** el `plan.md` de la feature nombra los servicios y el
coste mensual esperado; un servicio fuera del principio III no se
implementa sin enmienda de esta constitución o sin la aprobación explícita
de Jorge en ese plan.

## Roles

- **Jorge (Product Owner).** Aprueba esta constitución al fusionarla.
  Aprueba cada `spec.md` en su PR y, después, `plan.md` y `tasks.md` en
  una segunda PR. Es la única persona que hace merge. Las releases de
  `develop` a `main` las fusiona siempre Jorge.
- **Tech Lead.** Ejecuta `/speckit-specify`, `/speckit-plan` y
  `/speckit-tasks`.
- **Web Developer.** Ejecuta `/speckit-implement` y, en la última PR de la
  feature, `/speckit-converge`.
- **Reviewer.** Hace la revisión de QA contra `spec.md`, `tasks.md` y esta
  constitución antes de pedir el merge a Jorge. Comprueba que `Estado`
  sustituye a `Status: Draft`, los ids de tarea y, en la última PR, que
  `converge.md` existe y dice `Converged`.

## Ramas y releases

Spec Kit numera cada feature como `NNN-nombre` y crea
`specs/NNN-nombre/spec.md`. `plan.md` y `tasks.md` viven en ese mismo
directorio. Las specs nuevas MUST vivir solo ahí. MUST NOT abrirse una
feature en `docs/specs/`.

- La rama `NNN-nombre` MUST usarse para la PR de `spec.md` y para la PR
  posterior de `plan.md` + `tasks.md`. Ambas tienen base `develop`.
- Cada PR de implementación MUST usar una rama efímera `NNN-nombre-tXX`
  (por ejemplo `001-sitio-hugo-t01`), creada desde `develop`, con PR a
  `develop`. Puede cerrar una tarea o un grupo cohesionado; los ids van en
  la descripción y se marcan `[X]` en `tasks.md`.
- Esas PR MUST fusionarse de una en una. MUST NOT haber dos features
  fusionándose a `develop` a la vez.
- En una rama `NNN-nombre-tXX` la sesión MUST exportar
  `SPECIFY_FEATURE_DIRECTORY=specs/NNN-nombre` antes de los scripts.
  `SPECIFY_FEATURE` es opcional y no localiza el directorio.
  `.specify/feature.json` es estado local, ignorado por git, y MUST NOT
  commitirse.

### Ramas que no son de feature

`chore/`, `docs/`, `fix/` y `ci/` MAY usarse para un cambio sin
comportamiento nuevo visible para el usuario (herramientas, documentación
de proceso, correcciones sin cambio de producto, CI). La PR MUST ir a
`develop`, MUST pasar los mismos gates de CI y MUST fusionarla Jorge.
Cualquier comportamiento nuevo MUST tener spec (`specs/NNN-nombre/`) y
MUST NOT colarse en estas ramas.

Las enmiendas de esta constitución siguen esa regla (`chore/` o `docs/`)
salvo que cambien comportamiento visible, en cuyo caso exigen spec. La
release `develop` → `main` no es una rama de feature: MUST pasar los mismos
gates y MUST fusionarla solo Jorge.

## Governance

Esta constitución prevalece sobre la práctica informal. Una enmienda MUST
proponerse en una pull request hacia `develop` y MUST ser aprobada y
fusionada por Jorge. Hasta ese merge, la enmienda no entra en vigor.

El versionado MUST seguir Semantic Versioning:

- **MAJOR:** se elimina o se redefine de forma incompatible un principio o
  una regla de gobierno.
- **MINOR:** se añade un principio o una sección, o se amplía de forma
  material una regla.
- **PATCH:** aclaraciones, correcciones de redacción o cambios que no
  alteran el significado.

Cada enmienda posterior a la ratificación MUST actualizar la línea de
versión y la fecha de última enmienda. Esta v1.0.0 aún no está ratificada:
las correcciones de esta PR no suben la versión. Queda ratificada cuando
Jorge fusiona esta PR. La fecha de ratificación es 2026-10-20. Si el merge
ocurre otro día, esa misma PR MUST actualizar la fecha de ratificación
antes de fusionarse.

Antes de pedir un merge, el Reviewer MUST comprobar el cumplimiento de
esta constitución. Una PR que contradiga un principio MUST NOT fusionarse.

**Version**: 1.0.0 | **Ratified**: 2026-10-20 | **Last Amended**: 2026-10-20
