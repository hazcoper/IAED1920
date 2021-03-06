#!/bin/bash
#
# File:  test.sh
# Author:  mikolas
# Created on:  Sun Feb 17 13:31:59 STD 2019
# Copyright (C) 2019, Mikolas Janota
#
if [[ $# != 1 ]] ; then
    echo "Usage: $0 <exercise-name>"
    echo "Example: ./${0} ex01"
    exit 1
fi

prog_name="${1}"
cfile="${prog_name}.c"
DIFF="diff"
CC="gcc -ansi -Wall -Werror -Wextra -pedantic"

diff_opts="--ignore-space-change --ignore-blank-lines"

# use color for diff, if supported
if diff --help | grep -q -w -e '--color'
then
    diff_opts="${diff_opts} --color"
fi

if [ ! -f "${cfile}" ]; then
    echo "ERROR: file ${cfile} not found!"
    exit 1
fi

${CC} -o ${prog_name} ${cfile}
rv_compile=$?
if [ ${rv_compile} != 0 ]; then
    echo "ERROR: Compilation failed!"
    exit 1
else
    echo "Program successfully compiled..."
fi

for test_in in tests/${prog_name}_*.in ; do
    echo "Test:" "${test_in}"
    test_out="${test_in%.in}.out"
    stamp="${RANDOM}${RANDOM}"
    student_out=/tmp/in_${stamp}
    # ./${prog_name} <${test_in} | sed -e 's/\r$//' >${student_out}
    ./${prog_name} <${test_in} >${student_out}
    rv_student=$?

    if [ ! -f "${student_out}" ]; then
        echo "ERROR: The output of the exercise was not created (file ${student_out})!"
        exit 1
    fi

    if [ ${rv_student} != 0 ]; then
        echo "ERROR: Program did not return 0!"
        rm -f ${student_out}
        exit 1
    else
        echo "Program successfully ran..."
    fi

    ${DIFF} ${diff_opts} ${student_out} ${test_out}
    rv_diff=$?
    rm -f ${student_out}

    if [ ${rv_diff} == 0 ]; then
        echo "Test ${test_in} PASSED!"
    else
        echo "Test ${test_in} FAILURE!"
        exit 1
    fi
done
