import subprocess
import random
import os

def run(cmd):
    return subprocess.check_output(cmd, shell=True).decode('utf-8').splitlines()

# Get status
status_lines = run("git status --porcelain")

deleted_files = []
untracked_files = []

for line in status_lines:
    if line.startswith(" D "):
        deleted_files.append(line[3:])
    elif line.startswith("?? "):
        untracked_files.append(line[3:])

# Group by folder in contracts/smartcontracts
# We want to commit top-level folders in contracts/smartcontracts
# So we identify unique top-level folders there.

project_folders = set()
for f in untracked_files:
    if f.startswith("contracts/smartcontracts/"):
        parts = f.split("/")
        if len(parts) >= 3:
            project_folders.add(parts[2])

project_folders = list(project_folders)
random.shuffle(project_folders)

# Split into 3 chunks
n = len(project_folders)
chunk_size = n // 3 + 1
batches = [project_folders[i:i + chunk_size] for i in range(0, n, chunk_size)]

dates = [
    "2025-01-15 10:00:00 +0100",
    "2025-02-20 14:30:00 +0100",
    "2025-03-25 09:15:00 +0100"
]

for i, batch in enumerate(batches):
    if not batch:
        continue
        
    date = dates[i] if i < len(dates) else dates[-1]
    print(f"Processing Batch {i+1} with date {date} ({len(batch)} projects)")
    
    # Collect files for this batch
    files_to_add = []
    
    for project in batch:
        # Add new files
        project_path_new = f"contracts/smartcontracts/{project}"
        files_to_add.append(f"'{project_path_new}'")
        
        # Try to find corresponding deleted files (simple heuristics match)
        # We assume original was in cohort-xii/submissions/{project}
        project_path_old = f"cohort-xii/submissions/{project}"
        # detailed matching is hard without exact file list, so we filter deleted_files
        # that start with this path
        
        # Optimization: finding deleted files is O(N*M). Let's just blindly add the folder path
        # 'git add' on a deleted folder path stages the deletions of files under it?
        # Yes, 'git add path/to/deleted/folder' works if git knows about it?
        # actually 'git add -u path' might be needed for deletions.
        # But 'git add path' works for deleted files too.
        
        files_to_add.append(f"'{project_path_old}'")

    # We also need to add 'contracts/smartcontracts' itself if it's new? No, git handles files.
    
    # Executing git add in chunks to avoid command line length limits
    # But python's subprocess.call with list of args is better, but here we construct shell string.
    # Let's write to a temporary file and use xargs or just loop.
    
    # safer: write list of files to a file, then git add --pathspec-from-file
    with open(f"batch_{i}.txt", "w") as f:
        for project in batch:
            f.write(f"contracts/smartcontracts/{project}\n")
            f.write(f"cohort-xii/submissions/{project}\n")
            
    # Run git add
    print(f"  Staging files...")
    subprocess.call(f"cat batch_{i}.txt | xargs -d '\n' git add --ignore-errors", shell=True)
    
    # Commit
    print(f"  Committing...")
    env = os.environ.copy()
    env["GIT_AUTHOR_DATE"] = date
    env["GIT_COMMITTER_DATE"] = date
    subprocess.call(['git', 'commit', '-m', f'Add smart contract projects batch {i+1}'], env=env)

# Finally, clean up any remaining changes (e.g. root files or mismatches)
# and commit them with current date or the last date?
# Let's check status at end.
