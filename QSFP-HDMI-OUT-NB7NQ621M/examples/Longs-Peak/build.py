import argparse
import os
import shutil
import subprocess

MILL = os.getenv('MILL', shutil.which('mill'))
OPENOCD = shutil.which('openocd')
QUARTUS_SH = shutil.which('quartus_sh')
QUARTUS_CPF = shutil.which('quartus_cpf')
QSYS_SCRIPT = shutil.which('qsys-script')

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
SCRIPTS_PATH = os.path.join(PROJECT_PATH, 'scripts')
CONFIG_PATH = os.path.join(SCRIPTS_PATH, 'Config.tcl')
BUILD_PATH = os.path.join(PROJECT_PATH, 'build')
IP_PATH = os.path.join(BUILD_PATH, 'ip')
GENERATED_PATH = os.path.join(BUILD_PATH, 'generated')
BITSTREAM_PATH = os.path.join(BUILD_PATH, 'bitstream')

def runCommand(command, **kwargs):
    print(command)
    subprocess.run(command, check = True, **kwargs)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('command', choices = ['build', 'program'])
    parser.add_argument('--resolution', choices = RESOLUTION_LIST, default = '1920x1080')
    parser.add_argument('--refresh-rate', choices = REFRESH_RATE_LIST, default = '60')
    parser.add_argument('-j', '--jobs', default = '8')
    args = parser.parse_args()

    RESOLUTION = args.resolution
    REFRESH_RATE = args.refresh_rate
    JOBS = args.jobs

    PROJECT_NAME = 'Longs-Peak-Example'

    if args.command == 'build':
        os.makedirs(GENERATED_PATH, exist_ok = True)
        runCommand([ MILL, 'hdmioutexample.run', '-o', os.path.join(GENERATED_PATH, 'HDMIOutExample.sv') ], cwd = COMMON_CHISEL_PATH)

        runCommand([ QSYS_SCRIPT, f'''--script={ os.path.join(SCRIPTS_PATH, 'CreateIP.tcl') }''', IP_PATH, RESOLUTION, REFRESH_RATE ], cwd = BUILD_PATH)

        runCommand([ QUARTUS_SH, '-t', os.path.join(SCRIPTS_PATH, 'CreateProject.tcl'), JOBS, RESOLUTION, REFRESH_RATE ], cwd = BUILD_PATH)

        runCommand([ QUARTUS_SH, '--flow', 'compile', PROJECT_NAME ], cwd = BUILD_PATH)

        os.makedirs(BITSTREAM_PATH, exist_ok = True)
        shutil.copy(os.path.join(BUILD_PATH, 'output', f'{ PROJECT_NAME }.sof'), os.path.join(BITSTREAM_PATH, f'{ PROJECT_NAME }.sof'))

        runCommand([ QUARTUS_CPF, '--convert', '--frequency=30MHz', '--voltage=2.5', '--operation=p', os.path.join(BITSTREAM_PATH, f'{ PROJECT_NAME }.sof'), os.path.join(BITSTREAM_PATH, f'{ PROJECT_NAME }.svf') ], cwd = PROJECT_PATH)
    elif args.command == 'program':
        svfPath = os.path.join(BITSTREAM_PATH, f'{ PROJECT_NAME }.svf')
        svfPathEscaped = svfPath.replace('\\', '\\\\')
        runCommand([ OPENOCD, '--file', '../../../common/OpenOCD/Longs-Peak/Config.cfg', '--command', f'svf -tap 10AXF40AA.tap "{ svfPathEscaped }"; exit' ], cwd = PROJECT_PATH)
    else:
        assert False
