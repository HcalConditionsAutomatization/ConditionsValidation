import sys
from pathlib import Path
from .file_length_validator import FileLengthValidator

def runOneFile(config):
    validators = { 
            "flength" : FileLengthValidator
            }
    to_test = Path(config["file_name"]).resolve()
    for test in config["tests"]:
        validator = validators[test["name"]](*test["args"])
        result, msg = validator.validate(to_test)
        if not result:
            sys.stderr.write("Validation of file {} failed validator {}\n{}\n".format(to_test, test["name"],  msg))
            return False
        else:
            sys.stderr.write("Validation of file {} passed validator {}\n".format(to_test, test["name"]))

    return True
