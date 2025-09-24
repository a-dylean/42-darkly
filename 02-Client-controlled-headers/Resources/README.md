**Vulnerability: Reliance on client-controlled headers**

**Description:**
The application exposes secret content when specific HTTP headers are present (`Referer` and `User-Agent`). The copyright page contains comments instructing to use particular header values. Because headers like Referer and User-Agent are fully controlled by the client, an attacker can spoof them (via curl or browser extensions (like ModHeader)).

**Steps to Reproduce:**
```
http://<YOUR_IP_ADDRESS>/?page=b7e44c7a40c5f80139f0a50f3650fb2bd8d00b0d24667c4c2ca32c88e13b758f
```
```
Use Referer: https://www.nsa.gov/
Use User-Agent: ft_bornToSec
```
The value is an MD5 hash. Using an MD5 lookup/decrypt service like https://md5decrypt.net/ we can learn that the value equals to `false` and then we can change it to `true` (`b326b5062b2f0e69046810717534cb09`). If we reload the page the server accepts the poisoned cookie and treats the session as elevated (admin).

**Impact:**
1. Unauthorized data disclosure: Secrets or protected content can be revealed without proper authentication.
2. Impersonation: Attackers can gain administrative access and act as legitimate users.
3. Integrity & confidentiality risk: Unauthorized actions or data access may follow from elevated privileges.

**Mitigation:**
1. Remove secrets from client-facing source. Never place access instructions, tokens, or sensitive info in HTML comments or any client-side code.
2. Do not use Referer / User-Agent as an auth mechanism. These headers are easily spoofed and can only be used for analytics but never for access control.
3. Enforce proper server-side authentication & authorization. Require users to authenticate and check permissions on the server before returning secret content. Use sessions, signed tokens (JWT with proper signing & validation), or opaque session IDs mapped to server-side state.