Mains infos:

- Reverse Proxy: `nginx/1.4.6 (Ubuntu)`
- Backend server: `Apache/2.4.7 (Ubuntu)`
- PHP version: `5.5.9-1ubuntu4.29`
  - Expected HTTP Headers:
    `Referer: https://www.nsa.gov/`
    `User-Agent: ft_bornToSec`
- CMS: WordPress (not installed)
- JavaScript libraries/frameworks:
  - jQuery `1.11.1`
- Database:
  - MariaDB: `5.5.64-MariaDB-1ubuntu0.14.04.1` port: `3306`

## Attack Surface Analysis

### Dynamic Pages & Entry Points

| URL                         | Method   | Parameters                                     | Authentication | Input Validation | Identified Vulnerabilities | Notes                                                  |
| --------------------------- | -------- | ---------------------------------------------- | -------------- | ---------------- | -------------------------- | ------------------------------------------------------ |
| `/index.php?page=signin`    | GET/POST | `page=signin`, `username`, `password`, `Login` | No             | Unknown          | No rate limiting           | Login page - test for auth bypass, brute force         |
| `/index.php?page=member`    | GET      | `page=member`, `id` (string)                   | No             | None             | SQL Injection              | Member profile area - injectable id parameter          |
| `/index.php?page=media`     | GET      | `page=media`, `src`                            | No             | -                | -                          | -                                                      |
| `/index.php?page=searchimg` | GET      | `page=searchimg`, `id` (string)                | No             | None             | SQL Injection              | Image search - injectable id parameter                 |
| `/index.php?page=survey`    | GET/POST | `page=survey`, form fields                     | Unknown        | Unknown          | Possible XSS               | Survey form - test all input fields for XSS            |
| `/index.php?page=upload`    | GET/POST | `page=upload`, `file`                          | No             | Extension (jpeg) | Unrestricted File Upload   | File upload - test extensions, MIME types, size limits |
| `/index.php?page=feedback`  | GET/POST | `page=feedback`, form fields                   | No             | Unknown          | Possible XSS/CSRF          | Feedback form - test all input fields for XSS/CSRF     |
| `/index.php?page=home`      | GET      | `page=home`                                    | No             | N/A              | -                          | Home page                                              |
| `/index.php`                | GET      | `page` (empty/invalid)                         | No             | Unknown          | Path Traversal, LFI        | Test page parameter with `../`, `null`, special chars. |

### Testing Priorities

1. **Critical**: SQL Injection on `member` and `searchimg` pages
2. **High**: File upload vulnerabilities, XSS on forms
3. **Medium**: Authentication bypass, CSRF on POST endpoints
4. **Low**: Path traversal via `page` parameter

### Common Attack Vectors to Test

- **SQL Injection**: `' OR '1'='1`, `UNION SELECT`, `1; DROP TABLE`
- **XSS**: `<script>alert(1)</script>`, `<img src=x onerror=alert(1)>`
- **Path Traversal**: `../../../../etc/passwd`, `....//....//`
- **Local File Inclusion (LFI)**: `php://filter/read=convert.base64-encode/resource=index`
- **File Upload**: `.php.jpg`, null byte injection, web shells
- **CSRF**: Missing tokens on state-changing operations

## Information Gathering

### Web Server FingerPrinting

https://owasp.org/www-project-web-security-testing-guide/v42/4-Web_Application_Security_Testing/01-Information_Gathering/02-Fingerprint_Web_Server

Web server fingerprinting is the process of identifying the web server software and version that is running on a target system. This information can be useful for identifying potential vulnerabilities and attack vectors.

#### Banner Grabbing

Banner grabbing is the process of connecting to a network service and reading the banner that is returned. Banners often contain information about the software version and other details that can be useful for identifying vulnerabilities.

Here:

- Server: `nginx/1.4.6 (Ubuntu)`
- PHP version: `5.5.9-1ubuntu4.29`

```http
GET /index.php HTTP/1.1
Host: localhost:8080
User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate, br, zstd
Referer: http://localhost:8080/index.php?page=signin
Connection: keep-alive
Upgrade-Insecure-Requests: 1
Sec-Fetch-Dest: document
Sec-Fetch-Mode: navigate
Sec-Fetch-Site: same-origin
Priority: u=0, i
Pragma: no-cache
Cache-Control: no-cache
```

