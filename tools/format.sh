#! /bin/bash

if ! git diff-files --quiet; then
  echo "This command only runs on a clean repository."
  exit 1
fi

if [ ! -d hdl ]; then
  echo "Can't find the hdl directory, run from top level."
  exit 1
fi

for FILE in $(find hdl -name *.vhd | sort | grep -v jpeg_encoder); do
  echo
  echo $FILE
  echo "----------------------------------------------"
  # Strip trailing whitespace
  sed -i 's/\s*$//' $FILE
  # Run the pretty tool over the code
  ./tools/hdl-pretty/vhdl-pretty < $FILE > ${FILE}.new

  if [ -s ${FILE}.new ]; then
    mv -f ${FILE}.new $FILE
  else
    echo "Pretty tool produce no output!"
  fi
  echo "----------------------------------------------"

done

for FILE in $(find hdl -name *.v | sort); do
  echo
  echo $FILE
  echo "----------------------------------------------"
  # Strip trailing whitespace
  sed -i 's/\s*$//' $FILE
  # Run the pretty tool over the code
  echo "Running"
  echo "./tools/hdl-pretty/verilog-pretty < $FILE > ${FILE}.new"
  ./tools/hdl-pretty/verilog-pretty < $FILE > ${FILE}.new

  if [ -s ${FILE}.new ]; then
    mv -f ${FILE}.new $FILE
  else
    echo "Pretty tool produce no output!"
  fi
  echo "----------------------------------------------"
done

