# Run this on your file to see what the raw bytes look like
with open('as\DoAction.as', 'rb') as f:
    raw = f.read(200)
print(raw)
# Then try decoding manually:
print(raw.decode('utf-8'))       # if this looks right → file is UTF-8
print(raw.decode('latin-1'))     # if this looks right → file is Latin-1