```http
HTTP/1.1 200 OK
Server: nginx/1.4.6 (Ubuntu)
Date: Fri, 26 Sep 2025 10:45:16 GMT
Content-Type: text/html
Transfer-Encoding: chunked
Connection: keep-alive
X-Powered-By: PHP/5.5.9-1ubuntu4.29
Set-Cookie: I_am_admin=68934a3e9455fa72420237eb05902327; expires=Fri, 26-Sep-2025 11:45:16 GMT; Max-Age=3600
Content-Encoding: gzip
```

Remediation:

- Obscuring web server information in headers, such as with Apache’s mod_headers module.
- Using a hardened reverse proxy server to create an additional layer of security between the web server and the Internet.
- Ensuring that web servers are kept up-to-date with the latest software and security patches.

### WebServer Metafiles

https://owasp.org/www-project-web-security-testing-guide/v42/4-Web_Application_Security_Testing/01-Information_Gathering/03-Review_Webserver_Metafiles_for_Information_Leakage

#### Well Known Metafiles

- `robots.txt` : Instructions for web crawlers
- `sitemap.xml`: Guide for search engines to index the site
- `humans.txt`: Information about the people who built the site
- `favicon.ico`: The website's favicon
- `crossdomain.xml`: Security policy for cross-domain requests
- `ads.txt`: Authorized digital sellers
- `security.txt`: Security contact information
- Can also check for `.well-known/` directory

The list of well-known metafiles can be found at: https://www.iana.org/assignments/well-known-uris/well-known-uris.xhtml

```bash
curl localhost:8080/robots.txt
# User-agent: *
# Disallow: /whatever
# Disallow: /.hidden
```

- User-agent: \* indicates that the rules apply to all web crawlers.
- Disallow: /whatever tells web crawlers not to access the /whatever directory.
- Disallow: /.hidden tells web crawlers not to access the /.hidden directory.

To explore the hidden directory:

```bash
curl localhost:8080/.hidden/
```

