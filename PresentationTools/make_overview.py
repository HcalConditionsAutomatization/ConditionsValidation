from texmaker import TexMaker


if __name__ == "__main__":
    tm = TexMaker("testbuild","PresentationTools/templates/outline.tex", "output") 
    tm.preparation()
    tm.renderTemplate({
        "items":[[1,2],[3,4]],
        "images" : [
            [ "image1", "../test/dataRun3_HLTNew_HCAL/GainLutScatterHBHE.pdf", "" ]
            ]
        })
    tm.compile()

    

