## 2.0.1

* New custom library: snappy-java

## 2.0.0

* Add support for multiple data storage directories

## 1.2.7

* Move tmp dir changes to core-site.xml

## 1.2.6

* Add hadoop-site directory to conf file management

## 1.2.5

* Move global tmp dir to /mnt/tmp

## 1.2.4

* [PLATFORM-394](https://evertroops.atlassian.net/browse/PLATFORM-394) - Support overriding/adding things to hadoop startup environment

## 1.2.3

* [PLATFORM-325](https://evertroops.atlassian.net/browse/PLATFORM-325) - Add MySQL Connector JAR to Hadoop

## 1.2.2

* Fix broken notify structure.

## 1.2.1

* Upgrade Java cookbook to 1.21.2

## 1.2.0

* Move data to /mnt/data
* [PLATFORM-311](https://evertroops.atlassian.net/browse/PLATFORM-311) - Replace Jackson JARs with newer versions (in the process, somewhat refactor how JAR replacements are handled).

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
