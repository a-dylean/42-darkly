**Vulnerability: Client-side URL Redirect**

**Description:**
The application accepts a site parameter and performs a HTTP redirect using its value without sufficient validation. If the application takes an attacker-controlled value and issues a Location header or otherwise navigates the browser to that value, an attacker can cause users to be redirected to arbitrary external sites (phishing, malware hosts, login pages that capture credentials, tracking, etc.). This is a classic open redirect / unvalidated redirect issue and is covered in OWASP WSTG guidance for redirect testing:
https://cheatsheetseries.owasp.org/cheatsheets/Unvalidated_Redirects_and_Forwards_Cheat_Sheet.html
https://github.com/OWASP/wstg/blob/master/document/4-Web_Application_Security_Testing/11-Client-side_Testing/04-Testing_for_Client-side_URL_Redirect.md

**Steps to Reproduce:**
Send a request that triggers the redirect handler and supply a site value that points outside the application domain:
```http://<YOUR_IP_ADDRESS>/index.php?page=redirect&site=www.fake-target.site```

**Impact:**
1. Phishing facilitation: Attackers can craft links that appear to come from the vulnerable domain but redirect victims to malicious pages that mimic the original site to harvest credentials or other data.
2. Reputation & trust damage: Users clicking legitimate-looking links from the affected domain may be sent to malicious destinations, undermining trust in the domain.
3. Bypass of security controls: Redirects can be used in more complex attack chains (e.g., chaining through allowed domains to bypass filters or content security rules).
4. Tracking & privacy leakage: Attackers can use the redirect to track clicks/visitors

**Mitigation:**
1. Implement a whitelist of allowed redirect targets (hosts or paths). Only redirect to values present in that whitelist.
2. Prefer relative internal paths only. Reject absolute URLs (those including a scheme/host) unless the host is explicitly allowed.
3. Normalize and validate input: parse the provided URL and verify scheme, host and path against allowed patterns before issuing a redirect.
4. Default safe fallback: if site is missing, invalid or not allowed, redirect to a safe default page (e.g., / or /login) rather than performing an external redirect.

