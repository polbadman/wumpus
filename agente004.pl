%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Hunt The Wumpus - World Simulator                                          %
%    Copyright (C) 2012 - 2016  Ruben Carlo Benante <rcb at beco dot cc>        %
%                                                                               %
%    This program is free software; you can redistribute it and/or modify       %
%    it under the terms of the GNU General Public License as published by       %
%    the Free Software Foundation; version 2 of the License.                    %
%                                                                               %
%    This program is distributed in the hope that it will be useful,            %
%    but WITHOUT ANY WARRANTY; without even the implied warranty of             %
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              %
%    GNU General Public License for more details.                               %
%                                                                               %
%    You should have received a copy of the GNU General Public License along    %
%    with this program; if not, write to the Free Software Foundation, Inc.,    %
%    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hunt The Wumpus - World Simulator
%
%   Edited, Compiled, Modified by:
%   Author: 
%     - Ruben Carlo Benante (rcb@beco.cc)
%   Copyright: 2012 - 2016
%   License: GNU GPL Version 2.0
%
%   Special thanks to:
%     - Original by Gregory Yob (1972)
%     - Larry Holder (accessed version Oct/2005)
%     - Walter Nauber 09/02/2001
%     - An Anonymous version of Hunt The Wumpus with menus (aeric? 2012?)
%
% A Prolog implementation of the Wumpus world invented by Gregory Yob
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Strategy: try to solve the wumpus world without memory
% Performance: it does not go very well as you can imagine
%
% To define an agent within the navigate.pl scenario, define:
%   init_agent
%   run_agent
%   world_setup([Size, Type, Move, Gold, Pit, Bat, [RandS, RandA]])
%
%       +--------+-----------+
%       |  Type  |    Size   |
%       +--------+-----------+
%       | fig62  | 4 (fixed) |
%       | grid   | 2 ... 9   |
%       | dodeca | 20 (fixed)|
%       +--------+-----------+
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Lista de Percepcao: [Stench, Breeze, Glitter, Bump, Scream, Rustle]
% Traducao: [Fedor, Vento, Brilho, Trombada, Grito, Ruido]
% Acoes possiveis (abreviacoes):
% goforward (go)                - andar
% turnright (turn, turnr ou tr) - girar sentido horario
% turnleft (turnl ou tl)        - girar sentido anti-horario
% grab (gr)                     - pegar o ouro
% climb (cl)                    - sair da caverna
% shoot (sh)                    - atirar a flecha
% sit (si)                      - sentar (nao faz nada, passa a vez)
%
% Custos:
% Andar/Girar/Pegar/Sair/Atirar/Sentar: -1
% Morrer: -500 (buraco, wumpus ou fadiga)
% Matar Wumpus: +500
% Sair com ouro: +1000 para cada pepita
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
% Para rodar o exemplo, inicie o prolog com:
% swipl -s agente004.pl
% e faca a consulta (query) na forma:
% ?- start.

:- use_module(wumpus, [start/0]). % agente usa modulo simulador

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% world_setup([Size, Type, Move, Gold, Pit, Bat, Adv])
%
% Size and Type: - fig62, 4
%                - grid, [2-9] (default 4)
%                - dodeca, 20
%
% Configuration:
%    1.   Size: 0,2..9,20, where: grid is [2-9] or 0 for random, dodeca is 20, fig62 is 4.
%    2.   Type: fig62, grid or dodeca
%    3.   Move: stander, walker, runner (wumpus movement)
%    4.   Gold: Integer is deterministic number, float from 0.0<G<1.0 is probabilistic
%    5.   Pits: Idem, 0 is no pits.
%    6.   Bats: Idem, 0 is no bats.
%    7.   Adv: a list with advanced configuration in the form [RandS, RandA]:
%       - RandS - yes or no, random agent start position
%       - RandA - yes or no, random agent start angle of orientation
%
% examples: 
% world_setup([4, grid, stander, 0.1, 0.2, 0.1, [no, no]]). % default
% world_setup([5, grid, stander, 1, 3, 0.1, [yes]]). % size 5, 1 gold, 3 pits, some bats prob. 0.1, agent randomly positioned
%
%   Types of Wumpus Movement
%       walker    : original: moves when it hears a shoot, or you enter its cave
%       runner    : go forward and turn left or right on bumps, maybe on pits
%       wanderer  : arbitrarily choses an action from [sit,turnleft,turnright,goforward]
%       spinner   : goforward, turnleft, repeat.
%       hoarder   : go to one of the golds and sit
%       spelunker : go to a pit and sit
%       stander   : do not move (default)
%       trapper   : goes hunting agent as soon as it leaves [1,1]; goes home otherwise
%       bulldozer : hunt the agent as soon as it smells him
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- use_module(wumpus, [start/0]). % agente usa modulo simulador

% Mundo: 
%    4x4, quadrado, wumpus anda quando atira ou quando entra na casa dele
%    probabilidade de ouro 0.1, de buracos 0.2, um unico morcego
%    agente inicia em casa aleatoria
%    Maximo de acoes antes de morrer de fome: Size^2x4 = 4x4x4 = 64
world_setup([4, fig62, walker, 0.1, 0.2, 1, [yes]]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Inicie aqui seu programa.

init_agent.

% esta e a funcao chamada pelo simulador. Nao altere a "cabeca" da funcao. Apenas o corpo.
% Funcao recebe Percepcao, uma lista conforme descrito acima.
% Deve retornar uma Acao, dentre as acoes validas descritas acima.
run_agent(Percepcao, Acao) :-
    write('percebi: '), 
    writeln(Percepcao),
    acao(Percepcao, Acao). 

% Lista de Percepcao: [Fedor,Vento,Brilho,Trombada,Grito]
acao([_,_,yes|_], grab) :- %pega o ouro se sentir o brilho
    writeln('acao: pega').
acao([_,_,_,yes|_], turnright) :- %vira para a direita sempre que bater na parede
    writeln('acao: direita').
acao([yes,_,_,_,no|_], A):-  %atira, andar, girar ou sair em caso de fedor sem grito
    random_member(A, [shoot, shoot, shoot, shoot, turnright, turnright, turnright, climb, climb, goforward]),
    write('acao aleatoria com fedor, sem grito: '),
    writeln(A).
acao([_,no,_,_,yes|_], goforward) :- %anda se escutar grito e sem brisa
    writeln('acao com brisa, sem grito: frente').
acao([_,yes,_,_,yes|_], A):-  %grito com brisa
    random_member(A, [climb, turnright]),
    write('acao aleatoria com brisa e grito: '),
    writeln(A).
acao([_,yes|_], A):-  %brisa
    random_member(A, [climb, climb, climb, turnright, turnright, goforward]),
    write('acao aleatoria com brisa: '),
    writeln(A).
acao(_, A) :- % sorteia default
    random_member(A, [turnright, goforward, climb]),
    write('acao aleatoria outros casos: '),
    writeln(A).

