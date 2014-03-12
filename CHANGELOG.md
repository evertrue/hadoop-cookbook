## 1.1.2

* Fix (again) how we populate the FQDNs for the namenode and jobtracker attributes (includes adding a Chef version constraint of 11.10.0)
* Fix attribute reference for mapred.local.dir

## 1.1.1

* Replace default guava 11.0.02 with our version 14.0.1

## 1.1.0

* Change the logic for finding namenodes and datanodes at bootstrap
* Fix RuboCop compliance
* Move repo handling to its own recipe
* Set Java version to 7 in attributes
* Add tasktracker support
* Rearranged notification structure around data directory creation

## 1.0.1

* First rev!
