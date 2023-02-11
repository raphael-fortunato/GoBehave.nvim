import os
import sys
import io
import contextlib
import logging

from behave import runner_util
from behave.step_registry import registry


@contextlib.contextmanager
def nostdout():
    save_stdout = sys.stdout
    sys.stdout = io.BytesIO()
    yield
    sys.stdout = save_stdout


def get_step_definition(feature_folder, step):
    with nostdout():
        logger = logging.getLogger()
        logger.setLevel(logging.ERROR)
        file_handler = logging.FileHandler("/home/raphael/.cache/nvim/gobehave.log", "w", "utf-8")
        file_handler.setFormatter(logging.Formatter("%(asctime)s - %(levelname)s - %(message)s"))
        logger.addHandler(file_handler)

        logging.error("feature is %s", feature_folder)
        logging.error("step is %s", step)

        parsed_step = " ".join(step.lstrip().split(" ")[1:]).lstrip()
        logging.error("parsed_step is %s", parsed_step)
        base_path = os.path.dirname(os.path.abspath(feature_folder))
        logging.error("base_path is %s", base_path)

        os.chdir(base_path)

        logging.error("current dir %s", os.getcwd())
        steps_paths = [os.path.join(base_path, "steps")]

        runner_util.exec_file(os.path.join(base_path, "environment.py"))
        runner_util.load_step_modules(steps_paths)

    for step_type in registry.steps.keys():
        logging.error("--This is the step_type: %s", dir(registry.steps[step_type][0]))
        steps = list(registry.steps[step_type])
        if not steps:
            continue

        for step in registry.steps[step_type]:
            if step.match(parsed_step):
                file = step.location.abspath()
                line = step.location.line
                logging.error("found location %s:%s", file, line)
                print(f"edit +{line} {file}", file=sys.stdout)
                exit(0)
    print("echo 'Not found'")
    exit(1)
