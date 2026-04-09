# Guia de Publicacion

Esta web ya no es solo una plantilla estatica. Ahora mezcla:

- parte publica en HTML
- formulario externo
- publicidad
- cuentas reales
- perfiles editables
- panel admin
- articulos dinamicos
- avisos internos para nuevas publicaciones

Por eso, publicarla bien no es solo "subir archivos". Hay que dejar cerradas varias capas.

## 1. Orden correcto para dejarla lista

Hazlo en este orden:

1. Completa `site-config.js`.
2. Completa `lead-config.js`.
3. Completa `auth-config.js`.
4. Crea el proyecto de Supabase.
5. Ejecuta `supabase-schema.sql`.
6. Registrate con tu correo real desde la propia web.
7. Promociona tu usuario a admin en Supabase.
8. Prueba login, perfil, avisos y publicacion de articulos.
9. Revisa legales, `robots.txt`, `sitemap.xml` y `ads.txt`.
10. Publica.

## 2. Que archivo controla cada cosa

### `site-config.js`

Controla la identidad publica del sitio:

- nombre del sitio
- logo textual y marca `SA`
- dominio
- email y telefono publico
- horario
- titular legal
- NIF/CIF
- direccion legal
- proveedor de analitica
- proveedor del formulario
- datos de publicidad

### `lead-config.js`

Controla a donde se envia el formulario de contacto.

### `auth-config.js`

Controla la capa de usuarios:

- URL de Supabase
- anon key de Supabase
- rutas de login, registro, perfil y admin
- frecuencia de refresco de notificaciones

### `supabase-schema.sql`

Crea toda la parte segura de base de datos:

- `profiles`
- `admin_users`
- `articles`
- `article_notifications`
- triggers
- RLS
- funcion `is_admin`

### `auth-app.js`

Es la logica de:

- registro
- acceso
- perfil
- avisos
- panel admin
- listado dinamico de articulos
- vista publica de cada articulo nuevo

## 3. Que debes poner en cada archivo configurable

### `site-config.js`

Revisa y completa:

- `brandMark`
  Dejalo como `SA` salvo que quieras cambiar el monograma.
- `siteName`
  Nombre publico de la marca.
- `siteUrl`
  Dominio real con `https://`.
- `publicContactEmail`
  Correo publico real.
- `publicContactPhone`
  Solo si vas a atenderlo de verdad.
- `ownerName`
  Titular legal exacto.
- `taxId`
  NIF/CIF real.
- `legalAddress`
  Direccion legal completa.
- `privacyEmail`
  Correo real para privacidad.
- `analyticsProvider`
  Herramienta real.
- `cookieManager`
  CMP o sistema real de cookies.
- `formProcessorName`
  Formspree, CRM, webhook, etc.
- `ads.adsenseClient`
  Tu `ca-pub-...` real.

### `lead-config.js`

Debes revisar:

- `endpoint`
  URL real del formulario.
- `method`
  Normalmente `POST`.
- `headers`
  Lo normal es dejar `Accept: application/json`.

### `auth-config.js`

Debes revisar:

- `supabaseUrl`
  URL del proyecto de Supabase.
- `supabaseAnonKey`
  Anon key publica del proyecto.
- `confirmEmail`
  `true` si quieres validacion por correo.
- `notificationPollMs`
  Cada cuanto refresca avisos internos.

## 4. Como activar el sistema de cuentas de verdad

### Paso 1. Crear el proyecto en Supabase

Necesitas un proyecto nuevo o uno ya existente.

### Paso 2. Ejecutar `supabase-schema.sql`

Abre el SQL Editor de Supabase y pega todo el archivo:

- `supabase-schema.sql`

Eso crea las tablas, triggers y politicas.

### Paso 3. Poner credenciales en `auth-config.js`

Rellena:

- `supabaseUrl`
- `supabaseAnonKey`

Si lo dejas vacio, la web mostrara el sistema de cuentas desactivado.

