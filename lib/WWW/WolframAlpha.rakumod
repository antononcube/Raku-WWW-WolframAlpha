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