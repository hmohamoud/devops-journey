timestamp() {
	echo "$(date "$TIMESTAMP_FORMAT")"
	
}

log_info() {
	local message="$1"
	echo "[$(timestamp)] $message"

}

require_dir(){
	local directory="$1"
	if [ ! -d "$directory" ]; then
		mkdir -p "$directory"
		log_info "Directory created: $directory"
	fi
	return 0
}

log_error() {
	local message="$1"
	require_dir "$ERROR_DIR"
	echo "[$(timestamp)] $message" >> "$ERROR_DIR/toolkit-error-$(timestamp).log"
}

validate_arg_count(){
	local actual="$1"
	local required="$2"
	if [ "$actual" -ne "$required" ]; then
		log_error "Invalid argument count for $0"
		return 2
	else
		return 0
	fi
}

require_file(){
	local file="$1"
	if [ ! -f "$file" ]; then
		log_error "Required file not found: $file"
		return 1
	else
		return 0
	fi
}

