from pathlib import Path
import os

base_path = Path(os.environ["BASE_PATH"]).resolve()
analyzer_output = Path(os.environ["OUTDIR"]).resolve()
post_output = Path(os.environ["OUTDIR"]).resolve()
commit=os.environ["GIT_COMMIT"]