```html
<html>
  <head>
    <title>Index of /.hidden/</title>
  </head>
  <body bgcolor="white">
    <h1>Index of /.hidden/</h1>
    <hr />
    <pre><a href="../">../</a>
<a href="amcbevgondgcrloowluziypjdh/">amcbevgondgcrloowluziypjdh/</a>                        29-Jun-2021 18:15                   -
<a href="bnqupesbgvhbcwqhcuynjolwkm/">bnqupesbgvhbcwqhcuynjolwkm/</a>                        29-Jun-2021 18:15                   -
<a href="ceicqljdddshxvnvdqzzjgddht/">ceicqljdddshxvnvdqzzjgddht/</a>                        29-Jun-2021 18:15                   -
<a href="doxelitrqvhegnhlhrkdgfizgj/">doxelitrqvhegnhlhrkdgfizgj/</a>                        29-Jun-2021 18:15                   -
<a href="eipmnwhetmpbhiuesykfhxmyhr/">eipmnwhetmpbhiuesykfhxmyhr/</a>                        29-Jun-2021 18:15                   -
<a href="ffpbexkomzbigheuwhbhbfzzrg/">ffpbexkomzbigheuwhbhbfzzrg/</a>                        29-Jun-2021 18:15                   -
<a href="ghouhyooppsmaizbmjhtncsvfz/">ghouhyooppsmaizbmjhtncsvfz/</a>                        29-Jun-2021 18:15                   -
<a href="hwlayeghtcotqdigxuigvjufqn/">hwlayeghtcotqdigxuigvjufqn/</a>                        29-Jun-2021 18:15                   -
<a href="isufpcgmngmrotmrjfjonpmkxu/">isufpcgmngmrotmrjfjonpmkxu/</a>                        29-Jun-2021 18:15                   -
<a href="jfiombdhvlwxrkmawgoruhbarp/">jfiombdhvlwxrkmawgoruhbarp/</a>                        29-Jun-2021 18:15                   -
<a href="kpibbgxjqnvrrcpczovjbvijmz/">kpibbgxjqnvrrcpczovjbvijmz/</a>                        29-Jun-2021 18:15                   -
<a href="ldtafmsxvvydthtgflzhadiozs/">ldtafmsxvvydthtgflzhadiozs/</a>                        29-Jun-2021 18:15                   -
<a href="mrucagbgcenowkjrlmmugvztuh/">mrucagbgcenowkjrlmmugvztuh/</a>                        29-Jun-2021 18:15                   -
<a href="ntyrhxjbtndcpjevzurlekwsxt/">ntyrhxjbtndcpjevzurlekwsxt/</a>                        29-Jun-2021 18:15                   -
<a href="oasstobmotwnezhscjjopenjxy/">oasstobmotwnezhscjjopenjxy/</a>                        29-Jun-2021 18:15                   -
<a href="ppjxigqiakcrmqfhotnncfqnqg/">ppjxigqiakcrmqfhotnncfqnqg/</a>                        29-Jun-2021 18:15                   -
<a href="qcwtnvtdfslnkvqvzhjsmsghfw/">qcwtnvtdfslnkvqvzhjsmsghfw/</a>                        29-Jun-2021 18:15                   -
<a href="rlnoyduccpqxkvcfiqpdikfpvx/">rlnoyduccpqxkvcfiqpdikfpvx/</a>                        29-Jun-2021 18:15                   -
<a href="sdnfntbyirzllbpctnnoruyjjc/">sdnfntbyirzllbpctnnoruyjjc/</a>                        29-Jun-2021 18:15                   -
<a href="trwjgrgmfnzarxiiwvwalyvanm/">trwjgrgmfnzarxiiwvwalyvanm/</a>                        29-Jun-2021 18:15                   -
<a href="urhkbrmupxbgdnntopklxskvom/">urhkbrmupxbgdnntopklxskvom/</a>                        29-Jun-2021 18:15                   -
<a href="viphietzoechsxwqacvpsodhaq/">viphietzoechsxwqacvpsodhaq/</a>                        29-Jun-2021 18:15                   -
<a href="whtccjokayshttvxycsvykxcfm/">whtccjokayshttvxycsvykxcfm/</a>                        29-Jun-2021 18:15                   -
<a href="xuwrcwjjrmndczfcrmwmhvkjnh/">xuwrcwjjrmndczfcrmwmhvkjnh/</a>                        29-Jun-2021 18:15                   -
<a href="yjxemfsgdlkbvvtjiylhdoaqkn/">yjxemfsgdlkbvvtjiylhdoaqkn/</a>                        29-Jun-2021 18:15                   -
<a href="zzfzjvjsupgzinctxeqtzzdzll/">zzfzjvjsupgzinctxeqtzzdzll/</a>                        29-Jun-2021 18:15                   -
<a href="README">README</a>                                             29-Jun-2021 18:15                  34
</pre>
    <hr />
  </body>
</html>
```

### Enumerate Application on Web Server

https://owasp.org/www-project-web-security-testing-guide/v42/4-Web_Application_Security_Testing/01-Information_Gathering/04-Enumerate_Applications_on_Webserver

Many applications can be related to a given dns name / ip address. These applications can be identified by searching for common application paths or by using automated tools to scan the web server.

To find applications on a ip address / dns name:

- Search different based URL paths:
  - `example.com/blog` for blogs applications, `example.com/forum` for forums, etc.
  - `/wp-admin` for WordPress
- Non standard ports:
  - `8080`, `8888`, etc.
- Virtual hosts:
  - `dev.example.com`, `test.example.com`, etc.

#### Search Based URL

- `http://localhost:8080/wp-admin/` gives custom 404 html page. Means WordPress is probably not installed.

#### Search Non Standard Ports

Find open ports with nmap:

```bash
nmap -p- localhost
```

```bash
nmap –Pn –sT –sV –p0-65535 localhost
# -Pn: Treat all hosts as online -- skip host discovery
# -sT: TCP connect scan
# -sV: Version detection
# -p0-65535: Scan all ports
```

