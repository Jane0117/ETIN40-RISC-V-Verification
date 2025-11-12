package File::Copy::Recursive;

use strict;
use warnings;

use Exporter 'import';
use File::Copy qw(copy);
use File::Path qw(make_path);
use File::Basename;
use File::Spec;
use File::Find;

our @EXPORT_OK = qw(dircopy);

sub dircopy {
    my ( $src, $dst ) = @_;

    die "Source directory '$src' does not exist\n" unless -d $src;
    die "Destination path not specified\n" unless defined $dst;

    my $ok = 1;

    File::Find::find(
        {
            wanted => sub {
                my $path = $File::Find::name;
                my $rel  = File::Spec->abs2rel( $path, $src );
                my $target = File::Spec->catfile( $dst, $rel );

                if ( -d $path ) {
                    return if -d $target;
                    make_path($target) or $ok = 0;
                    return;
                }

                my $dir = File::Basename::dirname($target);
                make_path($dir) unless -d $dir;

                copy( $path, $target ) or $ok = 0;
            },
            no_chdir => 1
        },
        $src
    );

    return $ok;
}

1;

