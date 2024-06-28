#bash!

usage() {
    echo "Usage: $0 --session <session_name>"
    echo "This script is a wrapper for the following command:"
    echo "ssh -o TCPKeepAlive=no -t <username@hostname> \"tmux kill-session -t '\$session'\""
    echo "The script first tests the SSH connection before running the main command."
    echo "The --session option specifies the name of the tmux session to be closed."
    exit 1
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --session)
            session="$2"
            shift # past argument
            shift # past value
            ;;
        *)
            usage
            ;;
    esac
done

if [ -z "$session" ]; then
    usage
fi

echo "Testing SSH connection..."
ssh -o TCPKeepAlive=no -o BatchMode=yes -o ConnectTimeout=5 "$user_host" exit
if [ $? -ne 0 ]; then
    echo "Error: Failed to connect to the remote server. Please check your credentials and network connection."
    exit 1
fi
echo "SSH connection test successful."

echo "Closing tmux session '$session' on the remote server..."
remote_command="tmux kill-session -t '$session'"
ssh -o TCPKeepAlive=no -t "$user_host" "$remote_command"
exit_status=$?

if [ $exit_status -ne 0 ]; then
    echo "Error: Failed to close the tmux session. Please check the remote environment and configuration."
    exit $exit_status
fi

echo "Tmux session '$session' closed successfully."
echo "Exiting the shell to close the SSH connection..."
exit