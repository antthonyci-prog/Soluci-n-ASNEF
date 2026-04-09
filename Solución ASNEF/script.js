const navToggle = document.querySelector('.nav-toggle');
const siteNav = document.querySelector('.site-nav');
const yearTargets = document.querySelectorAll('[data-current-year]');
const leadForms = document.querySelectorAll('[data-lead-form]');
const runtimeBaseUrl = (() => {
  const currentScript = document.currentScript;
  if (currentScript && currentScript.src) {
    return new URL('./', currentScript.src).href;
  }
  return new URL('./', window.location.href).href;
})();

document.documentElement.classList.add('js-enhanced');

const defaultSiteConfig = {
  brandMark: 'SA',
  siteName: 'Solución ASNEF',
  siteUrl: 'https://www.solucionasnef.com',
  ogImage: 'https://www.solucionasnef.com/logo-icono.png',
  publicContactEmail: 'hola@solucionasnef.com',
  publicContactPhone: '+34 623 12 04 23',
  supportSchedule: 'Lunes a viernes de 9:00 a 19:00',
  ownerName: 'Ancor Hernández Casañas',
  taxId: '12345678X',
  legalAddress: 'C. los Perales, 3, 35018 Las Palmas de Gran Canaria, Las Palmas',
  privacyEmail: 'privacidad@solucionasnef.com',
  analyticsProvider: 'Google Analytics 4',
  cookieManager: 'Consentimiento propio con rechazo y aceptación; activa además la CMP certificada de Google si sirves anuncios personalizados en EEE',
  formProcessorName: 'Formspree',
  formDestinationLabel: 'Bandeja privada de consultas',
  leads: {
    enabled: true,
    responseWindow: '24 horas laborables',
    destinationLabel: 'Bandeja privada de revisión',
    disclaimer:
      'La orientación inicial es informativa y no sustituye asesoramiento jurídico o financiero individualizado.',
  },
  analytics: {
    enabled: false,
    measurementId: '',
  },
  ads: {
    enabled: false,
    provider: 'Google AdSense',
    adsenseClient: '',
    topBannerSlot: '',
    inContentSlot: '',
    bottomSlot: '',
  },
  cookieBanner: {
    enabled: true,
  },
  accounts: {
    enabled: true,
  },
};

const siteConfig = {
  ...defaultSiteConfig,
  ...(window.SITE_CONFIG || {}),
  analytics: {
    ...defaultSiteConfig.analytics,
    ...((window.SITE_CONFIG && window.SITE_CONFIG.analytics) || {}),
  },
  ads: {
    ...defaultSiteConfig.ads,
    ...((window.SITE_CONFIG && window.SITE_CONFIG.ads) || {}),
  },
  leads: {
    ...defaultSiteConfig.leads,
    ...((window.SITE_CONFIG && window.SITE_CONFIG.leads) || {}),
  },
  cookieBanner: {
    ...defaultSiteConfig.cookieBanner,
    ...((window.SITE_CONFIG && window.SITE_CONFIG.cookieBanner) || {}),
  },
  accounts: {
    ...defaultSiteConfig.accounts,
    ...((window.SITE_CONFIG && window.SITE_CONFIG.accounts) || {}),
  },
};

const leadConfig = window.LEAD_CONFIG || {
  endpoint: '',
  method: 'POST',
  headers: {
    Accept: 'application/json',
  },
};

const bindConfigValue = (selector, value, transform) => {
  document.querySelectorAll(selector).forEach((node) => {
    const nextValue = typeof transform === 'function' ? transform(value, node) : value;
    if (nextValue !== undefined && nextValue !== null && String(nextValue).trim()) {
      node.textContent = nextValue;
    }
  });
};

const bindConfigHref = (selector, value, prefix = '') => {
  document.querySelectorAll(selector).forEach((node) => {
    if (!value) return;
    node.setAttribute('href', `${prefix}${value}`);
    if (!node.textContent.trim()) {
      node.textContent = value;
    }
  });
};

