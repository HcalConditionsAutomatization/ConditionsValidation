from pathlib import Path
import jinja2
import shutil
import subprocess
import tempfile
import os

class TexMaker:
    def __init__(self, buildDirectory=None, templateFileName = None, outputDirectory= ".",saveTex = False):
        self.templateContents = ""
        if(buildDirectory):
            self.buildDirectory = Path(buildDirectory)
            self.ownsDirectory = False
        else:
            self.buildDirectory = Path(tempfile.mkdtemp(dir="."))
            self.ownsDirectory = True
        self.outFileName = 'outputReport.pdf';
        self.renderedSourceName = "source.tex"
        self.latexTemplate = templateFileName;
        self.outputDirectory = outputDirectory
        self.saveSource = saveTex

    def preparation(self):
        self.loadTemplateFromFile(self.latexTemplate)
        self.makeJinjaEnv()

    def setBuildDirectory(self,directory):
        self.buildDirectory = Path(directory)
        print(f"Build Directory for TexMaker set to {self.buildDirectory}")

    def setOutputDirectory(self,directory):
        self.outputDirectory = Path(directory)

    def loadTemplateFromFile(self, filename):
        try:
            with open(filename, 'r') as f:
                self.templateContents = f.read();
        except IOError as io:
            print("Could not open file {} due to error:\n{}".format(filename,io))


    def addResource(self, resourcePath):
        truePath = Path(resourcePath)
        shutil.move(truePath , self.buildDirectory/truePath.name)

    def makeJinjaEnv(self):
        self.latexTemplate = jinja2.Environment(
                block_start_string = '\BLOCK{',
                block_end_string = '}',
                variable_start_string = '\VAR{',
                variable_end_string = '}',
                comment_start_string = '\#{',
                comment_end_string = '}',
                line_statement_prefix = '%%',
                line_comment_prefix = '%#',
                trim_blocks = True,
                autoescape = False,
                loader = jinja2.FileSystemLoader(os.path.abspath('/'))
                )
        self.latexTemplate = self.latexTemplate.from_string(self.templateContents)

    def renderTemplate(self,options):
        if(self.latexTemplate != None):
            with open(self.buildDirectory/self.renderedSourceName ,'w') as f:
                f.write(self.latexTemplate.render(**options))
            if(self.saveSource):
                shutil.copyfile(self.buildDirectory/self.renderedSourceName,Path(self.outputDirectory)/self.renderedSourceName)
        else:
            print("Need to create template first")

    def compile(self):
        print(f"Compiling from {self.renderedSourceName} using build directory {self.buildDirectory}")
        subprocess.run(["pdflatex", "-output-directory", self.buildDirectory, self.buildDirectory / self.renderedSourceName] , stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
        outputFileName = (self.buildDirectory / self.renderedSourceName)
        outputFileName = outputFileName.with_suffix(".pdf")
        shutil.move(outputFileName,Path(self.outputDirectory)/self.outFileName)

    def __del__(self):
        if(self.ownsDirectory):
            pass
        # shutil.rmtree(self.buildDirectory)
