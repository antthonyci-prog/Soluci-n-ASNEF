import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const DEFAULT_AUTH_CONFIG = {
  provider: 'supabase',
  supabaseUrl: 'hggqwcsieegkcdiuizqm.supabase.co',
  supabaseAnonKey: 'sb_publishable_LDJUjmmuE97vs40YzWkwBg_Vv5FE4QI',
  confirmEmail: true,
  notificationPollMs: 60000,
  loginPath: 'cuenta/acceder.html',
  signupPath: 'cuenta/registro.html',
  profilePath: 'cuenta/perfil.html',
  adminPath: 'admin/index.html',
  articlesPath: 'articulos/index.html',
  articlePath: 'articulos/publicacion.html',
  articleNotificationsLabel: 'Avísame cuando SA publique un nuevo artículo',
  resetPasswordRedirectPath: 'cuenta/perfil.html',
};

const SECTION_FOLDERS = new Set(['pages', 'legal', 'articulos', 'admin', 'cuenta']);
const state = {
  siteConfig: {},
  authConfig: {},
  client: null,
  session: null,
  user: null,
  profile: null,
  isAdmin: false,
  notifications: [],
  unreadCount: 0,
  notificationIds: new Set(),
  notificationsReady: false,
  notificationTimer: null,
  adminArticles: [],
};

const escapeHtml = (value) =>
  String(value || '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');

const formatInline = (value) => {
  return escapeHtml(value)
    .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
    .replace(/`(.+?)`/g, '<code>$1</code>');
};

