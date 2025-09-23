**Vulnerability: Insecure Password Recovery Implementation**

**Description:**
The password recovery form (/?page=recover) relies on a hidden input field to set the target email address. Since hidden fields are controlled by the client, an attacker can modify this value in the browser (e.g., via DevTools) and initiate a password reset for arbitrary accounts, including administrative ones.

**Steps to Reproduce:**
```<input type="hidden" name="mail" value="webmaster@borntosec.com">```
By changing the mail value before form submission, the attacker can redirect the password reset process to another account.

**Impact:**
1. Account Takeover: Attackers can reset admin passwords.
2. Information Disclosure: Internal emails exposed.
3. Impersonation: Attackers can gain administrative access and act as legitimate users.

**Mitigation:**
1. Do not rely on client-side data for security decisions. Hidden fields must never determine sensitive values like target accounts.
2. Validate requests server-side. Confirm that the requesting user is authorized to reset the specified account’s password.
3. Use secure recovery workflows:
4. Identify accounts by user-provided input (e.g., username or email) with server-side verification.
5. Use session tracking or multi-step verification to confirm identity.
6. Implement challenge-response mechanisms (security questions, one-time codes or 2FA).
7. Apply rate limiting and monitoring on password recovery endpoints to reduce brute-force and abuse risks.
