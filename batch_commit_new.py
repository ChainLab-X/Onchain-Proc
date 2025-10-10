import subprocess
import random
import os

def run_cmd(cmd):
    subprocess.call(cmd, shell=True)

# 1. Get untracked files
status_output = subprocess.check_output("git status --porcelain", shell=True).decode('utf-8').splitlines()
untracked_folders = set()

for line in status_output:
    if line.startswith("?? "):
        path = line[3:]
        # Check if it is in contracts/smartcontracts
        if path.startswith("contracts/smartcontracts/"):
            parts = path.split("/")
            if len(parts) >= 3:
                # Add the folder name (contracts/smartcontracts/Folder/)
                folder_path = f"contracts/smartcontracts/{parts[2]}"
                untracked_folders.add(folder_path)

projects = list(untracked_folders)
projects.sort()
random.shuffle(projects)

if not projects:
    print("No new projects found to commit.")
    exit(0)

print(f"Found {len(projects)} new projects.")

# 2. Split into 2 chunks
n = len(projects)
chunk_size = n // 2 + 1
batches = [projects[i:i + chunk_size] for i in range(0, n, chunk_size)]

commits = [
    {
        "date": "2025-08-15 11:00:00 +0100",
        "msg": "Integrate additional community submissions (August Intake)"
    },
    {
        "date": "2025-09-20 15:45:00 +0100",
        "msg": "Onboard new cohort projects and improvements (September Intake)"
    }
]

for i, batch in enumerate(batches):
    if not batch:
        continue
        
    date = commits[i]['date']
    msg = commits[i]['msg']
    print(f"Processing Batch {i+1} with date {date} ({len(batch)} projects)")
    
    # Create file list
    batch_file = f"batch_new_{i}.txt"
    with open(batch_file, "w") as f:
        for project in batch:
            f.write(f"{project}\n")
            
    # Add files
    # Only adding the new paths
    run_cmd(f"cat {batch_file} | xargs -d '\n' git add --ignore-errors")
    
    # Commit
    env = os.environ.copy()
    env["GIT_AUTHOR_DATE"] = date
    env["GIT_COMMITTER_DATE"] = date
    
    subprocess.call(['git', 'commit', '-m', msg], env=env)

# Clean up
run_cmd("rm batch_new_*.txt")