const slugify = (value) =>
  String(value || '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .replace(/-{2,}/g, '-');

const currentFolder = () => {
  const segments = window.location.pathname.replace(/\\/g, '/').split('/').filter(Boolean);
  const folder = segments.length > 1 ? segments[segments.length - 2] : '';
  return SECTION_FOLDERS.has(folder) ? folder : '';
};

const toHref = (target) => {
  const normalized = String(target || '').replace(/^\/+/, '');
  const prefix = currentFolder() ? '../' : '';
  return `${prefix}${normalized}`;
};

const toAbsoluteHref = (target) => new URL(toHref(target), window.location.href).href;

const formatDate = (value) => {
  if (!value) return 'Pendiente';
  try {
    return new Intl.DateTimeFormat('es-ES', {
      day: '2-digit',
      month: 'short',
      year: 'numeric',
    }).format(new Date(value));
  } catch {
    return value;
  }
};

const getInitials = (profile, user) => {
  const parts = [
    profile?.display_name,
    profile?.first_name,
    profile?.last_name,
    user?.email ? user.email.split('@')[0] : '',
  ]
    .join(' ')
    .trim()
    .split(/\s+/)
    .filter(Boolean);

  if (!parts.length) return 'SA';
  return parts
    .slice(0, 2)
    .map((part) => part.charAt(0).toUpperCase())
    .join('');
};

const safeNextPath = () => {
  const value = new URLSearchParams(window.location.search).get('next');
  if (!value) return '';
  try {
    const candidate = new URL(value, window.location.origin);
    if (candidate.origin !== window.location.origin) return '';
    return `${candidate.pathname}${candidate.search}${candidate.hash}`;
  } catch {
    return '';
  }
};

const setMetaDescription = (content) => {
  const text = String(content || '').trim();
  if (!text) return;
  let node = document.querySelector('meta[name="description"]');
  if (!node) {
    node = document.createElement('meta');
    node.setAttribute('name', 'description');
    document.head.appendChild(node);
  }
  node.setAttribute('content', text);
};

const setCanonical = (href) => {
  if (!href) return;
  let node = document.querySelector('link[rel="canonical"]');
  if (!node) {
    node = document.createElement('link');
    node.rel = 'canonical';
    document.head.appendChild(node);
  }
  node.href = href;
};

const setSeoForArticle = (article) => {
  if (!article) return;
  document.title = `${article.title} | ${state.siteConfig.siteName || 'Solución ASNEF'}`;
  setMetaDescription(article.excerpt || article.hero_note || article.title);
  setCanonical(window.location.href);
};

const authConfigured = () =>
  Boolean(state.authConfig.supabaseUrl && state.authConfig.supabaseAnonKey && state.authConfig.provider === 'supabase');

const getDisplayName = () => {
  if (state.profile?.display_name) return state.profile.display_name;
  if (state.profile?.first_name) return state.profile.first_name;
  if (state.user?.email) return state.user.email.split('@')[0];
  return 'Cuenta';
};

const renderSetupMessage = (target, title, message) => {
  if (!target) return;
  target.innerHTML = `
    <div class="account-empty-state">
      <strong>${escapeHtml(title)}</strong>
      <p>${escapeHtml(message)}</p>
    </div>
  `;
};

const ensureAuthNavSlot = () => {
  const nav = document.querySelector('.site-nav');
  if (!nav) return null;
  let slot = nav.querySelector('[data-auth-nav-slot]');
  if (!slot) {
    slot = document.createElement('div');
    slot.className = 'auth-nav-slot';
    slot.setAttribute('data-auth-nav-slot', '1');
    nav.appendChild(slot);
  }
  return slot;
};

const closeNotificationPanel = () => {
  const panel = document.querySelector('[data-notification-panel]');
  if (panel) panel.hidden = true;
};

const renderNotificationsPanel = () => {
  const panel = document.querySelector('[data-notification-panel]');
  if (!panel) return;

  if (!state.user) {
    panel.innerHTML = '';
    panel.hidden = true;
    return;
  }

  if (!state.notifications.length) {
    panel.innerHTML = `
      <div class="notification-panel-empty">
        <strong>No hay avisos nuevos</strong>
        <p>Cuando se publique un artículo nuevo y tengas activados los avisos, te aparecerá aquí.</p>
      </div>
    `;
    return;
  }

  panel.innerHTML = `
    <div class="notification-panel-head">
      <strong>Notificaciones</strong>
      <button type="button" class="plain-action" data-mark-all-read>Marcar todo como leído</button>
    </div>
    <div class="notification-list">
      ${state.notifications
        .map((item) => {
          const article = item.article || {};
          return `
            <a
              class="notification-item ${item.is_read ? 'is-read' : ''}"
              href="${escapeHtml(toHref(state.authConfig.articlePath))}?slug=${encodeURIComponent(article.slug || '')}"
              data-notification-link
              data-notification-id="${escapeHtml(item.id)}"
            >
              <span class="notification-item-title">${escapeHtml(article.title || 'Nuevo artículo')}</span>
              <span class="notification-item-copy">${escapeHtml(article.excerpt || 'Hay una nueva publicación disponible.')}</span>
              <span class="notification-item-meta">${escapeHtml(formatDate(item.created_at))}</span>
            </a>
          `;
        })
        .join('')}
    </div>
  `;

  panel.querySelector('[data-mark-all-read]')?.addEventListener('click', async () => {
    await markAllNotificationsAsRead();
  });

  panel.querySelectorAll('[data-notification-link]').forEach((link) => {
    link.addEventListener('click', async (event) => {
      event.preventDefault();
      const id = link.getAttribute('data-notification-id');
      if (id) {
        await markNotificationAsRead(id);
      }
      window.location.href = link.href;
    });
  });
};

const renderAuthNavigation = () => {
  const slot = ensureAuthNavSlot();
  if (!slot) return;

  if (!state.user) {
    slot.innerHTML = `
      <div class="auth-nav-group">
        <a class="nav-member-link" href="${escapeHtml(toHref(state.authConfig.signupPath))}">Crear cuenta</a>
        <a class="nav-member-link nav-member-link-primary" href="${escapeHtml(toHref(state.authConfig.loginPath))}">Entrar</a>
      </div>
    `;
    return;
  }

  slot.innerHTML = `
    <div class="auth-nav-group">
      <button type="button" class="nav-notification-button" data-open-notifications aria-expanded="false" title="Avisos">
        <span>Avisos</span>
        ${state.unreadCount ? `<span class="nav-notification-badge">${state.unreadCount}</span>` : ''}
      </button>
      <a class="nav-member-link" href="${escapeHtml(toHref(state.authConfig.profilePath))}" title="Mi perfil">Mi perfil</a>
      ${
        state.isAdmin
          ? `<a class="nav-member-link nav-member-link-primary" href="${escapeHtml(toHref(state.authConfig.adminPath))}" title="Panel de administrador">Admin</a>`
          : ''
      }
      <button type="button" class="nav-member-link nav-member-link-button nav-member-link-danger" data-auth-logout title="Cerrar sesión">Cerrar sesión</button>
    </div>
    <div class="notification-panel" data-notification-panel hidden></div>
  `;

  slot.querySelector('[data-open-notifications]')?.addEventListener('click', async (event) => {
    event.stopPropagation();
    const panel = slot.querySelector('[data-notification-panel]');
    if (!panel) return;
    const nextState = panel.hidden;
    closeNotificationPanel();
    panel.hidden = !nextState;
    event.currentTarget.setAttribute('aria-expanded', String(nextState));
    if (nextState) {
      await refreshNotifications({ announceNew: false });
    }
  });

  slot.querySelector('[data-auth-logout]')?.addEventListener('click', async () => {
    await state.client?.auth.signOut();
    window.location.href = toHref('index.html');
  });

  renderNotificationsPanel();
};

const disableForm = (form) => {
  if (!form) return;
  form.querySelectorAll('input, textarea, select, button').forEach((field) => {
    field.disabled = true;
  });
};

const setFormMessage = (target, message, type = '') => {
  if (!target) return;
  target.textContent = message;
  target.className = `form-feedback ${type}`.trim();
};

const maybeCreateProfile = async () => {
  if (!state.client || !state.user) return null;

  const fallback = {
    id: state.user.id,
    email: state.user.email || '',
    display_name:
      state.user.user_metadata?.display_name ||
      state.user.user_metadata?.first_name ||
      (state.user.email ? state.user.email.split('@')[0] : 'Cuenta'),
    first_name: state.user.user_metadata?.first_name || '',
    last_name: state.user.user_metadata?.last_name || '',
  };

  await state.client.from('profiles').upsert(fallback, { onConflict: 'id' });
  const { data } = await state.client.from('profiles').select('*').eq('id', state.user.id).maybeSingle();
  return data || fallback;
};

const loadCurrentProfile = async () => {
  if (!state.client || !state.user) {
    state.profile = null;
    state.isAdmin = false;
    return;
  }

  const [profileResult, adminResult] = await Promise.all([
    state.client.from('profiles').select('*').eq('id', state.user.id).maybeSingle(),
    state.client.rpc('is_admin', { check_user: state.user.id }),
  ]);

  let profile = profileResult.data || null;
  if (!profile) {
    profile = await maybeCreateProfile();
  }

  state.profile = profile;
  state.isAdmin = Boolean(adminResult.data);
};

const markNotificationAsRead = async (notificationId) => {
  if (!state.client || !state.user || !notificationId) return;
  await state.client
    .from('article_notifications')
    .update({ is_read: true })
    .eq('id', notificationId)
    .eq('user_id', state.user.id);
  await refreshNotifications({ announceNew: false });
};

const markAllNotificationsAsRead = async () => {
  if (!state.client || !state.user) return;
  await state.client
    .from('article_notifications')
    .update({ is_read: true })
    .eq('user_id', state.user.id)
    .eq('is_read', false);
  await refreshNotifications({ announceNew: false });
};

const showBrowserNotification = (item) => {
  if (!('Notification' in window)) return;
  if (Notification.permission !== 'granted') return;
  if (!state.profile?.notify_browser) return;
  const article = item.article || {};
  const notice = new Notification('Nuevo artículo publicado', {
    body: article.title || 'Ya tienes una nueva publicación disponible.',
    tag: `article-${article.slug || item.id}`,
  });
  notice.onclick = () => {
    window.open(`${toHref(state.authConfig.articlePath)}?slug=${encodeURIComponent(article.slug || '')}`, '_self');
  };
};

const refreshNotifications = async ({ announceNew = false } = {}) => {
  if (!state.client || !state.user) {
    state.notifications = [];
    state.unreadCount = 0;
    renderAuthNavigation();
    return;
  }

  const notificationResult = await state.client
    .from('article_notifications')
    .select('id, article_id, is_read, created_at')
    .eq('user_id', state.user.id)
    .order('created_at', { ascending: false })
    .limit(8);

  const notifications = notificationResult.data || [];
  const articleIds = [...new Set(notifications.map((item) => item.article_id).filter(Boolean))];

  let articlesById = {};
  if (articleIds.length) {
    const articleResult = await state.client
      .from('articles')
      .select('id, slug, title, excerpt, category, read_time, published_at')
      .in('id', articleIds);

    articlesById = Object.fromEntries((articleResult.data || []).map((article) => [article.id, article]));
  }

  const merged = notifications.map((item) => ({
    ...item,
    article: articlesById[item.article_id] || null,
  }));

  if (announceNew && state.notificationsReady) {
    const unseen = merged.filter((item) => !state.notificationIds.has(item.id) && !item.is_read);
    unseen.forEach((item) => showBrowserNotification(item));
  }

  state.notifications = merged;
  state.unreadCount = merged.filter((item) => !item.is_read).length;
  state.notificationIds = new Set(merged.map((item) => item.id));
  state.notificationsReady = true;

  renderAuthNavigation();
};

const startNotificationPolling = () => {
  if (state.notificationTimer) {
    window.clearInterval(state.notificationTimer);
    state.notificationTimer = null;
  }

  if (!state.user || !authConfigured()) return;

  state.notificationTimer = window.setInterval(() => {
    refreshNotifications({ announceNew: true });
  }, Math.max(20000, Number(state.authConfig.notificationPollMs) || 60000));
};

const syncSession = async (session) => {
  state.session = session || null;
  state.user = session?.user || null;
  state.profile = null;
  state.isAdmin = false;
  state.notifications = [];
  state.unreadCount = 0;
  state.notificationIds = new Set();
  state.notificationsReady = false;

  if (state.user) {
    await loadCurrentProfile();
    await refreshNotifications({ announceNew: false });
  } else {
    renderAuthNavigation();
  }

  startNotificationPolling();
};

const requestBrowserPermissionIfNeeded = async () => {
  if (!('Notification' in window)) return false;
  if (Notification.permission === 'granted') return true;
  if (Notification.permission === 'denied') return false;
  const permission = await Notification.requestPermission();
  return permission === 'granted';
};

const renderMarkdownArticleBody = (source) => {
  const lines = String(source || '').split(/\r?\n/);
  const html = [];
  let paragraph = [];
  let list = [];

  const flushParagraph = () => {
    if (!paragraph.length) return;
    html.push(`<p>${formatInline(paragraph.join(' '))}</p>`);
    paragraph = [];
  };

  const flushList = () => {
    if (!list.length) return;
    html.push(`<ul>${list.map((item) => `<li>${formatInline(item)}</li>`).join('')}</ul>`);
    list = [];
  };

  lines.forEach((rawLine) => {
    const line = rawLine.trim();
    if (!line) {
      flushParagraph();
      flushList();
      return;
    }

    if (line.startsWith('### ')) {
      flushParagraph();
      flushList();
      html.push(`<h3>${formatInline(line.slice(4))}</h3>`);
      return;
    }

    if (line.startsWith('## ')) {
      flushParagraph();
      flushList();
      html.push(`<h2>${formatInline(line.slice(3))}</h2>`);
      return;
    }

    if (line.startsWith('- ')) {
      flushParagraph();
      list.push(line.slice(2));
      return;
    }

    if (line.startsWith('> ')) {
      flushParagraph();
      flushList();
      html.push(`<div class="note-box"><p>${formatInline(line.slice(2))}</p></div>`);
      return;
    }

    paragraph.push(line);
  });

  flushParagraph();
  flushList();

  return html.join('');
};

const redirectToLogin = () => {
  const next = encodeURIComponent(`${window.location.pathname}${window.location.search}${window.location.hash}`);
  window.location.href = `${toHref(state.authConfig.loginPath)}?next=${next}`;
};

const redirectAfterAuth = () => {
  const next = safeNextPath();
  if (next) {
    window.location.href = next;
    return;
  }
  window.location.href = toHref(state.authConfig.profilePath);
};

const setupLoginPage = async () => {
  const form = document.querySelector('[data-login-form]');
  const feedback = document.querySelector('[data-auth-feedback]');
  const setupBox = document.querySelector('[data-auth-setup]');
  if (!form || form.dataset.bound === 'true') return;
  form.dataset.bound = 'true';

  if (!authConfigured()) {
    disableForm(form);
    renderSetupMessage(
      setupBox || feedback,
      'Registro todavía sin activar',
      'Completa auth-config.js con tu proyecto de Supabase para abrir el acceso público.'
    );
    return;
  }

  if (state.user) {
    redirectAfterAuth();
    return;
  }

  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    const formData = new FormData(form);
    const email = String(formData.get('email') || '').trim();
    const password = String(formData.get('password') || '');

    if (!email || !password) {
      setFormMessage(feedback, 'Completa correo y contraseña para entrar.', 'error');
      return;
    }

    setFormMessage(feedback, 'Comprobando acceso...', 'warning');

    const { error } = await state.client.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      setFormMessage(feedback, error.message || 'No se ha podido iniciar sesión.', 'error');
      return;
    }

    setFormMessage(feedback, 'Sesión iniciada. Redirigiendo...', 'success');
    redirectAfterAuth();
  });

  document.querySelector('[data-reset-password]')?.addEventListener('click', async () => {
    const email = String(form.querySelector('input[name="email"]')?.value || '').trim();
    if (!email) {
      setFormMessage(feedback, 'Escribe primero tu correo para enviarte el enlace de recuperación.', 'error');
      return;
    }

    setFormMessage(feedback, 'Enviando enlace de recuperación...', 'warning');
    const { error } = await state.client.auth.resetPasswordForEmail(email, {
      redirectTo: toAbsoluteHref(state.authConfig.resetPasswordRedirectPath),
    });

    if (error) {
      setFormMessage(feedback, error.message || 'No se ha podido enviar el enlace.', 'error');
      return;
    }

    setFormMessage(feedback, 'Te hemos enviado un enlace para restablecer la contraseña.', 'success');
  });
};

