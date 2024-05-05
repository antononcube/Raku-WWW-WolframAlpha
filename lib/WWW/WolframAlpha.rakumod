unit module WWW::WolframAlpha;

use WWW::WolframAlpha::Simple;
use WWW::WolframAlpha::Query;

#===========================================================
#| Gives the base URL of OpenAI's endpoints.
our sub wolfram-alpha-base-url(-->Str) is export { return 'http://api.wolframalpha.com';}

#===========================================================
#| WolframAlpha simple API (returns images.)
#| C<$input> -- message(s) to the LLM;
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
our proto wolfram-alpha-simple(|) is export {*}

multi sub wolfram-alpha-simple(**@args, *%args) {
    return WWW::WolframAlpha::Simple::WolframAlphaSimple(|@args, |%args);
}

#===========================================================
#| WolframAlpha simple API (returns images.)
#| C<$input> -- message(s) to the LLM;
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
our proto wolfram-alpha-result(|) is export {*}

multi sub wolfram-alpha-result(**@args, *%args) {
    my %args2 = %args.clone;
    %args2<path> = 'result';
    return WWW::WolframAlpha::Query::WolframAlphaQuery(|@args, |%args2);
}

#===========================================================
#| WolframAlpha query API (returns full results in pods.)
#| C<$input> -- message(s) to the LLM;
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
our proto wolfram-alpha-query(|) is export {*}

multi sub wolfram-alpha-query(**@args, *%args) {
    return WWW::WolframAlpha::Query::WolframAlphaQuery(|@args, |%args);
}

#===========================================================
#| General WolframAlpha API.
#| C<$input> -- message(s) to the LLM;
#| C<:$path> -- which API path, one of 'simple', 'result' or 'query';
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
our proto wolfram-alpha(|) is export {*}

multi sub wolfram-alpha(**@args, *%args) {
    my $path = %args<path> // 'result';
    given $path {
        when $_ ∈ <result query> {
            my %args2 = %args.clone;
            %args2<path> = $path;
            return WWW::WolframAlpha::Query::WolframAlphaQuery(|@args, |%args2);
        }
        when 'simple' {
            return WWW::WolframAlpha::Simple::WolframAlphaSimple(|@args, |%args);
        }
        default {
            die "Unknown path.";
        }
    }
}


#===========================================================
# Convert W|A pods
#===========================================================

sub wa-subpod-converter(%subpod, Bool :$plaintext = False, UInt :$header-level = 3) {
    return [
        %subpod<title> ?? "{'#' x $header-level} {%subpod<title>}" !! '' ,
        (!$plaintext && %subpod<img>) ?? "![]({%subpod<img><src>})" !! '',
        %subpod<plaintext> ?? %subpod<plaintext> !! '',
    ].join("\n\n")
}

sub wa-pod-converter(%pod, Bool :$plaintext = False, UInt :$header-level = 2) {
    return [
        "{'#' x $header-level} {%pod<title> // '*Unknonw*'}",
        "**scanner:** " ~ %pod<scanner>,
        |%pod<subpods>.map({ wa-subpod-converter($_, :$plaintext, header-level => $header-level + 1) })
    ].join("\n\n")
}

proto sub wolfram-alpha-pods-to-markdown($waRes, Bool :$plaintext = False, UInt :$header-level = 2) is export {*}

multi sub wolfram-alpha-pods-to-markdown(%waRes, Bool :$plaintext = False, UInt :$header-level = 2) {
    my @pods = |%waRes<queryresult><pods> // |%waRes<pods> // Empty;
    return wolfram-alpha-pods-to-markdown(@pods, :$plaintext, :$header-level);
}

multi sub wolfram-alpha-pods-to-markdown(@pods, Bool :$plaintext = False, UInt :$header-level = 2) {
    return @pods.map({ wa-pod-converter($_, :$plaintext, :$header-level) }).join("\n\n");
}

# Overwrite
multi sub data-translation($data, Str :$target = 'Markdown', *%args) is export {
    return wolfram-alpha-pods-to-markdown($data, |%args);
}
