locals {
  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true
}