const setupSignupPage = async () => {
  const form = document.querySelector('[data-signup-form]');
  const feedback = document.querySelector('[data-auth-feedback]');
  const setupBox = document.querySelector('[data-auth-setup]');
  if (!form || form.dataset.bound === 'true') return;
  form.dataset.bound = 'true';

  if (!authConfigured()) {
    disableForm(form);
    renderSetupMessage(
      setupBox || feedback,
      'Registro todavía sin activar',
      'Completa auth-config.js y ejecuta supabase-schema.sql para activar cuentas, perfiles y artículos.'
    );
    return;
  }

  if (state.user) {
    redirectAfterAuth();
    return;
  }

  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    const formData = new FormData(form);
    const displayName = String(formData.get('display_name') || '').trim();
    const firstName = String(formData.get('first_name') || '').trim();
    const lastName = String(formData.get('last_name') || '').trim();
    const email = String(formData.get('email') || '').trim();
    const password = String(formData.get('password') || '');
    const passwordConfirm = String(formData.get('password_confirm') || '');

    if (!displayName || !email || !password) {
      setFormMessage(feedback, 'Completa nombre visible, correo y contraseña.', 'error');
      return;
    }

    if (password.length < 8) {
      setFormMessage(feedback, 'La contraseña debe tener al menos 8 caracteres.', 'error');
      return;
    }

    if (password !== passwordConfirm) {
      setFormMessage(feedback, 'La confirmación de la contraseña no coincide.', 'error');
      return;
    }

    setFormMessage(feedback, 'Creando tu cuenta...', 'warning');

    const { data, error } = await state.client.auth.signUp({
      email,
      password,
      options: {
        emailRedirectTo: toAbsoluteHref(state.authConfig.profilePath),
        data: {
          display_name: displayName,
          first_name: firstName,
          last_name: lastName,
        },
      },
    });

    if (error) {
      setFormMessage(feedback, error.message || 'No se ha podido crear la cuenta.', 'error');
      return;
    }

    if (data.user) {
      await state.client.from('profiles').upsert(
        {
          id: data.user.id,
          email,
          display_name: displayName,
          first_name: firstName,
          last_name: lastName,
        },
        { onConflict: 'id' }
      );
    }

    if (data.session) {
      setFormMessage(feedback, 'Cuenta creada correctamente. Redirigiendo a tu perfil...', 'success');
      redirectAfterAuth();
      return;
    }

    if (state.authConfig.confirmEmail) {
      setFormMessage(feedback, 'Cuenta creada. Revisa tu correo para confirmar el acceso.', 'success');
      form.reset();
      return;
    }

    setFormMessage(feedback, 'Cuenta creada correctamente.', 'success');
  });
};

