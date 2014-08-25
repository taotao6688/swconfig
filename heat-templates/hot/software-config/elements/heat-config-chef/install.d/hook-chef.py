#!/usr/bin/env python
import json
import logging
import os
import subprocess
import sys


def getLogger():
    l = logging.getLogger('heat-config')
    handler = logging.StreamHandler(sys.stderr)
    handler.setFormatter(
        logging.Formatter(
            '[%(asctime)s] (%(name)s) [%(levelname)s] %(message)s'))
    l.addHandler(handler)
    l.setLevel('DEBUG')
    return l


logger = getLogger()


def makedirs(path):
    if not os.path.isdir(path):
        os.makedirs(path, 0o700)


def generate_script():
    deployment = json.load(sys.stdin)
    logger.debug(json.dumps(deployment))
    working_dir = os.environ.get(
        'HEAT_SCRIPT_WORKING', '/var/lib/heat-config/heat-config-chef')
    makedirs(working_dir)
    script = os.path.join(working_dir, deployment['id'])
    with open(script, 'w') as f:
        f.write(deployment.get('config', ''))
    os.chmod(script, 0o700)
    logger.debug(script)
    return script


def execute_script(script):
    subproc = subprocess.Popen(['bash', script], stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE, env=os.environ)
    stdout, stderr = subproc.communicate()
    return {'deploy_stdout': stdout,
            'deploy_stderr': stderr,
            'deploy_status_code': subproc.returncode}


def main(argv=sys.argv):
    script = generate_script()
    logger.debug('Running %s' % script)
    response = execute_script(script)
    logger.debug(json.dumps(response))
    json.dump(response, sys.stdout)

if __name__ == '__main__':
    sys.exit(main(sys.argv))
