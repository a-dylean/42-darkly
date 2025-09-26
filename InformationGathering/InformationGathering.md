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
