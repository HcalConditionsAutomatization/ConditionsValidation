from .texmaker import TexMaker
import os
from pathlib import Path
from .rate_ratio import getRatio
import PostAnalysis.paths as paths

import importlib.util
import sys

def loadConfiguration(path):
    spec = importlib.util.spec_from_file_location("configuration", path)
    config = importlib.util.module_from_spec(spec)
    sys.modules["configuration"] = config
    spec.loader.exec_module(config)
    return config


rate_csv_path="rates/changes.csv"


if __name__ == "__main__":
    config = loadConfiguration(Path(sys.argv[1]).resolve())
    changes = config.trigger_changes
    plots = config.plots
    plots = [ [t, (paths.analyzer_output/ p).resolve(), d] for t, p, d in plots]


    old_rates=(paths.analyzer_output/"rates"/"rates_def.root").resolve()
    new_rates=(paths.analyzer_output/"rates"/"rates_new_cond.root").resolve()

    rate_changes= [[ trigger, round(getRatio(new_rates,old_rates,r[0], r[1], r[2]),3) ] 
            for trigger, r in changes.items()]

    overview_template = (Path(__file__).parent / "templates/outline.tex").resolve()
    tm = TexMaker("../scratch",overview_template, paths.post_output )
    tm.outFileName = "overview.pdf"
    tm.preparation()
    tm.renderTemplate({
        "triggerchanges": rate_changes,
        "images" :  plots
        })
    tm.compile()