const fillProfileSummary = () => {
  const avatar = document.querySelector('[data-profile-avatar]');
  const name = document.querySelector('[data-profile-name]');
  const email = document.querySelector('[data-profile-email]');
  const role = document.querySelector('[data-profile-role]');
  const status = document.querySelector('[data-profile-status]');

  if (avatar) {
    const avatarUrl = state.profile?.avatar_url;
    if (avatarUrl) {
      avatar.innerHTML = `<img src="${escapeHtml(avatarUrl)}" alt="${escapeHtml(getDisplayName())}" />`;
    } else {
      avatar.textContent = getInitials(state.profile, state.user);
    }
  }

  if (name) name.textContent = getDisplayName();
  if (email) email.textContent = state.user?.email || '';
  if (role) role.textContent = state.isAdmin ? 'Administrador' : 'Miembro';
  if (status) {
    status.textContent = state.profile?.notify_new_articles
      ? 'Avisos de nuevos artículos activados'
      : 'Avisos de nuevos artículos desactivados';
  }
};

const fillProfileForm = () => {
  const form = document.querySelector('[data-profile-form]');
  if (!form || !state.profile) return;

  const fields = [
    'display_name',
    'first_name',
    'last_name',
    'phone',
    'city',
    'province',
    'country',
    'birth_date',
    'occupation',
    'website_url',
    'avatar_url',
    'main_topic',
    'bio',
  ];

  fields.forEach((name) => {
    const field = form.elements.namedItem(name);
    if (field) field.value = state.profile[name] || '';
  });

  const notifyNewArticles = form.elements.namedItem('notify_new_articles');
  const notifyBrowser = form.elements.namedItem('notify_browser');
  const notifyEmail = form.elements.namedItem('notify_email');

  if (notifyNewArticles) notifyNewArticles.checked = Boolean(state.profile.notify_new_articles);
  if (notifyBrowser) notifyBrowser.checked = Boolean(state.profile.notify_browser);
  if (notifyEmail) notifyEmail.checked = Boolean(state.profile.notify_email);
};

