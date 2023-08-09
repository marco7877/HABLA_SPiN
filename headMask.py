import os
import argparse

'''
Note: You should have installed AFNI in order for this code to work. Remember to run MPRAGE before,
because we will search for files ended in rebiased_clean.nii.gz
'''

parser=argparse.ArgumentParser(
        description="Creates a whole head mask from T1 uni-clean")
parser.add_argument("--bids_dir", default=None, type=str,help="Full path to the BIDS directory ")
parser.add_argument("--dilate", default=3,type=int,help="Dilation size to close holes within head mask")

args = parser.parse_args()

bids_dir=args.bids_dir
dilate=str(args.dilate)

# Here we could have a condition to check if the script has already been run and the files are there.
# Im skipping this for now
#reading target files
source_T1= sorted([os.path.join(root, x) for root,dirs,files in os.walk(bids_dir) for x in files if x.endswith("uniclean_T1w.nii.gz")])
print(source_T1)
#making output file name
output_mask= [niifti.replace("uniclean_T1w.nii.gz", "whead_mask.nii.gz") for niifti in source_T1]
print("Calculating whole head mask")
for i in range(len(source_T1)):
    os.system("3dcalc" + " -a " + source_T1[i] + " -expr 'step(a-60)' " + " -prefix " + output_mask[i])
    os.system("3dmask_tool" + " -fill_holes -dilate_inputs " + " +" + dilate +" -" + dilate+ " -input "  + output_mask[i] + " -prefix " + output_mask[i] + " -overwrite" )

