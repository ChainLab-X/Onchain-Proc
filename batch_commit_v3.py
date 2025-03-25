import subprocess
import os

def run_cmd(cmd):
    subprocess.call(cmd, shell=True)

# Define the batches and their metadata
batches = [
    {
        "file": "batch_0.txt",
        "date": "2025-01-15 10:00:00 +0100",
        "msg": "Initialize smart contract repository with foundational voting and DeFi protocols"
    },
    {
        "file": "batch_1.txt",
        "date": "2025-02-20 14:30:00 +0100",
        "msg": "Integrate diverse collection of ERC-20, NFT, and PiggyBank implementations"
    },
    {
        "file": "batch_2.txt",
        "date": "2025-03-25 09:15:00 +0100",
        "msg": "Expand ecosystem with Multi-chain deployments, Scholarship Managers, and advanced contract logic"
    }
]

for i, batch in enumerate(batches):
    print(f"Processing Batch {i+1}: {batch['msg']}")
    
    # Check if batch file exists
    if not os.path.exists(batch['file']):
        print(f"Error: {batch['file']} not found")
        continue

    # Add files from the batch list
    # The batch file contains paths. We need to add them.
    # Since we did a mixed reset, the file changes are in working tree but unstaged.
    # Note: The batch file lists both New and Old paths. 
    # Adding the Old path (which is deleted) stages the deletion.
    # Adding the New path stages the new file.
    
    run_cmd(f"cat {batch['file']} | xargs -d '\n' git add --ignore-errors")
    
    # Commit
    env = os.environ.copy()
    env["GIT_AUTHOR_DATE"] = batch['date']
    env["GIT_COMMITTER_DATE"] = batch['date']
    
    subprocess.call(['git', 'commit', '-m', batch['msg']], env=env)

# Final cleanup commit
print("Processing Final Cleanup...")
run_cmd("git add -u")
# Also add any untracked files that might be lingering (like .gitignore changes etc if missed)
run_cmd("git add .") 

env = os.environ.copy()
env["GIT_AUTHOR_DATE"] = batches[-1]['date'] # Use last date
env["GIT_COMMITTER_DATE"] = batches[-1]['date']
subprocess.call(['git', 'commit', '-m', 'Finalize directory restructure and cleanup'], env=env)

