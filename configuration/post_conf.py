import os
from pathlib import Path

trigger_abnormality_threshold=0.05

base_path = Path(os.environ["BASE_PATH"]).resolve()
analyzer_output = Path(os.environ["OUTDIR"]).resolve()
post_output = Path(os.environ["OUTDIR"]).resolve()
scratch = Path(os.environ["SCRATCH_DIR"]).resolve()
commit=os.environ["GIT_COMMIT"]

trigger_changes = { 
        "L1\_SingleEG36" : ("singleEgRates_emu", 34,38),
        "L1\_SingleJet180" : ("singleJetRates_emu", 170,190),
        "L1\_DoubleIsoTau34" : ("doubleTauRates_emu", 32,36),
        #"L1_HTT360" : ("htSumRates_emu", 350,370)
        }

plots = [ 
        ["EG Rates", "plots/egRates_emu.pdf", "EG Rates"],
        ["Jet Rates", "plots/jetRates_emu.pdf", "Jet rates"],
        ["Tau Rates", "plots/tauRates_emu.pdf", "Tau rates"],
        ["Scalar Sum Rates", "plots/scalarSumRates_emu.pdf", "Scalar rates"],
        ["Vector Sum Rates", "plots/vectorSumRates_emu.pdf", "Vector rates"]
        ]