const renderProfileNotifications = () => {
  const list = document.querySelector('[data-profile-notification-list]');
  if (!list) return;

  if (!state.notifications.length) {
    list.innerHTML = `
      <div class="account-empty-state">
        <strong>Sin avisos recientes</strong>
        <p>Activa las notificaciones para ver aquí cada nuevo artículo que se publique.</p>
      </div>
    `;
    return;
  }

  list.innerHTML = state.notifications
    .map((item) => {
      const article = item.article || {};
      return `
        <a class="account-notification-item ${item.is_read ? 'is-read' : ''}" href="${escapeHtml(
          toHref(state.authConfig.articlePath)
        )}?slug=${encodeURIComponent(article.slug || '')}" data-notification-link data-notification-id="${escapeHtml(item.id)}">
          <strong>${escapeHtml(article.title || 'Nuevo artículo')}</strong>
          <span>${escapeHtml(article.excerpt || 'Tienes una nueva publicación disponible.')}</span>
          <small>${escapeHtml(formatDate(item.created_at))}</small>
        </a>
      `;
    })
    .join('');

  list.querySelectorAll('[data-notification-link]').forEach((link) => {
    link.addEventListener('click', async (event) => {
      event.preventDefault();
      const id = link.getAttribute('data-notification-id');
      if (id) await markNotificationAsRead(id);
      window.location.href = link.href;
    });
  });
};

const setupProfilePage = async () => {
  const form = document.querySelector('[data-profile-form]');
  const feedback = document.querySelector('[data-profile-feedback]');
  const setupBox = document.querySelector('[data-auth-setup]');

  if (!form || form.dataset.bound === 'true') return;
  form.dataset.bound = 'true';

  if (!authConfigured()) {
    disableForm(form);
    renderSetupMessage(
      setupBox || feedback,
      'Área privada sin activar',
      'Configura Supabase en auth-config.js para habilitar perfiles, artículos y avisos.'
    );
    return;
  }

  if (!state.user) {
    redirectToLogin();
    return;
  }

  fillProfileSummary();
  fillProfileForm();
  renderProfileNotifications();

  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    const formData = new FormData(form);
    const wantsBrowser = formData.get('notify_browser') === 'on';
    let notifyBrowser = wantsBrowser;

    if (wantsBrowser) {
      const granted = await requestBrowserPermissionIfNeeded();
      notifyBrowser = granted;
    }

    const payload = {
      id: state.user.id,
      email: state.user.email || '',
      display_name: String(formData.get('display_name') || '').trim(),
      first_name: String(formData.get('first_name') || '').trim(),
      last_name: String(formData.get('last_name') || '').trim(),
      phone: String(formData.get('phone') || '').trim(),
      city: String(formData.get('city') || '').trim(),
      province: String(formData.get('province') || '').trim(),
      country: String(formData.get('country') || '').trim(),
      birth_date: String(formData.get('birth_date') || '').trim() || null,
      occupation: String(formData.get('occupation') || '').trim(),
      website_url: String(formData.get('website_url') || '').trim(),
      avatar_url: String(formData.get('avatar_url') || '').trim(),
      main_topic: String(formData.get('main_topic') || '').trim(),
      bio: String(formData.get('bio') || '').trim(),
      notify_new_articles: formData.get('notify_new_articles') === 'on',
      notify_browser: notifyBrowser,
      notify_email: formData.get('notify_email') === 'on',
    };

    setFormMessage(feedback, 'Guardando cambios...', 'warning');

    const { data, error } = await state.client.from('profiles').upsert(payload, { onConflict: 'id' }).select('*').maybeSingle();

    if (error) {
      setFormMessage(feedback, error.message || 'No se ha podido guardar tu perfil.', 'error');
      return;
    }

    state.profile = data || payload;
    fillProfileSummary();
    fillProfileForm();
    renderProfileNotifications();
    renderAuthNavigation();
    setFormMessage(
      feedback,
      notifyBrowser || !wantsBrowser
        ? 'Perfil actualizado correctamente.'
        : 'Perfil actualizado. El navegador no ha concedido permisos para avisos del sistema.',
      'success'
    );
  });

  document.querySelector('[data-profile-reset-password]')?.addEventListener('click', async () => {
    if (!state.user?.email) return;
    setFormMessage(feedback, 'Enviando enlace para cambiar la contraseña...', 'warning');
    const { error } = await state.client.auth.resetPasswordForEmail(state.user.email, {
      redirectTo: toAbsoluteHref(state.authConfig.resetPasswordRedirectPath),
    });
    if (error) {
      setFormMessage(feedback, error.message || 'No se ha podido enviar el enlace.', 'error');
      return;
    }
    setFormMessage(feedback, 'Te hemos enviado un correo para cambiar la contraseña.', 'success');
  });
};

