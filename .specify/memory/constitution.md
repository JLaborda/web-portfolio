# Constitución de web-portfolio

## Core Principles

### I. Spec-driven y aprobación del PO

Ningún desarrollo MUST comenzar sin un `spec.md` aprobado por Jorge
(Product Owner). El flujo de cada feature MUST ser, en este orden:
`/speckit-specify`, `/speckit-plan`, `/speckit-tasks`, `/speckit-implement`,
`/speckit-converge`. No MUST saltarse una fase.

Jorge MUST aprobar esta constitución y cada `spec.md` y `tasks.md` antes de
avanzar a la fase siguiente. Nadie salvo Jorge MUST hacer merge.

Cada feature MUST vivir en `specs/NNN-nombre/` (`spec.md`, `plan.md`,
`tasks.md`) y en su propia rama `NNN-nombre`, con el nombre que asigna
Spec Kit. Las PR de feature MUST tener como base `develop` y MUST
fusionarse de una en una: no hay merges de features en paralelo. `main`
MUST recibir solo releases desde `develop`, y ese merge MUST hacerlo
siempre Jorge.

**Comprobación:** no hay commits de implementación sin `spec.md` y
`tasks.md` ya aprobados por Jorge; cada PR de feature apunta a `develop`;
en `develop` no se solapan merges de dos features; el historial de `main`
solo tiene merges desde `develop` hechos por Jorge.

### II. Stack fijo

El sitio MUST construirse con Hugo extended en una versión fijada en un
solo sitio y documentada. El tema PaperMod MUST ser un git submodule en
`themes/PaperMod` fijado a un tag de release, no a una rama. El tema MUST
NOT editarse. La personalización MUST limitarse a `layouts/` o `assets/`.

**Comprobación:** el puntero del submodule es un tag; el diff no modifica
ficheros dentro de `themes/PaperMod` salvo ese puntero; no hay CSS ni JS
propio fuera de `layouts/` y `assets/`.

### III. Hosting en AWS como restricción

El hosting MUST ser AWS, con estas reglas:

- Bucket S3 privado (Block Public Access activado) y CloudFront con Origin
  Access Control (OAC). El certificado ACM MUST estar en `us-east-1`.
- La infraestructura MUST definirse con Terraform y estado remoto.
- GitHub Actions MUST autenticarse con OIDC. MUST NOT haber claves de AWS
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

Estos gates MUST pasar para poder hacer merge:

- `hugo --gc --minify --panicOnWarning` termina sin errores. En CI el sitio
  MUST construirse con un `baseURL` relativo o local (por ejemplo
  `--baseURL /`).
- Los enlaces internos MUST comprobarse con lychee sobre `public/` usando
  `--root-dir` (apuntando a `public/`) para que las rutas absolutas del
  sitio se resuelvan en local. Un enlace interno roto MUST fallar CI.
- El escaneo de secretos con gitleaks MUST pasar. La prueba de que el gate
  falla MUST usar un secreto sintético que el ruleset de gitleaks realmente
  detecte. MUST NOT usarse `AKIAIOSFODNN7EXAMPLE`: las reglas por defecto
  lo tienen en la allowlist y la prueba no fallaría.
- En PR que toquen Terraform, MUST ejecutarse `terraform fmt -check`,
  `terraform validate`, `tflint` y `terraform plan` (este último con el rol
  OIDC de solo lectura del principio III).

Todo criterio de aceptación MUST ser comprobable en CI o mediante un paso
manual concreto descrito en `spec.md` o `tasks.md`. Un gate obligatorio en
rojo MUST bloquear el merge.

**Comprobación:** un shortcode inexistente, un enlace interno roto
(por ejemplo `[x](/no-existe/)`) o el secreto sintético de la prueba hacen
fallar el job correspondiente; sin ellos, el job pasa. `lychee` se invoca
con `--root-dir` sobre el `public/` generado con `--baseURL /`.

### V. Una tarea por PR

Cada PR de implementación MUST cubrir una sola tarea y MUST ser pequeña.
MUST enlazar su `spec.md` y su `tasks.md`, MUST decir qué criterios de
aceptación cubre y MUST explicar cómo probarlos.

El Reviewer MUST hacer la revisión de QA contra `spec.md`, `tasks.md` y
esta constitución antes de pedir el merge a Jorge. Sin esa revisión, la PR
MUST NOT fusionarse.

**Comprobación:** la descripción de la PR nombra una sola tarea, enlaza
los artefactos y describe la prueba; la revisión de QA está registrada
antes del merge de Jorge.

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

- **Jorge (Product Owner).** Aprueba esta constitución, cada `spec.md` y
  cada `tasks.md`. Es la única persona que hace merge. Las releases de
  `develop` a `main` las fusiona siempre Jorge.
- **Tech Lead.** Ejecuta `/speckit-specify`, `/speckit-plan` y
  `/speckit-tasks`.
- **Web Developer.** Ejecuta `/speckit-implement` y `/speckit-converge`.
- **Reviewer.** Hace la revisión de QA contra `spec.md`, `tasks.md` y esta
  constitución antes de pedir el merge a Jorge.

## Ramas y releases

Spec Kit numera cada feature como `NNN-nombre` y crea
`specs/NNN-nombre/spec.md`. `plan.md` y `tasks.md` viven en ese mismo
directorio. La rama de la feature MUST llamarse igual, `NNN-nombre`.

El orden MUST ser: trabajo en la rama de la feature, PR hacia `develop`,
merge de una feature cada vez, y release de `develop` a `main` solo cuando
Jorge la fusiona. Una feature no empieza su merge a `develop` mientras
otra feature siga sin fusionar.

## Governance

Esta constitución prevalece sobre la práctica informal. Una enmienda MUST
proponerse en una pull request y MUST ser aprobada y fusionada por Jorge.
Hasta ese merge, la enmienda no entra en vigor.

El versionado MUST seguir Semantic Versioning:

- **MAJOR:** se elimina o se redefine de forma incompatible un principio o
  una regla de gobierno.
- **MINOR:** se añade un principio o una sección, o se amplía de forma
  material una regla.
- **PATCH:** aclaraciones, correcciones de redacción o cambios que no
  alteran el significado.

Cada enmienda MUST actualizar la línea de versión y la fecha de última
enmienda. La fecha de ratificación queda pendiente hasta que Jorge apruebe
esta versión; después solo cambia con una ratificación explícita.

Antes de pedir un merge, el Reviewer MUST comprobar el cumplimiento de
esta constitución. Una PR que contradiga un principio MUST NOT fusionarse.

**Version**: 1.0.0 | **Ratified**: TODO(RATIFICATION_DATE): pendiente de aprobación de Jorge | **Last Amended**: 2026-10-20
