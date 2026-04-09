// ========================================
// EJEMPLO DE CONFIGURACIÓN COMPLETA
// Copia los valores que correspondan a tu sitio
// Reemplaza TU_... con tus datos reales
// ========================================

// ARCHIVO: auth-config.js
// Obtener valores de: https://app.supabase.com > Settings > API

window.AUTH_CONFIG = {
  provider: 'supabase',
  
  // ❌ REQUERIDO: Ve a Supabase > Settings > API > Project URL
  supabaseUrl: 'https://abcdefghijklmnopqrst.supabase.co',
  
  // ❌ REQUERIDO: Ve a Supabase > Settings > API > anon (public) key
  supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoaWprbG1ub3BxcnN0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2NjU1MDAwMDAsImV4cCI6MTk0NzA4MDAwMH0.dummyideal_signature_here',
  
  // Email de confirmación (recomendado: true para seguridad)
  confirmEmail: true,
  
  // Cada 60 segundos revisa notificaciones nuevas
  notificationPollMs: 60000,
  
  // Rutas del sitio (no cambiar)
  loginPath: 'cuenta/acceder.html',
  signupPath: 'cuenta/registro.html',
  profilePath: 'cuenta/perfil.html',
  adminPath: 'admin/index.html',
  articlesPath: 'articulos/index.html',
  articlePath: 'articulos/publicacion.html',
  articleNotificationsLabel: 'Avisame cuando SA publique un nuevo articulo',
  resetPasswordRedirectPath: 'cuenta/perfil.html',
};


// ========================================
// ARCHIVO: site-config.js
// Tus datos del negocio
// ========================================

window.SITE_CONFIG = {
  // Mostrar banner naranja con advertencias (false = no mostrar)
  showConfigWarning: false,
  
  // Tu marca/logo corto
  brandMark: 'SA',
  
  // Imagen para redes sociales (OPCIONAL)
  ogImage: 'https://tudominio.com/og-image.jpg',
  
  // Nombre de tu sitio web
  siteName: 'Solución ASNEF',
  
  // ❌ REQUERIDO: Tu dominio real (con https://)
  siteUrl: 'https://www.tudominio.com',
  
  // ❌ REQUERIDO: Email de contacto visible en el sitio
  publicContactEmail: 'contacto@tudominio.com',
  
  // ❌ REQUERIDO: Teléfono visible
  publicContactPhone: '+34 623 120 423',
  
  // Horario de atención
  supportSchedule: 'Lunes a viernes de 9:00 a 20:00',
  
  // ❌ REQUERIDO: Tu nombre o razón social
  ownerName: 'Ancor Hernández Casañas',
  
  // ❌ REQUERIDO: Tu NIF o CIF (para página legal)
  taxId: '12345678A',
  
  // ❌ REQUERIDO: Tu dirección legal (para página legal)
  legalAddress: 'Calle Principal 123, 28001 Madrid, España',
  
  // Email para políticas de privacidad
  privacyEmail: 'privacidad@tudominio.com',
  
  // Nombre de tu herramienta de analytics (informativo)
  analyticsProvider: 'Google Analytics 4',
  
  // Nombre de tu gestor de cookies (informativo)
  cookieManager: 'Banner integrado (Osano recomendado)',
  
  // Nombre del procesador de formularios
  formProcessorName: 'Formspree',
  
  // ANUNCIOS (deja vacío si no usas AdSense)
  ads: {
    provider: 'Google AdSense',
    adsenseClient: 'ca-pub-XXXXXXXXXXXXXXXX',  // Tu ID de editor
    topBannerSlot: '1111111111',                // IDs de slots de ads
    inContentSlot: '2222222222',
    bottomSlot: '3333333333',
    adsTxtLine: 'google.com, pub-XXXXXXXXXXXXXXXX, DIRECT, f08c47fec0942fa0',
    note: 'Si sirves anuncios personalizados en el EEE, usa una CMP certificada por Google.',
  },
  
  // FORMULARIOS DE CONTACTO / LEADS
  leads: {
    enabled: true,  // Mostrar formulario de consulta
    responseWindow: '24 horas laborables máximo',
    destinationLabel: 'Bandeja de revisión / CRM',
    disclaimer: 'El formulario sirve para una orientación inicial y no sustituye asesoramiento profesional.',
  },
  
  // BANNER DE COOKIES (recomendado dejar habilitado)
  cookieBanner: {
    enabled: true,
  },
  
  // SISTEMA DE CUENTAS Y ADMIN (recomendado dejar habilitado)
  accounts: {
    enabled: true,
  },
};


// ========================================
// ARCHIVO: lead-config.js
// Dónde recibir formularios de contacto
// ========================================

window.LEAD_CONFIG = {
  // ❌ REQUERIDO SI QUIERES FORMULARIOS:
  // 1. Ve a https://formspree.io
  // 2. Crea un formulario nuevo (es gratis)
  // 3. Te dará un endpoint tipo: https://formspree.io/f/mojpalwl
  // 4. Pegalo aquí:
  endpoint: 'https://formspree.io/f/TU_ID_AQUI',
  
  method: 'POST',
  headers: {
    Accept: 'application/json',
  },
  
  // Si tu API requiere JSON en lugar de FormData, descomenta:
  // useJsonBody: true,
};