const renderAdminArticles = (articles) => {
  const list = document.querySelector('[data-admin-articles]');
  if (!list) return;

  if (!articles.length) {
    list.innerHTML = `
      <div class="account-empty-state">
        <strong>Todavía no hay artículos nuevos</strong>
        <p>Usa el editor de esta página para publicar el primero.</p>
      </div>
    `;
    return;
  }

  list.innerHTML = articles
    .map((article) => {
      const publicUrl = `${toHref(state.authConfig.articlePath)}?slug=${encodeURIComponent(article.slug)}`;
      return `
        <article class="admin-list-card">
          <div>
            <strong>${escapeHtml(article.title)}</strong>
            <p>${escapeHtml(article.excerpt || '')}</p>
            <span class="admin-list-meta">${escapeHtml(article.category || 'General')} · ${escapeHtml(
        article.status === 'published' ? 'Publicado' : 'Borrador'
      )} · ${escapeHtml(formatDate(article.published_at || article.created_at))}</span>
          </div>
          <div class="admin-list-actions">
            <a class="button button-secondary" href="${escapeHtml(publicUrl)}" target="_blank" rel="noopener">Ver</a>
            <button type="button" class="button button-secondary" data-admin-edit="${escapeHtml(article.id)}">Editar</button>
            <button type="button" class="button button-secondary" data-admin-delete="${escapeHtml(article.id)}">Eliminar</button>
          </div>
        </article>
      `;
    })
    .join('');
};

const renderAdminMembers = (members) => {
  const list = document.querySelector('[data-admin-members]');
  if (!list) return;

  if (!members.length) {
    list.innerHTML = `
      <div class="account-empty-state">
        <strong>Sin miembros todavía</strong>
        <p>Cuando empiecen a registrarse, aquí verás su perfil básico y sus preferencias.</p>
      </div>
    `;
    return;
  }

  list.innerHTML = members
    .map((member) => {
      return `
        <article class="admin-member-card">
          <div class="admin-member-avatar">${escapeHtml(
            (member.display_name || member.email || 'SA').slice(0, 2).toUpperCase()
          )}</div>
          <div>
            <strong>${escapeHtml(member.display_name || member.email || 'Miembro')}</strong>
            <p>${escapeHtml(member.email || '')}</p>
            <span class="admin-list-meta">
              ${member.notify_new_articles ? 'Avisos activos' : 'Avisos inactivos'} ·
              ${escapeHtml(member.main_topic || 'Sin tema principal')}
            </span>
          </div>
        </article>
      `;
    })
    .join('');
};

const loadAdminOverview = async () => {
  const [membersCount, articleCount, publishedCount, subscribersCount, latestArticles, latestMembers] = await Promise.all([
    state.client.from('profiles').select('id', { count: 'exact', head: true }),
    state.client.from('articles').select('id', { count: 'exact', head: true }),
    state.client.from('articles').select('id', { count: 'exact', head: true }).eq('status', 'published'),
    state.client.from('profiles').select('id', { count: 'exact', head: true }).eq('notify_new_articles', true),
    state.client
      .from('articles')
      .select('id, slug, title, excerpt, category, status, published_at, created_at, hero_note, read_time, body_markdown, is_featured')
      .order('created_at', { ascending: false })
      .limit(12),
    state.client
      .from('profiles')
      .select('id, email, display_name, main_topic, notify_new_articles')
      .order('created_at', { ascending: false })
      .limit(10),
  ]);

  const metricMap = {
    members: membersCount.count || 0,
    articles: articleCount.count || 0,
    published: publishedCount.count || 0,
    subscribers: subscribersCount.count || 0,
  };

  Object.entries(metricMap).forEach(([key, value]) => {
    const node = document.querySelector(`[data-admin-metric="${key}"]`);
    if (node) node.textContent = String(value);
  });

  renderAdminArticles(latestArticles.data || []);
  renderAdminMembers(latestMembers.data || []);

  state.adminArticles = latestArticles.data || [];
};

const populateAdminEditor = (article) => {
  const form = document.querySelector('[data-admin-article-form]');
  if (!form || !article) return;

  form.elements.namedItem('article_id').value = article.id || '';
  form.elements.namedItem('title').value = article.title || '';
  form.elements.namedItem('slug').value = article.slug || '';
  form.elements.namedItem('category').value = article.category || 'General';
  form.elements.namedItem('read_time').value = article.read_time || '';
  form.elements.namedItem('excerpt').value = article.excerpt || '';
  form.elements.namedItem('hero_note').value = article.hero_note || '';
  form.elements.namedItem('body_markdown').value = article.body_markdown || '';
  form.elements.namedItem('status').value = article.status || 'draft';
  form.elements.namedItem('is_featured').checked = Boolean(article.is_featured);
  document.querySelector('[data-admin-editor-title]')?.replaceChildren(document.createTextNode(`Editando: ${article.title}`));
};

const resetAdminEditor = () => {
  const form = document.querySelector('[data-admin-article-form]');
  if (!form) return;
  form.reset();
  form.elements.namedItem('article_id').value = '';
  form.elements.namedItem('status').value = 'draft';
  document.querySelector('[data-admin-editor-title]')?.replaceChildren(document.createTextNode('Nuevo artículo'));
};

