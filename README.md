# Solr spatial search with dates

Let's consider problems like:

* Which restaurant is open right now?
* Who's available for a meeting next Thursday?

These kind of problems are not straight forward to solve using Solr only.

This project is a Proof Of Concept using Solr spatial search to tackle this class of problems, as exposed in [Chris Hostetter's article](https://home.apache.org/~hossman/spatial-for-non-spatial-meetup-20130117/).

## Prerequisites

* bash
* curl
* docker

## How to run

Just open a terminal and type:

```
bash ./run.sh
```

## License

* This project is pusblished under the [Apache 2 license](./LICENSE.md).
* The [jts library](./jts-1.14.jar) shipped in this project is part of the [JTS Topology Suite](https://sourceforge.net/projects/jts-topo-suite/), which is published under the [GNU Libary or Lesser General Public License version 2.0 (LGPLv2)](https://sourceforge.net/directory/license:lgpl/).

