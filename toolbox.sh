#!/bin/bash

echo "请输入数字1-10："
read input

case $input in
  1)
    echo "运行脚本A"
    sh script_a.sh
    ;;
  2)
    echo "运行脚本B"
    sh script_b.sh
    ;;
  3)
    echo "运行脚本C"
    sh script_c.sh
    ;;
  4)
    echo "运行脚本D"
    sh script_d.sh
    ;;
  5)
    echo "运行脚本E"
    sh script_e.sh
    ;;
  6)
    echo "运行脚本F"
    sh script_f.sh
    ;;
  7)
    echo "运行脚本G"
    sh script_g.sh
    ;;
  8)
    echo "运行脚本H"
    sh script_h.sh
    ;;
  9)
    echo "运行脚本I"
    sh script_i.sh
    ;;
  10)
    echo "运行脚本J"
    sh script_j.sh
    ;;
  *)
    echo "输入无效数字！"
    ;;
esac

exit 0
