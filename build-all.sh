#!/usr/bin/env bash

set -euo pipefail

markdown_file="info.md"
# Unfortunately, didn't start with task area 1
first_task_area="ta2"
last_task_area="ta3"
first_stage="pre"
last_stage="post"

declare -a packages_array=(
  "cudnn"
  "magma"
  "torch"
)

function get_outputs() {
  # shellcheck disable=SC2178
  local -n arr_ref=$1
  local attr=$2

  readarray -t arr_ref < <(nix eval --json ".#$attr.outputs" | jq -cr '.[]')
}

function get_short_path_info() {
  # shellcheck disable=SC2178
  local -n arr_ref=$1
  local attr=$2

  IFS=$'\t ' read -ra arr_ref < <(nix path-info -sSh ".#$attr")
  if [ "${#arr_ref[@]}" -ne 3 ]; then
    echo "get_short_path_info: Unexpected number of elements: ${#arr_ref[@]}"
    exit 1
  fi
}

function write_markdown_summary_subsection() {
  local subsection_name=$1
  local task_area=$2
  local stage=$3

  {
    echo
    echo "### $subsection_name"
    echo
    echo "| Package | Output | NAR Size | Closure Size |"
    echo "| ------- | ------ | -------- | ------------ |"
  } >>"$markdown_file"

  for package in "${packages_array[@]}"; do
    attr="$package-nixpkgs-$task_area-$stage"
    nom build --no-link ".#$attr"

    local -a outputs_array
    get_outputs outputs_array "$attr"

    for output in "${outputs_array[@]}"; do
      attr_with_output="$attr.$output"
      nom build --no-link ".#$attr_with_output"

      local -a short_path_info_array
      get_short_path_info short_path_info_array "$attr_with_output"

      echo "| $package | $output | ${short_path_info_array[1]} | ${short_path_info_array[2]} |" >>"$markdown_file"
    done
  done
}

function write_markdown_summary() {
  {
    echo
    echo "## Summary"
  } >>"$markdown_file"

  write_markdown_summary_subsection "At work start" "$first_task_area" "$first_stage"
  write_markdown_summary_subsection "At work end" "$last_task_area" "$last_stage"
}

function write_markdown_table() {
  echo "# Info" >"$markdown_file"

  write_markdown_summary
}

write_markdown_table

echo "Wrote $markdown_file"
exit 0
