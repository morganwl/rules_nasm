if ! $NASM -v | grep NASM; then 
    echo "Could not execute $NASM"
    exit 1
fi
