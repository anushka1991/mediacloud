package CRF::CrfUtils;

#
# Facade to either Inline::Java based or a web service-based CRF model runner
#

use strict;
use warnings;

use MediaWords::Util::Config;

# Name of a loaded and active CRF module, either 'CRF::CrfUtils::InlineJava' or
# 'CRF::CrfUtils::WebService'.
#
# Loading of the module is postponed because CRF::CrfUtils::InlineJava compiles
# a Java class and loads it into a JVM in BEGIN{}, which slows down scripts
# that don't have anything to do with extraction
my $_active_crf_module = undef;

sub _load_and_return_crf_module()
{
    unless ( $_active_crf_module )
    {
        my $module;
        my $config = MediaWords::Util::Config->get_config();

        if ( $config->{ crf_web_service }->{ enabled } eq 'yes' )
        {

            my $crf_server = $config->{ crf_web_service }->{ server };
            unless ( $crf_server )
            {
                die "Unable to determine CRF model runner web service server to connect to.";
            }

            $module = 'CRF::CrfUtils::WebService';
        }
        else
        {
            $module = 'CRF::CrfUtils::InlineJava';
        }

        eval {
            ( my $file = $module ) =~ s|::|/|g;
            require $file . '.pm';
            $module->import();
            1;
        } or do
        {
            my $error = $@;
            die "Unable to load $module: $error";
        };

        $_active_crf_module = $module;
    }

    return $_active_crf_module;
}

sub create_model($$)
{
    my ( $training_data_file, $iterations ) = @_;

    my $module = _load_and_return_crf_module();

    return $module->create_model( $training_data_file, $iterations );
}

sub run_model($$$)
{
    my ( $model_file_name, $test_data_file, $output_fhs ) = @_;

    my $module = _load_and_return_crf_module();

    return $module->run_model( $model_file_name, $test_data_file, $output_fhs );
}

sub run_model_with_tmp_file($$)
{
    my ( $model_file_name, $test_data_array ) = @_;

    my $module = _load_and_return_crf_module();

    return $module->run_model_with_tmp_file( $model_file_name, $test_data_array );
}

sub run_model_with_separate_exec($$)
{
    my ( $model_file_name, $test_data_array ) = @_;

    my $module = _load_and_return_crf_module();

    return $module->run_model_with_separate_exec( $model_file_name, $test_data_array );
}

sub run_model_inline_java_data_array($$)
{
    my ( $model_file_name, $test_data_array ) = @_;

    my $module = _load_and_return_crf_module();

    return $module->run_model_inline_java_data_array( $model_file_name, $test_data_array );
}

sub train_and_test($$)
{
    my ( $files, $output_fhs, $iterations ) = @_;

    my $module = _load_and_return_crf_module();

    return $module->train_and_test( $files, $output_fhs, $iterations );
}

1;