const setupAdminPage = async () => {
  const guard = document.querySelector('[data-admin-guard]');
  const shell = document.querySelector('[data-admin-shell]');
  const form = document.querySelector('[data-admin-article-form]');
  const feedback = document.querySelector('[data-admin-feedback]');

  if (!guard || !shell || !form || form.dataset.bound === 'true') return;
  form.dataset.bound = 'true';

  if (!authConfigured()) {
    renderSetupMessage(
      guard,
      'Panel todavía sin activar',
      'Completa auth-config.js y ejecuta supabase-schema.sql para abrir el panel seguro.'
    );
    shell.hidden = true;
    return;
  }

  if (!state.user) {
    redirectToLogin();
    return;
  }

  if (!state.isAdmin) {
    renderSetupMessage(
      guard,
      'Acceso restringido',
      'Tu cuenta existe, pero todavía no tiene permisos de administrador. Promociona tu usuario desde Supabase.'
    );
    shell.hidden = true;
    return;
  }

  guard.hidden = true;
  shell.hidden = false;
  await loadAdminOverview();

  form.querySelector('input[name="title"]')?.addEventListener('input', (event) => {
    const slugField = form.elements.namedItem('slug');
    if (!slugField.value.trim()) {
      slugField.value = slugify(event.currentTarget.value);
    }
  });

  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    const formData = new FormData(form);
    const articleId = String(formData.get('article_id') || '').trim();
    const title = String(formData.get('title') || '').trim();
    const slug = slugify(formData.get('slug') || title);
    const excerpt = String(formData.get('excerpt') || '').trim();
    const category = String(formData.get('category') || '').trim() || 'General';
    const bodyMarkdown = String(formData.get('body_markdown') || '').trim();
    const status = String(formData.get('status') || 'draft').trim();

    if (!title || !slug || !excerpt || !bodyMarkdown) {
      setFormMessage(feedback, 'Completa título, slug, resumen y cuerpo del artículo.', 'error');
      return;
    }

    const payload = {
      author_id: state.user.id,
      title,
      slug,
      excerpt,
      category,
      read_time: String(formData.get('read_time') || '').trim(),
      hero_note: String(formData.get('hero_note') || '').trim(),
      body_markdown: bodyMarkdown,
      status,
      is_featured: formData.get('is_featured') === 'on',
      published_at: status === 'published' ? new Date().toISOString() : null,
    };

    setFormMessage(feedback, articleId ? 'Actualizando artículo...' : 'Creando artículo...', 'warning');

    const query = articleId
      ? state.client.from('articles').update(payload).eq('id', articleId)
      : state.client.from('articles').insert(payload);

    const { error } = await query;

    if (error) {
      setFormMessage(feedback, error.message || 'No se ha podido guardar el artículo.', 'error');
      return;
    }

    setFormMessage(
      feedback,
      status === 'published'
        ? 'Artículo guardado y publicado. Los avisos se han generado para los suscriptores.'
        : 'Artículo guardado como borrador.',
      'success'
    );

    resetAdminEditor();
    await loadAdminOverview();
  });

  document.querySelector('[data-admin-reset]')?.addEventListener('click', () => {
    resetAdminEditor();
    setFormMessage(feedback, '', '');
  });

  document.querySelector('[data-admin-articles]')?.addEventListener('click', async (event) => {
    const editId = event.target.getAttribute('data-admin-edit');
    const deleteId = event.target.getAttribute('data-admin-delete');

    if (editId) {
      const article = (state.adminArticles || []).find((item) => item.id === editId);
      if (article) populateAdminEditor(article);
      return;
    }

    if (deleteId) {
      const article = (state.adminArticles || []).find((item) => item.id === deleteId);
      if (!article) return;
      const confirmed = window.confirm(`Vas a eliminar "${article.title}". Esta acción no se puede deshacer.`);
      if (!confirmed) return;

      setFormMessage(feedback, 'Eliminando artículo...', 'warning');
      const { error } = await state.client.from('articles').delete().eq('id', deleteId);

      if (error) {
        setFormMessage(feedback, error.message || 'No se ha podido eliminar el artículo.', 'error');
        return;
      }

      setFormMessage(feedback, 'Artículo eliminado correctamente.', 'success');
      await loadAdminOverview();
      resetAdminEditor();
    }
  });
};

const setupDynamicArticleFeed = async () => {
  const container = document.querySelector('[data-dynamic-articles]');
  const status = document.querySelector('[data-dynamic-articles-status]');
  if (!container || container.dataset.bound === 'true') return;
  container.dataset.bound = 'true';

  if (!authConfigured()) {
    if (status) {
      status.textContent = 'Activa auth-config.js para que los nuevos artículos del panel admin aparezcan aquí.';
    }
    return;
  }

  if (status) status.textContent = 'Cargando publicaciones nuevas...';

  const { data, error } = await state.client
    .from('articles')
    .select('id, slug, title, excerpt, category, read_time, published_at, hero_note, is_featured')
    .eq('status', 'published')
    .order('published_at', { ascending: false })
    .limit(9);

  if (error) {
    if (status) status.textContent = 'No se han podido cargar los artículos nuevos ahora mismo.';
    return;
  }

  if (!data || !data.length) {
    if (status) {
      status.textContent = 'Todavía no has publicado artículos dinámicos desde el panel admin.';
    }
    return;
  }

  container.innerHTML = data
    .map((article) => {
      return `
        <article class="info-card summary-guide-card dynamic-article-card ${article.is_featured ? 'is-featured' : ''}">
          <span class="card-tag">${escapeHtml(article.category || 'Artículo')}</span>
          <h3>${escapeHtml(article.title)}</h3>
          <p>${escapeHtml(article.excerpt || article.hero_note || '')}</p>
          <div class="dynamic-article-meta">
            <span>${escapeHtml(formatDate(article.published_at))}</span>
            <span>${escapeHtml(article.read_time || 'Lectura guiada')}</span>
          </div>
          <a class="card-link" href="${escapeHtml(toHref(state.authConfig.articlePath))}?slug=${encodeURIComponent(article.slug)}">Leer artículo</a>
        </article>
      `;
    })
    .join('');

  if (status) {
    status.textContent = 'Estas publicaciones se alimentan automáticamente desde el panel de administrador.';
  }
};

