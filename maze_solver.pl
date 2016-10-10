/*******************************   Diogo Redin 84711   *******************************
*
*
*   PROGRAMA RESOLUCAO LABIRINTOS
*   https://fenix.tecnico.ulisboa.pt/downloadFile/282093452017113/projectoLP2016.pdf
*
*
**************************************************************************************/

/*************************************************************************************
*
*   INDEX
*
*	1. MOVS_POSSIVEIS
*		1.1. parede_livre /2
*		1.2. paredes /4
*		1.3. mov_possivel /5
*			1.3.1. c - cima
*			1.3.2. b - baixo
*			1.3.3. e - esquerda
*			1.3.4. d - direita
*		1.4. movs_possiveis /4
*
*	2. DISTANCIA
*		2.1. distancia /3
*
*	3. ORDENA_POSS
*		3.1. ordena_poss /4
*		3.2. insere /5
*		3.3. criterio_um /3
*		3.4. criterio_dois /3
*
*	4. RESOLVE I
*		4.1. resolve1 /4
*		4.2. resolve1 /5
*
*	5. RESOLVE II
*		5.1. resolve2 /4
*		5.2. resolve2 /5
*
**************************************************************************************/

/*************************************************************************************
*
*   1. MOVS_POSSIVEIS
*	movs_possiveis(Lab, Pos_atual, Movs, Poss)
*
*	argumentos: labirinto, posicao atual e movimentos efetuados
*	objetivo: determina movimentos seguintes possiveis
*
**************************************************************************************/

% Parede Livre - Unifica quando a parede em teste nao existe na posicao atual
parede_livre(_, []).
parede_livre(Parede, [Cabeca|Cauda]) :-
	Cabeca \= Parede,
	parede_livre(Parede, Cauda).

% Acede Paredes - Unifica acedendo as paredes de uma celula
paredes(Lab, Linha, Coluna, Paredes) :-
	nth1(Linha, Lab, Linhas),
	nth1(Coluna, Linhas, Paredes).

% CIMA
mov_possivel(Lab, (Linha,Coluna), Movs, c, Mov) :-

	% Novas coordenadas
	X is Coluna, Y is (Linha - 1),

	% O movimento pode ser feito e nao foi feito antes
	paredes(Lab, Linha, Coluna, Paredes),
	not(member(c, Paredes)),
	not(member((_,Y,X), Movs)),

	% Unifica
	Mov = (c,Y,X).

% BAIXO
mov_possivel(Lab, (Linha,Coluna), Movs, b, Mov) :-

	% Novas coordenadas
	X is Coluna, Y is (Linha + 1),

	% O movimento pode ser feito e nao foi feito antes
	paredes(Lab, Linha, Coluna, Paredes),
	not(member(b, Paredes)),
	not(member((_,Y,X), Movs)),

	% Unifica
	Mov = (b,Y,X).

% ESQUERDA
mov_possivel(Lab, (Linha,Coluna), Movs, e, Mov) :-

	% Novas coordenadas
	X is (Coluna - 1), Y is Linha,

	% O movimento pode ser feito e nao foi feito antes
	paredes(Lab, Linha, Coluna, Paredes),
	not(member(e, Paredes)),
	not(member((_,Y,X), Movs)),

	% Unifica
	Mov = (e,Y,X).

% DIREITA
mov_possivel(Lab, (Linha,Coluna), Movs, d, Mov) :-
	
	% Novas coordenadas
	X is (Coluna + 1), Y is Linha,

	% O movimento pode ser feito e nao foi feito antes
	paredes(Lab, Linha, Coluna, Paredes),
	not(member(d, Paredes)),
	not(member((_,Y,X), Movs)),

	% Unifica
	Mov = (d,Y,X).

% Encontra todos os movimentos possiveis e unifica em Poss
movs_possiveis(Lab, Pos_atual, Movs, Poss) :-
	findall(Mov, mov_possivel(Lab, Pos_atual, Movs, _, Mov), Poss).

/*************************************************************************************
*
*   2. DISTANCIA
*	distancia((L1, C1),(L2, C2),Dist)
*
*	argumentos: (L1, C1) e (L2, C2)
*	objetivo: calcular distancia entre duas posicoes
*
**************************************************************************************/

% Calcula distancia conforme definido no enunciado do projeto
distancia((L1, C1),(L2, C2), Dist) :- 
	Dist is abs(L1 - L2) + abs(C1 - C2).

/*************************************************************************************
*
*   2. ORDENA_POSS
*	ordena_poss(Poss, Poss_ord, Pos_inicial, Pos_final)
*
*	argumentos: movimentos possiveis, posicao inicial e posicao final
*	objetivo: ordenar os movimentos seguintes possiveis
*
**************************************************************************************/

% INSERTION SORT - Percorre elementos da lista da direita para a esquerda e a medida
% que avanca coloca-os ordenamente na nova lista conforme os criteiros

% Lista vazia esta ordenada
ordena_poss([],[], _, _).

