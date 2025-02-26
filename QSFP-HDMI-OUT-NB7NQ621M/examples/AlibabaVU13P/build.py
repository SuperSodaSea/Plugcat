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
COMMON_PATH = os.path.join(PROJECT_PATH, '..', '..', '..', 'common')
COMMON_CHISEL_PATH = os.path.join(COMMON_PATH, 'Chisel')
COMMON_SCRIPTS_PATH = os.path.join(COMMON_PATH, 'Vivado', 'scripts')
SCRIPTS_PATH = os.path.join(PROJECT_PATH, 'scripts')
CONFIG_PATH = os.path.join(SCRIPTS_PATH, 'Config.tcl')
BUILD_PATH = os.path.join(PROJECT_PATH, 'build')
GENERATED_PATH = os.path.join(BUILD_PATH, 'generated')
BITSTREAM_PATH = os.path.join(BUILD_PATH, 'bitstream')

def runCommand(command, **kwargs):
    print(command)
    subprocess.run(command, shell = True, check = True, **kwargs)

def runVivadoScript(script, *args):
    runCommand([VIVADO, '-nojournal', '-nolog', '-mode', 'batch', '-source', script, '-tclargs', *args], cwd = BUILD_PATH)

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
        runCommand([MILL, 'hdmioutexample.run', '-o', os.path.join(GENERATED_PATH, 'HDMIOutExample.sv')], cwd = COMMON_CHISEL_PATH)

        runVivadoScript(os.path.join(SCRIPTS_PATH, 'CreateProject.tcl'), RESOLUTION, REFRESH_RATE)
        runVivadoScript(os.path.join(COMMON_SCRIPTS_PATH, 'Synthesis.tcl'), CONFIG_PATH, JOBS)
        runVivadoScript(os.path.join(COMMON_SCRIPTS_PATH, 'Implementation.tcl'), CONFIG_PATH, JOBS)
        runVivadoScript(os.path.join(COMMON_SCRIPTS_PATH, 'GenerateBitstream.tcl'), CONFIG_PATH, BITSTREAM_PATH)
    elif args.command == 'program':
        runVivadoScript(os.path.join(COMMON_SCRIPTS_PATH, 'Program.tcl'), CONFIG_PATH, BITSTREAM_PATH)
    elif args.command == 'flash':
        runVivadoScript(os.path.join(COMMON_SCRIPTS_PATH, 'Flash.tcl'), CONFIG_PATH, BITSTREAM_PATH)
    else:
        assert False
