%% =============================================================================
%%  wamp_client_sup.erl -
%%
%%  Copyright (c) 2016-2021 Leapsight. All rights reserved.
%%
%%  Licensed under the Apache License, Version 2.0 (the "License");
%%  you may not use this file except in compliance with the License.
%%  You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%%  Unless required by applicable law or agreed to in writing, software
%%  distributed under the License is distributed on an "AS IS" BASIS,
%%  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%  See the License for the specific language governing permissions and
%%  limitations under the License.
%% =============================================================================

-module(wamp_client_sup).

-behaviour(supervisor).

-define(SUPERVISOR(Id, Mod, Args, Restart, Timeout), #{
    id => Id,
    start => {Mod, start_link, Args},
    restart => Restart,
    shutdown => Timeout,
    type => supervisor,
    modules => [Mod]
}).
-define(WORKER(Id, Mod, Args, Restart, Timeout), #{
    id => Id,
    start => {Mod, start_link, Args},
    restart => Restart,
    shutdown => Timeout,
    type => worker,
    modules => [Mod]
}).
-define(EVENT_MANAGER(Id, Restart, Timeout), #{
    id => Id,
    start => {gen_event, start_link, [{local, Id}]},
    restart => Restart,
    shutdown => Timeout,
    type => worker,
    modules => [dynamic]
}).

%% API
-export([start_link/1]).
%% Supervisor callbacks
-export([init/1]).

%%====================================================================
%% API functions
%%====================================================================

start_link(Config) ->
    application:ensure_all_started(gproc, permanent),
    supervisor:start_link({local, ?MODULE}, ?MODULE, [Config]).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([Config]) ->
    Peers = key_value:get(peers, Config, #{}),

    AwreSup = ?SUPERVISOR(
        awre_sup,
        awre_sup,
        [],
        permanent,
        5000
    ),

    Children0 = maps:fold(
        fun(Name, PeerConfig, Acc) ->
            Id = list_to_atom(
                "wamp_client_peer_sup-" ++
                    atom_to_list(Name)
            ),
            Sup = ?SUPERVISOR(
                Id,
                wamp_client_peer_sup,
                [Id, Name, PeerConfig, Config],
                permanent,
                5000
            ),
            [Sup | Acc]
        end,
        [],
        Peers
    ),

    Children = [AwreSup | Children0],

    Specs = {{one_for_one, 5, 60}, Children},
    {ok, Specs}.

%%====================================================================
%% Internal functions
%%====================================================================