const getHostFromUrl = (url) => {
  try {
    return new URL(url).host;
  } catch {
    return String(url || '').replace(/^https?:\/\//, '').replace(/\/+$/, '');
  }
};

const renderConfigValues = () => {
  bindConfigValue('[data-site-name]', siteConfig.siteName);
  bindConfigValue('[data-site-url]', siteConfig.siteUrl);
  bindConfigValue('[data-site-host]', getHostFromUrl(siteConfig.siteUrl));
  bindConfigValue('[data-public-email]', siteConfig.publicContactEmail);
  bindConfigValue('[data-public-phone]', siteConfig.publicContactPhone);
  bindConfigValue('[data-support-schedule]', siteConfig.supportSchedule);
  bindConfigValue('[data-owner-name]', siteConfig.ownerName);
  bindConfigValue('[data-tax-id]', siteConfig.taxId);
  bindConfigValue('[data-legal-address]', siteConfig.legalAddress);
  bindConfigValue('[data-privacy-email]', siteConfig.privacyEmail);
  bindConfigValue('[data-form-processor]', siteConfig.formProcessorName);
  bindConfigValue('[data-response-window]', siteConfig.leads.responseWindow);
  bindConfigValue('[data-lead-destination]', siteConfig.leads.destinationLabel);
  bindConfigValue('[data-lead-disclaimer]', siteConfig.leads.disclaimer);
  bindConfigValue('[data-ads-provider]', siteConfig.ads.provider);
  bindConfigHref('[data-site-url-link]', siteConfig.siteUrl);
  bindConfigHref('[data-public-email-link]', siteConfig.publicContactEmail, 'mailto:');
  bindConfigHref('[data-privacy-email-link]', siteConfig.privacyEmail, 'mailto:');
  bindConfigHref('[data-public-phone-link]', siteConfig.publicContactPhone, 'tel:');
};

const injectSeoTags = () => {
  if (!siteConfig.siteUrl) return;

  try {
    const canonicalHref = new URL(window.location.pathname, `${siteConfig.siteUrl.replace(/\/+$/, '')}/`).href;
    let canonical = document.querySelector('link[rel="canonical"]');
    if (!canonical) {
      canonical = document.createElement('link');
      canonical.rel = 'canonical';
      document.head.appendChild(canonical);
    }
    canonical.href = canonicalHref;

    const ogUrl = document.querySelector('meta[property="og:url"]') || document.createElement('meta');
    ogUrl.setAttribute('property', 'og:url');
    ogUrl.setAttribute('content', canonicalHref);
    if (!ogUrl.parentNode) document.head.appendChild(ogUrl);

    const ogSite = document.querySelector('meta[property="og:site_name"]') || document.createElement('meta');
    ogSite.setAttribute('property', 'og:site_name');
    ogSite.setAttribute('content', siteConfig.siteName);
    if (!ogSite.parentNode) document.head.appendChild(ogSite);

    if (siteConfig.ogImage) {
      const ogImage = document.querySelector('meta[property="og:image"]') || document.createElement('meta');
      ogImage.setAttribute('property', 'og:image');
      ogImage.setAttribute('content', siteConfig.ogImage);
      if (!ogImage.parentNode) document.head.appendChild(ogImage);
    }
  } catch (error) {
    console.error(error);
  }
};

const decorateBrandMarks = () => {
  document.querySelectorAll('.brand').forEach((node) => {
    if (node.querySelector('.brand-mark')) return;
    const markWrap = document.createElement('span');
    markWrap.className = 'brand-mark';
    const mark = document.createElement('img');
    mark.alt = `${siteConfig.siteName} logo`;
    mark.src = new URL('logo-icono.png', runtimeBaseUrl).href;
    mark.loading = 'eager';
    markWrap.appendChild(mark);
    node.prepend(markWrap);
  });
};

const revealTargets = document.querySelectorAll(
  '.section-heading, .info-card, .article-card, .summary-guide-card, .metric-card, .trust-card, .legal-card, .ad-slot, .contact-card, .lead-form, .faq-list details, .quote-card, .timeline-card'
);

const mountRevealAnimations = () => {
  if (!revealTargets.length || !('IntersectionObserver' in window)) return;

  const observer = new IntersectionObserver(
    (entries, currentObserver) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        entry.target.classList.add('is-visible');
        currentObserver.unobserve(entry.target);
      });
    },
    {
      threshold: 0.14,
      rootMargin: '0px 0px -60px 0px',
    }
  );

  revealTargets.forEach((target) => {
    target.classList.add('reveal-up');
    observer.observe(target);
  });
};

