#!/exlibris/product/bin/perl -w
##########################################################################
# fix_doc_gen_num.pl
##########################################################################
# Extracts numeric characters from field 490..$v or 773..$g respectively,
# create a new subfield $i or $j respectively while separating the number
# blocks with slashes.
# Save in $aleph_dev/aleph/exe and make it executable
# Register in tab_fix
##########################################################################
# 27.07.2018 Created / IDSBB, ssch
##########################################################################

$ENV{NLS_LANG} = "AMERICAN_AMERICA.UTF8";

use strict;
no warnings 'once';

sub move_numeric_values {
    my ($line, $field, $origsubfield, $targetsubfield) = @_;
    my $targetsubfieldvalue = "";

    # Modify line if beginning with $field and not containing $targetsubfield
    if (substr($line, 0, 3) =~ /\Q$field/ && index($line, "\$\$$targetsubfield") == -1) {
        # Get subfields as array and skip first element
        my @subfields = split(/\$\$/, $line);
        shift @subfields;

        # Keep only subfields beginning with $origsubfield and concatenate them
        my $fields = join(" ", grep (/^\Q$origsubfield/, @subfields));
        my $after_number = 0;
        my $after_dash = 0;

        # Remove all non-numeric characters (except different flavors of dashes / hyphens / minus signs)
        # and separate resulting number blocks / ranges with slashes
        for (my $key = 0; $key < length($fields); $key++) {
            if (substr($fields, $key, 1) =~ /[0-9]/) {
                $after_number = 1;
                if (length $targetsubfieldvalue == 0) {
                    $targetsubfieldvalue = "\$\$$targetsubfield";
                }
                if ($after_dash == 1) {
                    $targetsubfieldvalue = $targetsubfieldvalue . "-";
                    $after_dash = 0;
                }
                $targetsubfieldvalue = $targetsubfieldvalue . substr($fields, $key, 1);
            }
            elsif ($after_number == 1 && substr($fields, $key, 1) =~ /[\x{002D}\x{2010}\x{2012}\x{2013}\x{2014}\x{2015}\x{2212}]/) {
                $after_dash = 1;
            }
            elsif ($after_number == 1) {
                $targetsubfieldvalue = $targetsubfieldvalue . "/";
                $after_number = 0;
            }
        }
        # Remove trailing slash
        if (substr($targetsubfieldvalue, -1) eq "/") {
            $targetsubfieldvalue = substr($targetsubfieldvalue, 0, -1);
        }
        # Return original string with potential new subfield $targetsubfieldvalue
        print $line . $targetsubfieldvalue . "\n";
        return 1;
    }
    return 0;
}

# Remove first line as it doesn't contain categories
my $line1 = <STDIN>;
while (my $line = <STDIN>) {
    if ($line) {
        chomp $line;
        # Only print unedited line if not field 490 or 773 with missing $i or $j subfield
        if (!move_numeric_values($line, "490", "v", "i") && !move_numeric_values($line, "773", "g", "j")) {
            print $line . "\n";
        }
    }
    else {
        last
    }
}
exit;