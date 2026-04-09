# 🚀 Guía Completa de Configuración para Producción

**Última actualización:** 26 Marzo 2026  
**Estado:** Listo para configuración completa

---

## 📋 Resumen Ejecutivo

Esta guía te lleva paso a paso por TODA la configuración necesaria para publicar **Solución ASNEF** como sitio completo, funcional y listo para Google AdSense.

**Tiempo estimado:** 2-3 horas (primera vez)  
**Complejidad:** ⭐⭐⭐ (Media)

### ✅ Lo que está listo:
- ✅ Interfaz rediseñada (sin burbujas decorativas, orden lógico)
- ✅ Formulario integrado con Formspree
- ✅ Banner de cookies funcional
- ✅ Google Analytics 4 integrado
- ✅ Google AdSense preparado
- ✅ Páginas legales completas (Privacidad, Términos, Sobre Nosotros)
- ✅ Sistema de autenticación (opcional, Supabase)

### ⚠️ Lo que NECESITAS hacer:
1. **Reemplazar datos de placeholder** en `site-config.js`
2. **Configurar Google Analytics 4** (obtener ID)
3. **Conectar formulario a Formspree** (ya configurado en `lead-config.js`)
4. **Solicitar AdSense** (cuando esté todo listo)
5. **Crear contenido de blog** (5+ artículos)
6. **Publicar en hosting** (Vercel, Netlify, etc.)

---

## 📝 PASO 1: Actualizar `site-config.js`

### 1.1 Abre el archivo:
```
site-config.js
```

### 1.2 Reemplaza TODOS estos datos (líneas 1-30):

**ANTES:**
```javascript
window.SITE_CONFIG = {
  showConfigWarning: false,
  brandMark: 'SA',
  siteName: 'Solución ASNEF',
  siteUrl: 'https://www.tudominio.com',
  publicContactEmail: 'hola@tudominio.com',
  publicContactPhone: '+34 600 000 000',
  ownerName: 'Nombre o razón social',
  taxId: 'NIF/CIF',
  legalAddress: 'Dirección completa',
```

**DESPUÉS (ejemplo real):**
```javascript
window.SITE_CONFIG = {
  showConfigWarning: false,
  brandMark: 'SA',
  siteName: 'Solución ASNEF',
  siteUrl: 'https://www.solucionasnef.com',     // TU DOMINIO REAL
  publicContactEmail: 'hola@solucionasnef.com', // TU EMAIL
  publicContactPhone: '+34 612 345 678',         // TU TELÉFONO
  ownerName: 'Ancor Hernández',                  // TU NOMBRE
  taxId: '12345678X',                            // TU NIF
  legalAddress: 'C. Los Perales 3, 35018 Las Palmas de Gran Canaria',
```

### 1.3 Datos CRÍTICOS a actualizar:

| Campo | Placeholder | Tu valor |
|-------|---|---|
| `siteName` | "Solución ASNEF" | El nombre de tu empresa |
| `siteUrl` | `https://www.tudominio.com` | **Tu dominio real** (ej: `https://www.misitiodeapoyo.com`) |
| `publicContactEmail` | `hola@tudominio.com` | Tu correo de contacto |
| `publicContactPhone` | `+34 600 000 000` | Tu teléfono |
| `ownerName` | "Nombre o razón social" | Tu nombre o razón social |
| `taxId` | "NIF/CIF" | Tu NIF o CIF |
| `legalAddress` | "Dirección completa" | Tu dirección legal |
| `privacyEmail` | `privacidad@tudominio.com` | Correo de privacidad |

---

## 🔍 PASO 2: Configurar Google Analytics 4

