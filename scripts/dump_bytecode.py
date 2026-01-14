import zipfile
import os

JAR_PATH = "../app/lib/Live2D_Cubism.jar"

PATCHES = [
    {
        "file": "com/live2d/cubism/CECubismEditorApp.class",
        "offset": 0x35fc,
        "desc": "Bypass RLM Hash Check"
    },
    {
        "file": "com/live2d/c/f.class",
        "offset": 6835,
        "desc": "Fix License Directory Resolution"
    }
]

def dump_bytes():
    if not os.path.exists(JAR_PATH):
        print(f"Error: JAR not found at {JAR_PATH}")
        return

    print(f"Dumping bytecode from {JAR_PATH}...")
    
    with zipfile.ZipFile(JAR_PATH, 'r') as zin:
        for patch in PATCHES:
            try:
                data = zin.read(patch["file"])
                offset = patch["offset"]
                
                start = max(0, offset - 20)
                end = min(len(data), offset + 60)
                
                chunk = data[start:end]
                
                print(f"\n--- {patch['desc']} ---")
                print(f"File: {patch['file']}")
                print(f"Offset: {offset} (0x{offset:x})")
                print(f"Context (Offset {start} to {end}):")
                
                # Print hex and ascii
                hex_str = chunk.hex()
                # Group by 2 chars
                hex_pairs = [hex_str[i:i+2] for i in range(0, len(hex_str), 2)]
                
                # Mark the patch byte
                rel_offset = offset - start
                hex_pairs[rel_offset] = f"[{hex_pairs[rel_offset]}]"
                
                print(" ".join(hex_pairs))
                
            except KeyError:
                print(f"[FAIL] File {patch['file']} not found in JAR")

if __name__ == "__main__":
    dump_bytes()
