(function () {
  async function sha256Hex(text) {
    const buf = new TextEncoder().encode(text);
    const hash = await crypto.subtle.digest('SHA-256', buf);
    return Array.from(new Uint8Array(hash))
      .map((b) => b.toString(16).padStart(2, '0'))
      .join('');
  }

  window.ASNEF_ADMIN_AUTH = {
    async tryLogin(password) {
      if (!window.ASNEF_ADMIN || !password) return false;
      const hash = await sha256Hex(password);
      return hash === window.ASNEF_ADMIN.passwordSha256;
    },
    openSession() {
      const A = window.ASNEF_ADMIN;
      sessionStorage.setItem(A.sessionKey, JSON.stringify({ ts: Date.now() }));
    },
    clearSession() {
      const A = window.ASNEF_ADMIN;
      sessionStorage.removeItem(A.sessionKey);
    },
    isSessionValid() {
      const A = window.ASNEF_ADMIN;
      const raw = sessionStorage.getItem(A.sessionKey);
      if (!raw) return false;
      try {
        const d = JSON.parse(raw);
        return Date.now() - d.ts <= A.sessionMaxMs;
      } catch {
        return false;
      }
    },
  };
})();
