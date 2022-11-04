function run_validator(){
     local validator_file=${1:?"You must provide a file name"}
     local file_to_validate=${2:?"You must provide a file name"}
     local result=$(bash "$validator_file" "$file_to_validate")
     if [[ "$result" == "ok" ]]; then 
         echo "File $file_to_validate was successfully validated using validator $validator_file"
         return
    else
         echo "File $file_to_validate was failed to validate using validator $validator_file"
         echo "Failure reason:"
         echo "$result"
         exit 1
    fi

}