const setBodyReady = () => {
  if (!document.body) return;
  window.requestAnimationFrame(() => {
    document.body.classList.add('page-ready');
  });
};

const injectGA4 = () => {
  const measurementId = String(siteConfig.analytics.measurementId || '').trim();
  if (!siteConfig.analytics.enabled || !measurementId) return;
  if (document.querySelector('script[data-site-ga4]')) return;

  window.dataLayer = window.dataLayer || [];
  window.gtag = function gtag() {
    window.dataLayer.push(arguments);
  };
  window.gtag('js', new Date());
  window.gtag('config', measurementId, {
    anonymize_ip: true,
    page_path: window.location.pathname,
    page_title: document.title,
  });

  const script = document.createElement('script');
  script.async = true;
  script.src = `https://www.googletagmanager.com/gtag/js?id=${encodeURIComponent(measurementId)}`;
  script.setAttribute('data-site-ga4', '1');
  document.head.appendChild(script);
};

const adsenseConfigured = () =>
  siteConfig.ads.enabled && String(siteConfig.ads.adsenseClient || '').trim() && !String(siteConfig.ads.adsenseClient).includes('XXXX');

let adsenseLoadPromise = null;

const injectAdsense = () => {
  if (!adsenseConfigured()) return Promise.resolve(false);
  if (adsenseLoadPromise) return adsenseLoadPromise;

  const existingScript = document.querySelector('script[data-site-adsense]');
  if (existingScript && existingScript.dataset.loaded === '1') {
    return Promise.resolve(true);
  }

  adsenseLoadPromise = new Promise((resolve, reject) => {
    const handleLoad = () => {
      const currentScript = document.querySelector('script[data-site-adsense]');
      if (currentScript) currentScript.dataset.loaded = '1';
      resolve(true);
    };

    const handleError = () => {
      adsenseLoadPromise = null;
      reject(new Error('No se ha podido cargar Google AdSense.'));
    };

    if (existingScript) {
      existingScript.addEventListener('load', handleLoad, { once: true });
      existingScript.addEventListener('error', handleError, { once: true });
      return;
    }

    const script = document.createElement('script');
    script.async = true;
    script.src = `https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=${encodeURIComponent(siteConfig.ads.adsenseClient)}`;
    script.crossOrigin = 'anonymous';
    script.setAttribute('data-site-adsense', '1');
    script.addEventListener('load', handleLoad, { once: true });
    script.addEventListener('error', handleError, { once: true });
    document.head.appendChild(script);
  }).catch((error) => {
    console.error(error);
    return false;
  });

  return adsenseLoadPromise;
};

const CONSENT_STORAGE_KEY = 'solucion_asnef_consent_v2';

const getStoredConsent = () => {
  try {
    const raw = localStorage.getItem(CONSENT_STORAGE_KEY);
    if (!raw) return null;
    const data = JSON.parse(raw);
    if (!data || typeof data !== 'object' || data.v !== 2) return null;
    return data;
  } catch {
    return null;
  }
};

const saveConsent = (analytics, marketing) => {
  const payload = {
    v: 2,
    analytics: !!analytics,
    marketing: !!marketing,
    ts: Date.now(),
  };
  localStorage.setItem(CONSENT_STORAGE_KEY, JSON.stringify(payload));
  return payload;
};

const maybeLoadConsentedScripts = () => {
  const consent = getStoredConsent();
  if (!consent) return;
  if (consent.analytics) injectGA4();
  if (consent.marketing) injectAdsense();
};

const resolveAdSlotId = (slot) => {
  const requestedKey = String(slot.dataset.adSlotKey || '').trim() || 'inContentSlot';
  const candidates = requestedKey === 'topBannerSlot'
    ? [requestedKey, 'inContentSlot', 'bottomSlot']
    : requestedKey === 'bottomSlot'
      ? [requestedKey, 'inContentSlot', 'topBannerSlot']
      : [requestedKey, 'inContentSlot', 'topBannerSlot', 'bottomSlot'];

  const slotId = candidates
    .map((key) => String((siteConfig.ads && siteConfig.ads[key]) || '').trim())
    .find(Boolean);

  return {
    slotId: slotId || '',
    slotKey: requestedKey,
  };
};