// ========================================
// ARCHIVO: admin/admin-config.js
// Protección del panel admin antiguo (OPCIONAL)
// Solo necesario si quieres panel admin con contraseña
// ========================================

window.ASNEF_ADMIN = {
  // Hash SHA256 de tu contraseña admin
  // Para generar en PowerShell:
  // [BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes('MiContraseña123'))).Replace('-','').ToLower()
  
  // Ejemplo con contraseña: AdminSitio2025!
  passwordSha256: 'ab88828a21d897fb743a953d5a9eea12c7bf5619f2b365e01b25896ef42fb8d4',
  
  sessionKey: 'asnef_admin_session_v1',
  sessionMaxMs: 1000 * 60 * 60 * 8,  // 8 horas de sesión
};


// ========================================
// ESTRUCTURA DE BASE DE DATOS (Supabase)
// Esto se crea automáticamente al ejecutar supabase-schema.sql
// TABLA: profiles (perfiles de usuarios)
// ========================================
/*
Campos:
- id (UUID, PK, referencias auth.users)
- email (TEXT, unique)
- display_name (TEXT) - Nombre de usuario que ven otros
- first_name (TEXT) - Nombre
- last_name (TEXT) - Apellido
- phone (TEXT) - Teléfono
- city (TEXT) - Ciudad
- province (TEXT) - Provincia
- country (TEXT) - País
- birth_date (DATE) - Fecha de nacimiento
- occupation (TEXT) - Ocupación/Profesión
- website_url (TEXT) - Tu sitio web
- avatar_url (TEXT) - URL de tu avatar/foto
- main_topic (TEXT) - Tema de interés principal
- bio (TEXT) - Biografía personal
- notify_new_articles (BOOLEAN) - ¿Notificaciones in-app?
- notify_browser (BOOLEAN) - ¿Notificaciones del navegador?
- notify_email (BOOLEAN) - ¿Notificaciones por email?
- created_at (TIMESTAMPTZ) - Fecha de registro
- updated_at (TIMESTAMPTZ) - Última actualización
*/


// ========================================
// TABLA: admin_users (administradores)
// ========================================
/*
Campos:
- user_id (UUID, PK, referencias auth.users)
- email (TEXT, unique)
- created_at (TIMESTAMPTZ)

Para convertir a un usuario en admin, ejecuta en SQL de Supabase:
INSERT INTO public.admin_users (user_id, email)
SELECT id, email FROM public.profiles 
WHERE email = 'tu_email@ejemplo.com';
*/


// ========================================
// TABLA: articles (artículos del blog)
// ========================================
/*
Campos:
- id (UUID, PK)
- author_id (UUID, FK a profiles)
- slug (TEXT, unique) - "mi-primer-articulo"
- title (TEXT) - "Mi Primer Artículo"
- excerpt (TEXT) - Resumen corto
- category (TEXT) - "Categoría"
- read_time (TEXT) - "5 min"
- hero_note (TEXT) - Nota en hero
- body_markdown (TEXT) - Contenido en Markdown
- is_featured (BOOLEAN) - ¿Destacado?
- status (TEXT) - 'draft' o 'published'
- published_at (TIMESTAMPTZ) - Fecha publicación
- created_at, updated_at (TIMESTAMPTZ)

Al publicar, trigger automático notifica a todos los suscriptores.
*/


// ========================================
// TABLA: article_notifications (notificaciones)
// ========================================
/*
Campos:
- id (UUID, PK)
- user_id (UUID, FK a profiles)
- article_id (UUID, FK a articles)
- is_read (BOOLEAN) - ¿Leída?
- channel (TEXT) - Tipo: 'in_app', 'browser', 'email'
- created_at (TIMESTAMPTZ)

Constraint: UNIQUE(user_id, article_id) - Un usuario, un artículo, una notificación
*/


// ========================================
// FUNCIONES SQL PRINCIPALES
// ========================================

/*
1. is_admin() - Verifica si usuario actual es admin
   SELECT public.is_admin();  -- retorna true/false

2. handle_new_user() - Trigger que crea perfil al registrarse
   Se ejecuta automáticamente en auth.users INSERT

3. notify_new_article() - Trigger que notifica al publicar
   Se ejecuta automáticamente en articles UPDATE cuando status='published'

4. touch_updated_at() - Actualiza updated_at automáticamente
   Se ejecuta en cualquier UPDATE
*/


// ========================================
// POLÍTICAS RLS (Row Level Security)
// ========================================

/*
Que significa:
- Los usuarios SOLO ven su propio perfil
- Los admins ven TODOS los perfiles
- Los artículos PUBLICADOS los ven todos
- Las notificaciones cada usuario ve sus propias notificaciones
- Esto garantiza seguridad y privacidad
*/
