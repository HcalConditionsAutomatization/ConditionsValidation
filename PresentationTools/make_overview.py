from texmaker import TexMaker


if __name__ == "__main__":
    tm = TexMaker("testbuild","PresentationTools/templates/main.tex", "output") 
    tm.preparation()
    tm.renderTemplate({"items":[[1,2],[3,4]]})
    tm.compile()

    

