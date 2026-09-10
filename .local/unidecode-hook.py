#!/usr/bin/env python

# Copyright 2026 Cloudera, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
import sys
import argparse

from unidecode import unidecode


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--to-ascii", action="store_true")
    parser.add_argument("filenames", nargs="*", help="Files to check")
    args = parser.parse_args()

    # Use filenames from args, or stdin if none provided
    filenames = (
        args.filenames
        if args.filenames
        else [line.strip() for line in sys.stdin if line.strip()]
    )

    for filename in filenames:
        with open(filename, "r", encoding="utf-8") as f:
            content = f.read()
            if args.to_ascii:
                ascii_content = unidecode(content)
                if ascii_content != content:
                    print(f"Converted non-ASCII characters in {filename}")
                    with open(filename, "w", encoding="utf-8") as out_f:
                        out_f.write(ascii_content)
                    sys.exit(1)
            else:
                if any(ord(c) > 127 for c in content):
                    print(
                        f"Error: {filename} contains non-ASCII characters. Use --to-ascii to convert or fix manually.",
                    )
                    sys.exit(1)
    sys.exit(0)


if __name__ == "__main__":
    main()
