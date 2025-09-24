**Vulnerability: Insecure Client-side session implementation (Cookie poisoning)**

**Description:**
The application stores state information on the client inside an unsigned and weakly hashed cookie. An attacker can reverse with that cookie value to escalate privileges (for example, set an “admin” flag) because the server does not cryptographically verify cookie integrity or authenticity.

**Steps to Reproduce:**
```
cookie {
    name: I_am_admin,
    value: 68934a3e9455fa72420237eb05902327
}
```
The value is an MD5 hash. Using an MD5 lookup/decrypt service like https://md5decrypt.net/ we can learn that the value equals to `false` and then we can change it to `true` (`b326b5062b2f0e69046810717534cb09`). If we reload the page the server accepts the poisoned cookie and treats the session as elevated (admin).

**Impact:**
1. Privilege escalation: Attackers can forge cookies to gain access to authenticated areas and existing sessions.
2. Impersonation: Attackers can gain administrative access and act as legitimate users.
3. Integrity & confidentiality risk: Unauthorized actions or data access may follow from elevated privileges.

**Mitigation:**
1. Never store trust decisions client-side. Keep sensitive session state on the server.
2. Use server-side sessions. Store authorization in server memory or datastore indexed by a session identifier (cookie contains only opaque session id).
3. If client cookies must carry state, sign and/or encrypt them. Use an HMAC (e.g., HMAC-SHA256) or AEAD with a server secret to ensure integrity and authenticity; verify signature server-side on every request. Do not use MD5 or unsalted hashes.
4. Set security flags for cookies (Secure, HttpOnly). More info here: https://www.invicti.com/learn/cookie-security-flags/
5. Use multi-factor authentication (MFA) as an additional security mechanism.