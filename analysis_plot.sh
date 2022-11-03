CORRECT_LUT_VALUES=""
REAL_LUT_VALUES=""

RUNS=(1 2 3 4 5 6 7 8)

FNAME="temp_parameters.txt"


sed -e "s/NewValidation.txt/$FNAME/" new.sh > temp_new.sh

for (( i=0; i<${#RUNS[@]}; i += 2));
do
    next=$(( i + 1 ))
    cp NewValidation.txt $FNAME
    echo "${RUNS[$i]} ${RUNS[$next]}"
    sed -i -e "s/NewLUTtag.*/NewLUTtag   ${CORRECT_LUT_VALUES}/" $FNAME
    sed -i -e "s/NewRun.*/NewRun   ${RUNS[$next]}/" $FNAME
    sed -i -e "s/OldRun.*/NewRun   ${RUNS[$i]}/" $FNAME
    sed -i -e "s/outdir*/outdir   test_${RUNS[$i]}/" $FNAME
    chmod +x temp_new.sh
    ./temp_new.sh
done

rm temp_new.sh
rm temp_parameters.sh


