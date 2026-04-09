/**
 * Contraseña por defecto (cámbiala YA en producción): AdminSitio2025!
 * Para generar un nuevo hash SHA-256 en PowerShell:
 * [BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes('TU_CLAVE'))).Replace('-','').ToLower()
 */
window.ASNEF_ADMIN = {
  passwordSha256: 'ab88828a21d897fb743a953d5a9eea12c7bf5619f2b365e01b25896ef42fb8d4',
  sessionKey: 'asnef_admin_session_v1',
  sessionMaxMs: 1000 * 60 * 60 * 8,
};
