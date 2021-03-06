package MediaWords::Util::SQL;

# Misc. utility functions for sql

use strict;
use warnings;

use Modern::Perl "2015";
use MediaWords::CommonLibs;

use MediaWords::Util::DateTime;

use Date::Parse;
use DateTime;
use DateTime::Format::Pg;

sub get_sql_date_from_str2time
{
    my ( $date_string ) = @_;

    return get_sql_date_from_epoch( Date::Parse::str2time( $date_string ) );
}

sub get_sql_date_from_epoch
{
    my ( $epoch ) = @_;

    my $dt = DateTime->from_epoch( epoch => $epoch );
    $dt->set_time_zone( MediaWords::Util::DateTime::local_timezone() );

    my $date = $dt->datetime;

    $date =~ s/(\d)T(\d)/$1 $2/;

    return $date;
}

sub sql_now
{
    return get_sql_date_from_epoch( time() );
}

# given a date in the sql format 'YYYY-MM-DD', return the epoch time
sub get_epoch_from_sql_date
{
    my ( $date ) = @_;

    my $dt = DateTime::Format::Pg->parse_datetime( $date );
    $dt->set_time_zone( MediaWords::Util::DateTime::local_timezone() );

    return $dt->epoch;
}

# given a date in the sql format 'YYYY-MM-DD', increment it by $days days
sub increment_day
{
    my ( $date, $days ) = @_;

    return $date if ( defined( $days ) && ( $days == 0 ) );

    $days = 1 if ( !defined( $days ) );

    my $epoch_date = get_epoch_from_sql_date( $date ) + ( ( ( $days * 24 ) + 12 ) * 60 * 60 );

    my ( undef, undef, undef, $day, $month, $year ) = localtime( $epoch_date );

    return sprintf( '%04d-%02d-%02d', $year + 1900, $month + 1, $day );
}

# given a date in sql format 'YYYY-MM-DD', increment it to the current or next monday
sub increment_to_monday
{
    my ( $date ) = @_;

    while ( ( localtime( get_epoch_from_sql_date( $date ) ) )[ 6 ] != 1 )
    {
        $date = increment_day( $date, 1 );
    }

    return $date;
}

1;
