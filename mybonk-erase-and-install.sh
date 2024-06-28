#bash!

construct_nix_run_command() {
    local target_host="$1" flake="$2" test_mode="$3"
    local nix_run_command="nix run github:nix-community/nixos-anywhere -- --flake ".#$flake" root@$target_host"
    [[ "$test_mode" == "true" ]] && nix_run_command+=" --vm-test"
    echo "$nix_run_command"
}

confirm_operation() {
    echo "### ALL DATA WILL BE LOST ###"
    echo "This action will change the partitions and format the drive(s) on the target machine."
    echo "The following command will be executed:" 
    echo "$nix_run_command"
    echo "Are you really certain you want to run it? (y/n)"
    read -r confirmation
    [[ "$confirmation" != "y" ]] && echo "Operation cancelled." && exit 0
}

test_ssh_connection() {
    local host="$1"
    echo "-------------------------------------------------"
    echo "Testing SSH connection $host..."
    ssh -o StrictHostKeyChecking=no "$host" "exit" </dev/null 2>&1 | grep -v "^debug" || { echo "Failed to connect to $host via SSH. Please check your SSH key setup."; exit 1; }
    echo "Test SSH connection for $host successful."
}

run_nix_run() {
    local nix_run_command="$1"
    local start_time=$(date +%s)
    $nix_run_command || { local end_time=$(date +%s); echo "Error executing nix run after $(display_elapsed_time $((end_time - start_time))). 😞"; exit 1; }
    local end_time=$(date +%s)
    echo "⏱️ Operation took $(display_elapsed_time $((end_time - start_time)))"
    echo "✅ Operation completed successfully 🚀"
}

display_elapsed_time() {
    local seconds=$1 days=$((seconds / 86400)) hours=$((seconds / 3600 % 24)) minutes=$((seconds / 60 % 60)) seconds=$((seconds % 60))
    printf "%ds (%02dd, %02dh, %02dm, %02ds)" $seconds $days $hours $minutes $seconds
}

usage() {
    echo "Usage: $0 <target-host> <flake> [--test]"
    echo "Options:"
    echo "  --test  Run the operation in test mode (adds --vm-test to the nix run command)"
    exit 1
}

[[ -z "$1" || -z "$2" ]] && usage

target_host="$1" flake="$2" test_mode="false"
[[ "$3" == "--test" ]] && test_mode="true"

nix_run_command=$(construct_nix_run_command "$target_host" "$flake" "$test_mode")
confirm_operation
#test_ssh_connection "$target_host"
run_nix_run "$nix_run_command"