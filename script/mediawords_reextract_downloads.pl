#!/usr/bin/env perl

use strict;

BEGIN
{
    use FindBin;
    use lib "$FindBin::Bin/../lib";
}

use Modern::Perl "2015";
use MediaWords::CommonLibs;

use Getopt::Long;
use HTML::Strip;
use DBIx::Simple::MediaWords;
use MediaWords::DB;

use MediaWords::DBI::Downloads;
use MediaWords::DBI::DownloadTexts;
use Readonly;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);
use XML::LibXML;
use Data::Dumper;

use Digest::SHA qw(sha1 sha1_hex sha1_base64);

#use XML::LibXML::CDATASection;
use Encode;
use MIME::Base64;

#use XML::LibXML::Enhanced;

my $_re_generate_cache = 0;

sub reextract_downloads
{

    my $downloads = shift;

    my @downloads = @{ $downloads };

    INFO "Starting reextract_downloads";

    @downloads = sort { $a->{ downloads_id } <=> $b->{ downloads_id } } @downloads;

    my $download_results = [];

    my $dbs = MediaWords::DB::connect_to_db;

    for my $download ( @downloads )
    {
        die "Non-content type download: $download->{ downloads_id } $download->{ type } "
          unless $download->{ type } eq 'content';

        INFO "Processing download $download->{downloads_id}";

        MediaWords::DBI::Downloads::process_download_for_extractor( $dbs, $download );
    }
}

# do a test run of the text extractor
sub main
{

    my $dbs = MediaWords::DB::connect_to_db;

    my $file;
    my @download_ids;

    GetOptions(
        'file|f=s'                  => \$file,
        'downloads|d=s'             => \@download_ids,
        'regenerate_database_cache' => \$_re_generate_cache,
    ) or die;

    unless ( $file || ( @download_ids ) )
    {
        die "no options given ";
    }

    my $downloads;

    DEBUG join( ', ', @download_ids );

    if ( @download_ids )
    {
        $downloads = $dbs->query( "SELECT * from downloads where downloads_id in (??)", @download_ids )->hashes;
    }
    elsif ( $file )
    {
        open( DOWNLOAD_ID_FILE, $file ) || die( "Could not open file: $file" );
        @download_ids = <DOWNLOAD_ID_FILE>;
        $downloads = $dbs->query( "SELECT * from downloads where downloads_id in (??)", @download_ids )->hashes;
    }
    else
    {
        die "must specify file or downloads id";
    }

    DEBUG Dumper( $downloads );

    die 'no downloads found ' unless scalar( @$downloads );

    DEBUG scalar( @$downloads ) . ' downloads';

    reextract_downloads( $downloads );

    INFO "completed extraction";
}

main();
