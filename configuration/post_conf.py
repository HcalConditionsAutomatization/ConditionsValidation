import os
from pathlib import Path

trigger_abnormality_threshold=0.05

base_path = Path(os.environ["BASE_PATH"]).resolve()
analyzer_output = Path(os.environ["OUTDIR"]).resolve()
post_output = Path(os.environ["OUTDIR"]).resolve()
scratch = Path(os.environ["SCRATCH_DIR"]).resolve()
#commit=os.environ["GIT_COMMIT"]
CMSSWl1=os.environ["CMSSW_L1"]
#DATASETraw=os.environ["DATASET"]
#L1RUN=os.environ["L1RUN"]
#GT=os.environ["GT"]
#NTAGS=os.environ["nTags"]
#NEWTAGS=os.environ["NEWTAG"]

trigger_changes = { 
        "L1\_SingleJet180" : ("singleJetRates_emu", 170,190),
        "L1\_HTT200\_SingleLLPJet60" : ("singleJetLLP_HTT200Rates_emu", 50,70),
        "L1\_METHF90" : ("metHFSumRates_emu", 80,100),
        "L1\_HTT360" : ("htSumRates_emu", 350,370),
        "L1\_DoubleIsoTau34" : ("doubleTauRates_emu", 32,36),
        "L1\_SingleEG36" : ("singleEgRates_emu", 34,38),
	"L1\_SingleIsoEG30" : ("singleISOEgRates_emu", 28,32),
        }

plots = [ 
        ["EG Rates", "Inclusive/egRates_emu.pdf", "EG Rates"],
        ["Jet Rates", "Inclusive/jetRates_emu.pdf", "Jet rates"],
        ["Jet Rates HB", "HB/jetRates_emu.pdf", "Jet rates"],
        ["Jet Rates HE1", "HE1/jetRates_emu.pdf", "Jet rates"],
        ["Jet Rates HE2", "HE2/jetRates_emu.pdf", "Jet rates"],
        ["Jet Rates HF", "HF/jetRates_emu.pdf", "Jet rates"],
        ["Tau Rates", "Inclusive/tauRates_emu.pdf", "Tau rates"],
        ["Scalar Sum Rates", "Inclusive/scalarSumRates_emu.pdf", "Scalar rates"],
        ["Vector Sum Rates", "Inclusive/vectorSumRates_emu.pdf", "Vector rates"],
        ["LLP Jet Rates", "Inclusive/jetllpRates_emu.pdf", "LLP Jet rates"]
        ]
