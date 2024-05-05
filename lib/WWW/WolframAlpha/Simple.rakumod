unit module WWW::WolframAlpha::Simple;

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
our proto WolframAlphaSimple($input is copy,
                             :api-key(:$auth-key) is copy = Whatever,
                             UInt :$timeout= 10,
                             :$format is copy = Whatever,
                             Str :$method = 'tiny',
                             Str :$base-url = 'http://api.wolframalpha.com/v1',
                             *%args) is export {*}

#| MistralAI completion access.
multi sub WolframAlphaSimple(@inputs, *%args) {
    return WolframAlphaSimple(@inputs.join("\n"), |%args);
}

#| MistralAI completion access.
multi sub WolframAlphaSimple($input is copy,
                             :api-key(:$auth-key) is copy = Whatever,
                             UInt :$timeout= 10,
                             :$format is copy = Whatever,
                             Str :$method = 'tiny',
                             Str :$base-url = 'http://api.wolframalpha.com/v1',
                             *%args) {

    #------------------------------------------------------
    # Make WolframAlpha URL
    #------------------------------------------------------

    if $format.isa(Whatever) { $format = 'asis'; }
    $auth-key = get-auth-key($auth-key);
    my $units = %args<units> // '';
    my $url = $base-url ~ "/simple?appid=$auth-key" ~ "&input={ uri_encode($input) }" ~ ($units ?? "&units=$units" !! '');

    return image-import($url, :$format);
}
