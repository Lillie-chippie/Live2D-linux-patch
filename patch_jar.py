import sys
import os

if len(sys.argv) < 2:
    print("Usage: python3 patch_jar.py <path_to_class_file>")
    sys.exit(1)

file_path = sys.argv[1]

if not os.path.exists(file_path):
    print(f"File not found: {file_path}")
    sys.exit(1)

with open(file_path, "rb") as f:
    data = f.read()

# Target: tag(1) + len(2) + "Windows"
# We replace "Windows" with "Linux  " (padding with spaces to keep length same)
target = b"\x01\x00\x07Windows"
replacement = b"\x01\x00\x07Linux  "

count = data.count(target)
print(f"Found {count} occurrences of 'Windows'")

if count > 0:
    new_data = data.replace(target, replacement)
    with open(file_path, "wb") as f:
        f.write(new_data)
    print(f"Successfully patched {file_path}")
else:
    print("Target string 'Windows' not found. File might already be patched.")
