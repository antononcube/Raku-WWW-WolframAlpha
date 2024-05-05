unit module WWW::WolframAlpha;

use JSON::Fast;
use HTTP::Tiny;

use WWW::WolframAlpha::Query;
use WWW::WolframAlpha::Parameters;
use WWW::WolframAlpha::Request;

#===========================================================
#| Gives the base URL of OpenAI's endpoints.
our sub wolfram-alpha-base-url(-->Str) is export { return 'http://api.wolframalpha.com/v2';}

#===========================================================
#| WolframAlpha chat completions access.
#| C<$prompt> -- message(s) to the LLM;
#| C<:$role> -- role associated with the message(s);
#| C<:$model> -- model;
#| C<:$temperature> -- number between 0 and 2;
#| C<:$max-tokens> -- max number of tokens of the results;
#| C<:$top-p> -- top probability of tokens to use in the answer;
#| C<:$stream> -- whether to stream the result or not;
#| C<:api-key($auth-key)> -- authorization key (API key);
#| C<:$timeout> -- timeout;
#| C<:$format> -- format to use in answers post processing, one of <values json hash asis>);
#| C<:$method> -- method to WWW API call with, one of <curl tiny>.
our proto wolfram-alpha-query(|) is export {*}

multi sub wolfram-alpha-query(**@args, *%args) {
    return WWW::WolframAlpha::Query::WolframAlphaQuery(|@args, |%args);
}