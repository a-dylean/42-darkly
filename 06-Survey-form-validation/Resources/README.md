**Vulnerability: Insufficient Input Validation**

**Description:**
The survey page contains an unprotected form that can result in an XSS attack.

**Steps to Reproduce:**
```
http://<YOUR_IP_ADDRESS>/index.php?page=survey#
```
User can send the value beyond the defined scope, e.g. `curl -X POST -F 'sujet=42' -F 'valeur=4242' 'http://localhost:8080/index.php?page=survey'`

**Impact:**
1. Data Integrity Issues: Insufficient validation may result in data corruption, incorrect processing, or inaccurate outputs, compromising the reliability and integrity of the system.
2. Financial Impact: Data breaches or system disruptions caused by the vulnerability can result in financial losses due to incident response, remediation costs, legal fees, and potential loss of revenue.

**Mitigation:**
Input Validation:
1. Validate and sanitize user input using strict validation techniques.
2. Implement input length restrictions and reject unexpected or malicious data.
3. Implement data integrity checks to detect and prevent data corruption or unauthorized modifications.

**References:**
1. https://github.com/OWASP/wstg/blob/master/document/4-Web_Application_Security_Testing/07-Input_Validation_Testing/01-Testing_for_Reflected_Cross_Site_Scripting.md 
2. https://cheatsheetseries.owasp.org/cheatsheets/XSS_Filter_Evasion_Cheat_Sheet.html
3. https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html
4. https://owasp.org/www-project-mobile-top-10/2023-risks/m4-insufficient-input-output-validation