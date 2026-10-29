% suppose the input S holds "abccdef",
% we expect the output 4. 
-spec length_of_longest_substring(
    S :: unicode:unicode_binary()
) -> integer().
length_of_longest_substring(S) ->
    % Normalize so we can work with 
    % built-in list functions.
    W = unicode:characters_to_list(S),
    % io:format("Received: ~w", [W]),
    
    % Detect lengths of tokens that
    % lack duplicate letters
    Found = find(W),
    
    % return the longest one found
    Found.

% Setting things up: we receive the 
% input as a normalized string and 
% use that to initiate traversal.
% Erlang normalized the input into
% a list of code points. 
-spec find(lists:list()) -> non_neg_integer().
find([]) -> 0;
find(W) -> 
    Stop = erlang:length(W),
    LongestThusFar = 0,
    Finds = maps:new(),
    Found = find(W, Stop, LongestThusFar, Finds),
    Found.

% Traversing over the input,
% shorting the stop point each time,
% returning the longest found that 
% has no duplicates. 
-spec find(
    lists:list(), 
    non_neg_integer(), 
    non_neg_integer(),
    maps:map()
) -> non_neg_integer().

% Implementation 1. 
% When the input becomes empty, the
% Longest Thus Far will be the Longest. 
% So we return that.  
find([], _, Ltf, _) -> Ltf;

% Implementation 2. 
% We traverse backwards over Stop.
% When it reaches zero we restart at
% the next input character. Because of
% implementation 1, this one doesn't 
% need to check whether the input becomes
% empty. 
find(W, 0, Ltf, F) -> 
    [_|XS] = W,
    Stop = erlang:length(XS),
    find(XS, Stop, Ltf, F);

% Implementation 3.
% Traversing backwards over Stop,
% means at some point we may have found 
% a sublist without duplicates, with a
% length longer than the length of W 
% from start to Stop. That means there
% is no need to continue searching W. 
% We move on to a shorter sublist of W 
% if and only if W is longer than Ltf.
% Otherwise we skip testing and return
% Ltf.
find(W, Stop, Ltf, F) when Stop =< Ltf ->
    case erlang:length(W) > Ltf of
        true -> find(W, 0, Ltf, F);
        false -> Ltf
    end;

% Implementation 4.
% Traversing backwards over Stop,
% take a word part out of the input,
% only test for duplicates if its length 
% exceeds Longest Thus Far, and only
% record that if the part contains no 
% duplicate letters. 
% We aren't storing the words, nor their 
% lengths. All we do is track the
% longest length found thus far. 
find(W, Stop, Ltf, F) when Stop > Ltf ->
    X = lists:sublist(W, 1, Stop),
    case has_dupes(X, F) of
        true -> find(W, Stop - 1, Ltf, F);
        false -> find(W, 0, Stop, F)
    end.
        
-spec has_dupes(lists:list(), maps:map()) -> boolean().
has_dupes([], F) -> false;
has_dupes(W, F) when erlang:length(W) < 2 -> false; 
has_dupes(W, F) -> 
    case maps:is_key(W, F) of
        true -> maps:get(W, F);
        false ->
            WordLength = erlang:length(W),
            Uniques = lists:usort(W),
            Amount = erlang:length(Uniques),
            HasDupes = WordLength > Amount,
            maps:put(W, HasDupes, F),
            HasDupes
    end.
