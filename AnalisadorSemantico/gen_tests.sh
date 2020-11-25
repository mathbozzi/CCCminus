#!/bin/bash

YEAR=$(pwd | grep -o '20..-.')
DATA=/home/matheus/Documentos/Matheus/UFES/8p/compiladores/trabcm/AnalisadorSemantico
IN=$DATA/in
OUT=$DATA/out3

EXE=./trab3

for infile in `ls $IN/*.cm`; do
    base=$(basename $infile)
    outfile=$OUT/${base/.cm/.out}
    $EXE < $infile > $outfile
done
