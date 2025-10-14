# Webpage Content for Information Leakage

https://owasp.org/www-project-web-security-testing-guide/v42/4-Web_Application_Security_Testing/01-Information_Gathering/05-Review_Webpage_Content_for_Information_Leakage

## Search in HTML Comments

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

Get the page containing the potential sensitive information:

```bash
curl -v -L -H "Referer: https://www.nsa.gov/" http://localhost:8080/\?page\=b7e44c7a40c5f80139f0a50f3650fb2bd8d00b0d24667c4c2ca32c88e13b758f -o commented_page_ref.html

curl -v -L http://localhost:8080/\?page\=b7e44c7a40c5f80139f0a50f3650fb2bd8d00b0d24667c4c2ca32c88e13b758f -o commented_page_no_ref.html
```

Diff the output when referer header (come from ...) with no referer:

```bash
diff -u commented_page_no_ref.html commented_page_ref.html
```

```html
--- commented_page_no_ref.html        2025-10-14 12:02:03.013157405 +0200
+++ commented_page_ref.html   2025-10-14 12:01:44.436965495 +0200
@@ -34,7 +34,7 @@
                <!-- Main -->
                        <section id="main" class="wrapper">
                                <div class="container" style="margin-top:75px">
-<audio id="best_music_ever" src="audio/music.mp3"preload="true" loop="loop" autoplay="autoplay">
+FIRST STEP DONE<audio id="best_music_ever" src="audio/music.mp3"preload="true" loop="loop" autoplay="autoplay">
 </audio>
 <script language="javascript">function coucou(){document.getElementById('best_music_ever').play();}</script>
```

The is a new msg `+FIRST STEP DONE` displayed.

