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


void conecta_prox(tree* atual)
{	atual->pai->prox = atual;
}

void conecta_esq(tree* atual)
{	atual->pai->esq = atual;
}


void cria_nodo_binario (tree* atual, int tipo, int valor1, int valor2)
{	tree *esquerdo = cria_nodo(valor1);
	tree *meio = cria_nodo(valor2);
	
}








