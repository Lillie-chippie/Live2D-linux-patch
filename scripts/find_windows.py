import zipfile
import os

JAR_PATH = "../app/lib/Live2D_Cubism.jar"

def find_windows():
    if not os.path.exists(JAR_PATH):
        print(f"Error: JAR not found at {JAR_PATH}")
        return

    print(f"Searching for 'Windows' in {JAR_PATH}...")
    
    with zipfile.ZipFile(JAR_PATH, 'r') as zin:
        data = zin.read("com/live2d/c/f.class")
        
        # Search for "Windows" string
        # In constant pool, it's prefixed by length. "Windows" is 7 bytes.
        # \x07Windows
        target = b'\x07Windows'
        offset = data.find(target)
        
        if offset != -1:
            print(f"Found 'Windows' string at offset {offset} (0x{offset:x})")
            
            # Now find where this constant is used.
            # We need the constant pool index.
            # This is hard without parsing.
            # But we can search for the LDC instruction that loads this string.
            # LDC is 0x12 (byte index) or 0x13 (short index).
            # We don't know the index.
            
            # Alternative: Search for the "Linux" check I found earlier, and look BEFORE it.
            # Linux check was at 0x1ab3.
            # Let's dump 100 bytes BEFORE 0x1ab3.
            
            check_offset = 0x1ab3
            start = max(0, check_offset - 200)
            end = check_offset
            
            chunk = data[start:end]
            print(f"\nContext before Linux check (Offset {start} to {end}):")
            print(chunk.hex())
            
        else:
            print("String 'Windows' not found!")

if __name__ == "__main__":
    find_windows()
