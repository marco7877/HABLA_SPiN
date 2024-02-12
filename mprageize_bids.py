import os
import argparse

'''
Note: The 3dMPRAGEize script in the repo must be edited to write out .nii.gz instead of .nii files
'''

parser = argparse.ArgumentParser(
    description="Removes background noise from MP2RAGE uni images and names them in a BIDS-like way")
parser.add_argument("--bids_dir",default=None,type=str,help="Full path to BIDS directory")
parser.add_argument("--mprageize_dir",default=None,type=str,help="Full path to MPRAGEize git repo")
parser.add_argument("--overwrite",required=False,default=False,type=bool,help="Set to True if you want to mprageize T1s, even if some or all have already been mprageized.")

args = parser.parse_args()

bids_dir = args.bids_dir
mprageize_dir = args.mprageize_dir
mprageize = mprageize_dir + "/3dMPRAGEize"
overwrite = args.overwrite

if [x for root,dirs,files in os.walk(bids_dir) for x in files if x.endswith("uniclean_T1w.nii.gz")] and not overwrite:
    raise Exception("Some images have already been mprageized. Run again with '--overwrite True' if you want to rerun anyway.")

inv2_images = sorted([os.path.join(root,x) for root,dirs,files in os.walk(bids_dir) for x in files if x.endswith("inv2_T1w.nii.gz")])
uni_images = sorted([os.path.join(root,x) for root,dirs,files in os.walk(bids_dir) for x in files if x.endswith("uni_T1w.nii.gz")])
uni_jsons = [x.replace(".nii.gz", ".json") for x in uni_images]
rename_cleaned_images = []
cleaned_jsons = []

if len(inv2_images) != len(uni_images):
    raise ValueError(f"Something went wrong, there are an unequal number of inv2 ({len(inv2_images)}) and uni ({len(uni_images)}) images")

for i in range(len(inv2_images)):
    if os.path.split(inv2_images[i])[0] != os.path.split(uni_images[i])[0]:
        raise FileNotFoundError(f"No matching uni image for inv2 image:{inv2_images[i]}")
        
    os.system(mprageize + " -i " + inv2_images[i] + " -u " + uni_images[i] )

    new_name = uni_images[i].replace("acq-uni_", "acq-uniclean_")
    rename_cleaned_images.append(new_name)
    cleaned_jsons.append(new_name.replace(".nii.gz", ".json"))

#cleaned_images = sorted([os.path.join(root,x) for root,dirs,files in os.walk("./") for x in files if x.endswith("unbiased_clean.nii.gz")])
cwd=os.getcwd()
print(f"you are running this script in {cwd}")
cleaned_images = sorted([f for f in os.listdir("./") if f.endswith("unbiased_clean.nii.gz")])
if len(cleaned_images) != len(rename_cleaned_images):
    raise ValueError(f"Something went wrong, there are an unequal number of cleaned images ({len(cleaned_images)}) and names to call them ({len(rename_cleaned_images)})")
if len(uni_jsons) != len(cleaned_jsons):
    raise ValueError(f"Something went wrong, there are an unequal number of old ({len(uni_jsons)}) and new ({len(cleaned_jsons)}) json filenames")


for i in range(len(cleaned_images)):
    os.rename(cleaned_images[i],rename_cleaned_images[i])
    os.system(f"cp {uni_jsons[i]} {cleaned_jsons[i]}")

