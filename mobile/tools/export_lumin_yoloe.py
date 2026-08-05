import subprocess
import sys
from pathlib import Path
from shutil import copy2

from ultralytics import YOLOE


root_path = Path(__file__).resolve().parents[1]
subprocess.run(
    [sys.executable, str(root_path / "tools" / "sync_lumin_vocabulary.py")],
    check=True,
)
classes_path = root_path / "assets" / "models" / "lumin_yoloe_classes.txt"
models_path = root_path / "assets" / "models"
export_name = "lumin_yoloe_26n_seg"
classes = [
    line.strip()
    for line in classes_path.read_text(encoding="utf-8").splitlines()
    if line.strip()
]

models_path.mkdir(parents=True, exist_ok=True)

model = YOLOE("yoloe-26n-seg.pt")
model.set_classes(classes)
model.model.eval()
exported_path = Path(
    model.export(format="litert", imgsz=640, nms=False, end2end=False)
)
target_path = models_path / f"{export_name}.tflite"
copy2(exported_path, target_path)
print(target_path)
