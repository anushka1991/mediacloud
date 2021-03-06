package MediaWords::Util::IdentifyLanguage;

use strict;
use warnings;
use utf8;

#
# Utility module to identify a language for a particular text.
#

use Modern::Perl "2015";
use MediaWords::CommonLibs;

use URI;
use Readonly;
use Lingua::Identify::CLD;

# CLD instance
my $cld = Lingua::Identify::CLD->new();

# Language name -> ISO 690 code mappings
Readonly my %language_names_to_codes => (
    "english"                              => "en",
    "danish"                               => "da",
    "dutch"                                => "nl",
    "finnish"                              => "fi",
    "french"                               => "fr",
    "german"                               => "de",
    "hebrew"                               => "he",
    "italian"                              => "it",
    "japanese"                             => "ja",
    "korean"                               => "ko",
    "norwegian"                            => "no",    # was "nb" (for Bokmål), changed to generic ISO 690-1 "no"
    "polish"                               => "pl",
    "portuguese"                           => "pt",
    "russian"                              => "ru",
    "spanish"                              => "es",
    "swedish"                              => "sv",
    "chinese"                              => "zh",
    "czech"                                => "cs",
    "greek"                                => "el",
    "icelandic"                            => "is",
    "latvian"                              => "lv",
    "lithuanian"                           => "lt",
    "romanian"                             => "ro",
    "hungarian"                            => "hu",
    "estonian"                             => "et",
    "bulgarian"                            => "bg",
    "croatian"                             => "hr",
    "serbian"                              => "sr",
    "irish"                                => "ga",
    "galician"                             => "gl",
    "tagalog"                              => "tl",
    "turkish"                              => "tr",
    "ukrainian"                            => "uk",
    "hindi"                                => "hi",
    "macedonian"                           => "mk",
    "bengali"                              => "bn",
    "indonesian"                           => "id",
    "latin"                                => "la",
    "malay"                                => "ms",
    "malayalam"                            => "ml",
    "welsh"                                => "cy",
    "nepali"                               => "ne",
    "telugu"                               => "te",
    "albanian"                             => "sq",
    "tamil"                                => "ta",
    "belarusian"                           => "be",
    "javanese"                             => "jw",
    "occitan"                              => "oc",
    "urdu"                                 => "ur",
    "bihari"                               => "bh",
    "gujarati"                             => "gu",
    "thai"                                 => "th",
    "arabic"                               => "ar",
    "catalan"                              => "ca",
    "esperanto"                            => "eo",
    "basque"                               => "eu",
    "interlingua"                          => "ia",
    "kannada"                              => "kn",
    "punjabi"                              => "pa",
    "scots_gaelic"                         => "gd",
    "swahili"                              => "sw",
    "slovenian"                            => "sl",
    "marathi"                              => "mr",
    "maltese"                              => "mt",
    "vietnamese"                           => "vi",
    "frisian"                              => "fy",
    "slovak"                               => "sk",
    "chineset"                             => "zh",
    "faroese"                              => "fo",
    "sundanese"                            => "su",
    "uzbek"                                => "uz",
    "amharic"                              => "am",
    "azerbaijani"                          => "az",
    "georgian"                             => "ka",
    "tigrinya"                             => "ti",
    "persian"                              => "fa",
    "bosnian"                              => "bs",
    "sinhalese"                            => "si",
    "norwegian_n"                          => "nn",
    "portuguese_p"                         => "pt",
    "portuguese_b"                         => "pt",
    "xhosa"                                => "xh",
    "zulu"                                 => "zu",
    "guarani"                              => "gn",
    "sesotho"                              => "st",
    "turkmen"                              => "tk",
    "kyrgyz"                               => "ky",
    "breton"                               => "br",
    "twi"                                  => "tw",
    "yiddish"                              => "yi",
    "serbo_croatian"                       => "sh",
    "somali"                               => "so",
    "uighur"                               => "ug",
    "kurdish"                              => "ku",
    "mongolian"                            => "mn",
    "armenian"                             => "hy",
    "laothian"                             => "lo",
    "sindhi"                               => "sd",
    "rhaeto_romance"                       => "rm",
    "afrikaans"                            => "af",
    "luxembourgish"                        => "lb",
    "burmese"                              => "my",
    "khmer"                                => "km",
    "tibetan"                              => "bo",
    "dhivehi"                              => "dv",
    "cherokee"                             => "chr",
    "syriac"                               => "syc",
    "limbu"                                => "lif",
    "oriya"                                => "or",
    "assamese"                             => "as",
    "corsican"                             => "co",
    "interlingue"                          => "ie",
    "kazakh"                               => "kk",
    "lingala"                              => "ln",
    "moldavian"                            => "mo",
    "pashto"                               => "ps",
    "quechua"                              => "qu",
    "shona"                                => "sn",
    "tajik"                                => "tg",
    "tatar"                                => "tt",
    "tonga"                                => "to",
    "yoruba"                               => "yo",
    "creoles_and_pidgins_english_based"    => "cpe",
    "creoles_and_pidgins_french_based"     => "cpf",
    "creoles_and_pidgins_portuguese_based" => "cpp",
    "creoles_and_pidgins_other"            => "crp",
    "maori"                                => "mi",
    "wolof"                                => "wo",
    "abkhazian"                            => "ab",
    "afar"                                 => "aa",
    "aymara"                               => "ay",
    "bashkir"                              => "ba",
    "bislama"                              => "bi",
    "dzongkha"                             => "dz",
    "fijian"                               => "fj",
    "greenlandic"                          => "kl",
    "hausa"                                => "ha",
    "haitian_creole"                       => "ht",
    "inupiak"                              => "ik",
    "inuktitut"                            => "iu",
    "kashmiri"                             => "ks",
    "kinyarwanda"                          => "rw",
    "malagasy"                             => "mg",
    "nauru"                                => "na",
    "oromo"                                => "om",
    "rundi"                                => "rn",
    "samoan"                               => "sm",
    "sango"                                => "sg",
    "sanskrit"                             => "sa",
    "siswant"                              => "ss",
    "tsonga"                               => "ts",
    "tswana"                               => "tn",
    "volapuk"                              => "vo",
    "zhuang"                               => "za",
    "khasi"                                => "kha",
    "scots"                                => "sco",
    "ganda"                                => "lg",
    "manx"                                 => "gv",
    "montenegrin"                          => "srp"
);