### 2.1 Crear propiedad de GA4:
1. Ve a [Google Analytics](https://analytics.google.com/)
2. Haz clic en "Crear propiedad"
3. Nombre: "Solución ASNEF"
4. Zona horaria: España
5. Moneda: EUR

### 2.2 Obtener Measurement ID:
1. En la propiedad nueva, ve a **Configuración** → **Fuentes de datos** → **Eventos**
2. Busca el **ID de medición** (empieza con `G-`)
3. Cópialo (ejemplo: `G-ABC123XYZ`)

### 2.3 Actualizar `site-config.js`:
Localiza esta sección (línea ~20):

```javascript
analytics: {
  enabled: true,
  provider: 'Google Analytics 4',
  measurementId: 'G-XXXXXXXXXX',     // ← REEMPLAZA ESTO
  trackingId: 'GTM-XXXXXXX',         // Opcional (Google Tag Manager)
},
```

**DESPUÉS:**
```javascript
analytics: {
  enabled: true,
  provider: 'Google Analytics 4',
  measurementId: 'G-ABC123XYZ',      // Tu ID real
  trackingId: '',                     // Deja vacío si no usas GTM
},
```

### 2.4 Verificar en Google Search Console:
1. Ve a [Google Search Console](https://search.google.com/search-console/)
2. Agrega tu dominio
3. Google Analytics debería registrar datos automáticamente

---

## 📧 PASO 3: Configurar Formspree (Formulario)

### 3.1 Tu formulario ya está conectado
El archivo `lead-config.js` ya tiene el endpoint configurado:

```javascript
window.LEAD_CONFIG = {
  endpoint: 'https://formspree.io/f/mojpalwl',
  method: 'POST',
  headers: {
    Accept: 'application/json',
  },
};
```

### 3.2 Verificar que funciona:
1. Ve a [Formspree](https://formspree.io/)
2. Inicia sesión con tu correo
3. Busca el proyecto "mojpalwl"
4. Deberías ver los envíos del formulario llegar aquí

### 3.3 (Opcional) Conectar a Zapier, Make.com o tu CRM:
Si quieres automatizar respuestas:

1. En Formspree, página de integración
2. Selecciona tu herramienta (Zapier, Make, Slack, etc.)
3. Copia el webhook URL
4. En `lead-config.js`, reemplaza el endpoint

---

## 💰 PASO 4: Preparar Google AdSense

### 4.1 Asegúrate de que tienes:
✅ Página de Privacidad (completa) → LISTA  
✅ Página de Términos y Condiciones → LISTA  
✅ Página "Sobre Nosotros" → LISTA  
✅ Google Analytics configurado → HACER EN PASO 2  
✅ Contenido de blog (5+ artículos) → PENDIENTE DE CREAR  
✅ Sitio publicado en hosting → PENDIENTE  

### 4.2 Actualizar IDs de AdSense:
Una vez que AdSense te apruebe, reemplaza en `site-config.js`:

```javascript
ads: {
  provider: 'Google AdSense',
  adsenseClient: 'ca-pub-XXXXXXXXXXXXXXXX',     // ← REEMPLAZA
  topBannerSlot: '1111111111',                   // ← REEMPLAZA
  inContentSlot: '2222222222',                   // ← REEMPLAZA
  bottomSlot: '3333333333',                      // ← REEMPLAZA
  adsTxtLine: 'google.com, pub-XXXXXXXXXXXXXXXX, DIRECT, f08c47fec0942fa0',
},
```

### 4.3 Solicitar AdSense:
1. Ve a [Google AdSense](https://www.google.com/adsense/)
2. Haz clic en "Empezar"
3. Conecta tu dominio real
4. Google revisará tu sitio (~1-3 semanas)
5. Una vez aprobado, usa los IDs reales en `site-config.js`

---

## 📱 PASO 5: Publicar el Sitio

### 5.1 Opciones de hosting recomendadas:

**Opción A: Vercel (recomendado para proyectos estáticos)**
```bash
# Instalar Vercel CLI
npm install -g vercel

# Publicar
vercel
```

**Opción B: Netlify**
1. Ve a [Netlify](https://www.netlify.com/)
2. Conecta tu repositorio Git
3. Config: `Build command: none` (es HTML estático)
4. Deploy

**Opción C: GitHub Pages**
```bash
git add .
git commit -m "Configuración lista para producción"
git push origin main
```

### 5.2 Configurar DNS:
1. Compra un dominio (Namecheap, GoDaddy, etc.)
2. Apunta el DNS a tu hosting
3. Espera 24-48 horas para propagación
4. Verifica con `ping tudominio.com`

---

## ✍️ PASO 6: Crear Contenido de Blog

Necesitas crear **mínimo 5 artículos de blog** para que Google AdSense te apruebe.

### 6.1 Estructura de artículos (1200-2500 palabras cada uno):

1. **"Cómo salir de ASNEF: Guía paso a paso 2026"**
   - Ubicación: `articulos/como-salir-asnef.html`
   - Keywords: `salir de ASNEF, ASNEF requisitos, prescripción ASNEF`
   
2. **"ASNEF vs. RAI: Diferencias y similitudes"**
   - Ubicación: `articulos/asnef-vs-rai.html`
   - Keywords: `ASNEF RAI diferencia, ficheros de solvencia, listas de morosos`

3. **"Prescripción de deudas: Cuándo prescriben en España"**
   - Ubicación: `articulos/prescripcion-deudas.html`
   - Keywords: `prescripción deudas, plazo prescripción, cuándo prescriben`

4. **"Embargo de bienes: Qué se puede embargar y qué no"**
   - Ubicación: `articulos/embargo-bienes.html`
   - Keywords: `embargo bienes, qué se puede embargar, derechos embargo`

5. **"Negociar deuda: Estrategias y planes de pago"**
   - Ubicación: `articulos/negociar-deuda.html`
   - Keywords: `negociar deuda, plan de pagos, renegociar prestamo`

### 6.2 Traducción de artículos guía:
Copia esto a `articulos/como-salir-asnef.html` como base:

```html
<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Cómo salir de ASNEF: Guía paso a paso 2026 | Solución ASNEF</title>
    <meta name="description" content="Guía completa con pasos reales para salir de ASNEF en 2026. Requisitos, plazos y qué hacer primero." />
    <link rel="stylesheet" href="../styles.css" />
  </head>
  <body class="theme-asnef page-article">
    <!-- Copia header de pages/asnef.html -->
    <!-- ... resto del contenido ... -->
  </body>
</html>
```

**Consejo:** Requiere contenido de 1200-2500 palabras. Si necesitas ayuda, cuéntame y te ayudo a crear plantillas siguiendo SEO.

---

## 🔒 PASO 7: Verificación de Seguridad

### 7.1 SSL/HTTPS:
- ✅ Vercel/Netlify lo hacen automático
- Si usas otro hosting: solicita certificado SSL gratis en [Let's Encrypt](https://letsencrypt.org/)

### 7.2 Headers de seguridad:
En `vercel.json` (crea si no existe):

```json
{
  "headers": [
    {
      "source": "/:path*",
      "headers": [
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        },
        {
          "key": "X-Frame-Options",
          "value": "SAMEORIGIN"
        },
        {
          "key": "X-XSS-Protection",
          "value": "1; mode=block"
        }
      ]
    }
  ]
}
```

### 7.3 Privacy y cookies:
- ✅ Banner de cookies: funcional
- ✅ Política de privacidad (actualizada con Google Analytics + AdSense)
- ✅ Términos y Condiciones: completos

---

## 🧪 PASO 8: Pruebas Finales

### 8.1 Checklist antes de publicar:

- [ ] Todos los datos de `site-config.js` están actualizados (no hay placeholders)
- [ ] Google Analytics está inyectado correctamente (revisa Console del navegador)
- [ ] Formulario envía datos a Formspree (manda mensaje de prueba)
- [ ] Banner de cookies aparece al entrar
- [ ] Política de Privacidad menciona AdSense
- [ ] Términos y Condiciones completados
- [ ] Página "Sobre Nosotros" tiene información personal
- [ ] 5+ artículos de blog creados
- [ ] Sitio responde bien en móvil (F12 → Responsive)
- [ ] Links internos funcionan sin errores 404
- [ ] Meta tags de SEO están completos (title, description)

### 8.2 Validación en la consola:
Abre la consola (F12) y comprueba:

```javascript
// Debería mostrar config correcta
console.log(window.SITE_CONFIG.siteUrl)

// Debería mostrar "GA4" o los datos de Analytics
console.log(window.SITE_CONFIG.analytics)

// Debería mostrar tu email
console.log(window.SITE_CONFIG.publicContactEmail)
```

---

## 📊 PASO 9: Monitorear y Optimizar

### 9.1 Primeras 2 semanas (después de publicar):

**Google Analytics:**
- Ve a Analytics.google.com
- Debería mostrar tráfico en tiempo real
- Objetivo: 5-10 visitas/día mínimo

**Google Search Console:**
- Vigila que no haya errores de indexación
- Envia Sitemap: `/sitemap.xml` (ya existe)
- Monitorea palabras clave encontradas

**Google AdSense (después de aprobación):**
- Primera semana: sin ingresos (tarda en recopilar datos)
- Después: debería generar $1-5/día mínimo

### 9.2 Mejoras posteriores:

1. **Blog:** Publicar 1 artículo/semana
2. **SEO:** Mejorar títulos y meta descriptions
3. **Velocidad:** Hacer test en [PageSpeed](https://pagespeed.web.dev/)
4. **Links:** Conseguir backlinks de sitios relacionados
5. **Contenido:** Escuchar feedback y actualizar guías

---

## 🐛 Solución de Problemas Comunes

### ❌ "Mi sitio no aparece en Google"
- [ ] Esperar 1-2 semanas (nuevo sitio)
- [ ] Ir a Google Search Console → Solicitar indexación
- [ ] Verificar que `robots.txt` y `sitemap.xml` son accesibles

### ❌ "Los formularios no envían"
```javascript
// Verifica en Console que lead-config.js cargó:
console.log(window.LEAD_CONFIG.endpoint)
// Si está vacío, ve a lead-config.js y rellena el endpoint
```

### ❌ "Google Analytics no registra nada"
```javascript
// Abre Console (F12) y comprueba:
console.log(window.dataLayer) // Debería tener eventos
console.log(window.gtag)       // Función debe existir
```

### ❌ "AdSense rechaza mi sitio"
Motivos más comunes:
- No tiene 3+ meses de antigüedad
- Poco contenido (menos de 5 artículos)
- Faltas de ortografía o contenido de baja calidad
- **Solución:** Mejora contenido y vuelve a solicitar en 1 mes

---

## 📞 Soporte

Si algo no funciona:

1. **Revisa:** La sección "Solución de Problemas"
2. **Busca:** En la documentación (`GUIA-CONFIGURACION-COMPLETA.md`)
3. **Contacta:** Formulario de contacto del sitio (`pages/contacto.html`)

---

## ✅ RESUMEN: Lo que acabas de hacer

| Tarea | Estado |
|-------|--------|
| Actualizar `site-config.js` | ← AQUÍ |
| Configurar Google Analytics 4 | ← AQUÍ |
| Conectar Formspree | ✅ Ya está |
| Crear páginas legales | ✅ Ya está |
| Rediseño de interfaz (sin burbujas) | ✅ Ya está |
| Crear contenido de blog | ← PENDIENTE |
| Publicar en hosting | ← PENDIENTE |
| Solicitar Google AdSense | ← PENDIENTE |

---

**🎉 Siguiente paso:** Crea contenido de blog y publica el sitio. El resto debería funcionar automáticamente.

**Tiempo total estimado:** 3-4 semanas hasta primeros ingresos por AdSense.
