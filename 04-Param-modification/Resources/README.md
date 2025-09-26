**Vulnerability: Possible to bypass Authentication Schema**

**Description:**
The application verifies a successful log in on the basis of a fixed value parameters. A user can modify these parameters to gain access to the protected areas without providing valid credentials. Change the "authenticated" parameter to "yes" to obtain a flag.

**Steps to Reproduce:**
```
http://<YOUR_IP_ADDRESS>/?authenticated=yes
```
Add the "authenticated" parameter to URL to obtain a flag.
https://github.com/OWASP/wstg/blob/master/document/4-Web_Application_Security_Testing/04-Authentication_Testing/04-Testing_for_Bypassing_Authentication_Schema.md#parameter-modification 

**Impact:**
1. 

**Mitigation:**
1. Follow session management good practices.
2. Ensure that no credentials are stored in clear text or are easily retrievable in encoded or encrypted forms in browser storage mechanisms; they should be stored server-side and follow good password storage practices.