# Vice-versa
Readonly my %language_codes_to_names => reverse %language_names_to_codes;

# Min. text length for reliable language identification
Readonly my $RELIABLE_IDENTIFICATION_MIN_TEXT_LENGTH => 10;

# Returns an ISO 690 language code for the plain text passed as a parameter
# Parameters:
#  * Text that should be identified (required)
#  * Top-level domain that can help with the identification (optional)
#  * True if the content is (X)HTML, false otherwise (optional)
# Returns: ISO 690 language code (e.g. 'en') on successful identification, empty string ('') on failure
sub language_code_for_text($;$$)
{
    my ( $text, $tld, $is_html ) = @_;

    return '' unless ( $text );

    # Lingua::Identify::CLD doesn't like undef TLDs
    $tld ||= '';

    my $language_name =
      lc( $cld->identify( $text, tld => $tld, isPlainText => ( !$is_html ), allowExtendedLanguages => 0 ) );

    if ( $language_name eq 'unknown' or $language_name eq 'tg_unknown_language' or ( !$language_name ) )
    {
        return '';
    }

    unless ( exists( $language_names_to_codes{ $language_name } ) )
    {
        ERROR "Language '$language_name' was identified but is not mapped, please add this language " .
          "to %language_names_to_codes hashmap.";
        return '';
    }

    return $language_names_to_codes{ $language_name };
}

# Returns 1 if the language identification for the text passed as a parameter is likely to be reliable; 0 otherwise
# Parameters:
#  * Text that should be identified (required)
# Returns: 1 if language identification is likely to be reliable; 0 otherwise
sub identification_would_be_reliable($)
{
    my $text = shift;

    unless ( $text )
    {
        return 0;
    }

    # Too short?
    if ( length( $text ) < $RELIABLE_IDENTIFICATION_MIN_TEXT_LENGTH )
    {
        return 0;
    }

    # Not enough letters as opposed to non-letters?
    my $word_character_count = 0;
    my $digit_count          = 0;
    my $underscore_count     = 0;    # Count underscores (_) because \w matches those too

    $word_character_count++ while ( $text =~ m/\w/gu );
    $digit_count++          while ( $text =~ m/\d/g );
    $underscore_count++     while ( $text =~ m/_/g );

    my $letter_count = $word_character_count - $digit_count - $underscore_count;
    if ( $letter_count < $RELIABLE_IDENTIFICATION_MIN_TEXT_LENGTH )
    {
        return 0;
    }

    return 1;
}

# Returns 1 if the language code if supported by the identifier, 0 otherwise
# Parameters:
#  * ISO 639-1 language code
# Returns: 1 if the language can be identified, 0 if it can not
sub language_is_supported($)
{
    my $language_id = shift;

    unless ( $language_id )
    {
        return 0;
    }

    return ( exists $language_codes_to_names{ $language_id } );
}

1;
