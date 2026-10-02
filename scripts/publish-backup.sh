#!/usr/bin/env bash
#
# Publish a worksheets backup zip to the site: branch, unzip, swap in the files
# as they come, verify the links, commit, push, open a PR.
#
#   scripts/publish-backup.sh                      # newest *.zip in the repo root
#   scripts/publish-backup.sh ~/Downloads/backup.zip
#   scripts/publish-backup.sh backup.zip --dry-run
#
# The zip's folder structure is used as-is. Everything else at the repo root is
# cleared out, except what KEEP lists below -- skills/ is never touched.

set -euo pipefail

# Paths at the repo root that a publish leaves alone. Everything else at the
# root is removed before the backup is unpacked in its place.
KEEP=(.git .gitignore .idea LICENSE README.md skills scripts)

BASE_BRANCH="main"
BRANCH_PREFIX="backup"

# Homebrew's bin is not on PATH in every shell; gh lives there.
[ -d /opt/homebrew/bin ] && PATH="/opt/homebrew/bin:$PATH"

DRY_RUN=0
NO_PR=0
ALLOW_BROKEN=0
ZIP_ARG=""

usage() {
  sed -n '3,12p' "$0" | sed 's/^# \{0,1\}//'
  cat <<'EOF'

Options:
  --dry-run        Make the changes on the branch but stop before committing.
  --no-pr          Commit and push, but do not open a pull request.
  --allow-broken   Continue even if some links do not resolve (default: abort).
  -h, --help       Show this help.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run)      DRY_RUN=1 ;;
    --no-pr)        NO_PR=1 ;;
    --allow-broken) ALLOW_BROKEN=1 ;;
    -h|--help)      usage; exit 0 ;;
    -*)             echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
    *)              ZIP_ARG="$1" ;;
  esac
  shift
done

die() { echo "error: $*" >&2; exit 1; }
step() { printf '\n==> %s\n' "$*"; }

# --- preconditions ----------------------------------------------------------

command -v git >/dev/null || die "git not found"
command -v unzip >/dev/null || die "unzip not found"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || die "not inside a git repository"
cd "$ROOT"

if [ -n "$ZIP_ARG" ]; then
  ZIP="$ZIP_ARG"
else
  # Newest zip sitting in the repo root.
  ZIP="$(ls -t ./*.zip 2>/dev/null | head -1)" || true
  [ -n "${ZIP:-}" ] || die "no zip found in the repo root; pass one as an argument"
fi
[ -f "$ZIP" ] || die "not a file: $ZIP"
ZIP="$(cd "$(dirname "$ZIP")" && pwd)/$(basename "$ZIP")"
unzip -tq "$ZIP" >/dev/null 2>&1 || die "not a readable zip: $ZIP"

if git status --porcelain | grep -qv '^??'; then
  git status --short | grep -v '^??' >&2
  die "you have uncommitted changes to tracked files; commit or stash them first"
fi

if [ "$NO_PR" -eq 0 ] && [ "$DRY_RUN" -eq 0 ]; then
  command -v gh >/dev/null || die "gh not found (install it, or pass --no-pr)"
  gh auth status >/dev/null 2>&1 || die "gh is not logged in; run: gh auth login"
fi

# --- unpack -----------------------------------------------------------------

STAGE="$(mktemp -d "${TMPDIR:-/tmp}/publish-backup.XXXXXX")"
cleanup_stage() { rm -rf "$STAGE"; }
trap cleanup_stage EXIT

step "Unzipping $(basename "$ZIP")"
unzip -q "$ZIP" -d "$STAGE"
rm -rf "$STAGE/__MACOSX"

# A backup zip normally holds one top-level folder; use its contents as the
# payload so that folder name does not end up in the repo.
PAYLOAD="$STAGE"
entries=$(find "$STAGE" -mindepth 1 -maxdepth 1 ! -name '.DS_Store' | wc -l | tr -d ' ')
if [ "$entries" -eq 1 ]; then
  only="$(find "$STAGE" -mindepth 1 -maxdepth 1 ! -name '.DS_Store')"
  [ -d "$only" ] && PAYLOAD="$only"
