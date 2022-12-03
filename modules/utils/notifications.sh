#!/usr/bin/env bash

print_and_notify() {
  printf "${1}\n"
  printf "${1} - ${domain}\n" | $NOTIFY
}

if [ -n "$1" ] && [ -n "$2" ]; then
  case $2 in
    info)
      text="\n${bblue} ${1} ${reset}"
      print_and_notify "${text}"
      ;;
    warn)
      text="\n${yellow} ${1} ${reset}"
      print_and_notify "${text}"
      ;;
    error)
      text="\n${bred} ${1} ${reset}"
      print_and_notify "${text}"
      ;;
    good)
      text="\n${bgreen} ${1} ${reset}"
      print_and_notify "${text}"
      ;;
  esac
fi