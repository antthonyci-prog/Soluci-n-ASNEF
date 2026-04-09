# 🚀 GUÍA COMPLETA DE CONFIGURACIÓN Y PUBLICACIÓN - SOLUCIÓN ASNEF

> **Tiempo estimado:** 45-60 minutos | **Dificultad:** Principiante-Intermedia

Esta guía te llevará paso a paso para configurar completamente tu sitio ASNEF con:
- ✅ Autenticación de usuarios (Supabase)
- ✅ Administrador (tú mismo como primer admin)
- ✅ Perfiles de usuarios personalizables
- ✅ Sistema de notificaciones de nuevos artículos
- ✅ Logo con marca "SA"
- ✅ Publicación en dominio propio

---

## 📋 ÍNDICE

1. [Requisitos previos](#requisitos-previos)
2. [FASE 1: Setup de Supabase](#fase-1-setup-de-supabase)
3. [FASE 2: Configuración del sitio](#fase-2-configuración-del-sitio)
4. [FASE 3: Crear tu usuario Admin](#fase-3-crear-tu-usuario-admin)
5. [FASE 4: Probar localmente](#fase-4-probar-localmente)
6. [FASE 5: Publicar en producción](#fase-5-publicar-en-producción)
7. [Troubleshooting](#troubleshooting)

---

## Requisitos previos

Antes de empezar, necesitas:

- [ ] **Cuenta Supabase** (gratuita): [https://supabase.com](https://supabase.com)
- [ ] **Dominio propio** o subdominio (ej: `www.tudominio.com`)
- [ ] **Hosting estático** (Netlify, Vercel, GitHub Pages, Azure Static Web Apps, etc.)
- [ ] **VS Code** o editor de texto
- [ ] **Navegador moderno** (Chrome, Firefox, Edge)
- [ ] **Email personal** para ser el admin
- [ ] **Formspree** (gratuito para formularios): [https://formspree.io](https://formspree.io) - OPCIONAL

---

## FASE 1: Setup de Supabase

### Paso 1.1: Crea un proyecto en Supabase

1. Ve a [https://supabase.com](https://supabase.com) e inicia sesión (o crea cuenta)
2. Haz clic en **"New project"**
3. **Nombre del proyecto**: `asnef-solucion` (o el que prefieras)
4. **Elige región más cercana** a tu ubicación (ej: Europa-Irlanda)
5. **Contraseña de base de datos**: Crea una fuerte. **GUÁRDALA EN LUGAR SEGURO**
6. Haz clic en **"Create new project"**
7. Espera a que se cree (2-5 minutos)

### Paso 1.2: Obtén las credenciales de Supabase

Una vez creado el proyecto:

1. Ve a **Settings > API** (en la barra izquierda)
2. Copia estos valores:
   - **Project URL** → Servirá como `supabaseUrl`
   - **anon public** (Key) → Servirá como `supabaseAnonKey`
3. **Guárdalos temporalmente** en un bloc de notas

**Ejemplo de cómo se ven:**
```
Project URL: https://abcdefghijklmnopqrst.supabase.co
Anon Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBh...
```

### Paso 1.3: Ejecuta el script de base de datos

1. En Supabase, ve a **SQL Editor** (barra izquierda)
2. Haz clic en **"New Query"**
3. **Abre el archivo** `supabase-schema.sql` en tu carpeta del proyecto
4. **Copia TODO el contenido** del archivo
5. **Pégalo** en el editor SQL de Supabase
6. Haz clic en **"RUN"** (botón arriba a la derecha)
7. Espera a que termine (verás un mensaje verde ✅)

**Si ves errores:**
- ✅ Si dice `function already exists` = Normal, ignora
- ❌ Si dice `permission denied` = Verifica que estés en cuenta admin de Supabase

### Paso 1.4: Verifica que las tablas se crearon

1. Ve a **Table Editor** (barra izquierda)
2. Deberías ver estas tablas:
   - `profiles` (perfiles de usuarios)
   - `admin_users` (tabla de administradores)
   - `articles` (artículos publicados)
   - `article_notifications` (notificaciones de artículos)

Si ves error de acceso, ve a **Authentication > Providers** y asegúrate de que **Email** esté habilitado ✅

---

## FASE 2: Configuración del sitio

### Paso 2.1: Completa `auth-config.js`

1. Abre el archivo `auth-config.js` en VS Code
2. Reemplaza los valores vacíos con los que copiaste en Paso 1.2:

```javascript
window.AUTH_CONFIG = {
  provider: 'supabase',
  supabaseUrl: 'https://TU_PROJECT_URL.supabase.co',  // ⬅️ Reemplaza aquí
  supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',  // ⬅️ Reemplaza aquí
  confirmEmail: true,  // Los usuarios deben confirmar email al registrarse
  notificationPollMs: 60000,  // Revisar notificaciones cada 60 segundos
  loginPath: 'cuenta/acceder.html',
  signupPath: 'cuenta/registro.html',
  profilePath: 'cuenta/perfil.html',
  adminPath: 'admin/index.html',
  articlesPath: 'articulos/index.html',
  articlePath: 'articulos/publicacion.html',
  articleNotificationsLabel: 'Avisame cuando SA publique un nuevo articulo',
  resetPasswordRedirectPath: 'cuenta/perfil.html',
};
```

3. **Guarda el archivo** (Ctrl+S)

### Paso 2.2: Completa `site-config.js`

1. Abre el archivo `site-config.js`
2. Completa los campos marcados como **REQUERIDO**:

```javascript
window.SITE_CONFIG = {
  showConfigWarning: false,  // Oculta el banner naranja
  brandMark: 'SA',  // ✅ Tu marca de logo
  ogImage: '',  // OPCIONAL: URL de imagen para redes sociales
  siteName: 'Solución ASNEF',  // Nombre de tu sitio
  siteUrl: 'https://www.tudominio.com',  // ⬅️ CAMBIA: tu dominio real
  publicContactEmail: 'hola@tudominio.com',  // ⬅️ CAMBIA: tu email
  publicContactPhone: '+34 623 12 04 23',  // ⬅️ CAMBIA: tu teléfono
  supportSchedule: 'Lunes a viernes de 9:00 a 20:00',  // ⬅️ CAMBIA: tu horario
  ownerName: 'Tu Nombre o Razón Social',  // ⬅️ CAMBIA
  taxId: 'NIF/CIF',  // ⬅️ CAMBIA: Tu NIF o CIF
  legalAddress: 'Tu Dirección Completa, Código Postal, Ciudad',  // ⬅️ CAMBIA
  privacyEmail: 'privacidad@tudominio.com',  // ⬅️ CAMBIA
  analyticsProvider: 'Google Analytics o Plausible (OPCIONAL)',
  cookieManager: 'Osano o Cookiebot (OPCIONAL)',
  formProcessorName: 'Formspree',
  ads: {
    provider: 'Google AdSense',
    adsenseClient: 'ca-pub-XXXXXXXXXXXXXXXX',  // OPCIONAL
    topBannerSlot: '1111111111',
    inContentSlot: '2222222222',
    bottomSlot: '3333333333',
    adsTxtLine: 'google.com, pub-XXXXXXXXXXXXXXXX, DIRECT, f08c47fec0942fa0',
    note: 'Si sirves anuncios en el EEE, usa una CMP certificada.',
  },
  leads: {
    enabled: true,
    responseWindow: '24 horas laborables máximo',
    destinationLabel: 'Bandeja de revisión',
    disclaimer:
      'El formulario sirve para una orientación inicial y no sustituye asesoramiento profesional.',
  },
  cookieBanner: {
    enabled: true,  // Mostrar banner de cookies
  },
  accounts: {
    enabled: true,  // Habilitar autenticación de usuarios
  },
};
```

3. **Guarda el archivo** (Ctrl+S)

### Paso 2.3: Configura `lead-config.js` (Opcional pero recomendado)

Si quieres recibir los formularios de contacto por email:

1. Ve a [https://formspree.io](https://formspree.io) y cría una cuenta gratuita
2. Crea un nuevo formulario con el nombre `asnef-consultas`
3. Te dará un endpoint tipo: `https://formspree.io/f/mojpalwl`
4. Abre `lead-config.js` y reemplaza el endpoint:

```javascript
window.LEAD_CONFIG = {
  endpoint: 'https://formspree.io/f/TU_ID_AQUI',  // ⬅️ Reemplaza con TU endpoint
  method: 'POST',
  headers: {
    Accept: 'application/json',
  },
};
```

5. **Guarda el archivo** (Ctrl+S)

---

## FASE 3: Crear tu usuario Admin

### Paso 3.1: Registrate en tu sitio (local)

1. Inicia el sitio localmente en un servidor (ver Fase 4)
2. Ve a **Menú > Registrarse** o `cuenta/registro.html`
3. **Usa tu email real** (es importante)
4. Elige una contraseña fuerte (mín. 8 caracteres)
5. Haz clic en **Registrarse**
6. Verás: _"Hemos enviado un email de confirmación"_
7. **Abre tu email** y confirma el enlace

### Paso 3.2: Promociona tu usuario a Admin

Una vez registrado y confirmado:

1. Ve a **Supabase > SQL Editor**
2. Crea una nueva query:

```sql
INSERT INTO public.admin_users (user_id, email)
SELECT id, email FROM public.profiles 
WHERE email = 'TU_EMAIL_REAL@ejemplo.com'
ON CONFLICT DO NOTHING;
```

3. **Reemplaza** `TU_EMAIL_REAL@ejemplo.com` con TU email real
4. Haz clic en **"RUN"**
5. Verás: `1 row inserted` ✅

### Paso 3.3: Verifica que eres Admin

1. **Vuelve a tu navegador** (o recarga la página)
2. **Cierra sesión** y vuelve a iniciar sesión
3. En la **navegación superior**, ahora deberías ver un botón **"Panel Admin"** o similar
4. Haz clic. Deberías ver el dashboard con:
   - Métrica de miembros totales
   - Métrica de artículos
   - Métrica de suscriptores
   - Última actividad de usuarios

**Si no ves el botón Admin:**
- Recarga completamente la página (Ctrl+Shift+R para limpiar caché)
- Abre Consola del navegador (F12) y busca errores rojo
- Verifica que el email en SQL coincida exactamente con el del registro

---

## FASE 4: Probar localmente

### Opción A: Con Python (más simple)

1. Abre Terminal en la carpeta del proyecto
2. Ejecuta:
   ```bash
   python -m http.server 8000
   ```
3. Abre navegador en `http://localhost:8000`

### Opción B: Con Node.js

1. Instala un servidor simple:
   ```bash
   npm install -g http-server
   ```
2. Ejecuta:
   ```bash
   http-server -c-1 -p 8000
   ```
3. Abre navegador en `http://localhost:8000`

### Opción C: Con VS Code Live Server

1. Instala la extensión "Live Server"
2. Click derecho en `index.html` > "Open with Live Server"

### Tests a realizar:

- [ ] **Registro**: ¿Puedo registrarme con email y contraseña?
- [ ] **Email confirmación**: ¿Recibo el email de confirmación?
- [ ] **Login**: ¿Puedo iniciar sesión tras confirmar?
- [ ] **Perfil**: ¿Puedo editar mi perfil con nombre, ciudad, avatar, etc.?
- [ ] **Notificaciones**: ¿Puedo activar/desactivar avisos?
- [ ] **Admin**: Como admin, ¿veo el panel de administración?
- [ ] **Crear artículo**: ¿Puedo crear un nuevo artículo desde el panel admin?
- [ ] **Publicar artículo**: ¿Aparece automáticamente en el blog?
- [ ] **Notificación**: ¿Los usuarios suscritos reciben notificación del nuevo artículo?

**Si algo falla:**
- Abre **F12** (consola del navegador)
- Busca mensajes de error en rojo
- Copia el error y documéntalo

---

## FASE 5: Publicar en producción

### Opción recomendada: **Netlify** (gratuito, fácil, HTTPS incluido)

#### 5.1: Prepara tu repositorio Git

1. Abre Terminal en tu carpeta de proyecto
2. Inicializa Git:
   ```bash
   git init
   git add .
   git commit -m "Initial commit - ASNEF solution"
   ```
3. Crea un repositorio en [GitHub](https://github.com) (gratuito)
4. Sube tu código:
   ```bash
   git remote add origin https://github.com/TU_USUARIO/asnef-solucion.git
   git branch -M main
   git push -u origin main
   ```

#### 5.2: Despliega en Netlify

1. Ve a [https://netlify.com](https://netlify.com) e inicia sesión
2. Click en **"New site from Git"**
3. Selecciona **GitHub**, autoriza y elige tu repositorio `asnef-solucion`
4. **Build settings:**
   - Build command: (dejar vacío, es un sitio estático)
   - Publish directory: `.` (la raíz del proyecto)
5. Click en **"Deploy site"**
6. **Espera 1-2 minutos** a que se despliegue ✅

#### 5.3: Conecta tu dominio

Una vez desplegado:

1. En Netlify, ve a **Domain settings**
2. Click en **"Add domain"**
3. Ingresa tu dominio (ej: `www.tudominio.com`)
4. Sigue las instrucciones de DNS con tu proveedor de dominios
5. **Esperaras 24-48 horas** a que la DNS se propague
6. Netlify genera **HTTPS automáticamente** ✅

### Alternativas: Otra hosting

Si prefieres otro hosting:

| Plataforma | Gratuito | HTTPS | Facilidad |
|:---|:---|:---|:---|
| **Netlify** | ✅ | ✅ | ⭐⭐⭐⭐⭐ |
| **Vercel** | ✅ | ✅ | ⭐⭐⭐⭐⭐ |
| **GitHub Pages** | ✅ | ✅ | ⭐⭐⭐⭐ |
| **Azure Static Web Apps** | ✅ | ✅ | ⭐⭐⭐ |
| **Bluehost/SiteGround** | ❌ | ✅ | ⭐⭐⭐ |

**Importante:** Cualquier plataforma que uses debe tener **HTTPS** habilitado (obligatorio para notificaciones del navegador).

---

## ✨ Lo que tu sitio ahora tiene:

### Para usuarios normales:
- ✅ **Registro seguro** con Supabase
- ✅ **Perfil personalizable** con:
  - Nombre, apellidos, email
  - Teléfono, ciudad, provincia, país
  - Fecha de nacimiento, ocupación
  - Sitio web (URL), avatar personalizado
  - Tema principal de interés
  - Biografía personal
- ✅ **Opciones de notificación**:
  - Notificaciones in-app (dentro del sitio)
  - Notificaciones del navegador (pop-ups)
  - Notificaciones por email (preferencia guardada)
- ✅ **Blog dinámico** que ve nuevos artículos al publicarse
- ✅ **Acceso seguro** a áreas restringidas

### Para ti (Admin):
- ✅ **Panel de administración** con:
  - Dashboard con estadísticas
  - Gestión de todos los artículos (crear, editar, eliminar, publicar)
  - Vista de todos los usuarios registrados
  - Sistema de notificaciones automático
- ✅ **Logo de marca** "SA" en todo el sitio
- ✅ **Control total** del contenido

---

## 🆘 Troubleshooting

### Problema: "No veo el botón de Admin"

**Causas posibles:**
1. Email no coincide exactamente (espacios, mayúsculas)
2. No has recargado la página completamente
3. Caché del navegador

**Solución:**
```bash
# En Supabase SQL:
SELECT * FROM admin_users;  -- Verifica que tu email esté allí

# En navegador:
# Presiona Ctrl+Shift+R (limpia caché)
# Cierra sesión y vuelve a iniciar sesión
```

---

### Problema: "Error de autenticación, no puedo registrarme"

**Causas posibles:**
1. `supabaseUrl` o `supabaseAnonKey` incorrectos en `auth-config.js`
2. Typo en las credenciales (espacios, caracteres faltantes)
3. Supabase Authentication deshabilitado

**Solución:**
```javascript
// En F12 Console (Consola del navegador), copia-pega:
console.log(window.AUTH_CONFIG);

// Verifica que sean strings (texto) no vacío:
// supabaseUrl: "https://abcde.supabase.co"
// supabaseAnonKey: "eyJhbGc..."

// Si ves vacío, tu auth-config.js no se cargó correctamente.
```

---

### Problema: "Las notificaciones no funcionan"

**Causas posibles:**
1. Usuario no tiene `notify_browser: true` en su perfil
2. Navegador bloqueó permisos de notificaciones
3. Sitio no tiene HTTPS (obligatorio)

**Solución:**
1. Abre tu perfil > Avisos
2. Marca las opciones que desees
3. Publica un nuevo artículo como admin
4. Deberías Recibir notificación en 60 segundos máximo

---

### Problema: "¿Cómo publico un nuevo artículo?"

**Proceso:**
1. Inicia sesión como admin
2. Ve a **Panel Admin**
3. Click en **"Crear artículo"** o similar
4. Rellena: Título, Resumen, Categoría, Cuerpo (Markdown)
5. Haz clic en **"Publicar"**
6. **Automáticamente:**
   - Se crea en la BD
   - Aparece en el blog
   - Los usuarios suscritos reciben notificación
   - Se crea un enlace único `/articulos/publicacion.html?slug=tu-titulo`

---

### Problema: "Mi dominio no funciona tras 48 horas"

**Causas:**
1. DNS aún se está propagando (puede tardar 24-72 horas)
2. Registros DNS no configurados correctamente
3. Servidor de nombres no apuntando al hosting

**Solución:**
```bash
# En terminal, verifica DNS:
nslookup www.tudominio.com

# Si ves la IP de Netlify/Vercel, está bien.
# Si ves la IP vieja, espera más tiempo o contacta al registrador de dominios.
```

---

### Problema: "¿Cómo cambio la contraseña?"

**Para usuarios:**
1. Ve a tu Perfil
2. Click en **"Cambiar contraseña"**
3. Supabase te envía un email con enlace
4. Haces click en el enlace y creas nueva contraseña

**Para olvidada:**
1. Ve a **Acceder**
2. Click en **"¿Olvidaste tu contraseña?"**
3. Ingresa tu email
4. Haces click en el enlace del email

---

## 📞 Próximos pasos / Mejoras futuras

Una vez que todo funcione:

1. **Email reales**: Integra un proveedor como SendGrid o Mailgun para enviar notificaciones por email de verdad
2. **Google Analytics**: Configura analytics.google.com para ver estadísticas del sitio
3. **Google Search Console**: Submite tu sitemap.xml para SEO
4. **AdSense**: Si quieres monetizar, aplica a Google AdSense
5. **SSL/TLS**: Ya incluido en Netlify/Vercel automáticamente ✅
6. **Backups**: Supabase hace backups automáticos (plan gratuito: 7 días)
7. **Discord/Telegram**: Integra notificaciones a tus canales personales cuando se registren usuarios

---

## 📝 Checklist Final

Antes de decir que está "listo para producción":

- [ ] Email de confirmación funciona
- [ ] Puedo registrarme, confirmar y iniciar sesión
- [ ] Puedo editar mi perfil completamente
- [ ] Como admin, veo el panel de control
- [ ] Puedo crear un artículo de prueba
- [ ] Al publicarlo, veo notificación inmediata
- [ ] El sitio tiene HTTPS
- [ ] El dominio apunta correctamente
- [ ] Formularios de contacto reciben información correctamente
- [ ] Logo "SA" se ve claro en header y footer
- [ ] Página de error 404 personalizada funciona
- [ ] Cookies y política de privacidad están actualizadas
- [ ] Robots.txt y sitemap.xml están configurados para el dominio correcto

---

## 🎉 ¡Felicidades!

Tu sitio ASNEF está completamente funcional. 

**Próximo paso:** Empieza a crear contenido (artículos) y promueve tu sitio en redes sociales.

¿Necesitas ayuda? Revisa los archivos `.js` para entender cómo funciona la autenticación internamente, o abre un issue en tu repositorio.
