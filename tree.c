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


