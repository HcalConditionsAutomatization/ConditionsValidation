class FileLengthValidator:
    def __init__(self, num_lines):
        self.num_lines = num_lines

    def validate(self, path):
        num_lines = sum(1 for line in open(path))
        if num_lines == self.num_lines:
            return True, ""
        else:
            return False, "File length {} doe snot match desired {}".format(num_lines, self.num_lines)