fi
[ -f "$PAYLOAD/table-of-contents.dc.html" ] ||
  die "the zip does not look like a backup (no table-of-contents.dc.html at its top level)"
echo "    $(find "$PAYLOAD" -type f | wc -l | tr -d ' ') files to publish"

# --- branch -----------------------------------------------------------------

BRANCH="$BRANCH_PREFIX-$(date +%Y-%m-%d)"
n=2
while git show-ref --quiet --verify "refs/heads/$BRANCH"; do
  BRANCH="$BRANCH_PREFIX-$(date +%Y-%m-%d)-$n"
  n=$((n + 1))
done
step "Creating branch $BRANCH"
PREV_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
git checkout -q -b "$BRANCH"

# From here on the working tree is mid-swap, so say how to get back out.
on_failure() {
  cat >&2 <<EOF

Stopped on $BRANCH with the working tree already changed. To undo it all:
  git reset --hard HEAD && git checkout $PREV_BRANCH && git branch -D $BRANCH
EOF
}
trap 'cleanup_stage; on_failure' ERR

# --- clear the old site, unpack the new one ---------------------------------

step "Clearing the old site files"
keep_this() {
  local name="$1" k
  for k in "${KEEP[@]}"; do [ "$name" = "$k" ] && return 0; done
  # The zip itself, wherever the user left it, and local scratch files.
  [ "$ROOT/$name" = "$ZIP" ] && return 0
  case "$name" in .DS_Store|*.zip) return 0 ;; esac
  return 1
}
removed=0
while IFS= read -r entry; do
  name="$(basename "$entry")"
  if keep_this "$name"; then continue; fi
  rm -rf "$entry"
  removed=$((removed + 1))
done < <(find "$ROOT" -mindepth 1 -maxdepth 1)
echo "    removed $removed path(s) from the repo root"

step "Unpacking the backup as-is"
cp -R "$PAYLOAD/." "$ROOT/"
find "$ROOT" -name '.DS_Store' -delete

# --- fix known-bad links, verify every link ---------------------------------

step "Checking links"
ALLOW_BROKEN="$ALLOW_BROKEN" python3 - "$ROOT" <<'PY'
import os, re, sys, pathlib

root = pathlib.Path(sys.argv[1]).resolve()
allow_broken = os.environ.get("ALLOW_BROKEN") == "1"

# Links the exporter gets wrong in ways no rule can derive: the page points at a
# filename that has never existed. Keyed by the page's path within the site, so
# a wrong link in one chapter cannot silently rewrite another's.
KNOWN_FIXES = {
    ("worksheets/interactive/2i-proposal-memo-worksheet-blank.dc.html",
     "organization-context.html"): "2i-organization-context-worksheet.dc.html",
    ("worksheets/interactive/2i-proposal-memo-worksheet-case-study.dc.html",
     "organization-context.html"): "2i-organization-context-worksheet.dc.html",
    ("worksheets/interactive/2i-proposal-memo-worksheet-case-study.dc.html",
     "proposal-memo.html"): "2i-proposal-memo-worksheet-blank.dc.html",
}

ASSET = r"(?:dc\.html|html|js|json|md|png|jpg|jpeg|gif|svg|webp)"
REF = re.compile(rf"""(["'])([^"'<>\s][^"'<>]*?\.{ASSET})(\#[^"']*)?\1""")
TEXT_SUFFIXES = {".html", ".js", ".json", ".md"}


def skip(ref):
    # External, inline, or a bare extension appearing in script logic (".dc.html").
    return ("//" in ref or ref.startswith(("http", "data:", "mailto:", "#"))
            or pathlib.PurePosixPath(ref).name.startswith("."))


