import sys
from pathlib import Path
import importlib.util
from .make_overview import makeOverviewSlides


def loadConfiguration(path):
    spec = importlib.util.spec_from_file_location("configuration", path)
    config = importlib.util.module_from_spec(spec)
    sys.modules["configuration"] = config
    spec.loader.exec_module(config)
    return config

config = loadConfiguration(Path(sys.argv[1]).resolve())
makeOverviewSlides(config)