### Paso 4. Crear tu propia cuenta

Entra en:

- `cuenta/registro.html`

Registrate con el correo que vas a usar como administrador.

### Paso 5. Promocionarte a admin

Despues de registrarte, ejecuta esto en Supabase cambiando el correo:

```sql
insert into public.admin_users (user_id, email)
select id, email
from public.profiles
where email = 'tu-correo-real@dominio.com';
```

Con eso tu usuario pasa a tener acceso real al panel.

### Paso 6. Entrar al panel

Ve a:

- `admin/index.html`

Si tu usuario es admin, veras:

- resumen de miembros
- total de articulos
- total publicados
- personas suscritas a avisos
- editor de articulos
- listado de articulos

## 5. Como funciona ahora la parte de articulos

Hay dos capas:

### Articulos base

Son los HTML fijos que ya existian dentro de `articulos/`.

### Articulos nuevos

Se crean desde `admin/index.html`.

Cuando publicas uno:

- se guarda en Supabase
- aparece en `articulos/index.html`
- se puede leer desde `articulos/publicacion.html?slug=...`
- genera avisos internos para usuarios con notificaciones activadas

## 6. Como funciona la notificacion de nuevos articulos

### Lo que ya hace la web

- el usuario se registra
- entra en `cuenta/perfil.html`
- activa la opcion de avisos
- cuando publicas, se crea una notificacion interna
- el usuario la ve en el menu y en su perfil

### Lo que hace la opcion de navegador

Si el usuario activa avisos del navegador y da permiso, la web puede mostrar avisos locales mientras la pagina este abierta.

### Lo que NO queda resuelto solo con esta base

El envio real por email cada vez que publiques.

La preferencia queda guardada en perfil, pero si quieres correo automatico tendras que integrar despues:

- Resend
- Brevo
- Mailgun
- o una funcion/automatizacion propia

## 7. Que comprobar en la parte publica

Antes de publicar revisa:

- `index.html`
  Home correcta y limpia.
- `articulos/index.html`
  Aparecen articulos base y, si ya publicaste, los dinamicos.
- `articulos/publicacion.html?slug=...`
  Abre bien una publicacion nueva.
- `cuenta/acceder.html`
  Login correcto.
- `cuenta/registro.html`
  Registro correcto.
- `cuenta/perfil.html`
  Guarda cambios de perfil.
- `admin/index.html`
  Solo entra el admin real.

## 8. Que revisar en legales

Como ahora hay cuentas y perfiles, debes revisar especialmente:

- `legal/politica-privacidad.html`

Comprueba que refleje:

- formulario
- cuentas
- perfiles
- notificaciones
- proveedores tecnicos reales

## 9. Publicidad y cuentas: como convivir sin estorbar

La web mantiene publicidad separada del contenido. Lo importante aqui es:

- no romper el flujo de lectura
- no meter anuncios en login, registro o dentro del editor admin
- mantener transparencia visual

Las cuentas y perfiles no deben sentirse como un muro. La web sigue siendo publica y la cuenta sirve para:

- personalizar perfil
- recibir avisos
- acceder al panel si eres admin

## 10. Checklist tecnico final

- `site-config.js` completo
- `lead-config.js` probado
- `auth-config.js` completo
- `supabase-schema.sql` ejecutado
- tu usuario ya es admin
- login funciona
- perfil guarda datos
- avisos internos aparecen
- panel publica articulos
- `robots.txt` correcto
- `sitemap.xml` corregido con tu dominio
- `ads.txt` real
- legales revisados

## 11. Lo unico que no puedo cerrar por ti

Hay cuatro cosas que siguen dependiendo de tus datos reales:

1. Tus credenciales y proyecto de Supabase.
2. Tu dominio final.
3. Tu identificador real de AdSense.
4. Tu proveedor real si quieres notificaciones por correo.

Todo lo demas ya queda preparado para que la web se comporte como una web publica mucho mas seria y completa.
