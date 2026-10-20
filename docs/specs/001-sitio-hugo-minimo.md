# Spec 001 — Sitio Hugo/PaperMod mínimo con secciones

- **Estado:** Borrador (pendiente de aprobación de Jorge)
- **Autor:** Tech Lead
- **Fecha:** 2026-10-20
- **Relacionado:** ADR-001 (stack e infraestructura). El despliegue en AWS queda para la spec 002.

## Contexto
Jorge quiere un blog/portfolio que cuente lo que ha construido (empezando por SmartWealthAI), por qué y cómo funciona, y qué está aprendiendo ahora. Público: recruiters y hiring managers de ML Engineering/MLOps en fintech. Esta spec solo crea el esqueleto del sitio que compila en local y en CI; no despliega nada.

## Requisitos
1. Repo `JLaborda/web-portfolio` con un sitio Hugo (versión *extended* fijada, p. ej. `0.15x`), tema PaperMod como **git submodule** en `themes/PaperMod` fijado a un tag de release.
2. Configuración en `hugo.yaml` (no `config.toml`): título, `baseURL` provisional, idioma por defecto, autor, enlaces sociales (GitHub `JLaborda`, LinkedIn; email opcional).
3. Secciones de contenido:
   - `content/projects/` — listado de proyectos; una entrada inicial `smartwealthai.md` con placeholder claramente marcado y enlace a https://github.com/JLaborda/SmartWealthAI.
   - `content/now/` (o página `now.md`) — "Aprendiendo ahora / en qué trabajo".
   - `content/about.md` — "Sobre mí".
   - `content/posts/` — blog, vacío salvo un post de bienvenida en `draft: true`.
4. Menú principal con: Proyectos, Ahora, Blog, Sobre mí. Página de inicio en modo *profile* o *home-info* de PaperMod con nombre, una línea de titular y enlaces.
5. Funciones de PaperMod activadas: búsqueda (JSON index + `search.md`), RSS, modo claro/oscuro, tiempo de lectura, ToC en posts.
6. `README.md` con: qué es, requisitos (versión de Hugo), cómo clonar con submódulos y cómo arrancar en local (`hugo server -D`).
7. GitHub Actions `ci.yml`: en cada PR y push a `main`, checkout con submódulos, instala la versión fijada de Hugo extended y ejecuta `hugo --gc --minify` en modo estricto (falla si hay warnings de plantillas o enlaces internos rotos: `--panicOnWarning`).
8. El mismo workflow comprueba enlaces rotos sobre `public/` con `lychee` (internos siempre; externos solo como aviso) y escanea secretos con `gitleaks`.
9. `.gitignore` con `public/`, `resources/_gen/`, `.hugo_build.lock`.

## Criterios de aceptación (verificables)
- [ ] `git clone --recurse-submodules` + `hugo --gc --minify --panicOnWarning` termina con código 0 y genera `public/index.html`.
- [ ] Existen `public/projects/index.html`, `public/projects/smartwealthai/index.html`, `public/now/index.html`, `public/about/index.html`, `public/posts/index.html`, `public/index.xml` y `public/index.json`.
- [ ] El menú de `public/index.html` contiene los 4 enlaces del requisito 4.
- [ ] El post de bienvenida en borrador **no** aparece en `public/` sin `-D`.
- [ ] El job de CI pasa en verde en la PR y falla si se rompe la compilación (comprobable introduciendo un shortcode inexistente en una rama de prueba).
- [ ] El paso `lychee` falla en CI si hay un enlace interno roto (comprobable añadiendo `[x](/no-existe/)` en una rama de prueba).
- [ ] El paso `gitleaks` pasa en verde y falla si se añade un secreto de prueba (p. ej. una clave AWS de ejemplo de la documentación).
- [ ] La versión de Hugo está fijada en un solo sitio (variable en el workflow) y documentada en el README.
- [ ] El submódulo de PaperMod apunta a un tag concreto, no a `master`.

## Decisiones técnicas
- Submódulo en vez de Hugo Modules: más simple de explicar y no requiere Go en CI.
- Sin CSS/JS propio en esta spec; cualquier personalización va en `assets/` o `layouts/` en specs posteriores, nunca editando el tema.

## Fuera de alcance
- Despliegue en AWS, dominio, DNS, HTTPS (spec 002, según ADR-001).
- Contenido real de proyectos y textos definitivos (los escribe/aprueba Jorge).
- Analítica, comentarios, formulario de contacto, multidioma.

## Preguntas abiertas para Jorge
1. Idioma del sitio: ¿solo inglés (recomendado para recruiters), solo español, o bilingüe más adelante?
2. ¿Qué enlaces sociales quieres visibles (GitHub, LinkedIn, Google Scholar, email)?