```bash
# Works only if the port is open and port forwarding is setup correctly (here this port forwarding is done in VirtualBox NAT settings so it's not like a real scan)
# Here 8080 -> 80
#      8888 -> 443
#      2222 -> 22
#      3306 -> 3306
nmap -sV -p 8888,8080,2222,3306 --script=http-enum,http-title,http-methods,http-headers,banner localhost
# Starting Nmap 7.80 ( https://nmap.org ) at 2025-10-10 14:44 CEST
# Nmap scan report for localhost (127.0.0.1)
# Host is up (0.000055s latency).
#
# PORT     STATE  SERVICE    VERSION
# 2222/tcp open   tcpwrapped
# 3306/tcp closed mysql
# 8080/tcp open   http       nginx 1.4.6 (Ubuntu)
# | http-headers:
# |   Server: nginx/1.4.6 (Ubuntu)
# |   Date: Fri, 10 Oct 2025 12:44:16 GMT
# |   Content-Type: text/html
# |   Connection: close
# |   X-Powered-By: PHP/5.5.9-1ubuntu4.29
# |   Set-Cookie: I_am_admin=68934a3e9455fa72420237eb05902327; expires=Fri, 10-Oct-2025 13:44:16 GMT; Max-Age=3600
# |
# |_  (Request type: HEAD)
# | http-methods:
# |_  Supported Methods: GET HEAD POST
# |_http-server-header: nginx/1.4.6 (Ubuntu)
# |_http-title: BornToSec - Web Section
# 8888/tcp open   tcpwrapped
# Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
#
# Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
```

#### Search Virtual Hosts

Nmap script `http-vhosts` can be used to find virtual hosts:

```bash
nmap --script http-vhosts -p 8080 localhost
# Starting Nmap 7.80 ( https://nmap.org ) at 2025-10-10 18:08 CEST
# Nmap scan report for localhost (127.0.0.1)
# Host is up (0.000064s latency).
#
# PORT     STATE SERVICE
# 8080/tcp open  http-proxy
# | http-vhosts:
# |_127 names had status 200
#
# Nmap done: 1 IP address (1 host up) scanned in 0.17 seconds
```

Here the server is replying 200 for many hostnames, which often means the webserver is serving the same site regardless of the Host: header (or it’s configured with a catch-all vhost). That can hide and enable a number of issues (host-header attacks, cache poisoning, takeover opportunities, inadvertent disclosure of absolute URLs, etc.)

### Review Webpage Content for Information Leakage

https://owasp.org/www-project-web-security-testing-guide/v42/4-Web_Application_Security_Testing/01-Information_Gathering/05-Review_Webpage_Content_for_Information_Leakage

#### Search in HTML Comments

Comments in HTML can sometimes contain sensitive information that should not be exposed to users. It could be developer notes, credentials, or other information that could be useful to an attacker.

```html
<!--
    This is a comment that should not be here.
    Contact the webmaster at admin@localhost for more information.
    Do not share this information with anyone.
    Sensitive information: Password is 'P@ssw0rd!'
-->
```

```bash
# Scan HTML,JS for comments
nmap -sV -p 8080 --script http-comments-displayer localhost
# Nmap scan report for localhost (127.0.0.1)
# Host is up (0.00011s latency).
#
# PORT     STATE SERVICE VERSION
# 8080/tcp open  http    nginx 1.4.6 (Ubuntu)
# | http-comments-displayer:
# | Spidering limited to: maxdepth=3; maxpagecount=20; withinhost=localhost
# |
# |     Path: http://localhost:8080/css/style.css
# |     Line number: 498
# |     Comment:
# |         /* Image */
# |
# |     Path: http://localhost:8080/css/skel.css
# |     Line number: 97
# |     Comment:
# |         /* margin: -(gutters.horizontal) 0 -1px -(gutters.vertical) */
# |
# |     Path: http://localhost:8080/?page=b7e44c7a40c5f80139f0a50f3650fb2bd8d00b0d24667c4c2ca32c88e13b758f
# |     Line number: 520
# |     Comment:
# |         <!--
# |         You must come from : "https://www.nsa.gov/".
# |         -->
# |
# ...
```

#### Identify Application Entry Points

https://owasp.org/www-project-web-security-testing-guide/v42/4-Web_Application_Security_Testing/01-Information_Gathering/06-Identify_Application_Entry_Points

Entry points are the various ways that users can interact with a web application. This can include forms, search fields, file upload fields, and other input fields.

To identify application entry points, you can use a variety of tools and techniques, including:

- Manual testing: Manually explore the web application and look for input fields and forms.
- Automated tools: Use tools like Burp Suite, OWASP ZAP, or Nikto to scan the web application for input fields and forms.
- Source code review: If you have access to the source code, review it for input fields and forms.

Once you have identified the entry points, you can then test them for vulnerabilities such as SQL injection, cross-site scripting (XSS), and file inclusion vulnerabilities.

Making a spreadsheet to track the entry points and their parameters can be very useful for organizing your testing efforts.
