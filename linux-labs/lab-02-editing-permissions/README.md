# Lab 02 — Editing Files & Permissions

## Objective
Build practical Linux skill in editing files, inspecting permissions, changing access, and fixing permission-related failures.

## Skills Covered
- `nano`
- `cat`
- `ls -l`
- `chmod`
- executable scripts with `./file`

## What I Did
- Created a small Linux lab environment with:
  - `files/`
  - `configs/`
  - `scripts/`
  - `archive/`
- Edited files using `nano`
- Verified file contents using `cat`
- Inspected permissions with `ls -l`
- Changed permissions using:
  - symbolic mode (`+x`, `-w`)
  - numeric mode (`755`, `640`, `440`, etc.)
- Ran scripts with `./script`

## Problems I Solved
- Fixed a broken script that failed due to an incorrect shebang
- Fixed execution failures caused by missing execute permission
- Triggered and fixed read permission failures
- Triggered and fixed write/edit permission issues
- Corrected multiple path and command mistakes using terminal inspection

## Key Learning
- `ls -l` is the first command to use when checking file access
- `r`, `w`, and `x` control what actions are allowed
- `644` is a normal file pattern
- `755` is a common script pattern
- permissions should be set intentionally, not guessed

## Outcome
This lab strengthened my understanding of:
- file editing in Linux
- permission structure
- symbolic vs numeric chmod
- debugging permission-related problems

## Next Step
Lab 03 — file searching, inspection, and text filtering
