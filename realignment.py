"""
@author: Marco Flores-Coronado
@github: marco7877
"""
import os
import argparse

'''
Note: You should have installed AFNI in order for this code to work. Remember to run MPRAGE before,
because we will search for files ended in rebiased_clean.nii.gz
'''
####### Arguments #############################################################
parser=argparse.ArgumentParser(
        description="""Generate reference images for motion correction.
        inputs are sbref and bold files. 
        Generate a motion correction matrix from sbref echo 1,
        then applies it to the remaining echoes""")
parser.add_argument("--bids_dir", default=None, type=str,
                    help="Full path to the BIDS directory ")
parser.add_argument("--echoes", default= None, type=int,
                    help="Number of echoes")
parser.add_argument("--output_dir",default="func_preproc/", type =str,
                    help ="""Directory to store output at.
                    Default is func_preproc:
                        -anat
                        -func
                        -func_preproc""")
args = parser.parse_args()
bids_dir=args.bids_dir
output_dir=args.output_dir
#bids_dir= "/bcbl/home/public/MarcoMotion/Habla_debbug"#to debbug
echoes=args.parse_args()
#echoes=4#to debbug
# Here we could have a condition to check if the script has already been run and the files are there.
# Im skipping this for now
#reading target files
####### Reading files #########################################################
# TODO: change echo-1_sbref.nii.gz to echo-1_part-mag_sbref.nii.gz
source_sbref= sorted([os.path.join(root, x) 
                      for root,dirs,files in os.walk(bids_dir) 
                      for x in files if x.endswith("echo-1_sbref.nii.gz")])
####### Output names/dir ######################################################
output_filerealign=[x.split("/")[-1] for x in source_sbref]
file_len=[len(x) for x in output_filerealign]
output_filerealign=[x.replace(".nii.gz","") for x in output_filerealign]
# checking if output directory exist
filenames=[ directory.partition("anat/")[0]+output_dir
           for directory in source_sbref]
for directory in filenames:
    if not os.path.exists(directory):
        os.mkdir(directory)
del filenames
####### Matrix motion correction from sbref echo n ############################
print(f"Generating {len(source_sbref)} reference image for motion correction (mean based)")
for i in range(len(source_sbref)):
    os.chdir(source_sbref[i][0:-file_len[i]])
    os.system("3dvolreg -overwrite -Fourier -base " + source_sbref[i]+ 
              " -1Dfile " + output_filerealign[i] + "_mcf.1D " +
              "-1Dmatrix_save "+ output_filerealign[i] + "_mcf.aff12.1D -prefix " +
              output_filerealign[i] + "_mcf.nii.gz "+ output_filerealign[i] + ".nii.gz")
####### Realigning all echos ##################################################
print("Realigning remaining echoes ")
realign_ref= sorted([os.path.join(root, x) 
                      for root,dirs,files in os.walk(bids_dir) 
                      for x in files if x.endswith("_mcf.aff12.1D")])
filenames_out=[x.replace("1_sbref.nii.gz","") and x.replace("anat/","func_preproc")
               for x in source_sbref]
# TODO: erase below line when rec-magnitude and rec-phase added in all niifti files
#filenames_out=[x.replace("_rec-magnitude","") for x in filenames_out]

for i in range(len(source_sbref)):
    target_dir=source_sbref[i][0:-file_len[i]]
    os.chdir(target_dir)
    for echo in range(echoes):#indentation starts in 0
        tmp_filename=filenames_out[i]+str(echo+1)#skipping first echo
        os.system("3dAllineate -overwrite -base "+source_sbref[i]+
                  " -final cubic -1Dmatrix_apply "+ realign_ref[i]+
                  " -prefix "+ tmp_filename+"_bold_mcf_al.nii.gz "+
                  tmp_filename+"_bold.nii.gz")
