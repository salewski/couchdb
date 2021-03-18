%
% Licensed under the Apache License, Version 2.0 (the "License"); you may not
% use this file except in compliance with the License. You may obtain a copy of
% the License at
%
%   http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
% WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
% License for the specific language governing permissions and limitations under
% the License.

-module(couch_jobs_activity_monitor_sup).


-behaviour(supervisor).


-export([
    start_link/0,

    start_monitor/1,
    stop_monitor/1,
    get_child_pids/0
]).

-export([
    init/1
]).


start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).


start_monitor(Type) ->
    supervisor:start_child(?MODULE, [Type]).


stop_monitor(Pid) ->
    supervisor:terminate_child(?MODULE, Pid).


get_child_pids() ->
    lists:map(fun({_Id, Pid, _Type, _Mod}) ->
        Pid
    end, supervisor:which_children(?MODULE)).


init(_) ->
    Flags = #{
        strategy => simple_one_for_one,
        intensity => 1000,
        period => 3
    },
    Children = [
        #{
            id => couch_jobs_monitor,
            restart => temporary,
            start => {couch_jobs_activity_monitor, start_link, []}
        }
    ],
    {ok, {Flags, Children}}.
