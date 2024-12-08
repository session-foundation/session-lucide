#!/bin/bash

set -e

mute=">/dev/null 2>&1"
if [[ "$1" == "-v" ]]; then
	mute=
fi

cwd="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
workdir="$(mktemp -d)"
mkdir -p "${workdir}/Logs"
# trap 'rm -rf "$workdir"' EXIT
source_dir="${workdir}/Lucide-source"
release_dir="${workdir}/Lucide-release"

print_usage_and_exit() {
	cat <<- EOF
	Usage:
	  $ $(basename "$0") [-v] [-h] [<lucide_tag>]

	Options:
	 -h      Show this message
	 -v      Verbose output
	EOF

	exit 1
}

read_command_line_arguments() {
	while getopts 'hv' OPTION; do
		case "${OPTION}" in
			h)
				print_usage_and_exit
				;;
			v)
				mute=
				;;
			*)
				;;
		esac
	done

	shift $((OPTIND-1))

	lucide_tag="$1"
	if [[ -n "$lucide_tag" ]]; then
		force_release=1
	fi
}

clone_source() {
	if ! [[ -d "$source_dir" ]]; then
		rm -rf "$source_dir"
	fi

	printf '%s' "Cloning upstream Lucide... "
	eval git clone https://github.com/lucide-icons/lucide.git "$source_dir" "$mute"
	cd "${source_dir}"
	lucide_tag="${1:-$(git describe --tags --abbrev=0)}"
	eval git checkout "${lucide_tag}" "$mute"
	echo "Checked out at ${lucide_tag} ✅"
}

download_release() {
	if ! [[ -d "$release_dir" ]]; then
		rm -rf "$release_dir"
	fi
	
	printf '%s' "Downloading latest Lucide release... "
	ASSET_URL=$(curl -s "https://api.github.com/repos/lucide-icons/lucide/releases/tags/$lucide_tag" | \
		jq -r ".assets[] | select(.name | test(\"font\")) | select(.name | endswith(\".zip\")) | .browser_download_url")
 
	if [ -z "$ASSET_URL" ]; then
	    echo "No assets containing 'font' found in release $lucide_tag."
	    exit 1
	fi

	mkdir "${release_dir}"
	ASSET_NAME=$(basename "$ASSET_URL")
	curl -s -L -o "$release_dir/$ASSET_NAME" "$ASSET_URL"

	if [[ "$ASSET_NAME" == *.zip ]]; then
	    unzip -q -o "$release_dir/$ASSET_NAME" -d "$release_dir"
	fi

	echo "Retrieved $lucide_tag ✅"
}

update_readme() {
	current_version="$(git describe --tags --abbrev=0 --exclude=v* main)"
	current_upstream_version="$(grep '\* Lucide' README.md | cut -d '*' -f 3)"

	export new_version upstream_version="${lucide_tag#v}"

	if [[ "${current_upstream_version}" == "${upstream_version}" ]] && \
		[[ -z "$force_release" ]]; then
		echo "Lucide (${upstream_version}) version did not change. Skipping release."
		exit 1
	fi

	cat <<- EOF

	Session Lucide current version: ${current_version}
	Upstream Lucide version: ${current_upstream_version} -> ${upstream_version}
	EOF

	while ! [[ "${new_version}" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]; do
		read -rp "Input Session Lucide desired version number (x.y.z): " new_version < /dev/tty
	done

	envsubst < "${cwd}/assets/README.md.in" > README.md

	echo "Updated README.md ✅"
}

setup_log_formatter() {
	if command -v xcbeautify &> /dev/null; then
		log_formatter='xcbeautify'
	elif command -v xcpretty &> /dev/null; then
		log_formatter='xcpretty'
	else
		echo
		echo "xcbeautify and xcpretty not found - not prettifying Xcode logs. You can install xcbeautify using 'brew install xcbeautify'."
		echo
		log_formatter='tee'
	fi
}

generate_swift_code() {
	local json_path="$1"
	local output_swift_path="$2"

	# Process JSON and generate Swift enum cases
    icons=$(jq -rc 'to_entries | .[] | 
        # Convert kebab-case to camelCase
        (.key |
        	split("-") | 
        	to_entries | 
        	map(
        	    if .key == 0 then 
                	.value  # Keep the first element in lowercase
	            else 
	                (.value | ascii_upcase | .[0:1]) + .value[1:]  # Capitalize subsequent words
	            end
        	) |
        	join("")
        ) as $camelCase | 
        
        # Convert encoded unicode
        (.value | 
            if type == "object" and has("encodedCode") then 
                .encodedCode | 
                ltrimstr("\\") | 
                "\\u{" + . + "}"
            else 
                "\"\"" 
            end
        ) as $unicodeChar |

        # Convert to Swift with special handling for reservede terms
        if $camelCase | test("^(import|repeat|subscript)$") then
            "        case `\($camelCase)` = \"\($unicodeChar)\""
        else
            "        case \($camelCase) = \"\($unicodeChar)\""
        end
    ' "$json_path")

	# Create a placeholder Swift file for static variables (you can replace this later)
	cat > $output_swift_path << EOF
// This file is dynamically generated so shouldn't be modified directly

import Foundation

public extension Lucide {
    // Dynamically generated icon cases from JSON
    public enum Icon: String {
$icons
    }
}
EOF
}

update_sources() {
	local license_path="${cwd}/LICENSE"
	local font_path="${cwd}/Sources/Lucide/lucide.ttf"
	local swift_path="${cwd}/Sources/Lucide/Lucide+Icon.swift"

	printf '%s' "Updating Sources..."

	rm -rf "${license_path}" "${swift_path}" "${font_path}"

	# Generate the framework contents
	cp "${source_dir}/LICENSE" "${license_path}"
	cp "${release_dir}/lucide-font/lucide.ttf" "${font_path}"
	generate_swift_code "${release_dir}/lucide-font/info.json" "${swift_path}"

	echo "✅"
}

make_release() {
	echo "Making ${new_version} release... 🚢"

	local commit_message="Session Lucide ${new_version} (Lucide ${upstream_version})"

	cd "${cwd}"
	git add "${cwd}/README.md" "${cwd}/LICENSE" "${cwd}/Sources/Lucide/lucide.ttf" "${cwd}/Sources/Lucide/Lucide+Icon.swift"
	git commit -m "$commit_message"
	git tag -m "$commit_message" "$new_version"

	cat <<- EOF

	🎉 Release is ready"
	EOF
}

main() {
	printf '%s\n' "Using directory at ${workdir}"

	read_command_line_arguments "$@"

	clone_source "$lucide_tag"
	download_release "$lucide_tag"
	update_readme
	update_sources
	make_release
}

main "$@"
