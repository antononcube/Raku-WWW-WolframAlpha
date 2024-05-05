unit module WWW::WolframAlpha::Query;

use WWW::WolframAlpha::Parameters;
use WWW::WolframAlpha::Request;
use JSON::Fast;
use URI::Encode;

#============================================================
# Known roles
#============================================================

my $knownRoles = Set.new(<user assistant>);


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
                            :$format is copy = Whatever,
                            Str :$method = 'tiny',
                            Str :$base-url = 'http://api.wolframalpha.com/v2') is export {*}

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
                            :$format is copy = Whatever,
                            Str :$method = 'tiny',
                            Str :$base-url = 'http://api.wolframalpha.com/v2') {

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

    my $url = $base-url ~ '/query?' ~ "input={uri_encode($input)}&format=$output-format&output=$output";

    #------------------------------------------------------
    # Delegate
    #------------------------------------------------------

    return wolfram-alpha-request(:$url, body => '', :$auth-key, :$timeout, :$format, :$method);
}
