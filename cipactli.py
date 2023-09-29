"""
author: Marco Flores-Coronado
@github: marco7877
"""
import os
import argparse
from subprocess import check_output
from datetime import datetime
'''
Note: You should have installed/loaded AFNI for this to work. Moreover, you 
need to have the HABLA_SPiN repo cloned so that you have acces to 
realignment.py and ME-ICA_tedana.py as both are used internally here
through os.system("something").

'''
# DEBUGG
#matlab_nordic="nordic.m"
#echo1="/bcbl/home/public/MarcoMotion/Habla_restingState/sub-002/ses-1/func_preproc/sub-002_ses-1_task-HABLA1200_echo-1_part-mag_bold_dsd.nii.gz"
#output_dir="func_preproc_cipactli/"
#echoes=4
#output_dir="func_preproc_cipactli/"
#repo_directory="/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/"
#mask="/bcbl/home/public/MarcoMotion/Habla_restingState/sub-002/ses-1/func_preproc/sub-002_ses-1_task-HABLA1200_echo-1_part-mag_brain_mask.nii.gz"
#TE="11,28, 45, 61"
####### Arguments #############################################################
parser = argparse.ArgumentParser(
    description="""Cipactli pipeline to remove thermal noise""")
parser.add_argument("--echo1", default=None, type=str,
                    help="Full path to echo 1. mag and phase should be stored")
parser.add_argument("--source_sbref", default=None, type=str,
                    help="""Sbref image to align epi volumes post nordic
                    currently we only support aligning to a single sbref,
                    but will be allowed to do so in the future""")
parser.add_argument("--matlab_nordic", default="nordic.m", type=str,
                    help="""filename of the script to be run
                    CAUTION: This works, but is not good practice. 
                    SUggestions to avoid this """)
parser.add_argument("--output_dir", default="func_preproc_cipactli/", type=str,
                    help="""Directory to store output at.
                    Default is func_preproc:
                        -anat
                        -func
                        -func_preproc""")
parser.add_argument("--echoes", default=None, type=int,
                    help="Number of echoes")
parser.add_argument("--TE", default=None, type=str,
                    help= "Time in ms for each echo")
parser.add_argument("--repo_directory",default="/bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/",type=str,
                    help="""The complete direction where the 
                    HABLA_SPiN repo is stored, e.g. :
                        /bcbl/home/public/MarcoMotion/scripts/HABLA_SPiN/""")
parser.add_argument("--filt_pattern", default=None, type=str,
                    help="""The string pattern to identify specific files:
                        This is useful to parallelize subjects, e.g.:
                        --filt_pattern 001
                        or to parallelize tasks, e.g. :
                        --filt_pattern task-breathhold
                        """)
parser.add_argument("--mask", default=None, type=str,
                    help="""Mask to run tedana, only the filename is needed""")
parser.add_argument("-phase_filter", default=10, type=str, help="""
			Temporal phase for nifti_nordic script""")
args = parser.parse_args()
output_dir=args.output_dir
matlab_nordic=args.matlab_nordic
echo1 = args.echo1
filt_pattern = args.filt_pattern
phase_filter = args.phase_filter
echoes = args.echoes
mask=args.mask
TE = args.TE
repo_directory=args.repo_directory
# start
parts = echo1.partition("echo-1")
head,_,mag_tail = zip(parts)
head="".join(head)
print(mag_tail)
mag_tail="".join(mag_tail)
print(mag_tail)
phase_tail=mag_tail.replace("part-mag","part-phase")
outhead=head.replace("func_preproc/",output_dir)
out_name=outhead.partition(output_dir)
directory_out,_,file_name=zip(out_name)
file_name="".join(file_name)
directory_cipactli="".join(directory_out ) + output_dir
print("dir_cipactli ="+directory_cipactli+"|")
directory,_,_=outhead.partition(output_dir)
if not os.path.exists(directory_cipactli):
    os.mkdir(directory_cipactli)
#del directory
mask=mask.partition("func_preproc/")
mask_dir,_,mask_filename=zip(mask)
mask_file="".join(mask_filename)
# make simbolic link of mask 
source_mask= sorted([os.path.join(root, x) 
                      for root,dirs,files in os.walk(directory) 
                      for x in files if mask_file in x])
for i in range(len(source_mask)):
    os.system("ln -s "+source_mask[i]+" "+directory+output_dir+mask_file)
# Concatenating part-mag and part-phase echoes
mag_terms=""
phase_terms=""

for i in range(echoes):
    mag_terms+=head+"echo-"+str(i+1)+mag_tail+" "
    phase_terms+=head+"echo-"+str(i+1)+phase_tail+" "
## concatenating everything with AFNI
print(mag_terms)
print(f'Concatenating {echoes} echoes for nordic denoising')
os.system("3dZcat "+mag_terms+" -prefix "+outhead+"echoes_part-mag_bold_dsd.nii.gz")
os.system("3dZcat "+phase_terms+" -prefix "+outhead+"echoes_part-phase_bold_dsd.nii.gz")

