# Solucion ASNEF

Proyecto web en HTML, CSS y JavaScript orientado a una web informativa sobre ASNEF, deuda, solvencia y soluciones relacionadas, con capa publica y area privada.

## Que incluye ahora

- Portada y guias informativas en `pages/`
- Blog publico en `articulos/`
- Articulos base en HTML y articulos nuevos dinamicos
- Registro, acceso y perfil de usuario
- Preferencias de avisos para nuevos articulos
- Panel de administracion para crear, editar y publicar articulos
- Espacios publicitarios discretos
- Formulario de consulta inicial
- Pags legales y archivos publicos de despliegue

## Archivos principales

- `index.html`
  Home publica.
- `pages/`
  Guias y contacto.
- `articulos/index.html`
  Indice del blog con articulos base y publicaciones nuevas.
- `articulos/publicacion.html`
  Plantilla publica para articulos dinamicos.
- `cuenta/acceder.html`
  Login.
- `cuenta/registro.html`
  Registro.
- `cuenta/perfil.html`
  Perfil editable y avisos.
- `admin/index.html`
  Panel admin real basado en cuenta + rol.
- `styles.css`
  Diseno global.
- `script.js`
  Config, UX comun, formulario, cookies y carga del sistema de cuentas.
- `auth-config.js`
  Credenciales y rutas del sistema de cuentas.
- `auth-app.js`
  Logica de auth, perfiles, admin, articulos y notificaciones.
- `supabase-schema.sql`
  Esquema de base de datos y politicas RLS para Supabase.

## Antes de publicar

1. Completa `site-config.js` con tus datos reales.
2. Completa `auth-config.js` con tu `supabaseUrl` y `supabaseAnonKey`.
3. Ejecuta `supabase-schema.sql` en Supabase.
4. Registrate con tu correo real.
5. Promociona tu usuario a admin en Supabase con el `insert into public.admin_users ...` indicado en el SQL.
6. Prueba login, perfil, publicacion de articulos y avisos.
7. Revisa `lead-config.js`, legales, `robots.txt`, `sitemap.xml` y `ads.txt`.

## Notas importantes

- El panel antiguo con contrasena en navegador ya no es la via recomendada.
- Los avisos de nuevos articulos funcionan de forma interna dentro de la web.
- La preferencia de aviso por correo queda guardada en perfil, pero para envio real por email tendras que integrar un proveedor externo si quieres dar ese paso.
- Los articulos nuevos se publican sin crear HTML manual, pero si quieres sitemap automatico por cada slug tendras que automatizarlo con tu backend o con una funcion externa.