const syncStandaloneAdSection = (slot) => {
  const section = slot.closest('section');
  if (!section) return;

  const sectionClone = section.cloneNode(true);
  sectionClone.querySelectorAll('.ad-slot').forEach((node) => node.remove());

  const hasMeaningfulText = String(sectionClone.textContent || '').replace(/\s+/g, '').length > 0;
  const hasMeaningfulElements = !!sectionClone.querySelector(
    'img, iframe, form, .panel, .content-main, .content-sidebar, .section-heading, .cards-grid, .summary-guide-grid, .legal-grid, .steps-grid, .faq-list, .contact-card, .lead-form, .article-card, .info-card, .timeline-card, .metric-card, .trust-card, .callout-box'
  );

  if (hasMeaningfulText || hasMeaningfulElements) return;

  const visibleAdExists = Array.from(section.querySelectorAll('.ad-slot')).some((node) => !node.hidden);
  section.hidden = !visibleAdExists;
};

const setAdSlotVisibility = (slot, isVisible) => {
  slot.hidden = !isVisible;
  syncStandaloneAdSection(slot);
};

const restoreAdPlaceholder = (slot) => {
  slot.classList.remove('ad-slot-live');
  const frame = slot.querySelector('.ad-slot-frame');
  if (frame) frame.remove();
  slot.querySelectorAll('.ad-slot-shell, .ad-slot-copy, .ad-slot-meta').forEach((node) => {
    node.hidden = false;
  });
  delete slot.dataset.adRendered;
};

const renderAdSlots = async () => {
  const slots = Array.from(document.querySelectorAll('.ad-slot'));
  if (!slots.length) return;

  slots.forEach((slot) => {
    setAdSlotVisibility(slot, false);
  });

  const consent = getStoredConsent();
  const marketingAllowed = !!(consent && consent.marketing);
  if (!marketingAllowed || !adsenseConfigured()) {
    slots.forEach((slot) => {
      if (slot.dataset.adRendered === '1') restoreAdPlaceholder(slot);
    });
    return;
  }

  const adsenseReady = await injectAdsense();
  if (!adsenseReady) return;

  slots.forEach((slot) => {
    if (slot.dataset.adRendered === '1') return;

    const { slotId } = resolveAdSlotId(slot);
    if (!slotId) return;

    setAdSlotVisibility(slot, true);

    slot.querySelectorAll('.ad-slot-shell, .ad-slot-copy, .ad-slot-meta').forEach((node) => {
      node.hidden = true;
    });

    const frame = document.createElement('div');
    frame.className = 'ad-slot-frame';

    const ad = document.createElement('ins');
    ad.className = 'adsbygoogle';
    ad.style.display = 'block';
    ad.dataset.adClient = siteConfig.ads.adsenseClient;
    ad.dataset.adSlot = slotId;
    ad.dataset.adFormat = slot.dataset.adFormat || 'auto';
    ad.dataset.fullWidthResponsive = 'true';

    frame.appendChild(ad);
    slot.appendChild(frame);
    slot.classList.add('ad-slot-live');

    try {
      (window.adsbygoogle = window.adsbygoogle || []).push({});
      slot.dataset.adRendered = '1';
    } catch (error) {
      console.error(error);
      restoreAdPlaceholder(slot);
    }
  });
};

const cookiesPolicyPath = () => {
  const path = window.location.pathname.replace(/\\/g, '/');
  if (path.includes('/pages/') || path.includes('/articulos/') || path.includes('/admin/') || path.includes('/cuenta/')) {
    return '../legal/politica-cookies.html';
  }
  if (path.includes('/legal/')) {
    return 'politica-cookies.html';
  }
  return 'legal/politica-cookies.html';
};