const setupDynamicArticlePage = async () => {
  const mount = document.querySelector('[data-dynamic-article]');
  if (!mount || mount.dataset.bound === 'true') return;
  mount.dataset.bound = 'true';

  if (!authConfigured()) {
    renderSetupMessage(
      mount,
      'Artículo dinámico no disponible',
      'Configura auth-config.js y publica desde el panel admin para ver aquí los nuevos artículos.'
    );
    return;
  }

  const params = new URLSearchParams(window.location.search);
  const slug = slugify(params.get('slug') || '');
  if (!slug) {
    renderSetupMessage(
      mount,
      'Artículo no encontrado',
      'Falta el slug del artículo. Vuelve al índice y entra desde una publicación válida.'
    );
    return;
  }

  let result = await state.client
    .from('articles')
    .select('id, slug, title, excerpt, category, read_time, hero_note, body_markdown, status, published_at, created_at')
    .eq('slug', slug)
    .eq('status', 'published')
    .maybeSingle();

  if (!result.data && state.isAdmin) {
    result = await state.client
      .from('articles')
      .select('id, slug, title, excerpt, category, read_time, hero_note, body_markdown, status, published_at, created_at')
      .eq('slug', slug)
      .maybeSingle();
  }

  if (!result.data) {
    renderSetupMessage(
      mount,
      'Artículo no disponible',
      'No hemos encontrado esa publicación o todavía no está publicada.'
    );
    return;
  }

  const article = result.data;
  setSeoForArticle(article);
  mount.innerHTML = `
    <article class="dynamic-article-shell">
      <p class="breadcrumbs"><a href="${escapeHtml(toHref('index.html'))}">Inicio</a> / <a href="${escapeHtml(
    toHref(state.authConfig.articlesPath)
  )}">Artículos</a> / ${escapeHtml(article.title)}</p>
      <p class="eyebrow accent">${escapeHtml(article.category || 'Artículo')}</p>
      <h1>${escapeHtml(article.title)}</h1>
      <p class="dynamic-article-intro">${escapeHtml(article.excerpt || article.hero_note || '')}</p>
      <div class="dynamic-article-meta">
        <span>${escapeHtml(formatDate(article.published_at || article.created_at))}</span>
        <span>${escapeHtml(article.read_time || 'Lectura orientativa')}</span>
        ${
          article.status !== 'published' && state.isAdmin
            ? '<span class="article-status-pill">Vista previa de borrador</span>'
            : ''
        }
      </div>
      <div class="dynamic-article-body">
        ${renderMarkdownArticleBody(article.body_markdown)}
      </div>
      <div class="highlight-box" style="margin-top: 2rem">
        <p class="eyebrow">Siguiente paso</p>
        <p>Si quieres recibir avisos de nuevas publicaciones, crea tu cuenta o activa esa opción en tu perfil.</p>
        <div class="inline-actions">
          <a class="button button-primary" href="${escapeHtml(toHref(state.authConfig.signupPath))}">Crear cuenta</a>
          <a class="button button-secondary" href="${escapeHtml(toHref(state.authConfig.articlesPath))}">Ver más artículos</a>
        </div>
      </div>
    </article>
  `;
};

const routeCurrentPage = async () => {
  const path = window.location.pathname.replace(/\\/g, '/');

  if (path.endsWith('/cuenta/acceder.html') || path.endsWith('cuenta/acceder.html')) {
    await setupLoginPage();
  }

  if (path.endsWith('/cuenta/registro.html') || path.endsWith('cuenta/registro.html')) {
    await setupSignupPage();
  }

  if (path.endsWith('/cuenta/perfil.html') || path.endsWith('cuenta/perfil.html')) {
    await setupProfilePage();
  }

  if (
    path.endsWith('/admin/index.html') ||
    path.endsWith('admin/index.html') ||
    path.endsWith('/admin/dashboard.html') ||
    path.endsWith('admin/dashboard.html')
  ) {
    await setupAdminPage();
  }

  if (path.endsWith('/articulos/index.html') || path.endsWith('articulos/index.html')) {
    await setupDynamicArticleFeed();
  }

  if (path.endsWith('/articulos/publicacion.html') || path.endsWith('articulos/publicacion.html')) {
    await setupDynamicArticlePage();
  }
};

const bindGlobalEvents = () => {
  document.addEventListener('click', (event) => {
    const slot = document.querySelector('[data-auth-nav-slot]');
    if (!slot) return;
    if (!slot.contains(event.target)) {
      closeNotificationPanel();
    }
  });

  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') {
      closeNotificationPanel();
    }
  });

  document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible' && state.user) {
      refreshNotifications({ announceNew: false });
    }
  });

  window.addEventListener('beforeunload', () => {
    if (state.notificationTimer) {
      window.clearInterval(state.notificationTimer);
    }
  });
};

export async function boot({ siteConfig = {} } = {}) {
  state.siteConfig = siteConfig || {};
  state.authConfig = {
    ...DEFAULT_AUTH_CONFIG,
    ...(window.AUTH_CONFIG || {}),
  };

  bindGlobalEvents();
  renderAuthNavigation();

  if (!authConfigured()) {
    await routeCurrentPage();
    return;
  }

  state.client = createClient(state.authConfig.supabaseUrl, state.authConfig.supabaseAnonKey, {
    auth: {
      persistSession: true,
      autoRefreshToken: true,
      detectSessionInUrl: true,
    },
  });

  const sessionResult = await state.client.auth.getSession();
  await syncSession(sessionResult.data.session);
  await routeCurrentPage();

  state.client.auth.onAuthStateChange(async (_event, session) => {
    await syncSession(session);
    await routeCurrentPage();
  });
}
