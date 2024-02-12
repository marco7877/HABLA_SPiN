"""
@author: Marco Flores-Coronado
@github: marco7877
"""
import os
import argparse
from subprocess import check_output

'''
Note: You should have installed/loaded AFNI & fsl in order for this code to work.

'''

bids_dir= "/bcbl/home/public/MarcoMotion/Habla_restingState/sub-005/ses-1/"
echoes= 4 
output_dir="func_preproc_hydra/" 
bold_mag_ext= "_part-mag_bold_cipactli" 
nordic=False
dir_pattern="func/" 
dir_preproc_pattern="func_preproc_hydra/" 
align_matrix_ext="17_mcf.aff12.1D" 
filt_pattern="task-HABLA1700" 
noise_volumes=3#change this 0, this in an obligatory argument
###### Arguments #############################################################
'''
parser=argparse.ArgumentParser(
        description="""Generate reference images for motion correction.
        inputs are sbref and bold files. 
        Generate a motion correction matrix from sbref echo 1,
        then applies it to the remaining echoes""")
parser.add_argument("--bids_dir", default=None, type=str,
                    help="Full path to the BIDS directory ")
parser.add_argument("--echoes", default= None, type=int,
                    help="Number of echoes")
parser.add_argument("--output_dir",default=None, type =str,
                    help ="""Directory to store output at.
                    Default is func_preproc:
                        -anat
                        -func
                        -func_preproc""")
parser.add_argument("--bold_mag_ext", default=None, type=str,
                    help="bold name extention after **echo-{n} without .nii.gz")
parser.add_argument("--filt_pattern", default=None, type=str,
                    help="""The string pattern to identify specific files:
                        This is useful to parallelize subjects, e.g.:
                        --filt_pattern 005
                        or to parallelize tasks, e.g. :
                        --filt_pattern task-breathhold #TODO agregar un ejemplo son sub_ses y task
                        """)
parser.add_argument("--dir_pattern", default=None, type=str,
                    help="""The string pattern to identify files root directory
                        """)
parser.add_argument("--dir_preproc_pattern", default="func_preproc/", type=str,
                    help="""The string pattern to identify files root directory
                        """)
parser.add_argument("--nordic", default=False, type=bool,
                    help="Are file to be realigned post-NORDIC? Default, False")
parser.add_argument("--noise_volumes", default=0, type=int,
                    help="Do file to be realiigned have noise volumes to be removed? how many?")
parser.add_argument("--align_matrix_ext", default="_mcf.aff12.1D", type=str,
                    help="""extention that the target matrix should have. This is useful to differentiate
                    between different pipelines that need their own transformation matrix""")
args = parser.parse_args()
bids_dir=args.bids_dir
output_dir=args.output_dir
echoes=args.echoes
bold_mag_ext=args.bold_mag_ext
filt_pattern=args.filt_pattern
nordic=args.nordic
noise_volumes=args.noise_volumes
dir_pattern=args.dir_pattern
dir_preproc_pattern=args.dir_preproc_pattern
align_matrix_ext=args.align_matrix_ext
'''
# Here we could have a condition to check if the script has already been run and the files are there.
# Im skipping this for now
#reading target files
####### Reading files #########################################################
# TODO: add a condition where if sbref is not provided. Motion correction
# is computed from mean voxel activation from echo 1 nold.nii.gz image
source_sbref= sorted([os.path.join(root, x) 
                      for root,dirs,files in os.walk(bids_dir) 
                      for x in files if x.endswith("echo-1_part-mag_sbref.nii.gz")])

source_sbref=[directory for directory in source_sbref 
                  if dir_pattern in directory]
## filter condition
if filt_pattern != None:
    source_sbref=sorted([directory for directory in source_sbref 
                  if filt_pattern in directory])
####### Output names/dir ######################################################
if nordic == False:
    epi_ext="_dsd.nii.gz"
    epi_ext_out=epi_ext
else:
    epi_ext="_nordic_dsd.nii"
    epi_ext_out=epi_ext+".gz"
source_bold= sorted([os.path.join(root, x) 
                      for root,dirs,files in os.walk(bids_dir) 
                      for x in files if x.endswith("echo-1"+bold_mag_ext+epi_ext)])
print(f"Source bold files  are {source_bold}")
print(f"the command used to generate them was:")
print(f"""[os.path.join(root, x) 
                      for root,dirs,files in os.walk({bids_dir}) 
                      for x in files if x.endswith("echo-1"+{bold_mag_ext}+{epi_ext})]""")
source_bold=[file for file in source_bold if dir_preproc_pattern in file]
print(f"Source bold files inside {dir_preproc_pattern} are {source_bold}")
if filt_pattern!=None:
    source_bold=[file for file in source_bold
                 if filt_pattern in file]
    
filerealign=[directory.partition("echo-")[0]+"echo-"
           for directory in source_bold]
print(f"File name pattern is: {filerealign[0]}")
bold_dir_source=filerealign[0].split("/")[-2]+"/"
print(f"Target directory is: {bold_dir_source}")
output_filerealign=[directory.replace(bold_dir_source,output_dir) 
                    for directory in filerealign]
# checking of output directory exists
sbref_dir_source=source_sbref[0].split("/")[-2]+"/"
filenames=[ directory.partition(sbref_dir_source)[0]+output_dir
           for directory in source_sbref]
