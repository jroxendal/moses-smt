#!/bin/bash -exu

mkdir -p ${WORK_HOME}/tune
cd ${WORK_HOME}/tune

for LANG in $SOURCE_LANG $TARGET_LANG; do
    # Escape special characters
    ${MOSES_HOME}/scripts/tokenizer/escape-special-chars.perl \
                 < ${DATA_HOME}/tune/bitext.tok.${LANG} \
                 > bitext.esc.${LANG}
    # Truecase
    ${MOSES_HOME}/scripts/recaser/train-truecaser.perl \
                 --model truecase-model.${LANG} \
                 --corpus bitext.esc.${LANG}
    ${MOSES_HOME}/scripts/recaser/truecase.perl \
                 --model truecase-model.${LANG} \
                 < bitext.esc.${LANG} \
                 > bitext.true.${LANG}
done

# Clean
${MOSES_HOME}/scripts/training/clean-corpus-n.perl \
	bitext.true ${TARGET_LANG} ${SOURCE_LANG} \
	bitext.clean 1 80


# Tune
${MOSES_HOME}/scripts/training/mert-moses.pl \
	bitext.clean.${SOURCE_LANG} \
    bitext.clean.${TARGET_LANG} \
	${MOSES_HOME}/bin/moses ${WORK_HOME}/train/model/moses.ini \
    --mertdir ${MOSES_HOME}/bin/ \
	--decoder-flags="-threads $(nproc)" > mert.out
