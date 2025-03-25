import subprocess
import random
import os

def run_cmd(cmd):
    subprocess.call(cmd, shell=True)

# 1. Get list of projects in contracts/smartcontracts
base_dir = "contracts/smartcontracts"
projects = [f for f in os.listdir(base_dir) if os.path.isdir(os.path.join(base_dir, f))]
projects.sort() # consistenoy
random.shuffle(projects)

# 2. Split into 3 chunks
n = len(projects)
chunk_size = n // 3 + 1
batches = [projects[i:i + chunk_size] for i in range(0, n, chunk_size)]

dates = [
    "2025-01-15 10:00:00 +0100",  # Jan
    "2025-02-20 14:30:00 +0100",  # Feb
    "2025-03-25 09:15:00 +0100"   # Mar
]

old_base_dir = "cohort-xii/submissions"

for i, batch in enumerate(batches):
    if not batch:
        continue
        
    date = dates[i] if i < len(dates) else dates[-1]
    print(f"Processing Batch {i+1} with date {date} ({len(batch)} projects)")
    
    # Create file list for git add
    with open(f"batch_{i}.txt", "w") as f:
        for project in batch:
            # New location
            f.write(f"contracts/smartcontracts/{project}\n")
            # Old location (to stage deletion)
            f.write(f"{old_base_dir}/{project}\n")
            
    # Add files
    # We use xargs to handle many files. -d '\n' handles spaces in filenames.
    run_cmd(f"cat batch_{i}.txt | xargs -d '\n' git add --ignore-errors")
    
    # Commit
    env = os.environ.copy()
    env["GIT_AUTHOR_DATE"] = date
    env["GIT_COMMITTER_DATE"] = date
    # Clean env of other GIT vars? No, just set dates.
    
    msg = f"Add smart contracts batch {i+1}"
    subprocess.call(['git', 'commit', '-m', msg], env=env)

# Final cleanup: commit any remaining deletions or root changes
# This catches files that might have been missed or root level changes
run_cmd("git add -u")
env = os.environ.copy()
env["GIT_AUTHOR_DATE"] = dates[-1] # Use last date
env["GIT_COMMITTER_DATE"] = dates[-1]
subprocess.call(['git', 'commit', '-m', 'Clean up remaining files and deletions'], env=env)

