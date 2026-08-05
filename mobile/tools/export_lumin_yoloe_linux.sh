#!/usr/bin/env bash
set -euo pipefail

export HOME="/workspace/mobile/.export-home"
export YOLO_CONFIG_DIR="/workspace/mobile/.export-home/ultralytics"
export MPLCONFIGDIR="/workspace/mobile/.export-home/matplotlib"
export PIP_CACHE_DIR="/workspace/mobile/.export-home/pip"

mkdir -p "$HOME" "$YOLO_CONFIG_DIR" "$MPLCONFIGDIR" "$PIP_CACHE_DIR"

apt-get update
apt-get install -y git
python -m pip install --upgrade pip
python -m pip install --index-url https://download.pytorch.org/whl/cpu torch torchvision
python -m pip install "ultralytics-opencv-headless[export-litert]>=8.4.83"
python tools/export_lumin_yoloe.py