const mountCookieBanner = () => {
  if (!siteConfig.cookieBanner.enabled) {
    maybeLoadConsentedScripts();
    return;
  }

  if (document.body && document.body.classList.contains('page-admin')) {
    maybeLoadConsentedScripts();
    return;
  }

  const currentConsent = getStoredConsent();
  if (currentConsent) {
    maybeLoadConsentedScripts();
    return;
  }

  const bar = document.createElement('div');
  bar.className = 'cookie-consent-bar';
  bar.innerHTML = `
    <div class="cookie-consent-inner container">
      <div class="cookie-consent-text">
        <p><strong>Privacidad y cookies.</strong> Usamos cookies técnicas necesarias y, solo si aceptas, cookies analíticas y publicitarias. Aceptar y rechazar están al mismo nivel. Puedes consultar todos los detalles en la política de cookies.</p>
      </div>
      <div class="cookie-consent-actions">
        <button type="button" class="button button-secondary" data-cookie-choice="reject">Rechazar</button>
        <button type="button" class="button button-primary" data-cookie-choice="accept">Aceptar</button>
        <a class="cookie-consent-link" href="${cookiesPolicyPath()}">Política de cookies</a>
      </div>
    </div>
  `;

  bar.querySelector('[data-cookie-choice="reject"]')?.addEventListener('click', () => {
    saveConsent(false, false);
    bar.remove();
  });

  bar.querySelector('[data-cookie-choice="accept"]')?.addEventListener('click', () => {
    saveConsent(true, true);
    injectGA4();
    injectAdsense();
    renderAdSlots();
    bar.remove();
  });

  document.body.appendChild(bar);
};

const setFeedback = (form, message, type = '') => {
  const feedback = form.querySelector('[data-form-feedback]');
  if (!feedback) return;
  feedback.textContent = message;
  feedback.className = `form-feedback ${type}`.trim();
};

const serializeLeadForm = (form) => {
  const formData = new FormData(form);
  return {
    nombre: String(formData.get('nombre') || '').trim(),
    email: String(formData.get('email') || '').trim(),
    telefono: String(formData.get('telefono') || '').trim(),
    interes: String(formData.get('interes') || '').trim(),
    tema: String(formData.get('tema') || '').trim(),
    importe_deuda: String(formData.get('importe_deuda') || '').trim(),
    mensaje: String(formData.get('mensaje') || '').trim(),
    consentimiento: formData.get('consentimiento'),
    website: String(formData.get('website') || '').trim(),
    pagina_origen: window.location.pathname,
    titulo_pagina: document.title,
    enviado_en: new Date().toISOString(),
  };
};

const validateLead = (payload) => {
  if (payload.website) return 'No se ha podido validar el envío.';
  if (!payload.nombre || payload.nombre.length < 3) return 'Indica tu nombre completo.';
  if (!payload.email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(payload.email)) return 'Indica un correo electrónico válido.';
  if (!payload.tema || payload.tema.length < 4) return 'Resume el tema principal de la consulta.';
  if (!payload.mensaje || payload.mensaje.length < 20) return 'Describe tu situación con un poco más de detalle.';
  if (!payload.consentimiento) return 'Debes aceptar la política de privacidad para enviar el formulario.';
  return '';
};

const postLead = async (form, payload) => {
  if (!leadConfig.endpoint) {
    return {
      ok: false,
      mode: 'demo',
      message: 'El formulario local está listo, pero aún no tiene endpoint configurado.',
    };
  }

  const useJson = leadConfig.useJsonBody === true;
  const headers = {
    Accept: 'application/json',
    ...(leadConfig.headers || {}),
  };

  let body;
  if (useJson) {
    headers['Content-Type'] = 'application/json';
    body = JSON.stringify(payload);
  } else {
    delete headers['Content-Type'];
    const formData = new FormData(form);
    formData.set('pagina_origen', payload.pagina_origen);
    formData.set('titulo_pagina', payload.titulo_pagina);
    formData.set('enviado_en', payload.enviado_en);
    body = formData;
  }

  const response = await fetch(leadConfig.endpoint, {
    method: leadConfig.method || 'POST',
    headers,
    body,
  });

  if (!response.ok) {
    throw new Error(`Lead request failed with status ${response.status}`);
  }

  return { ok: true, mode: 'live' };
};

