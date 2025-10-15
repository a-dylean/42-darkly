Hey, here is your flag : d5eec3ec36cf80dce44a896f961c1831a05526ec215693c8f2c39543497d4466

## Remediation

- Prevent directory listing by disabling it in the web server configuration. For Apache, this can be done by setting `Options -Indexes` in the appropriate configuration file or `.htaccess` file.
- Implement proper access controls to restrict access to sensitive directories and files.
- Regularly audit the web server configuration to ensure that directory listing is disabled and that no sensitive information is exposed.

## Directory listing leakage

Directory listing leakage occurs when a web server is configured to allow users to view the contents of a directory when there is no index file (like `index.html` or `index.php`) present. This can expose sensitive files and information that should not be publicly accessible.

## Exploitation

### Well Known Metafiles

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

### Brute forcing directories and files

Little python script to brute force directories with BeautifulSoup and requests.

```bash
cd ExploreHidden
./search.sh
```