% Comeca a percorrer a lista
ordena_poss([X|Resto], Poss_ord, Pos_inicial, Pos_final) :-

	% Continua a percorrer
	ordena_poss(Resto, Resto_ordenado, Pos_inicial, Pos_final),

	% Insere elemento na lista se o restante estiver ordenado caso contrario
	% fica em espera ate que esteja
	insere(X, Resto_ordenado, Poss_ord, Pos_inicial, Pos_final).

% Se satisfaz criterio pode ser inserido caso contrario vai ver
% se os proximos elementos podem ser inseridos na vez dele
insere(X, [Y|Poss_ord], [Y|Poss_ord_ad], Pos_inicial, Pos_final) :-
	criterio_dois(X, Y, Pos_inicial), !,
	insere(X, Poss_ord, Poss_ord_ad, Pos_inicial, Pos_final).

% Se satisfaz criterio pode ser inserido caso contrario vai ver
% se os proximos elementos podem ser inseridos na vez dele
insere(X, [Y|Poss_ord], [Y|Poss_ord_ad], Pos_inicial, Pos_final) :-
	criterio_um(X, Y, Pos_final), !,
	insere(X, Poss_ord, Poss_ord_ad, Pos_inicial, Pos_final).

% Insere na posicao correta para que a lista resultante esteja ordenada
insere(X, Poss_ord, [X|Poss_ord], _, _).

% PRIMEIRO CRITERIO -
% Melhor movimento e o conducente a uma menor distancia a uma posicao final
criterio_um((_,Mov1_X,Mov1_Y), (_,Mov2_X,Mov2_Y), (Final_X,Final_Y)) :-
	distancia((Mov1_X,Mov1_Y), (Final_X,Final_Y), Dist1),
	distancia((Mov2_X,Mov2_Y), (Final_X,Final_Y), Dist2),
	Dist1 > Dist2.

% SEGUNDO CRITERIO -
% Melhor movimento e o conducente a uma maior distancia a uma posicao inicial
criterio_dois((_,Mov1_X,Mov1_Y), (_,Mov2_X,Mov2_Y), (Inicial_X,Inicial_Y)) :- 
	distancia((Mov1_X,Mov1_Y), (Inicial_X,Inicial_Y), Dist1),
	distancia((Mov2_X,Mov2_Y), (Inicial_X,Inicial_Y), Dist2),
	Dist1 < Dist2.

/*************************************************************************************
*
*   3. RESOLVE I
*	resolve1(Lab, Pos_inicial, Pos_final, Movs)
*
*	argumentos: movimentos possiveis, posicao inicial e posicao final
*	objetivo: ordenar os movimentos seguintes possiveis
*
**************************************************************************************/

% Adiciona posicao inicial a lista de movimentos
resolve1(Lab, (Linha,Coluna), Pos_final, Movs) :-
	resolve1(Lab, (Linha,Coluna), Pos_final, [(i,Linha,Coluna)], Movs).

% Termina quando a posicao atual e igual a final
resolve1(_, Pos_final, Pos_final, Aux, Movs) :-
	reverse(Aux, Movs).

% Calcula proximos movimentos
%	- Calcula movimentos possiveis para a posicao atual
%	- O movimento e tal que tem de estar na lista dos possiveis (permite backtracking)

resolve1(Lab, (Linha,Coluna), Pos_final, Aux, Movs) :-

	movs_possiveis(Lab, (Linha,Coluna), Aux, Poss),
	member((Mov,X,Y), Poss),

	% Continua para calcular proximos movimentos
	resolve1(Lab, (X,Y), Pos_final, [(Mov,X,Y)|Aux], Movs).

/*************************************************************************************
*
*   4. RESOLVE II
*	resolve2(Lab, Pos_inicial, Pos_final, Movs)
*
*	argumentos: movimentos possiveis, posicao inicial e posicao final
*	objetivo: ordenar os movimentos seguintes possiveis 
*
**************************************************************************************/

% Adiciona posicao inicial a lista de movimentos
resolve2(Lab, (Linha,Coluna), Pos_final, Movs) :-
	resolve2(Lab, (Linha,Coluna), (Linha,Coluna), Pos_final, [(i,Linha,Coluna)], Movs).

% Termina quando a posicao atual e igual a final
resolve2(_, Pos_final, _, Pos_final, Aux, Movs) :-
	reverse(Aux, Movs).

% Calcula proximos movimentos
%	- Calcula movimentos possiveis para a posicao atual
%	- Ordena os movimentos possiveis para quando for escolhido um ser escolhido o melhor
%	- O movimento e tal que tem de estar na lista dos possiveis (permite backtracking)

resolve2(Lab, (Linha,Coluna), (Linha_inicial,Coluna_inicial), Pos_final, Aux, Movs) :-

	movs_possiveis(Lab, (Linha,Coluna), Aux, Poss),
	ordena_poss(Poss, Poss_ord, (Linha_inicial,Coluna_inicial), Pos_final),
	member((Mov,X,Y), Poss_ord),

	% Continua para calcular proximos movimentos
	resolve2(Lab, (X,Y), (Linha_inicial,Coluna_inicial), Pos_final, [(Mov,X,Y)|Aux], Movs).