const bindLeadForms = () => {
  leadForms.forEach((form) => {
    form.addEventListener('submit', async (event) => {
      event.preventDefault();
      const payload = serializeLeadForm(form);
      const validationError = validateLead(payload);

      if (validationError) {
        setFeedback(form, validationError, 'error');
        return;
      }

      setFeedback(form, 'Enviando consulta…', 'warning');

      try {
        const result = await postLead(form, payload);
        if (result.mode === 'demo') {
          setFeedback(form, result.message, 'warning');
          return;
        }

        setFeedback(
          form,
          `Consulta enviada correctamente. Revisaremos el caso y responderemos en ${siteConfig.leads.responseWindow}.`,
          'success'
        );
        form.reset();
      } catch (error) {
        console.error(error);
        setFeedback(
          form,
          'No se ha podido enviar el formulario ahora mismo. Revisa el endpoint o vuelve a intentarlo en unos minutos.',
          'error'
        );
      }
    });
  });
};

const bindArticleSearch = () => {
  const input = document.querySelector('[data-article-search]');
  const cards = Array.from(document.querySelectorAll('[data-article-card]'));
  const summary = document.querySelector('[data-search-summary]');
  if (!input || !cards.length) return;

  const applyFilter = () => {
    const query = input.value.trim().toLowerCase();
    let visible = 0;

    cards.forEach((card) => {
      const haystack = String(card.getAttribute('data-search-value') || card.textContent || '').toLowerCase();
      const matches = !query || haystack.includes(query);
      card.hidden = !matches;
      if (matches) visible += 1;
    });

    if (summary) {
      summary.textContent = query
        ? `${visible} resultado${visible === 1 ? '' : 's'} para “${query}”.`
        : `${visible} artículo${visible === 1 ? '' : 's'} disponibles.`;
    }
  };

  input.addEventListener('input', applyFilter);
  applyFilter();
};

const bindNavigation = () => {
  if (!navToggle || !siteNav) return;

  navToggle.addEventListener('click', () => {
    const isOpen = siteNav.classList.toggle('is-open');
    navToggle.setAttribute('aria-expanded', String(isOpen));
  });

  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && siteNav.classList.contains('is-open')) {
      siteNav.classList.remove('is-open');
      navToggle.setAttribute('aria-expanded', 'false');
      navToggle.focus();
    }
  });

  document.addEventListener('click', (event) => {
    if (!siteNav.classList.contains('is-open')) return;
    if (siteNav.contains(event.target) || navToggle.contains(event.target)) return;
    siteNav.classList.remove('is-open');
    navToggle.setAttribute('aria-expanded', 'false');
  });
};

const loadRuntimeScript = (filename, dataAttr) =>
  new Promise((resolve, reject) => {
    if (document.querySelector(`script[${dataAttr}]`)) {
      resolve();
      return;
    }

    const script = document.createElement('script');
    script.src = new URL(filename, runtimeBaseUrl).href;
    script.async = true;
    script.setAttribute(dataAttr, '1');
    script.onload = () => resolve();
    script.onerror = () => reject(new Error(`No se ha podido cargar ${filename}`));
    document.head.appendChild(script);
  });

const bootAuthExperience = async () => {
  if (!siteConfig.accounts || siteConfig.accounts.enabled === false) return;

  try {
    await loadRuntimeScript('auth-config.js', 'data-auth-config');
    const authModuleUrl = new URL('auth-app.js', runtimeBaseUrl).href;
    const authModule = await import(authModuleUrl);
    if (authModule && typeof authModule.boot === 'function') {
      await authModule.boot({ siteConfig });
    }
  } catch (error) {
    console.error(error);
  }
};

if (yearTargets.length) {
  const year = new Date().getFullYear();
  yearTargets.forEach((node) => {
    node.textContent = String(year);
  });
}

renderConfigValues();
injectSeoTags();
decorateBrandMarks();
mountRevealAnimations();
bindNavigation();
bindLeadForms();
bindArticleSearch();
mountCookieBanner();
renderAdSlots();
setBodyReady();
bootAuthExperience();

window.addEventListener('pageshow', () => {
  if (!document.body) return;
  document.body.classList.add('page-ready');
});
