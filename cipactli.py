"""
author: Marco Flores-Coronado
@github: marco7877
"""
import os
import argparse
'''
Note: You should have installed/loaded AFNI & fsl in order for this code to work.

'''
# DEBUGG
# bold_phase_ext="_parthase_bold"
# bold_ext="_part-mag_bold"
# echoes=4
# bids_dir="/bcbl/home/public/MarcoMotion/Habla_restingState/"
# output_dir="func_preproc/"
# drop_vol=10
# drop_noise=3
# temporal_phase="1"
# phase_filter="10"

####### Arguments #############################################################
parser = argparse.ArgumentParser(
    description="""Cipactli pipeline to remove thermal noise""")
parser.add_argument("--echo1", default=None, type=str,
                    help="Full path to echo 1. mag and phase should be stored")
parser.add_argument("--matlab_nordic", default=None, type=str,
                    help="directory where the matlab script is allocated")
parser.add_argument("--output_dir", default="func_preproc/", type=str,
                    help="""Directory to store output at.
                    Default is func_preproc:
                        -anat
                        -func
                        -func_preproc""")
parser.add_argument("--echoes", default=None, type=int,
                    help="Number of echoes")
parser.add_argument("--filt_pattern", default=None, type=str,
                    help="""The string pattern to identify specific files:
                        This is useful to parallelize subjects, e.g.:
                        --filt_pattern 001
                        or to parallelize tasks, e.g. :
                        --filt_pattern task-breathhold
                        """)
parser.add_argument("--temporal_phase", default=1, type=str, help="""
			Temporal phase for nifti_nordic script""")
parser.add_argument("-phase_filter", default=10, type=str, help="""
			Temporal phase for nifti_nordic script""")
args = parser.parse_args()
bids_dir = args.bids_dir
output_dir=args.output_dir
matlab_nordic = args.matlab_nordic
echo1 = args.echo1
filt_pattern = args.filt_pattern
temporal_phase = args.temporal_phase
phase_filter = args.phase_filter
echoes = args.echoes
# start
parts = echo1.partition("echo-1")
head,_,mag_tail = zip(parts)
head="".join(head)
mag_tail="".join(mag_tail)
phase_tail=mag_tail.replace("part-mag","part-phase")
outhead=head.replace("func_preproc/",output_dir)
directory,_,_=outhead.partition(output_dir)
if not os.path.exists(directory+output_dir):
    os.mkdir(directory+output_dir)
#del directory
# Concatenating part-mag and part-phase echoes
mag_terms=""
phase_terms=""
for i in range(echoes):
    mag_terms+=head+"echo-"+str(i+1)+mag_tail+" "
    phase_terms+=head+"echo-"+str(i+1)+phase_tail+" "
## concatenating everything with AFNI
os.system("3dZcat "+mag_terms+" -prefix "+outhead+"_echoes_part-mag_bold_dsd.nii.gz")
os.system("3dZcat "+phase_terms+" -prefix "+outhead+"_echoes_part-phase_bold_dsd.nii.gz")
## running nordic over concat niiftis
nordic=matlab_nordic.split("/")[-1]
nordic_directory=matlab_nordic[0:(len(nordic)*-1)]
os.system("sed -i 's~code_directory~"+nordic_directory+"~' "+matlab_nordic)
os.system("sed -i 's~bold_mag~"+outhead+"_echoes_part-mag_bold_dsd.nii.gz"+"~' "+matlab_nordic)
os.system("sed -i 's~bold_phase~"+outhead+"_echoes_part-phase_bold_dsd.nii.gz"+"~' "+matlab_nordic)
os.system("sed -i 's~target~"+directory+output_dir+"~' "+matlab_nordic)
os.system("sed -i 's~fn_out~"+outhead+"_echoes_part-mag_bold_cipactli"+"~' "+matlab_nordic)
print("matlab -batch " + '"' +"run('"+nordic+"');exit"+'"')
os.system("matlab -batch " + '"' +"run('"+nordic+"');exit"+'"')
os.system("sed -i 's~"+outhead+"_echoes_part-mag_bold_dsd.nii.gz"+"~bold_mag~' "+matlab_nordic)
os.system("sed -i 's~"+outhead+"_echoes_part-phase_bold_dsd.nii.gz"+"~bold_phase~' "+matlab_nordic)
os.system("sed -i  's~"+outhead+"_echoes_part-mag_bold_cipactli"+"~fn_out~' "+matlab_nordic)
os.system("sed -i  's~"+directory+output_dir+"~target~' "+matlab_nordic)
