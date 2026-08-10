from pathlib import Path

src = Path(
    r"C:\Users\Sonali\.cursor\projects\c-Users-Sonali-Desktop-herSync\assets"
    r"\c__Users_Sonali_AppData_Roaming_Cursor_User_workspaceStorage_0990d949185405bc32283191a90e4d80"
    r"_images_file_00000000205c8207a2bbfc62f9740264__1_-removebg-preview-6a60de7b-5c25-4126-9e02-03dad21bbfff.png"
)
dst = Path(r"c:\Users\Sonali\Desktop\herSync\assets\images\1000062542.png")

try:
    data = src.read_bytes()
    dst.write_bytes(data)
    print(f"OK wrote {len(data)} bytes to {dst}")
except Exception as e:
    print(f"read_bytes failed: {e}")
    for p in Path(r"C:\Users\Sonali\.cursor\projects\c-Users-Sonali-Desktop-herSync").rglob("*removebg*.png"):
        try:
            data = p.read_bytes()
            dst.write_bytes(data)
            print(f"OK wrote {len(data)} bytes from {p.name}")
            break
        except Exception as err:
            print(f"failed {p}: {err}")
