from .texmaker import TexMaker
import os
from pathlib import Path
from .rate_ratio import getRatio




def makeOverviewSlides(config):
    changes = config.trigger_changes
    plots = config.plots
    plots = [ [t, (config.analyzer_output/"plots"/ p).resolve(), d] for t, p, d in plots]


    old_rates=(config.analyzer_output/"plots"/"Inclusive"/"rates_def.root").resolve()
    new_rates=(config.analyzer_output/"plots"/"Inclusive"/"rates_new_cond.root").resolve()
#    git_commit = config.commit.strip()
#    cmsswl1 = config.CMSSWl1.strip()
#    dataset = config.DATASETraw.strip()
#    l1run = config.L1RUN.strip()
#    gt = config.GT.strip()
#    ntags = config.NTAGS.strip()
#    newtags = config.NEWTAGS.strip()

    rate_changes= [[ trigger, round(getRatio(new_rates,old_rates,r[0], r[1], r[2]),3) ] 
            for trigger, r in changes.items()]


    anomalous_changes=[ [t,c] for t,c in rate_changes if abs(c-1.0) > config.trigger_abnormality_threshold]
    max_change = round(max([100*abs(c-1.0) for t,c in rate_changes]),2)

    overview_template = (Path(__file__).parent / "templates/outline.tex").resolve()
    tm = TexMaker(config.scratch ,overview_template, config.post_output )
    tm.outFileName = "overview.pdf"
    tm.preparation()
    tm.renderTemplate({
        "triggerchanges": rate_changes,
        "images" :  plots,
        "max_change" : max_change,
        "bad_changes": anomalous_changes,
#        "commit" : git_commit,
#        "cmsswl1" : cmsswl1,
#        "dataset" : dataset,
#        "l1run" : l1run,
#        "gt" : gt,
#        "ntags" : ntags,
#        "newtags" : newtags,
        })
    tm.compile()



if __name__ == "__main__":
    makeOverviewSlides()
