#!/bin/bash

# Script to generate PR statistics for a given month
# Usage: ./pr_stats.sh YYYY-MM [username]
# Example: ./pr_stats.sh 2024-05
# Example: ./pr_stats.sh 2025-05 caramelomartins

set -euo pipefail

# Function to display usage
usage() {
    echo "Usage: $0 YYYY-MM-DD [username]"
    echo "Example: $0 2024-05-01 2025-05-31"
    echo "Example: $0 2025-05-01 2025-05-31 caramelomartins"
    exit 1
}

# Check if month is provided
if [ $# -lt 2 ]; then
    usage
fi

START_DATE="$1"
END_DATE="$2"
USERNAME="${3:-@me}"

if [[ ! "$START_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "Error: Start must be in YYYY-MM-DD format"
    usage
fi

if [[ ! "$END_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "Error: End must be in YYYY-MM-DD format"
    usage
fi

echo "Fetching PRs for $USERNAME from $START_DATE to $END_DATE..."

# Fetch all PRs for the month
PR_DATA=$(gh pr list --author="$USERNAME" --state=merged --search="merged:${START_DATE}..${END_DATE}" --json number,title,createdAt,state,url)

if [ "$PR_DATA" = "[]" ]; then
    echo "No PRs found for $USERNAME."
    exit 0
fi

# Extract merged and open PRs
MERGED_PRS=$(echo "$PR_DATA" | jq -r '.[] | select(.state == "MERGED") | .number' | sort -nr)
OPEN_PRS=$(echo "$PR_DATA" | jq -r '.[] | select(.state == "OPEN") | .number' | sort -nr)
CLOSED_PRS=$(echo "$PR_DATA" | jq -r '.[] | select(.state == "CLOSED") | .number' | sort -nr)

# Function to get PR details
get_pr_details() {
    local pr_number="$1"
    gh pr view "$pr_number" --json number,title,additions,deletions,changedFiles,commits,createdAt,mergedAt
}

# Function to format date
format_date() {
    local iso_date="$1"
    date -d "$iso_date" "+%B %d, %Y" 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$iso_date" "+%B %d, %Y" 2>/dev/null || echo "$iso_date"
}

# Function to generate markdown for PR list
generate_pr_markdown() {
    local pr_type="$1"
    local pr_list="$2"
    local show_stats="$3"

    if [ -z "$pr_list" ]; then
        return
    fi

    echo "#### $pr_type PRs"
    echo ""

    local total_additions=0
    local total_deletions=0
    local total_files=0
    local total_commits=0
    local pr_count=0

    for pr in $pr_list; do
        local pr_details=$(get_pr_details "$pr")
        local title=$(echo "$pr_details" | jq -r '.title')
        local created_at=$(echo "$pr_details" | jq -r '.mergedAt')
        local additions=$(echo "$pr_details" | jq -r '.additions // 0')
        local deletions=$(echo "$pr_details" | jq -r '.deletions // 0')
        local files=$(echo "$pr_details" | jq -r '.changedFiles // 0')
        local commits=$(echo "$pr_details" | jq -r '.commits | length')

        local formatted_date=$(format_date "$created_at")

        if [ "$show_stats" = "true" ]; then
            echo "- **$formatted_date** - [#$pr - $title](https://github.com/DataDog/dd-source/pull/$pr) - +$additions/-$deletions lines, $files files, $commits commits"
            total_additions=$((total_additions + additions))
            total_deletions=$((total_deletions + deletions))
            total_files=$((total_files + files))
            total_commits=$((total_commits + commits))
        else
            echo "- **$formatted_date** - [#$pr - $title](https://github.com/DataDog/dd-source/pull/$pr)"
        fi

        pr_count=$((pr_count + 1))
    done

    if [ "$show_stats" = "true" ] && [ $pr_count -gt 0 ]; then
        echo ""
        echo "**Total: $pr_count $pr_type PRs - +$total_additions/-$total_deletions lines, $total_files files, $total_commits commits**"
    fi

    echo ""
}

# Generate the markdown report
echo "### PR Statistics"
echo ""

# Generate merged PRs with stats
if [ -n "$MERGED_PRS" ]; then
    generate_pr_markdown "Merged" "$MERGED_PRS" "true"
fi

# Generate open PRs without stats
if [ -n "$OPEN_PRS" ]; then
    generate_pr_markdown "Open" "$OPEN_PRS" "false"
fi

# Generate closed PRs without stats
if [ -n "$CLOSED_PRS" ]; then
    generate_pr_markdown "Closed" "$CLOSED_PRS" "false"
fi
