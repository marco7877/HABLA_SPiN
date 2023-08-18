"""
@author: Marco Flores-Coronado
@github: marco7877
"""
import os
import argparse
from itertools import product
'''
Note: You should have installed AFNI in order for this code to work. 
This code will remove the first and the last volumes from bolf acquisitions.
First volumes are removed to wait for magnetization stabilization.
Last volumes are removed because we acquired phase
'''
####### DEBUGG
#preproc_bold_ext="bold_dsd"
#echoes=4
#TE= "11 28 45 61"#1200 
#bids_dir="/bcbl/home/public/MarcoMotion/Habla_restingState/"
#output_dir="ME-ICA/"
#filt_pattern="1200"
####### Arguments #############################################################
parser=argparse.ArgumentParser(
        description="Creates a whole head mask from T1 uni-clean")
parser.add_argument("--echoes", default=None, type=int,
                    help="Number of echoes")
parser.add_argument("--TE", default=None, type=str,
                    help="Echo times in ms.")
parser.add_argument("--bids_dir", default=None, type=str,
                    help="Full path to the BIDS directory ")
parser.add_argument("--output_dir",default="ME-ICA/", type =str,
                    help ="""Directory to store output at.
                    Default is func_preproc:
                        -anat
                        -func
                        -func_preproc""")
parser.add_argument("--preproc_bold_ext", default="bold_dsd", type=str,
                    help="""bold preproc files name extention  without .nii.gz.
                    default is bold_dsd """)
parser.add_argument("--mask_ext", default="brain_mask", type = str,
                    help="""name pattern of mask to be used.
                    It has to be the ending of the file, e.g.:
                        brain_mask
                        acq-whead_mask""")
parser.add_argument("--filt_pattern", default=None, type=str,
                    help="""The string pattern to identify specific files:
                        This is useful to parallelize subjects, e.g.:
                        --filt_pattern 001
                        or to parallelize tasks, e.g. :
                        --filt_pattern task-breathhold
                        """)
args = parser.parse_args()
echoes=args.echoes
TE=args.TE
bids_dir=args.bids_dir
output_dir=args.output_dir
preproc_bold_ext=args.preproc_bold_ext
mask_ext=args.mask_ext
filt_pattern=args.filt_pattern
####### Find files ############################################################
# TODO: check with Cesar if we have to change dsd to another extention as in 
# Stephanos workflow
source_bold= sorted([os.path.join(root, x) 
                      for root,dirs,files in os.walk(bids_dir) 
                      for x in files if x.endswith(preproc_bold_ext+
                                                   ".nii.gz") 
                       if "part-mag" in x if "echo-1" in x])
## filter condition
if filt_pattern != None:
    source_bold=sorted([directory for directory in source_bold 
                  if filt_pattern in directory])
files=[directory.partition("echo-1") for directory in source_bold]
head,_,tail=zip(*files)
bold_names=list(set([directory.partition("func_preproc/")[-1]
                        for directory in source_bold]))
#subjects=sorted(list(set([file.split("_")[0] for file in bold_names])))
tasks=sorted(list(set([file.split("_")[2] for file in bold_names])))
dir_names=list(set([directory.partition("func_preproc/")[0]+output_dir 
           for directory in source_bold]))
source_mask=sorted([os.path.join(root,x)
                    for root,dirs,files in os.walk(bids_dir)
                    for x in files if x.endswith(mask_ext+".nii.gz")])
## filter condition
if filt_pattern != None:
    source_mask=sorted([directory for directory in source_mask
                  if filt_pattern in directory])
for directory in dir_names:
    if not os.path.exists(directory):
        os.mkdir(directory)
dir_names_out=sorted([r_step[0] + r_step[1]+mask_ext 
               for r_step in product(dir_names,tasks)])
del dir_names
for directory in dir_names_out:
    if not os.path.exists(directory):
        os.mkdir(directory)
if len(source_bold) != len(source_mask): 
    raise ValueError(f"""Something went wrong, 
                     there are an unequal number of epi images ({len(source_bold)})
                     and number of brain masks ({len(source_mask)})""")
if len(source_bold) != len(dir_names_out):
    raise ValueError(f"""Something went wrong, 
                     there are an unequal number of epi images ({len(source_bold)})
                     and number of output directories ({len(dir_names_out)})""")
for i in range(len(source_bold)):
    tmp_echoesfiles=""
    for j in range(echoes):
        tmp_echo=" "+head[i]+"echo-"+str(j+1)+tail[i]
        tmp_echoesfiles= tmp_echoesfiles+tmp_echo
    os.system("tedana -d"+tmp_echoesfiles+" -e "+TE+
              " --out-dir "+dir_names_out[i]+
              " --mask "+source_mask[i]+ " --overwrite")
