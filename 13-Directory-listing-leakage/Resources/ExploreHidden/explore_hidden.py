"""
This program explores the URL directory and all subdirectories until it finds a token or flag
"""

import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse
import time
import re
from collections import deque
import sys


class DirectoryExplorer:
    def __init__(self, base_url, file_max=200000, delay=0.1):
        self.base_url = base_url
        self.file_count = 0
        self.file_max = file_max
        self.delay = delay
        self.session = requests.Session()
        self.session.timeout = 10
        self.visited_urls = set()
        self.found_flags = []

        # Patterns that might indicate flags or tokens
        self.flag_patterns = [
            r'flag\{[^}]+\}',
            r'[a-f0-9]{32,}',  # MD5/SHA hashes
            r'[A-Za-z0-9+/]{20,}={0,2}',  # Base64-like
            r'token[:\s]*[a-zA-Z0-9]+',
        ]

    def is_valid_url(self, url):
        """Check if URL is within our target domain"""
        parsed_base = urlparse(self.base_url)
        parsed_url = urlparse(url)
        return (parsed_url.netloc == parsed_base.netloc or
                parsed_url.netloc == '' or
                url.startswith(self.base_url))

    def make_request(self, url):
        """Make HTTP request with error handling"""
        try:
            print(f"[{self.file_count}/{self.file_max}] Exploring: {url}")
            response = self.session.get(url)
            # time.sleep(self.delay)  # Be polite to the server
            return response
        except requests.RequestException as e:
            print(f"Error accessing {url}: {e}")
            return None

    def extract_links(self, html_content, base_url):
        """Extract links from HTML content"""
        links = []
        try:
            soup = BeautifulSoup(html_content, 'html.parser')

            # Find all anchor tags
            for link in soup.find_all('a', href=True):
                href = link['href']

                # Skip parent directory links and anchors
                if href in ['../', '../', '#']:
                    continue

                # Convert relative URLs to absolute
                full_url = urljoin(base_url, href)

                if self.is_valid_url(full_url):
                    links.append(full_url)

        except Exception as e:
            print(f"Error parsing HTML: {e}")

        return links

    def check_for_flags(self, content, url):
        """Check content for flag patterns"""
        flags_found = []

        for pattern in self.flag_patterns:
            matches = re.findall(pattern, content, re.IGNORECASE)
            for match in matches:
                flag_info = {
                    'url': url,
                    'flag': match,
                    'pattern': pattern
                }
                flags_found.append(flag_info)
                print(f"🚩 FLAG FOUND at {url}: {match}")

        return flags_found

    def is_directory_listing(self, content):
        """Determine if content looks like a directory listing"""
        indicators = [
            'Index of',
            'Directory listing',
            '<title>Index of',
            'Parent Directory',
            '[DIR]',
            'folder.gif'
        ]

        content_lower = content.lower()
        return any(indicator.lower() in content_lower for indicator in indicators)

    def explore_url(self, url):
        """Explore a single URL"""
        if url in self.visited_urls or self.file_count >= self.file_max:
            return []

        self.visited_urls.add(url)
        self.file_count += 1

        response = self.make_request(url)
        if not response:
            return []

        new_urls = []

        # Check response status
        if response.status_code == 200:
            content = response.text

            # If it's a directory listing, extract more URLs to explore
            if self.is_directory_listing(content):
                links = self.extract_links(content, url)
                new_urls.extend(links)
                print(f"Found {len(links)} links in directory: {url}")
            else:
                # This is a file - check its content for flags
                print(
                    f"Checking file content at {url} (size: {len(content)} bytes)")
                flags = self.check_for_flags(content, url)
                self.found_flags.extend(flags)

                # Show a preview of the content if it's not too long
                if len(content.strip()) > 0:
                    preview = content.strip()[:200]
                    if len(content.strip()) > 200:
                        preview += "..."
                    print(f"Content preview: {preview}")

        elif response.status_code == 403:
            print(f"Access denied: {url}")
        elif response.status_code == 404:
            print(f"Not found: {url}")
        else:
            print(f"Status {response.status_code}: {url}")

        return new_urls

    def explore_breadth_first(self):
        """Explore directories using breadth-first search"""
        queue = deque([self.base_url])

        print(f"Starting exploration of: {self.base_url}")
        print(f"File limit: {self.file_max}")
        print("=" * 50)

        while queue and self.file_count < self.file_max:
            current_url = queue.popleft()
            new_urls = self.explore_url(current_url)

            # Add new URLs to queue
            for url in new_urls:
                if url not in self.visited_urls:
                    queue.append(url)

        print("=" * 50)
        print("Exploration complete!")
        print(f"Total URLs explored: {self.file_count}")
        print(f"Flags found: {len(self.found_flags)}")

        if self.found_flags:
            print("\n🚩 FLAGS DISCOVERED:")
            for i, flag in enumerate(self.found_flags, 1):
                print(f"{i}. URL: {flag['url']}")
                print(f"   Flag: {flag['flag']}")
                print(f"   Pattern: {flag['pattern']}")
                print()


def main():
    # Configuration
    base_url = 'http://localhost:8080/.hidden/'
    file_max = 200000000
    delay = 0  # Delay between requests in seconds

    # Create and run explorer
    explorer = DirectoryExplorer(base_url, file_max, delay)

    try:
        explorer.explore_breadth_first()
    except KeyboardInterrupt:
        print("\nExploration interrupted by user")
        print(f"Explored {explorer.file_count} URLs so far")
        if explorer.found_flags:
            print(f"Found {len(explorer.found_flags)} flags")


if __name__ == "__main__":
    main()
