@echo off
pushd "%~dp0"

python -m stats-conv.py mpv.stats

popd
