from .texmaker import TexMaker
import os
from pathlib import Path
from ..rate_ratio import getRatio



rate_csv_path="rates/changes.csv"

changes = { 
        "L1\_SingleEG36" : ("singleEgRates_emu", 34,38),
        "L1\_SingleJet180" : ("singleJetRates_emu", 170,190),
        "L1\_DoubleIsoTau34" : ("doubleTauRates_emu", 32,36),
        #"L1_HTT360" : ("htSumRates_emu", 350,370)
        }



if __name__ == "__main__":
    outdir=Path(os.environ["OUTDIR"])
    old_rates=(outdir/"rates"/"rates_def.root").resolve()
    new_rates=(outdir/"rates"/"rates_new_cond.root").resolve()

    rate_changes= [[ trigger, round(getRatio(new_rates,old_rates,r[0], r[1], r[2]),3) ] 
            for trigger, r in changes.items()]


    tm = TexMaker("../scratch","Tools/PresentationTools/templates/outline.tex", outdir) 
    tm.preparation()
    tm.renderTemplate({
        "triggerchanges": rate_changes,
        "images" : [
            ]
        })
    tm.compile()



