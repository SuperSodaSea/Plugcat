import argparse
import os
import subprocess

VIVADO = os.getenv('VIVADO', 'vivado')
MILL = os.getenv('MILL', 'mill')

RESOLUTION_LIST = [
    '1920x1080',
    '2560x1440',
    '3840x2160',
]
REFRESH_RATE_LIST = [
    '30',
    '60',
    '120',
    '144',
    '240',
]

PROJECT_PATH = os.path.dirname(os.path.realpath(__file__))
CHISEL_PATH = os.path.join(PROJECT_PATH, '..', '..', '..', 'common', 'Chisel')
SCRIPTS_PATH = os.path.join(PROJECT_PATH, 'scripts')
BUILD_PATH = os.path.join(PROJECT_PATH, 'build')
GENERATED_PATH = os.path.join(BUILD_PATH, 'generated')
BITSTREAM_PATH = os.path.join(BUILD_PATH, 'bitstream')

def runCommand(command, **kwargs):
    print(command)
    subprocess.run(command, shell = True, check = True, **kwargs)

def runVivadoScript(script, *args):
    runCommand([VIVADO, '-nojournal', '-nolog', '-mode', 'batch', '-source', os.path.join(SCRIPTS_PATH, script), '-tclargs', *args], cwd = BUILD_PATH)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('command', choices = ['build', 'program', 'flash'])
    parser.add_argument('--resolution', choices = RESOLUTION_LIST, default = '1920x1080')
    parser.add_argument('--refresh-rate', choices = REFRESH_RATE_LIST, default = '60')
    parser.add_argument('-j', '--jobs', default = '8')
    args = parser.parse_args()

    RESOLUTION = args.resolution
    REFRESH_RATE = args.refresh_rate
    JOBS = args.jobs

    if args.command == 'build':
        os.makedirs(GENERATED_PATH, exist_ok = True)
        runCommand([MILL, 'hdmioutexample.run', '-o', os.path.join(GENERATED_PATH, 'HDMIOutExample.sv')], cwd = CHISEL_PATH)

        runVivadoScript('CreateProject.tcl', RESOLUTION, REFRESH_RATE)
        runVivadoScript('Synthesis.tcl', JOBS)
        runVivadoScript('Implementation.tcl', JOBS)
        runVivadoScript('GenerateBitstream.tcl', BITSTREAM_PATH)
    elif args.command == 'program':
        runVivadoScript('Program.tcl', BITSTREAM_PATH)
    elif args.command == 'flash':
        runVivadoScript('Flash.tcl', BITSTREAM_PATH)
    else:
        assert False
