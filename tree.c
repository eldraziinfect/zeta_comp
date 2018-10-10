#include<stdlib.h>
#include<stdio.h>
#include"tree.h"


tree* cria_nodo (int valor)
{	tree *nodo = malloc(sizeof(tree));
	if(!node)
	{	printf("Memory allocation failure.")
	}
	else
	{	nodo->valor = valor;
		nodo->num_filhos = 0;
		nodo->filho_esq = NULL;
		nodo->filho_mei = NULL;
		nodo->filho_dir = NULL;
		nodo->pai = NULL;
		nodo->prox = NULL;
	}
return nodo;
}


void conecta_prox(tree* atual, tree* pai)
{	atual->pai = pai;
	pai->prox = atual;
	pai->num_filhos += 1;
}

void conecta_meio(tree* atual, tree* pai)
{	atual->pai = pai;
	pai->prox = atual;
	pai->num_filhos += 1;
}

void conecta_esq(tree* atual, tree* pai)
{	atual->pai = pai;
	pai->filho_esq = atual;
	pai->num_filhos += 1;
}

tree* cria_nodo_unario (tree* atual, int tipo, int valor1)
{	tree *esquerdo = cria_nodo(valor1);
	tree *novo = cria_nodo(tipo);
	// faz as conexões "na mão"
	novo->filho_esq = esquerdo;
	novo->num_filhos = 1;
	//não precisa de set null pois já está na função de criação

return novo;
}

tree* cria_nodo_binario (tree* atual, int tipo, int valor1, int valor2)
{	tree *esquerdo = cria_nodo(valor1);
	tree *meio = cria_nodo(valor2);
	tree *novo = cria_nodo(tipo);
	
	novo->filho_esq = esquerdo;
	novo->filho_mei = meio;
	novo->num_filhos = 2;

return novo;
}

tree* cria_nodo_ternario (tree* atual, int tipo, int valor1, int valor2, int valor3)
{	tree *esquerdo = cria_nodo(valor1);
	tree *meio = cria_nodo(valor2);
	tree *direito = cria_nodo(valor3);
	tree *novo = cria_nodo(tipo);
	
	novo->filho_esq = esquerdo;
	novo->filho_mei = meio;
	novo->filho_dir = direito;
	novo->num_filhos = 3;

return novo;
}



/* SUBSTITUIR POR FUNÇÕES ESPECÍFICAS
void conectanodo(tree *pai, tree *filho, int modo)
{	switch(modo)
	{
	}
}
*/

//Como conectar o nodo no pai durante o parsing?
// *> precisa dos ponteiros para os dois nodos! 







