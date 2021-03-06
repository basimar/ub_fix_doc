#!/exlibris/product/bin/perl -w
##########################################################################
# fix_doc_2gnd.pl
##########################################################################
# speichern in $aleph_dev/aleph/exe
# Skript muss ausfuehrbar gemacht werden (chmod 755)
# einhaengen in tab_fix 
#
# Anforderungen: 
# Bei allen Sacherschliessungsfeldern (6##), die GND-Verknuepfungen 
# enthalten, wird automatisch $$2gnd hinzugefuegt. 
##########################################################################
# xx.09.2015 Erstellt / IDSBB, bmt 
# 17.07.2018 Bugfixes bei mehrfach vorkommenden Unterfeldern / IDSBB, bmt
##########################################################################

$ENV{NLS_LANG} = "AMERICAN_AMERICA.UTF8";

use strict;

my $line   = '';

my $line1 = <STDIN>;                                              # Weg damit (1. Zeile enthaelt keine Kategorien)
while ($line = <STDIN>) {
   if ($line) {
      chomp $line; 	
      if (substr($line, 0, 5) =~ /6(00|10|11|30|50|51).7/) {      # Fall 1: Sacherschliessungfeld mit Indikator 2=7
         $line =~ s/\$\$.(?=(\$\$|$))//g;                         # Loesche leere Unterfelder in der Feldmitte und am Feldende
         if ( $line =~ /(\$\$1\(DE-588\).+?)(\$\$|$)/ ) {         # Pruefe ob $$1 (DE-588) * vorkommt
            $line =~ s/\$\$2.+?(?=(\$\$|$))//g;                   # Loesche allfaellig vorhandenes Unterfeld $$2gnd 
            $line =~ s/$/\$\$2gnd/                                # Fuege Unterfeld $$2gnd am Ende ein
         }                                            
      }
   print $line . "\n";                                            # Schreibe Feld wieder ins Katalogisat
   } else {
      last
   }
}

exit;
