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
####### DEBUGG
#bold_phase_ext="_part-phase_bold"
#bold_ext="_bold"
#echoes=4
#bids_dir="/bcbl/home/public/MarcoMotion/Habla_debbug"
#output_dir="func_preproc/"
#dilate= 1
#drop_vol=10
#drop_noise=3
####### TODO: Add despiking and trimming as non-default options
####### Arguments #############################################################
parser=argparse.ArgumentParser(description="Creates a whole head mask from T1 uni-clean")
parser.add_argument("--bids_dir", default=None, type=str,help="Full path to the BIDS directory ")
parser.add_argument("--dilate", default=3,type=int,help="Dilation size to close holes within head mask")
parser.add_argument("--despike", default=False,type=bool,help="Despike data? Default is False")                        
parser.add_argument("--sliceTimming", default=False,type=bool,help="""Slice timme data? Default is False WARNING: THIS FEATURE IS IN DEPLOYMENT. IT DOESN'T WORK YET""")
parser.add_argument("--filt_pattern", default=None, type=str,help="""The string pattern to identify specific files: This is useful to parallelize subjects, e.g.: --filt_pattern 001or to parallelize tasks, e.g. : --filt_pattern task-breathhold""")
parser.add_argument("--method", default="vanilla", type=str, help=""" The string pattern to identify the resulting func_preproc_* output directory""")
parser.add_argument("--output_dir",default="func_preproc_vanilla/", type =str, help ="""Directory to store output at Default is func_preproc: -anat -func -func_preproc""")
args = parser.parse_args()
bids_dir=args.bids_dir
dilate=str(args.dilate)
output_dir=args.output_dir
despike=args.despike
sliceTimming=args.sliceTimming
filt_pattern=args.filt_pattern
method=args.method
# Here we could have a condition to check if the script has already been run and the files are there.
# Im skipping this for now
####### Reading files #########################################################
source_sbref= sorted([os.path.join(root, x) 
    for root,dirs,files in os.walk(bids_dir) 
    for x in files if x.endswith("echo-1_part-mag_sbref.nii.gz")])
source_sbref=sorted([directory for directory in source_sbref 
        if "func/" in directory])
## filter condition
if filt_pattern != None:
    source_sbref=sorted([directory for directory in source_sbref 
        if filt_pattern in directory])
    tcount_bold= [ niifti.replace("sbref","bold") for niifti in source_sbref]
tcount_bold= [ niifti.replace(".nii.gz","") for niifti in tcount_bold]
tcount_bold= [ niifti.replace("func",output_dir)for niifti in tcount_bold]
preproc_bold= [niifti.replace("func/",output_dir)for niifti in source_sbref]
preproc_bold= [niifti.replace("sbref","bold_"+method) for niifti in preproc_bold]
####### Output names/dir ######################################################
output_msk= [niifti.replace("func/", output_dir)  for niifti in source_sbref]
output_mask_surf= [niifti.replace("sbref", "brain_mask_surf") for niifti in output_msk]
output_mask= [niifti.replace("sbref", "brain_mask") for niifti in output_msk]
# checking if output directory exist
filenames=[ directory.partition(output_dir)[0]+output_dir for directory in source_sbref]
for directory in filenames:
    if not os.path.exists(directory):
        os.mkdir(directory)
del filenames
####### Head mask creation ####################################################
for i in range(len(source_sbref)):
    print("Calculating brain mask")
    os.system("3dSkullStrip -input "+ source_sbref[i]+
            " -prefix "+ output_mask_surf[i]+
            " -use_skull -no_avoid_eyes -mask_vol -overwrite")
    os.system("3dcalc -a "+output_mask_surf[i]+
            " -expr 'astep(a,3)' -prefix "+output_mask[i]+" -overwrite")
    os.system("3dmask_tool -input "+output_mask[i]+" -prefix "+output_mask[i]+
            " -fill_holes -dilate_inputs " + " +" +
            dilate +" -" + dilate+ " -overwrite")
    os.system("3dToutcount -mask "+output_mask[i]+
            " -fraction -polort 5 -legendre "+preproc_bold[i]+
            " > "+tcount_bold[i]+"_outcount.1D")
    if despike == True:
        for i in range(len(source_sbref)):
            print("Despiking Data")
        os.system("3dDespike -prefix "+tcount_bold[i]+"_dsk.nii.gz "+
                preproc_bold[i]+".nii.gz -overwrite")
        # TODO: add slice timming     
#if sliceTimming == True:
 #   for i in range(len(source_sbref)):
  #      print("Slice timming Data")
   #     os.system("3dTshift -Fourier -prefix "tcount_bold[i]"_si.nii.gz" -tpattern "${siot}" -overwrite "${funcsource}.nii.gz" -overwrite)




