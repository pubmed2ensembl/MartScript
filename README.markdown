MartScript
==========

MartScript is a simple non-branching imperative scripting language
for creating BioMarts (see [www.biomart.org](http://www.biomart.org)) 
automatically (i.e. non-interactively). The
language supports

 * extending Ensembl databases with custom data
 * automation of MartBuilder/MartEditor functionality
 * the creation and execution of a BioMart's SQL-commands

This is a fully functional release of MartScript as a beta version,
mainly due to the lack of documentation and
some minor cosmetic issues. However, we used MartScript in production
to create: [www.pubmed2ensembl.org](http://www.pubmed2ensembl.org)

### Executing MartScripts

Clone this repo or download the ZIP file. With Java 1.6 and Perl 5.12
(or newer) run the following:

    for jar in lib/*.jar ; do export CLASSPATH=$CLASSPATH:`pwd`/$jar ; done
    cd bin
    java -Xmx3G org.bergmanlab.martscript.MartScript yourscript.mscr

### Re-compiling MartScript

MartScript's Java classes can be recompiled using:

    for jar in lib/*.jar ; do export CLASSPATH=$CLASSPATH:`pwd`/$jar ; done
    javac -source 1.4 -d bin -sourcepath src src/org/bergmanlab/martscript/MartScript.java

Supporting Software
-------------------

MartScript depends on partially modified code of MartBuilder as well as as 
JAR files of several libraries that from the BioMart project, which are 
redistributed here. MartBuilder, MartEditor and the JAR-packaged files 
are released under LGPL.

License
-------

MartScript is released under the LGPL (see LICENSE).
