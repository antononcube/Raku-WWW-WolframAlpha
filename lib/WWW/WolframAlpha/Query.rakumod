unit module WWW::WolframAlpha::Query;

use WWW::WolframAlpha::Parameters;
use WWW::WolframAlpha::Request;
use Image::Markup::Utilities;
use JSON::Fast;
use URI::Encode;

#============================================================
# Query
#============================================================

# https://products.wolframalpha.com/api/documentation

#| MistralAI completion access.
our proto WolframAlphaQuery($input is copy,
                            :api-key(:$auth-key) is copy = Whatever,
                            UInt :$timeout= 10,
                            :$output-format is copy = Whatever,
                            :$output is copy = 'json',
                            Str :$path = 'query',
                            :$format is copy = Whatever,
                            Str :$method = 'tiny',
                            Str :$base-url = 'http://api.wolframalpha.com',
                            *%args) is export {*}

#| MistralAI completion access.
multi sub WolframAlphaQuery(@inputs, *%args) {
    return WolframAlphaQuery(@inputs.join("\n"), |%args);
}

#| MistralAI completion access.
multi sub WolframAlphaQuery($input is copy,
                            :api-key(:$auth-key) is copy = Whatever,
                            UInt :$timeout= 10,
                            :$output-format is copy = Whatever,
                            :$output is copy = 'json',
                            Str :$path = 'query',
                            :$format is copy = Whatever,
                            Str :$method = 'tiny',
                            Str :$base-url = 'http://api.wolframalpha.com',
                            *%args) {

    #------------------------------------------------------
    # Process $output-format
    #------------------------------------------------------
    my @knownFormats = ["image", "imagemap", "plaintext", "minput", "moutput", "cell", "mathml", "sound", "wav"];
    if $output-format.isa(Whatever) { $output-format = <plaintext image>; }
    if $output-format ~~ Str:D { $output-format = [$output-format, ]; }
    die "The argument \$format is expected to be Whatever or one of the strings: { '"' ~ @knownFormats.join('", "') ~ '"' }, " ~
            "or a list of those strings."
    unless ($output-format ~~ Positional:D) && ($output-format (-) @knownFormats).elems == 0;

    $output-format = $output-format.join(',');

    #------------------------------------------------------
    # Process $output
    #------------------------------------------------------
    if $output.isa(Whatever) { $output = 'json'; }
    die "The argument \$output is expected to be Whatever or one of the strings 'json' or 'xml'."
    unless ($output ~~ Str:D) && $output ∈ <json xml>;


    #------------------------------------------------------
    # Make WolframAlpha URL
    #------------------------------------------------------

    my $url = do given $path {

        when 'result' {
            if $format.isa(Whatever) { $format = 'asis'; }
            my $units = %args<units> // '';
            $base-url ~ "/v1/result?" ~ "input={ uri_encode($input) }" ~ ($units ?? "&units=$units" !! '');
        }

        when 'query' {
            $base-url ~ "/v2/query?" ~ "input={ uri_encode($input) }&format=$output-format&output=$output";
        }

        default {
            die 'Unknown path.'
        }
    }

    return wolfram-alpha-request(:$url, body => '', :$auth-key, :$timeout, :$format, :$method);
}
