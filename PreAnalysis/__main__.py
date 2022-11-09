import sys
from pathlib import Path
import importlib.util
from .validation_sys import runOneFile


def loadConfiguration(path):
    spec = importlib.util.spec_from_file_location("pre_conf", path)
    config = importlib.util.module_from_spec(spec)
    sys.modules["pre_conf"] = config
    spec.loader.exec_module(config)
    return config

config = loadConfiguration(Path(sys.argv[1]).resolve())
result = True
for validation_step in config.validation_steps:
    result = result and runOneFile(validation_step)




