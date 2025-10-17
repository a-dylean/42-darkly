# No Rate Limiting on Login Attempts

## Flag

Here,

The application contains a login functionality that is vulnerable to brute-force attacks due to the absence of rate limiting on login attempts. An attacker can exploit this vulnerability by systematically trying a large number of username and password combinations in rapid succession until valid credentials are found.

Page:

http://localhost:8080/index.php?page=signin

In this page, there is a login form that accepts a username and password. The HTML code for the login form is as follows:

```html
<table width="40%">
  <tbody>
    <tr style="background-color:transparent;border:none;">
      <td align="center" style="vertical-align:middle;" colspan="2">
        <h2>Login</h2>
      </td>
    </tr>
    <tr style="background-color:transparent;border:none;">
      <td rowspan="2" style="vertical-align:middle;">
        <img src="images/marvin.jpg" height="150px" />
      </td>
      <td style="vertical-align:middle;">
        <form action="#" method="GET">
          <input type="hidden" name="page" value="signin" />
          Username:<input type="text" name="username" style="width:100%;" />
        </form>
      </td>
    </tr>
    <tr style="background-color:transparent;border:none;">
      <td style="vertical-align:middle;">
        Password:<input
          type="password"
          name="password"
          style="width:100%;"
          autocomplete="off"
        />
      </td>
    </tr>
    <tr style="background-color:transparent;border:none;">
      <td style="vertical-align:middle;" align="center" colspan="2">
        <input type="submit" value="Login" name="Login" />
      </td>
    </tr>
    <tr style="background-color:transparent;border:none;">
      <td style="vertical-align:middle;" align="center" colspan="2">
        <a href="?page=recover">I forgot my password</a>
      </td>
    </tr>
  </tbody>
</table>
```

When a user fills out the form and clicks the "Login" button, the form data is sent via a GET request. Like this:

```http
GET http://localhost:8080/index.php?page=signin&username=gfdgfas&password=dfsf&Login=Login# HTTP/1.1
Host: localhost:8080
```

No rate limiting is implemented on the login page and there is no CSRF protection, allowing for rapid successive login attempts.
So an attacker can automate the process of trying different username and password combinations using tools like Hydra, Burp Suite Intruder, or custom scripts.

## Explanation

https://owasp.org/www-community/attacks/Brute_force_attack
https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html#account-lockout

The absence of rate limiting and account lockout mechanisms makes the login functionality vulnerable to brute-force attacks. Attackers can exploit this vulnerability to gain unauthorized access to user accounts by systematically trying different username and password combinations without any restrictions.

Brute-force attacks involve systematically trying a large number of possible username and password combinations to gain unauthorized access to a system. This is often done using automated tools that can rapidly test many combinations.

## Mitigation

To mitigate brute-force attacks on the login functionality, the following measures can be implemented:

1. **Rate Limiting**: Implement rate limiting to restrict the number of login attempts from a single IP address within a specified time frame. For example, after five failed login attempts, block further attempts for 15 minutes.
2. **Account Lockout**: Temporarily lock user accounts after a certain number of failed login attempts. Notify users of suspicious activity on their accounts.
3. **CAPTCHA**: Introduce CAPTCHA challenges after a certain number of failed login attempts to differentiate between human users and automated scripts.
4. **Multi-Factor Authentication (MFA)**: Implement MFA to add an additional layer of security, requiring users to provide a second form of verification.
5. **Strong Password Policies**: Enforce strong password policies to make it more difficult for attackers to guess passwords.
6. **Logging and Monitoring**: Monitor login attempts and log suspicious activities for further investigation.
7. **User Notifications**: Notify users of failed login attempts on their accounts
8. **Use POST Method**: Change the login form to use the POST method instead of GET to prevent credentials from being exposed in URLs.
9. **CSRF Protection**: Implement CSRF tokens to protect against cross-site request forgery attacks.
