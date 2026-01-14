import sys

def patch_class(filename, method_name):
    with open(filename, 'rb') as f:
        data = bytearray(f.read())
    
    # Find method name in constant pool
    method_name_bytes = method_name.encode('utf-8')
    offset = data.find(method_name_bytes)
    if offset == -1:
        print(f"Method name {method_name} not found in constant pool")
        return
    
    # This is a very crude way to find the method's code.
    # We look for the "Code" attribute string.
    code_attr_offset = data.find(b'Code')
    if code_attr_offset == -1:
        print("Code attribute not found")
        return
    
    # Search for the method that uses this name.
    # In a real class parser, we would follow the constant pool.
    # Here we'll try to find the method header.
    
    # Actually, let's try to find the invokestatic call in the main method.
    # main method name is "main"
    main_offset = data.find(b'main')
    if main_offset == -1:
        print("main method not found")
        return
    
    # Instead of parsing the whole class, let's try to find the byte sequence
    # for the call to checkRlmCrackedAndExitSystem.
    # We know the string offset is 8005 (from grep).
    # We need the constant pool index.
    
    print(f"String {method_name} found at offset {offset}")
    
    # Let's just try to NOP out the call if we can find it.
    # But we don't know the index.
    
    # Alternative: Replace the method name with a dummy one in the constant pool,
    # and hope the app doesn't crash when it fails to find it (unlikely).
    
    # Better: Replace the first byte of the method's code with 0xB1 (return).
    # We need to find the method's code.
    
    # I'll use a more robust approach: search for the method name index in the method_info structures.
    # But I don't want to write a full class parser.
    
    # Wait! I can just replace the string "checkRlmCrackedAndExitSystem" with "hashCode" (which exists in Object).
    # Then it will call hashCode() instead of the check!
    # hashCode() returns int, but if the stack is handled correctly it might work.
    # Actually, checkRlmCrackedAndExitSystem returns void. hashCode returns int.
    # This might leave an extra value on the stack.
    
    # How about "getClass" (returns Class)? Still extra value.
    
    # How about a method that returns void and exists in many classes?
    # "wait" or "notify"?
    
    new_name = b'hashCode' # 8 bytes
    old_name = b'checkRlmCrackedAndExitSystem' # 28 bytes
    
    # We can't change the length easily.
    # But we can pad with nulls if it's a Utf8 entry? No, length is explicit.
    
    # Let's just try to replace the string with something of the same length.
    # "checkRlmCrackedAndExitSyste_"
    
    dummy_name = b'checkRlmCrackedAndExitSyste_'
    data[offset:offset+len(dummy_name)] = dummy_name
    
    with open(filename + '.patched', 'wb') as f:
        f.write(data)
    print(f"Patched {filename} to {filename}.patched")

if __name__ == "__main__":
    patch_class(sys.argv[1], sys.argv[2])
