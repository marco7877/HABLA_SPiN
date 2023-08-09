import os
import argparse

'''
Note: You should have installed AFNI in order for this code to work. Remember to run MPRAGE before,
because we will search for files ended in rebiased_clean.nii.gz
'''

#parser=argparse.ArgumentParser(
#        description="Creates a whole head mask from T1 uni-clean")
#parser.add_argument("--bids_dir", default=None, type=str,help="Full path to the BIDS directory ")
#parser.add argument("--echoes, default= None, type=integer, help="Number of echoes ")
#args = parser.parse_args()
#bids_dir=args.bids_dir
bids_dir= "/bcbl/home/public/MarcoMotion/Habla_restingState"
#echoes=args.parse_args()
echoes=4
# Here we could have a condition to check if the script has already been run and the files are there.
# Im skipping this for now
#reading target files
source_bold= sorted([os.path.join(root, x) for root,dirs,files in os.walk(bids_dir) for x in files if x.endswith("echo-1_bold.nii.gz")])
#making output file name
name_meanfiles=[x.split("/")[-1] for x in source_bold]
file_len=[len(x) for x in name_meanfiles]
name_meanfiles=[x.replace(".nii.gz","") for x in name_meanfiles]
test=[x.replace("/sub-00*_ses_*", "") for x in source_bold]
print(f"Generating {len(source_bold)} reference image for motion correction (mean based)")
for i in range(len(source_bold)):
    os.chdir(source_bold[i][0:-file_len[i]])
    os.system("3dTstat -mean -prefix "+ name_meanfiles[i]+"mean_ref "+ source_bold[i]) 
print("Realigning volumes")
realign_ref= sorted([os.path.join(root, x) for root,dirs,files in os.walk(bids_dir) for x in files if x.endswith(".HEAD")])
name_meanfiless=[x.replace("1_bold","") for x in name_meanfiles]
for i in range(len(realign_ref)):
    for echo in range(echoes):
        filename=name_meanfiless+str(echo)
        target_dir=source_bold[i][0:-file_len[i]]
        os.chdir(target_dir)
        os.system("3dvolreg -Fourier -base " + realign_ref[i] + " -1Dfile "+
                  filename + "_mfc.1D -1Dmatrix_save " + filename +
                  "_mcf.aff12.1D -prefix " + filename + "_mcf.nii.gz "+ 
                  "-overwrite " + filename + "_bold.nii.gz")
