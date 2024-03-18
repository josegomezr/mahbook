#!/usr/bin/env bash

set -e

declare -a FILELIST

FILELIST=$(
cat <<EOF
00-metadata.md
first-chapter.md
second-chapter.md
EOF
)

OUT_FILENAME=mahbook
OUT_FOLDER=out
mkdir -p $OUT_FOLDER

for FORMAT in html a5.pdf serif.pdf; do
    OUT_PATH="${OUT_FOLDER}/${OUT_FILENAME}.${FORMAT}"

    EXTRA_ARGS=
    if [[ "$FORMAT" == "html" ]]; then
        EXTRA_ARGS="--number-sections --listings --standalone --embed-resources --file-scope"
    fi

    if [[ "$FORMAT" == "pdf" ]]; then
        EXTRA_ARGS="--template ./template.tex --number-sections --listings --file-scope"
    fi

    if [[ "$FORMAT" == "a5.pdf" ]]; then
        EXTRA_ARGS="--template ./template.tex --variable=papersize=a5 --number-sections --listings --file-scope"
    fi
    
    if [[ "$FORMAT" == "serif.pdf" ]]; then
        EXTRA_ARGS="--template ./template.tex --variable=fontserif --number-sections --listings --file-scope"
    fi

    if [[ "$FORMAT" == "epub" ]]; then
        EXTRA_ARGS="--epub-title-page=false"
    fi

    # EPUB EXPORT DOES NOT WORK WITH --file-scope
    docker run --rm -v $(pwd):/data pandoc/extra:edge \
        --from=gfm+rebase_relative_paths+raw_attribute \
        --top-level-division=chapter \
        --pdf-engine=xelatex \
        --output=$OUT_PATH \
        $EXTRA_ARGS \
        $FILELIST
done