####### nordic ################################################################
## running nordic over concat niiftis
#nordic=matlab_nordic.split("/")[-1]
#nordic_directory=nordic[0:(len(nordic)*-1)]
matlab_nordic=repo_directory+matlab_nordic
# TODO: find a better way to call matlab, open to suggestions
### do changes to nordic.m
os.system("sed -i 's~code_directory~"+repo_directory+"~' "+matlab_nordic)
os.system("sed -i 's~bold_mag~"+outhead+"echoes_part-mag_bold_dsd.nii.gz"+"~' "+matlab_nordic)
os.system("sed -i 's~bold_phase~"+outhead+"echoes_part-phase_bold_dsd.nii.gz"+"~' "+matlab_nordic)
os.system("sed -i 's~target~"+directory+output_dir+"~' "+matlab_nordic)
os.system("sed -i 's~fn_out~"+file_name+"echoes_part-mag_bold_cipactli"+"~' "+matlab_nordic)
print("matlab -batch " + '"' +"run('"+matlab_nordic+"');exit"+'"')
### run nordic.m and get time for log output
run_time=datetime.now()
time_string = run_time.strftime("%d-%m-%Y_%H-%M-%S")
os.system("matlab -batch " + '"' +"run('"+matlab_nordic+"');exit"+'" > '+
          outhead+"cipactli_nordic_"+time_string+".log")
print("matlab -batch " + '"' +"run('"+matlab_nordic+"');exit"+'" > '+
          outhead+"cipactli_nordic_"+time_string+".log")### revert change to nordic.m
os.system("sed -i 's~"+outhead+"echoes_part-mag_bold_dsd.nii.gz"+"~bold_mag~' "+matlab_nordic)
os.system("sed -i 's~"+outhead+"echoes_part-phase_bold_dsd.nii.gz"+"~bold_phase~' "+matlab_nordic)
os.system("sed -i  's~"+file_name+"echoes_part-mag_bold_cipactli"+"~fn_out~' "+matlab_nordic)
os.system("sed -i  's~"+directory+output_dir+"~target~' "+matlab_nordic)
## slicing diferent echoes back with AFNI
#TODO: find the correct name output for cipactli scripts
z_cipactli=int(check_output("3dinfo -nk "+ outhead+"echoes_part-mag_bold_cipactli"+".nii", shell=True))
z_raw=int(check_output("3dinfo -nk "+ echo1, shell=True))
z_slices_cut=list(range(0,z_cipactli,z_raw))
z_slices_cut.append(z_cipactli)
print(f'Cutting apart {echoes} echoes after nordic denoising')
for echo in range(echoes):
    os.system("3dZcutup -prefix "+outhead+"echo-"+str(echo+1)+
              "_part-mag_bold_cipactli_dsd.nii.gz -keep "+
              str(z_slices_cut[echo]) +" "+ str(z_slices_cut[echo+1]-1)+" "+
                                              outhead+"echoes_part-mag_bold_cipactli.nii -overwrite")
print(f'Done sepparating echoes')
print(f'Calculating geometrix matrix from {outhead+"echo-1_part-mag_bold_cipactli_dsd.nii.gz"}')
geom_matrix=str(check_output("3dAttribute IJK_TO_DICOM_REAL "+ outhead+
                             "echo-1_part-mag_bold_cipactli_dsd.nii.gz", shell=True))
SCL = "n'b"+'\\'  
for character in SCL:
    geom_matrix = geom_matrix.replace(character, '')
print("Aligning all achoes to the same grid matrix after Z")
for i in range(1,echoes):
    os.system("ATR=$(3dAttribute IJK_TO_DICOM_REAL "+ outhead+
                             "echo-1_part-mag_bold_cipactli_dsd.nii.gz) && 3drefit -atrfloat IJK_TO_DICOM_REAL "+
                             '"${ATR}"'+" "+outhead+"echo-"+str(i+1)+"_part-mag_bold_cipactli_dsd.nii.gz")
####### realignment ###########################################################
### create simbolic link and then use realignment.py
head_sbref=head.replace("func_preproc/", "func/")
ref_sbref=head_sbref+"echo-1_part-mag_sbref.nii.gz"
os.system("ln -s "+ref_sbref+" "+outhead+"echo-1_part-mag_sbref.nii.gz")
# using realignment.py
realignment=repo_directory+"realignment.py"
os.system("python "+ realignment+" --bids_dir "+directory_cipactli+" --echoes "+
          str(echoes)+ " --output_dir "+output_dir+" --bold_mag_ext _part-mag_bold_cipactli")
# using tedana
tedana=repo_directory+"ME-ICA_tedana.py"
os.system("python "+tedana+ " --bids_dir "+directory_cipactli+" --echoes "+
          str(echoes)+" --TE "+'"'+TE+'"'+" --output_dir "+output_dir+
          " --preproc_bold_ext bold_cipactli_mcf_al --mask_ext brain_mask")
