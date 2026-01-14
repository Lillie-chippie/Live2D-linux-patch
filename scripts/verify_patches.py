import zipfile
import os

JAR_PATH = "../app/lib/Live2D_Cubism.jar"

PATCHES = [
    {
        "file": "com/live2d/cubism/CECubismEditorApp.class",
        "offset": 0x35fc,
        "expected": b'\x04', # We expect the PATCHED value
        "desc": "Bypass RLM Hash Check"
    },
    {
        "file": "com/live2d/c/f.class",
        "offset": 6835,
        "expected": b'\x9c\x00\x17', # We expect the PATCHED value
        "desc": "Fix License Directory Resolution"
    }
]

def verify():
    if not os.path.exists(JAR_PATH):
        print(f"Error: JAR not found at {JAR_PATH}")
        return

    print(f"Verifying {JAR_PATH}...")
    
    with zipfile.ZipFile(JAR_PATH, 'r') as zin:
        for patch in PATCHES:
            try:
                data = zin.read(patch["file"])
                offset = patch["offset"]
                expected = patch["expected"]
                actual = data[offset : offset + len(expected)]
                
                if actual == expected:
                    print(f"[OK] {patch['desc']}: Found {actual.hex()}")
                else:
                    print(f"[FAIL] {patch['desc']}: Found {actual.hex()}, expected {expected.hex()}")
            except KeyError:
                print(f"[FAIL] File {patch['file']} not found in JAR")

if __name__ == "__main__":
    verify()
