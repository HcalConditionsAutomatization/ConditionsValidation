file=$1
desired_length=${2?"You must provide the correct length"}
lines=$(wc -l "$file")
if [[ $desired_length == $lines ]]; then
    echo "ok"
else
    echo "Number of lines $lines is not the same as the desired number of lines $desired_length"
fi

