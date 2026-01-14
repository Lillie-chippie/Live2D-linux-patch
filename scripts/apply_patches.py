import zipfile
import os
import shutil

JAR_PATH = "../app/lib/Live2D_Cubism.jar"
BACKUP_PATH = "../app/lib/Live2D_Cubism.jar.bak"
PATCH_FILES_DIR = "patch_files"

# Patch Definitions
PATCHES = [
    {
        "file": "com/live2d/cubism/CECubismEditorApp.class",
        "offset": 0x35fc,
        "expected": b'\x03', # iconst_0
        "new": b'\x04',      # iconst_1
        "desc": "RLM Hash Check Bypass (iconst_0 -> iconst_1)"
    }
]

INJECT_FILES = [
    {
        "source": "f.class",
        "target": "com/live2d/c/f.class",
        "desc": "License Directory Fix (f.class)"
    }
]

def apply_patches():
    if not os.path.exists(JAR_PATH):
        print(f"Error: JAR not found at {JAR_PATH}")
        return

    # Backup
    if not os.path.exists(BACKUP_PATH):
        print(f"Creating backup at {BACKUP_PATH}")
        shutil.copy2(JAR_PATH, BACKUP_PATH)
    else:
        print(f"Backup already exists at {BACKUP_PATH}, using it as source to ensure clean state.")
        shutil.copy2(BACKUP_PATH, JAR_PATH)

    print(f"Opening {JAR_PATH}...")
    
    # Create a temp jar
    TEMP_JAR = JAR_PATH + ".tmp"
    
    with zipfile.ZipFile(JAR_PATH, 'r') as zin:
        with zipfile.ZipFile(TEMP_JAR, 'w') as zout:
            # Copy all files, patching the targets
            for item in zin.infolist():
                # Check if this file is being replaced completely
                replaced = False
                for inject in INJECT_FILES:
                    if item.filename == inject["target"]:
                        print(f"Injecting {inject['target']} ({inject['desc']})...")
                        source_path = os.path.join(PATCH_FILES_DIR, inject["source"])
                        if os.path.exists(source_path):
                            with open(source_path, "rb") as f:
                                zout.writestr(item.filename, f.read())
                            replaced = True
                        else:
                            print(f"  Error: Source file {source_path} not found!")
                        break
                
                if replaced:
                    continue

                # Skip signature files
                if item.filename.startswith("META-INF/") and (item.filename.endswith(".SF") or item.filename.endswith(".RSA") or item.filename.endswith(".DSA")):
                    print(f"Skipping signature file: {item.filename}")
                    continue

                data = zin.read(item.filename)
                
                # Strip digests from MANIFEST.MF
                if item.filename == "META-INF/MANIFEST.MF":
                    print("Cleaning MANIFEST.MF...")
                    manifest_lines = data.decode('utf-8').splitlines()
                    clean_lines = []
                    skip = False
                    for line in manifest_lines:
                        # Skip digest lines and their continuations
                        if "Digest:" in line:
                            skip = True
                            continue
                        if skip and line.startswith(" "):
                            continue
                        skip = False
                        clean_lines.append(line)
                    
                    # Remove empty sections (Name: ... followed immediately by another Name: or end)
                    # Actually, simpler approach: Just keep Main-Class and other global headers.
                    # But we want to keep other metadata if possible.
                    # The previous sed approach was: delete from first "Name:" to end.
                    # Let's do that: stop at first "Name:"
                    final_lines = []
                    for line in clean_lines:
                        if line.startswith("Name:"):
                            break
                        final_lines.append(line)
                    
                    data = "\n".join(final_lines).encode('utf-8') + b"\n"

                # Check if this file needs bytecode patching
                for patch in PATCHES:
                    if item.filename == patch["file"]:
                        print(f"Patching {item.filename}: {patch['desc']}")
                        
                        mutable_data = bytearray(data)
                        offset = patch["offset"]
                        expected = patch["expected"]
                        actual = mutable_data[offset : offset + len(expected)]
                        
                        if actual == expected:
                            new_bytes = patch["new"]
                            mutable_data[offset : offset + len(new_bytes)] = new_bytes
                            data = bytes(mutable_data)
                            print("  -> Success")
                        elif actual == patch["new"]:
                             print("  -> Already patched")
                        else:
                            print(f"  -> FAILED verification! Expected {expected.hex()} but found {actual.hex()} at offset {offset}")
                
                zout.writestr(item, data)

    # Replace original
    shutil.move(TEMP_JAR, JAR_PATH)
    print("Done.")

if __name__ == "__main__":
    apply_patches()
