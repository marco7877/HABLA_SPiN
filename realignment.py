"""
@author: Marco Flores-Coronado
@github: marco7877
"""
import os
import argparse

'''
Note: You should have installed/loaded AFNI & fsl in order for this code to work.

'''
####### DEBUGG
#bold_phase_ext="_part-phase_bold"
#bold_ext="_part-mag_bold"
#echoes=4
#bids_dir="/bcbl/home/public/MarcoMotion/Habla_debbug/"
#output_dir="func_preproc/"
#drop_vol=10
#drop_noise=3
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
parser.add_argument("--bold_phase_ext",
                    default="_part-phase_bold", type=str,
                    help="bold_phase name extention after **echo-{n} without .nii.gz")                        
parser.add_argument("--bold_mag_ext", default="_part-mag_bold", type=str,
                    help="bold name extention after **echo-{n} without .nii.gz")
args = parser.parse_args()
bids_dir=args.bids_dir
output_dir=args.output_dir
echoes=args.echoes
bold_phase_ext=args.bold_phase_ext
bold_ext=args.bold_mag_ext
# Here we could have a condition to check if the script has already been run and the files are there.
# Im skipping this for now
#reading target files
####### Reading files #########################################################
# TODO: change echo-1_sbref.nii.gz to echo-1_part-mag_sbref.nii.gz
# TODO: add a condition where if sbref is not provided. Motion correction
# is computed from mean voxel activation from echo 1 nold.nii.gz image
source_sbref= sorted([os.path.join(root, x) 
                      for root,dirs,files in os.walk(bids_dir) 
                      for x in files if x.endswith("echo-1_part-mag_sbref.nii.gz")])
####### Output names/dir ######################################################
output_filerealign=[directory.partition("echo-")[0]+"echo-"
           for directory in source_sbref]
output_filerealign=[directory.replace("func/",output_dir) 
                    for directory in output_filerealign]
# checking of output directory exists
filenames=[ directory.partition("anat/")[0]+output_dir
           for directory in source_sbref]
for directory in filenames:
    if not os.path.exists(directory):
        os.mkdir(directory)
del filenames
####### Matrix motion correction from sbref echo n ############################
# TODO: add a condition where if sbref is not provided. Motion correction
# is computed from mean voxel activation from echo 1 nold.nii.gz image
# command: 3dTstat -mean -prefix "${mref}" "${tmp}"/"${func_in}" -overwrite
print(f"Generating {len(source_sbref)} reference image for motion correction (mean based)")
for i in range(len(source_sbref)):
    os.system("3dvolreg -overwrite -Fourier -base " + source_sbref[i]+ 
              " -1Dfile " + output_filerealign[i] + "1"+bold_ext+"_mcf.1D " +
              "-1Dmatrix_save "+ output_filerealign[i] + "1"+bold_ext+
              "_mcf.aff12.1D -prefix " +output_filerealign[i] +"1"+bold_ext+
              "_mcf.nii.gz "+output_filerealign[i] + "1"+bold_ext+
              "_dsd.nii.gz")
    ## Demean motion parameters
    os.system("1d_tool.py -infile "+ 
              output_filerealign[i] + "1"+bold_ext+"_mcf.1D" +
              " -demean -write "+
              output_filerealign[i] + "1"+bold_ext+"_mcf_demean.1D -overwrite")
    os.system("1d_tool.py -infile "+ 
              output_filerealign[i] + "1"+bold_ext+"_mcf_demean.1D" +
              " -derivative -demean -write "+
              output_filerealign[i] + "1"+bold_ext+"_mcf_deriv1.1D -overwrite")
    ## Dvars and FD motion parameters
    os.system("fsl_motion_outliers -i "
              +output_filerealign[i] + "1"+bold_ext+"_mcf -o "+
              output_filerealign[i] + "1"+bold_ext+"_mcf_dvars_confounds -s "+
              output_filerealign[i] + "1"+bold_ext+"_dvars_post.par -p "+
              output_filerealign[i] + "1"+bold_ext+
              "_dvars_post --dvars --nomoco")
    os.system("fsl_motion_outliers -i "
              +output_filerealign[i] + "1"+bold_ext+bold_ext+"_dsd.nii.gz -o "+
              output_filerealign[i] + "1"+bold_ext+"_mcf_dvars_confounds -s "+
              output_filerealign[i] + "1"+bold_ext+"_dvars_pre.par -p "+
              output_filerealign[i] + "1"+bold_ext+
              "_dvars_pre --dvars --nomoco")
    os.system("fsl_motion_outliers -i "
              +output_filerealign[i] + "1"+bold_ext+bold_ext+"_dsd.nii.gz -o "+
              output_filerealign[i] + "1"+bold_ext+"_mcf_fd_confounds -s "+
              output_filerealign[i] + "1"+bold_ext+"_fd.par -p "+
              output_filerealign[i] + "1"+bold_ext+
              "_fd --fd")
    os.system("1d_tool.py -infile "+ 
              output_filerealign[i] + "1"+bold_ext+"_mcf.1D" +
              " -derivative -collapse_cols euclidean_norm -write "+
              output_filerealign[i] + "1"+bold_ext+"_mcf_enorm.1D -overwrite")    
####### Realigning all echos ##################################################
print("Realigning remaining echoes ")
realign_ref= sorted([os.path.join(root, x) 
                      for root,dirs,files in os.walk(bids_dir) 
                      for x in files if x.endswith("_mcf.aff12.1D")])
# TODO: erase below line when rec-magnitude and rec-phase added in all niifti files
#filenames_out=[x.replace("_rec-magnitude","") for x in filenames_out]
for i in range(len(source_sbref)):
    for echo in range(echoes):#indentation starts in 0
        tmp_filename=output_filerealign[i]+str(echo+1)
        print(f"Motion realignment for {tmp_filename}")
        os.system("3dAllineate -overwrite -base "+source_sbref[i]+
                  " -final cubic -1Dmatrix_apply "+ realign_ref[i]+
                  " -prefix "+ tmp_filename+bold_ext+"_mcf_al.nii.gz "+
                  tmp_filename+bold_ext+"_dsd.nii.gz")
        
        
