**Vulnerability: No input validation**

**Description:**
The feedback page contains an unprotected form that can result in an XSS attack.

**Steps to Reproduce:**
```
http://<YOUR_IP_ADDRESS>/index.php?page=feedback
```
Insert malisious script `<script>alert(123)</script>` to trigger responses from the web browser that manifests the vulnerability. 
https://github.com/OWASP/wstg/blob/master/document/4-Web_Application_Security_Testing/07-Input_Validation_Testing/01-Testing_for_Reflected_Cross_Site_Scripting.md 

**Impact:**
1. Unprotected data entrypoint resulting in  an XSS attack.
https://cheatsheetseries.owasp.org/cheatsheets/XSS_Filter_Evasion_Cheat_Sheet.html

**Mitigation:**
1. Sanitize inputs.