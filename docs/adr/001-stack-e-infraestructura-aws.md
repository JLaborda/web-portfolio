# ADR-001 — Stack del sitio e infraestructura en AWS

- **Estado:** Propuesto (pendiente de aprobación de Jorge)
- **Fecha:** 2026-10-20

## Contexto
Sitio estático Hugo + PaperMod. Hosting obligatorio en AWS, coste objetivo ~1 $/mes, y la infraestructura debe poder explicarse en una entrevista de MLOps (IaC, CI/CD, mínimo privilegio).

## Decisión propuesta
- **Generador:** Hugo extended + PaperMod (submódulo, tag fijado).
- **Almacenamiento:** bucket S3 privado (Block Public Access activado), sin website hosting.
- **CDN/HTTPS:** CloudFront con Origin Access Control (OAC) hacia S3, HTTP→HTTPS, certificado ACM en **us-east-1** (requisito de CloudFront).
- **URLs bonitas:** una CloudFront Function en *viewer-request* que reescribe `/ruta/` → `/ruta/index.html` (con OAC el origen REST de S3 no resuelve índices de subdirectorios).
- **IaC:** Terraform; estado remoto en un bucket S3 dedicado con versionado y `use_lockfile` (sin DynamoDB). El bucket de estado se crea en un paso de bootstrap documentado.
- **CI/CD:** GitHub Actions con **OIDC** hacia un rol IAM (sin claves de larga duración), permisos limitados a `s3:PutObject/DeleteObject/ListBucket` en el bucket del sitio y `cloudfront:CreateInvalidation` en la distribución. En push a `main`: build, `aws s3 sync --delete`, invalidación. En PR: build, `terraform fmt -check`, `terraform validate`, `tflint` y `terraform plan`; estos checks serán criterios de aceptación de la spec 002.
- **Coste:** alerta de AWS Budgets a 1 $/mes (avisos al 80 % real y 100 % previsto) por email.
- **Región:** `eu-south-2` (España) o `eu-west-1` para el bucket; ACM siempre en `us-east-1`.

## Opciones de DNS
| Opción | Coste aprox. | Pros | Contras |
|---|---|---|---|
| A. Route 53 | 0,50 $/mes por zona + consultas (alias a CloudFront gratis) + dominio (~13–15 $/año un `.com`) | Todo en AWS y en Terraform; validación ACM automática; mejor relato en entrevista | Solo la zona ya consume ~la mitad del presupuesto de 1 $ |
| B. Cloudflare DNS (proxy desactivado) | 0 $ DNS + dominio (~10 $/año a precio de coste) | Más barato | Dos proveedores; registros CNAME manuales o con provider de Cloudflare en Terraform |
| C. Sin dominio propio (`*.cloudfront.net`) | 0 $ | Arranque inmediato | URL poco profesional; se puede migrar a A o B después |

**Recomendación:** empezar con C para tener el pipeline en marcha y pasar a A cuando haya dominio (subir el Budget a ~2 $/mes). El dominio se paga aparte de la cuota mensual.

## Coste estimado (tráfico de portfolio, < 10 GB/mes)
- S3 y CloudFront: dentro de la capa gratuita (CloudFront: 1 TB y 10 M peticiones/mes gratis de forma permanente) → ~0 $.
- AWS Budgets: las dos primeras alertas son gratis.
- Route 53 (si A): ~0,50–0,60 $/mes.
- **Total:** ~0 $/mes con C o B; ~0,6 $/mes con A, más el dominio anual.

## Consecuencias
- (+) Infraestructura reproducible, sin secretos en el repo, explicable de punta a punta.
- (−) Más piezas que GitHub Pages; requiere una cuenta de AWS y un bootstrap manual inicial (bucket de estado y proveedor OIDC).

## Alternativas descartadas
- **AWS Amplify Hosting:** más sencillo pero oculta la infraestructura; menos valor como pieza de portfolio.
- **S3 website endpoint público:** no admite HTTPS propio sin CloudFront y obliga a bucket público.
- **GitHub Pages:** incumple el requisito de AWS.

## Preguntas abiertas para Jorge
1. ¿Tienes ya un dominio? Si no, ¿empezamos sin dominio (opción C)?
2. ¿Tienes cuenta de AWS lista para esto (idealmente una cuenta o perfil separado) y qué email recibe la alerta de Budgets?
3. Región del bucket: ¿`eu-south-2` o `eu-west-1`?
