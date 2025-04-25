-module(wamp_client_utils).


%% API
-export([build_registration_name/1]).
-export([build_registration_name/2]).



%%====================================================================
%% API
%%====================================================================



%% -----------------------------------------------------------------------------
%% @doc It builds a registration name for the given list of atoms
%% @param Parts The list of atoms to be joined
%% @return The registration name as an atom
%% @end
%% -----------------------------------------------------------------------------
-spec build_registration_name([atom() | undefined]) -> atom().
build_registration_name(Parts) ->
    build_registration_name(Parts, "-").


%% -----------------------------------------------------------------------------
%% @doc It builds a registration name for the given list of atoms
%% @param Parts The list of atoms to be joined
%% @param Separator The separator to be used between the atoms
%% @return The registration name as an atom
%% @end
%% -----------------------------------------------------------------------------
-spec build_registration_name([atom() | undefined], string()) -> atom().
build_registration_name(Parts, Separator) ->
    StringParts = [atom_to_list(P) || P <- Parts, P =/= undefined],
    list_to_atom(string:join(StringParts, Separator)).