for directory in filenames:
    if not os.path.exists(directory):
        os.mkdir(directory)
del filenames
###### Matrix motion correction from sbref echo n ############################
# TODO: add a condition where if sbref is not provided. Motion correction
# is computed from mean voxel activation from echo 1 nold.nii.gz image
# command: 3dTstat -mean -prefix "${mref}" "${tmp}"/"${func_in}" -overwrite
#print(f"Generating {len(source_sbref)} reference image for motion correction (mean based)")
if noise_volumes != 0:
    for epi_n in range(len(source_bold)):
        volumes=int(check_output("3dinfo -nt "+source_bold[epi_n], shell=True))
        volume_target=volumes-noise_volumes-1
        for echo in range(echoes):
            file_2_trim=filerealign[epi_n]+str(echo+1)+bold_mag_ext+epi_ext
            file_2_trim_out=filerealign[epi_n]+str(echo+1)+bold_mag_ext+epi_ext_out
            os.system("3dcalc -a '"+file_2_trim+"[0.."+str(volume_target)+"]' -expr 'a' -prefix "+
                      file_2_trim_out+" -overwrite")
for i in range(len(source_bold)):
    os.system("3dvolreg -overwrite -Fourier -base " + source_sbref[i]+ 
              " -1Dfile " + output_filerealign[i] + "1"+bold_mag_ext+"_mcf.1D " +
              "-1Dmatrix_save "+ output_filerealign[i] + "1"+bold_mag_ext+
              align_matrix_ext+" -prefix " +output_filerealign[i] +"1"+bold_mag_ext+
              "_mcf.nii.gz "+filerealign[i] + "1"+bold_mag_ext+
              epi_ext)
    ## Demean motion parameters
#TODO make derivatives to work again. Problem with source files declaration
# checar el código de stefano y la ayuda de fsl
    os.system("1d_tool.py -infile "+ 
              output_filerealign[i] + "1"+bold_mag_ext+"_mcf.1D" +
              " -demean -write "+
              output_filerealign[i] + "1"+bold_mag_ext+"_mcf_demean.1D -overwrite")
    os.system("1d_tool.py -infile "+ 
              output_filerealign[i] + "1"+bold_mag_ext+"_mcf_demean.1D" +
              " -derivative -demean -write "+
              output_filerealign[i] + "1"+bold_mag_ext+"_mcf_deriv1.1D -overwrite")
    ## Dvars and FD motion parameters
   # os.system("fsl_motion_outliers -i "
    #          +output_filerealign[i] + "1"+bold_mag_ext+"_mcf -o "+
     #         output_filerealign[i] + "1"+bold_mag_ext+"_mcf_dvars_confounds -s "+
      #        output_filerealign[i] + "1"+bold_mag_ext+"_dvars_post.par -p "+
       #       output_filerealign[i] + "1"+bold_mag_ext+
        #      "_dvars_post --dvars --nomoco")
    #os.system("fsl_motion_outliers -i "
     #         +output_filerealign[i] + "1"+bold_mag_ext+epi_ext+" -o "+
      #        output_filerealign[i] + "1"+bold_mag_ext+"_mcf_dvars_confounds -s "+
       #       output_filerealign[i] + "1"+bold_mag_ext+"_dvars_pre.par -p "+
        #      output_filerealign[i] + "1"+bold_mag_ext+
         #     "_dvars_pre --dvars --nomoco")
   # os.system("fsl_motion_outliers -i "
    #          +filerealign[i] + "1"+bold_mag_ext+epi_ext+" -o "+
     #         output_filerealign[i] + "1"+bold_mag_ext+"_mcf_fd_confounds -s "+
      #        output_filerealign[i] + "1"+bold_mag_ext+"_fd.par -p "+
       #       output_filerealign[i] + "1"+bold_mag_ext+
        #      "_fd --fd")
    os.system("1d_tool.py -infile "+ 
              output_filerealign[i] + "1"+bold_mag_ext+"_mcf.1D" +
              " -derivative -collapse_cols euclidean_norm -write "+
              output_filerealign[i] + "1"+bold_mag_ext+"_mcf_enorm.1D -overwrite")    
####### Realigning all echos ##################################################
print("Realigning remaining echoes ")
realign_ref= sorted([os.path.join(root, x) 
                      for root,dirs,files in os.walk(bids_dir) 
                      for x in files if x.endswith(align_matrix_ext)])
realign_ref=sorted([x for x in realign_ref if output_dir in x])
if filt_pattern != None:
    realign_ref=sorted([directory for directory in realign_ref 
                  if filt_pattern in directory])
for i in range(len(source_sbref)):
    for echo in range(echoes):#indentation starts in 0
        tmp_filename=output_filerealign[i]+str(echo+1)
        tmp_filerealign=filerealign[i]+str(echo+1)
        print(f"Motion realignment for {tmp_filename}")
        os.system("3dAllineate -overwrite -base "+source_sbref[i]+
                  " -final cubic -1Dmatrix_apply "+ realign_ref[i]+
                  " -prefix "+ tmp_filename+bold_mag_ext+"_mcf_al.nii.gz "+
                  tmp_filerealign+bold_mag_ext+epi_ext)
        
        