fixed, checked, unresolved = 0, 0, []
for path in sorted(root.rglob("*")):
    if not path.is_file() or path.suffix.lower() not in TEXT_SUFFIXES:
        continue
    rel = path.relative_to(root).as_posix()
    src = path.read_text(encoding="utf-8", errors="ignore")

    def fix(m):
        global fixed
        quote, ref, frag = m.group(1), m.group(2), m.group(3) or ""
        target = KNOWN_FIXES.get((rel, ref))
        if target and (path.parent / target).exists():
            fixed += 1
            return f"{quote}{target}{frag}{quote}"
        return m.group(0)

    out = REF.sub(fix, src)
    if out != src:
        path.write_text(out, encoding="utf-8")

    for m in REF.finditer(out):
        ref = m.group(2)
        if skip(ref):
            continue
        checked += 1
        if not (path.parent / ref).exists():
            unresolved.append((rel, ref))

print(f"    applied {fixed} known fix(es)")
print(f"    checked {checked} relative reference(s)")

if unresolved:
    print(f"\n    {len(unresolved)} reference(s) do not resolve:")
    for where, ref in sorted(set(unresolved)):
        print(f"      {where}: {ref}")
    if not allow_broken:
        print("\n    Fix these in the export, add them to KNOWN_FIXES in this"
              "\n    script, or rerun with --allow-broken.")
        sys.exit(1)
else:
    print("    every link and image resolves")
PY

# --- index.html -------------------------------------------------------------

# The backup has no index.html, and GitHub Pages serves the repo root.
step "Pointing index.html at the table of contents"
cat > "$ROOT/index.html" <<'EOF'
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Software Engineer's Library</title>
  <meta http-equiv="refresh" content="0; url=table-of-contents.dc.html">
  <link rel="canonical" href="table-of-contents.dc.html">
</head>
<body>
  <p><a href="table-of-contents.dc.html">Go to the Table of Contents</a></p>
</body>
</html>
EOF

# Backup zips are large and belong outside the repo's history.
if ! grep -qx '\*.zip' "$ROOT/.gitignore" 2>/dev/null; then
  printf '*.zip\n' >> "$ROOT/.gitignore"
fi

# --- commit, push, PR -------------------------------------------------------

git add -A -- . ':!.idea' ':!*.zip'

if git diff --cached --quiet; then
  step "No changes -- this backup matches what is already committed"
  git checkout -q "$PREV_BRANCH"
  git branch -q -D "$BRANCH"
  exit 0
fi

step "Changes staged"
git diff --cached --shortstat

if [ "$DRY_RUN" -eq 1 ]; then
  cat <<EOF

Dry run: stopping before the commit. You are on $BRANCH with the changes staged.
  review:  git status && git diff --cached --stat
  keep:    git commit
  discard: git reset --hard HEAD && git checkout $PREV_BRANCH && git branch -D $BRANCH
EOF
  exit 0
fi

SUMMARY="$(git diff --cached --shortstat | sed 's/^ *//')"
git commit -q -F - <<EOF
Publish worksheets backup of $(date +%Y-%m-%d)

Replaces the site with $(basename "$ZIP"), using the zip's folder structure
as-is. skills/ is untouched.

$SUMMARY

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF

step "Pushing $BRANCH"
git push -q -u origin "$BRANCH"

if [ "$NO_PR" -eq 1 ]; then
  step "Pushed. Skipping the PR (--no-pr)."
  exit 0
fi

step "Opening a pull request"
# Built in a variable rather than inline: bash 3.2, which is what macOS ships,
# cannot parse a heredoc inside $( ).
read -r -d '' PR_BODY <<EOF || true
Replaces the site with \`$(basename "$ZIP")\`, using the zip's folder structure as-is.

$SUMMARY

\`skills/\` is untouched. \`index.html\` redirects to \`table-of-contents.dc.html\`.

Every relative link and image path in the published files was checked to resolve
to a file that exists. That is a scan of the files, not a click-through in a
browser.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF

gh pr create --base "$BASE_BRANCH" --head "$BRANCH" \
  --title "Publish worksheets backup of $(date +%Y-%m-%d)" \
  --body "$PR_BODY"
